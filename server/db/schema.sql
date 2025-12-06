
-- Database schema for BEPRESS API
-- Generated from Drizzle migrations (up to migration 0004)

CREATE TABLE "plans" (
    "slug" text PRIMARY KEY NOT NULL,
    "name" text NOT NULL,
    "price" integer NOT NULL,
    "features" jsonb DEFAULT '{}'::jsonb NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL
);

CREATE TABLE "tenants" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "plan_slug" text NOT NULL,
    "credit_balance" integer DEFAULT 0 NOT NULL,
    "version" integer DEFAULT 0 NOT NULL,
    "deleted_at" timestamp,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "tenants_slug_unique" UNIQUE("slug")
);

CREATE TABLE "users" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "email" text NOT NULL,
    "password_hash" text NOT NULL,
    "role" text DEFAULT 'user' NOT NULL,
    "phone" text,
    "avatar" text,
    "deleted_at" timestamp,
    "is_active" boolean DEFAULT true NOT NULL,
    "last_login_at" timestamp,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "users_email_unique" UNIQUE("email"),
    CONSTRAINT "users_phone_unique" UNIQUE("phone")
);

CREATE TABLE "assets" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "uploader_id" uuid,
    "url" text NOT NULL,
    "filename" text NOT NULL,
    "mime_type" text NOT NULL,
    "size" integer NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "deleted_at" timestamp
);

CREATE TABLE "categories" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "parent_id" uuid,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL,
    "deleted_at" timestamp
);

CREATE TABLE "tags" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL,
    "deleted_at" timestamp
);

CREATE TABLE "articles" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "author_id" uuid NOT NULL,
    "category_id" uuid,
    "cover_image_id" uuid,
    "title" text NOT NULL,
    "slug" text NOT NULL,
    "content" text NOT NULL,
    "excerpt" text,
    "status" text DEFAULT 'draft' NOT NULL,
    "seo_title" text,
    "seo_description" text,
    "deleted_at" timestamp,
    "published_at" timestamp,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL
);

CREATE TABLE "article_tags" (
    "article_id" uuid NOT NULL,
    "tag_id" uuid NOT NULL,
    CONSTRAINT "article_tags_article_id_tag_id_pk" PRIMARY KEY("article_id","tag_id")
);

CREATE TABLE "comments" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "article_id" uuid NOT NULL,
    "user_id" uuid,
    "parent_id" uuid,
    "content" text NOT NULL,
    "is_approved" boolean DEFAULT false NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL,
    "deleted_at" timestamp
);

CREATE TABLE "api_keys" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "key" text NOT NULL,
    "key_hash" text NOT NULL,
    "expires_at" timestamp,
    "created_at" timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "api_keys_key_unique" UNIQUE("key")
);

CREATE TABLE "tenant_domains" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "domain" text NOT NULL,
    "is_primary" boolean DEFAULT false NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    CONSTRAINT "tenant_domains_domain_unique" UNIQUE("domain")
);

CREATE TABLE "banners" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "image_id" uuid NOT NULL,
    "position" text NOT NULL,
    "active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL,
    "deleted_at" timestamp
);

CREATE TABLE "audit_logs" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "actor_id" uuid,
    "action" text NOT NULL,
    "entity" text NOT NULL,
    "entity_id" text NOT NULL,
    "metadata" jsonb,
    "created_at" timestamp DEFAULT now() NOT NULL
);

CREATE TABLE "transactions" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "type" text NOT NULL,
    "amount" integer NOT NULL,
    "balance_after" integer NOT NULL,
    "reference_id" text,
    "description" text,
    "created_at" timestamp DEFAULT now() NOT NULL
);

CREATE TABLE "invoices" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "tenant_id" uuid NOT NULL,
    "amount" integer NOT NULL,
    "status" text DEFAULT 'pending' NOT NULL,
    "invoice_url" text,
    "due_date" timestamp,
    "paid_at" timestamp,
    "created_at" timestamp DEFAULT now() NOT NULL,
    "updated_at" timestamp DEFAULT now() NOT NULL
);

-- Foreign key constraints
ALTER TABLE "tenants" ADD CONSTRAINT "tenants_plan_slug_plans_slug_fk" FOREIGN KEY ("plan_slug") REFERENCES "public"."plans"("slug") ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "users" ADD CONSTRAINT "users_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "assets" ADD CONSTRAINT "assets_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "assets" ADD CONSTRAINT "assets_uploader_id_users_id_fk" FOREIGN KEY ("uploader_id") REFERENCES "public"."users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE "categories" ADD CONSTRAINT "categories_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "categories" ADD CONSTRAINT "categories_parent_id_categories_id_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."categories"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "tags" ADD CONSTRAINT "tags_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "articles" ADD CONSTRAINT "articles_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "articles" ADD CONSTRAINT "articles_author_id_users_id_fk" FOREIGN KEY ("author_id") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE NO ACTION;
ALTER TABLE "articles" ADD CONSTRAINT "articles_category_id_categories_id_fk" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "articles" ADD CONSTRAINT "articles_cover_image_id_assets_id_fk" FOREIGN KEY ("cover_image_id") REFERENCES "public"."assets"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE "article_tags" ADD CONSTRAINT "article_tags_article_id_articles_id_fk" FOREIGN KEY ("article_id") REFERENCES "public"."articles"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "article_tags" ADD CONSTRAINT "article_tags_tag_id_tags_id_fk" FOREIGN KEY ("tag_id") REFERENCES "public"."tags"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "comments" ADD CONSTRAINT "comments_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "comments" ADD CONSTRAINT "comments_article_id_articles_id_fk" FOREIGN KEY ("article_id") REFERENCES "public"."articles"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "comments" ADD CONSTRAINT "comments_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;
ALTER TABLE "comments" ADD CONSTRAINT "comments_parent_id_comments_id_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."comments"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "tenant_domains" ADD CONSTRAINT "tenant_domains_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "banners" ADD CONSTRAINT "banners_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "banners" ADD CONSTRAINT "banners_image_id_assets_id_fk" FOREIGN KEY ("image_id") REFERENCES "public"."assets"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_actor_id_users_id_fk" FOREIGN KEY ("actor_id") REFERENCES "public"."users"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE "transactions" ADD CONSTRAINT "transactions_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

