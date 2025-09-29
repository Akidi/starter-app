-- init.template.sql - Database and user setup only
-- Tables will be created via Drizzle migrations

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE DATABASE "{{APP_NAME}}";
\c "{{APP_NAME}}";

-- Drop public schema for security
REVOKE ALL ON SCHEMA public FROM PUBLIC;
DROP SCHEMA public CASCADE;

-- Core schemas
CREATE SCHEMA "{{APP_NAME}}";
CREATE SCHEMA auth;
CREATE SCHEMA analytics;
CREATE SCHEMA migrations;

CREATE TYPE auth.user_role AS ENUM ('admin', 'user', 'moderator');

SET search_path TO "{{APP_NAME}}";

-- Install extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- CUID function for ID generation
CREATE SEQUENCE IF NOT EXISTS cuid_counter_seq;

CREATE OR REPLACE FUNCTION cuid() RETURNS TEXT AS $$
DECLARE
  ts BIGINT;
  counter INT;
  rand TEXT;
BEGIN
  ts := EXTRACT(EPOCH FROM clock_timestamp()) * 1000;
  rand := encode(gen_random_bytes(8), 'hex');
  counter := nextval('cuid_counter_seq');
  RETURN 'c' || to_hex(ts) || to_hex(counter) || rand;
END;
$$ LANGUAGE plpgsql;

-- Roles
CREATE ROLE admin NOLOGIN INHERIT CREATEDB CREATEROLE;
CREATE ROLE developer NOLOGIN INHERIT;
CREATE ROLE api NOLOGIN INHERIT;
CREATE ROLE read_only NOLOGIN INHERIT;
CREATE ROLE backup NOLOGIN INHERIT;
CREATE ROLE auditor NOLOGIN INHERIT;

-- App Users
CREATE ROLE archon LOGIN PASSWORD '{{ADMIN_PASSWORD}}';
GRANT admin TO archon;
CREATE ROLE runesmith LOGIN PASSWORD '{{DEVELOPER_PASSWORD}}';
GRANT developer TO runesmith;
CREATE ROLE tinkerer LOGIN PASSWORD '{{API_PASSWORD}}';
GRANT api TO tinkerer;
CREATE ROLE lorekeeper LOGIN PASSWORD '{{READONLY_PASSWORD}}';
GRANT read_only TO lorekeeper;
CREATE ROLE stoneguard LOGIN PASSWORD '{{BACKUP_PASSWORD}}';
GRANT backup TO stoneguard;
CREATE ROLE seer LOGIN PASSWORD '{{AUDITOR_PASSWORD}}';
GRANT auditor TO seer;

-- Schema search path defaults
ALTER ROLE archon SET search_path TO "{{APP_NAME}}", auth, analytics;
ALTER ROLE tinkerer SET search_path TO "{{APP_NAME}}", auth, analytics;
ALTER ROLE lorekeeper SET search_path TO "{{APP_NAME}}", auth, analytics;
ALTER ROLE runesmith SET search_path TO "{{APP_NAME}}", auth, analytics;

-- Harden database-level access
REVOKE CONNECT ON DATABASE "{{APP_NAME}}" FROM PUBLIC;
REVOKE TEMP ON DATABASE "{{APP_NAME}}" FROM PUBLIC;
GRANT CONNECT ON DATABASE "{{APP_NAME}}" TO admin, developer, api, read_only, backup, auditor;
GRANT TEMP ON DATABASE "{{APP_NAME}}" TO admin, developer, api;

