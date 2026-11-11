CREATE EXTENSION IF NOT EXISTS "pgcrypto";


CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barcode VARCHAR(50) UNIQUE,
    name VARCHAR(255) NOT NULL,
    brand VARCHAR(255),
    category VARCHAR(100),
    image_url TEXT,
    ingredients JSONB DEFAULT '[]'::jsonb,
    nutrition_facts JSONB DEFAULT '{}'::jsonb,
    processing_level SMALLINT CHECK (processing_level BETWEEN 1 AND 4),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_name ON products USING gin(to_tsvector('french', name));
CREATE INDEX idx_products_brand ON products(brand);


CREATE TABLE scoring_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    weights JSONB NOT NULL,
    thresholds JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO scoring_configs (name, weights) VALUES (
    'default_v1',
    '{"nutrition": 0.40, "additives": 0.35, "processing": 0.25}'::jsonb
);


CREATE TABLE scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    config_id UUID REFERENCES scoring_configs(id),
    total_score NUMERIC(5,2) NOT NULL,
    breakdown JSONB NOT NULL,
    computed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_scores_product ON scores(product_id);


CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    preferences JSONB DEFAULT '{}'::jsonb,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);


CREATE TABLE scan_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    scan_type VARCHAR(20) NOT NULL CHECK (scan_type IN ('barcode', 'photo', 'search')),
    scanned_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_history_user ON scan_history(user_id, scanned_at DESC);


INSERT INTO products (barcode, name, brand, category, processing_level, nutrition_facts)
VALUES (
    '3017620422003',
    'Nutella',
    'Ferrero',
    'Pâte à tartiner',
    4,
    '{"sugar": 56.3, "fat": 30.9, "salt": 0.107, "fiber": 0}'::jsonb
);