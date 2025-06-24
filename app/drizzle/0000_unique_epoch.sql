CREATE TABLE "auth"."api_keys" (
	"id" text PRIMARY KEY DEFAULT cuid() NOT NULL,
	"user_id" text NOT NULL,
	"key_hash" text NOT NULL,
	"name" text NOT NULL,
	"permissions" jsonb DEFAULT '[]'::jsonb,
	"expires_at" timestamp with time zone,
	"last_used" timestamp with time zone,
	"is_active" boolean DEFAULT true,
	"created_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "api_keys_key_hash_unique" UNIQUE("key_hash")
);
--> statement-breakpoint
CREATE TABLE "auth"."users" (
	"id" text PRIMARY KEY DEFAULT cuid() NOT NULL,
	"name" text NOT NULL,
	"email" text NOT NULL,
	"password_hash" text NOT NULL,
	"role" "user_role" DEFAULT 'user' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "auth"."user_role_assignments" (
	"id" text PRIMARY KEY DEFAULT cuid() NOT NULL,
	"user_id" text NOT NULL,
	"role_id" text NOT NULL,
	"assigned_by" text,
	"assigned_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "auth"."user_roles" (
	"id" text PRIMARY KEY DEFAULT cuid() NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"permissions" jsonb DEFAULT '[]'::jsonb,
	"created_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "user_roles_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "auth"."user_sessions" (
	"id" text PRIMARY KEY DEFAULT cuid() NOT NULL,
	"user_id" text NOT NULL,
	"session_token" text NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"last_accessed" timestamp with time zone DEFAULT now(),
	"ip_address" "inet",
	"user_agent" text,
	CONSTRAINT "user_sessions_session_token_unique" UNIQUE("session_token")
);
--> statement-breakpoint
ALTER TABLE "auth"."api_keys" ADD CONSTRAINT "api_keys_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "auth"."user_role_assignments" ADD CONSTRAINT "user_role_assignments_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "auth"."user_role_assignments" ADD CONSTRAINT "user_role_assignments_role_id_user_roles_id_fk" FOREIGN KEY ("role_id") REFERENCES "auth"."user_roles"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "auth"."user_role_assignments" ADD CONSTRAINT "user_role_assignments_assigned_by_users_id_fk" FOREIGN KEY ("assigned_by") REFERENCES "auth"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "auth"."user_sessions" ADD CONSTRAINT "user_sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE cascade ON UPDATE no action;