-- Helper to standardize future object privileges within schemas
CREATE OR REPLACE FUNCTION apply_default_privileges_for_role(
  role_name TEXT,
  schema_name TEXT,
  write_roles TEXT,
  read_roles TEXT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  IF write_roles <> '' THEN
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA %I GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO %s', role_name, schema_name, write_roles);
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA %I GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO %s', role_name, schema_name, write_roles);
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA %I GRANT EXECUTE ON FUNCTIONS TO %s', role_name, schema_name, write_roles);
  END IF;

  IF read_roles <> '' THEN
    EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA %I GRANT SELECT ON TABLES TO %s', role_name, schema_name, read_roles);
  END IF;
END;
$$;

-- Apply ACLs consistently across schemas and future DDL
CREATE OR REPLACE FUNCTION apply_standard_schema_acls(
  schema_name TEXT,
  profile TEXT DEFAULT 'app'
) RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  usage_roles TEXT;
  default_write_roles TEXT;
  default_read_roles TEXT;
BEGIN
  IF schema_name IS NULL OR schema_name = '' THEN
    RETURN;
  END IF;

  IF schema_name LIKE 'pg_%' OR lower(schema_name) = 'information_schema' THEN
    RETURN;
  END IF;

  IF profile NOT IN ('app', 'restricted') THEN
    RAISE EXCEPTION 'Unknown schema profile %', profile;
  END IF;

  EXECUTE format('REVOKE ALL ON SCHEMA %I FROM PUBLIC', schema_name);
  EXECUTE format('ALTER SCHEMA %I OWNER TO admin', schema_name);

  IF profile = 'restricted' THEN
    usage_roles := 'admin, developer';
    default_write_roles := 'admin, developer';
    default_read_roles := '';
  ELSE
    usage_roles := 'admin, developer, api, read_only, backup, auditor';
    default_write_roles := 'admin, developer, api';
    default_read_roles := 'read_only, backup, auditor';
  END IF;

  EXECUTE format('GRANT USAGE ON SCHEMA %I TO %s', schema_name, usage_roles);
  EXECUTE format('GRANT CREATE ON SCHEMA %I TO admin, developer', schema_name);

  PERFORM apply_default_privileges_for_role('archon', schema_name, default_write_roles, default_read_roles);
  PERFORM apply_default_privileges_for_role('runesmith', schema_name, default_write_roles, default_read_roles);
  PERFORM apply_default_privileges_for_role('tinkerer', schema_name, default_write_roles, default_read_roles);
END;
$$;

-- Event trigger to automatically enforce ACLs for new schemas
CREATE OR REPLACE FUNCTION enforce_schema_acl_on_create()
RETURNS event_trigger
LANGUAGE plpgsql
AS $$
DECLARE
  obj RECORD;
  target_profile TEXT;
BEGIN
  FOR obj IN
    SELECT schema_name
    FROM pg_event_trigger_ddl_commands()
    WHERE object_type = 'schema'
      AND schema_name IS NOT NULL
  LOOP
    IF obj.schema_name LIKE 'pg_%' OR lower(obj.schema_name) = 'information_schema' THEN
      CONTINUE;
    END IF;

    target_profile := CASE lower(obj.schema_name)
      WHEN 'migrations' THEN 'restricted'
      ELSE 'app'
    END;

    PERFORM apply_standard_schema_acls(obj.schema_name, target_profile);
  END LOOP;
END;
$$;

DROP EVENT TRIGGER IF EXISTS ensure_schema_acl_on_create;
CREATE EVENT TRIGGER ensure_schema_acl_on_create
  ON ddl_command_end
  WHEN TAG IN ('CREATE SCHEMA')
  EXECUTE FUNCTION enforce_schema_acl_on_create();

-- Apply ACL profiles to the initial schemas
SELECT apply_standard_schema_acls('{{APP_NAME}}', 'app');
SELECT apply_standard_schema_acls('auth', 'app');
SELECT apply_standard_schema_acls('analytics', 'app');
SELECT apply_standard_schema_acls('migrations', 'restricted');

-- Grant sequence permissions for already-created helpers
GRANT USAGE, SELECT, UPDATE ON SEQUENCE cuid_counter_seq TO admin, developer, api;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE cuid_counter_seq TO archon, runesmith, tinkerer;

-- Database ownership
ALTER DATABASE "{{APP_NAME}}" OWNER TO admin;
