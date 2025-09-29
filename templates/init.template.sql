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

-- Schema ownership and permissions
ALTER SCHEMA "{{APP_NAME}}" OWNER TO admin;
ALTER SCHEMA auth OWNER TO admin;
ALTER SCHEMA analytics OWNER TO admin;
ALTER SCHEMA migrations OWNER TO admin;

-- Grant schema usage permissions
GRANT USAGE ON SCHEMA "{{APP_NAME}}" TO admin, developer, api, read_only, backup, auditor;
GRANT USAGE ON SCHEMA auth TO admin, developer, api, read_only, backup, auditor;
GRANT USAGE ON SCHEMA analytics TO admin, developer, api, read_only, backup, auditor;
GRANT USAGE ON SCHEMA migrations TO admin, developer;

-- Grant create permissions for migrations
GRANT CREATE ON SCHEMA "{{APP_NAME}}" TO admin, developer;
GRANT CREATE ON SCHEMA auth TO admin, developer;
GRANT CREATE ON SCHEMA analytics TO admin, developer;
GRANT CREATE ON SCHEMA migrations TO admin, developer;

-- Grant sequence permissions
GRANT USAGE, SELECT, UPDATE ON SEQUENCE cuid_counter_seq TO admin, developer, api;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE cuid_counter_seq TO archon, runesmith, tinkerer;

-- Schema search path (update manually when adding new schemas)
ALTER ROLE archon SET search_path TO "{{APP_NAME}}", auth, analytics;
ALTER ROLE tinkerer SET search_path TO "{{APP_NAME}}", auth, analytics;
ALTER ROLE lorekeeper SET search_path TO "{{APP_NAME}}", auth, analytics;
ALTER ROLE runesmith SET search_path TO "{{APP_NAME}}", auth, analytics;

-- Default privileges for future tables/sequences created by Drizzle
ALTER DEFAULT PRIVILEGES FOR ROLE archon IN SCHEMA auth GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO admin, developer, api;
ALTER DEFAULT PRIVILEGES FOR ROLE archon IN SCHEMA auth GRANT SELECT ON TABLES TO read_only, backup, auditor;
ALTER DEFAULT PRIVILEGES FOR ROLE archon IN SCHEMA auth GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO admin, developer, api;

ALTER DEFAULT PRIVILEGES FOR ROLE runesmith IN SCHEMA auth GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO admin, developer, api;
ALTER DEFAULT PRIVILEGES FOR ROLE runesmith IN SCHEMA auth GRANT SELECT ON TABLES TO read_only, backup, auditor;
ALTER DEFAULT PRIVILEGES FOR ROLE runesmith IN SCHEMA auth GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO admin, developer, api;

-- Database ownership
ALTER DATABASE "{{APP_NAME}}" OWNER TO admin;