ALTER TABLE "invoices" ADD CONSTRAINT "invoices_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- Indexes
CREATE INDEX "api_keys_tenant_id_idx" ON "api_keys" USING btree ("tenant_id");
CREATE INDEX "api_keys_key_hash_idx" ON "api_keys" USING btree ("key_hash");
CREATE INDEX "article_tags_tag_id_idx" ON "article_tags" USING btree ("tag_id");
CREATE INDEX "articles_tenant_status_published_idx" ON "articles" USING btree ("tenant_id", "status", "published_at");
CREATE INDEX "articles_tenant_slug_idx" ON "articles" USING btree ("tenant_id", "slug");
CREATE INDEX "articles_deleted_at_idx" ON "articles" USING btree ("deleted_at");
CREATE INDEX "articles_tenant_author_idx" ON "articles" USING btree ("tenant_id", "author_id");
CREATE INDEX "articles_tenant_category_idx" ON "articles" USING btree ("tenant_id", "category_id");
CREATE INDEX "articles_cover_image_id_idx" ON "articles" USING btree ("cover_image_id");
CREATE INDEX "assets_tenant_id_idx" ON "assets" USING btree ("tenant_id");
CREATE INDEX "assets_uploader_id_idx" ON "assets" USING btree ("uploader_id");
CREATE INDEX "assets_deleted_at_idx" ON "assets" USING btree ("deleted_at");
CREATE INDEX "audit_logs_tenant_id_idx" ON "audit_logs" USING btree ("tenant_id");
CREATE INDEX "audit_logs_actor_id_idx" ON "audit_logs" USING btree ("actor_id");
CREATE INDEX "audit_logs_created_at_idx" ON "audit_logs" USING btree ("created_at");
CREATE INDEX "banners_tenant_id_idx" ON "banners" USING btree ("tenant_id");
CREATE INDEX "banners_image_id_idx" ON "banners" USING btree ("image_id");
CREATE INDEX "banners_deleted_at_idx" ON "banners" USING btree ("deleted_at");
CREATE INDEX "categories_tenant_id_idx" ON "categories" USING btree ("tenant_id");
CREATE UNIQUE INDEX "categories_tenant_slug_idx" ON "categories" USING btree ("tenant_id", "slug");
CREATE INDEX "categories_parent_id_idx" ON "categories" USING btree ("parent_id");
CREATE INDEX "categories_deleted_at_idx" ON "categories" USING btree ("deleted_at");
CREATE INDEX "comments_tenant_id_idx" ON "comments" USING btree ("tenant_id");
CREATE INDEX "comments_article_id_idx" ON "comments" USING btree ("article_id");
CREATE INDEX "comments_user_id_idx" ON "comments" USING btree ("user_id");
CREATE INDEX "comments_parent_id_idx" ON "comments" USING btree ("parent_id");
CREATE INDEX "comments_deleted_at_idx" ON "comments" USING btree ("deleted_at");
CREATE INDEX "invoices_tenant_id_idx" ON "invoices" USING btree ("tenant_id");
CREATE INDEX "tags_tenant_id_idx" ON "tags" USING btree ("tenant_id");
CREATE UNIQUE INDEX "tags_tenant_slug_idx" ON "tags" USING btree ("tenant_id", "slug");
CREATE INDEX "tags_deleted_at_idx" ON "tags" USING btree ("deleted_at");
CREATE INDEX "tenant_domains_tenant_id_idx" ON "tenant_domains" USING btree ("tenant_id");
CREATE INDEX "tenant_domains_domain_idx" ON "tenant_domains" USING btree ("domain");
CREATE INDEX "tenants_deleted_at_idx" ON "tenants" USING btree ("deleted_at");
CREATE INDEX "transactions_tenant_id_idx" ON "transactions" USING btree ("tenant_id");
CREATE INDEX "users_tenant_email_idx" ON "users" USING btree ("tenant_id", "email");
CREATE INDEX "users_tenant_id_idx" ON "users" USING btree ("tenant_id");
CREATE INDEX "users_deleted_at_idx" ON "users" USING btree ("deleted_at");
