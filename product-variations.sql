-- Create variation_types table
CREATE TABLE variation_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    position INTEGER NOT NULL CHECK (position IN (1, 2)), -- Only allow 2 variations per product
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, position) -- Ensure unique position per product
);

-- Create variation_options table
CREATE TABLE variation_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variation_type_id UUID REFERENCES variation_types(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(variation_type_id, name) -- Prevent duplicate options for a variation type
);

-- Create product_variations table (for combinations)
CREATE TABLE product_variations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    option1_id UUID REFERENCES variation_options(id),
    option2_id UUID REFERENCES variation_options(id),
    sku TEXT UNIQUE,
    price_adjustment DECIMAL(10,2) DEFAULT 0, -- Additional price for this variation
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, option1_id, option2_id) -- Prevent duplicate combinations
);

-- Modify inventory table to track variations
ALTER TABLE inventory
    DROP CONSTRAINT inventory_product_id_fkey,
    ADD COLUMN variation_id UUID REFERENCES product_variations(id),
    ADD CONSTRAINT inventory_product_variation_unique UNIQUE(product_id, variation_id);

-- Add updated_at triggers
CREATE TRIGGER set_timestamp_variation_types
    BEFORE UPDATE ON variation_types
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_variation_options
    BEFORE UPDATE ON variation_options
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_product_variations
    BEFORE UPDATE ON product_variations
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

-- Add indexes for better query performance
CREATE INDEX idx_variation_types_product_id ON variation_types(product_id);
CREATE INDEX idx_variation_options_type_id ON variation_options(variation_type_id);
CREATE INDEX idx_product_variations_product_id ON product_variations(product_id);
CREATE INDEX idx_inventory_variation_id ON inventory(variation_id);

-- Add RLS policies
ALTER TABLE variation_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE variation_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variations ENABLE ROW LEVEL SECURITY;

-- Variation types policies
CREATE POLICY "Sellers can view their variation types"
    ON variation_types FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM products p
            JOIN stores s ON s.id = p.store_id
            WHERE p.id = variation_types.product_id
            AND s.seller_id = auth.uid()
        )
    );

CREATE POLICY "Sellers can insert their variation types"
    ON variation_types FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM products p
            JOIN stores s ON s.id = p.store_id
            WHERE p.id = variation_types.product_id
            AND s.seller_id = auth.uid()
        )
    );

CREATE POLICY "Sellers can update their variation types"
    ON variation_types FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM products p
            JOIN stores s ON s.id = p.store_id
            WHERE p.id = variation_types.product_id
            AND s.seller_id = auth.uid()
        )
    );

CREATE POLICY "Sellers can delete their variation types"
    ON variation_types FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM products p
            JOIN stores s ON s.id = p.store_id
            WHERE p.id = variation_types.product_id
            AND s.seller_id = auth.uid()
        )
    );

-- Variation options policies
CREATE POLICY "Sellers can view their variation options"
    ON variation_options FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM variation_types vt
            JOIN products p ON p.id = vt.product_id
            JOIN stores s ON s.id = p.store_id
            WHERE vt.id = variation_options.variation_type_id
            AND s.seller_id = auth.uid()
        )
    );

CREATE POLICY "Sellers can insert their variation options"
    ON variation_options FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM variation_types vt
            JOIN products p ON p.id = vt.product_id
            JOIN stores s ON s.id = p.store_id
            WHERE vt.id = variation_options.variation_type_id
            AND s.seller_id = auth.uid()
        )
    );

CREATE POLICY "Sellers can update their variation options"
    ON variation_options FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM variation_types vt
            JOIN products p ON p.id = vt.product_id
            JOIN stores s ON s.id = p.store_id
            WHERE vt.id = variation_options.variation_type_id
            AND s.seller_id = auth.uid()
        )
    );

CREATE POLICY "Sellers can delete their variation options"
    ON variation_options FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM variation_types vt
            JOIN products p ON p.id = vt.product_id
            JOIN stores s ON s.id = p.store_id
            WHERE vt.id = variation_options.variation_type_id
            AND s.seller_id = auth.uid()
        )
    );

-- Product variations policies
CREATE POLICY "Sellers can view their product variations"
    ON product_variations FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM products p
            JOIN stores s ON s.id = p.store_id
            WHERE p.id = product_variations.product_id
            AND s.seller_id = auth.uid()
        )
    );

CREATE POLICY "Sellers can insert their product variations"
    ON product_variations FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM products p
            JOIN stores s ON s.id = p.store_id
            WHERE p.id = product_variations.product_id
            AND s.seller_id = auth.uid()
        )
    );

CREATE POLICY "Sellers can update their product variations"
    ON product_variations FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM products p
            JOIN stores s ON s.id = p.store_id
            WHERE p.id = product_variations.product_id
            AND s.seller_id = auth.uid()
        )
    );

CREATE POLICY "Sellers can delete their product variations"
    ON product_variations FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM products p
            JOIN stores s ON s.id = p.store_id
            WHERE p.id = product_variations.product_id
            AND s.seller_id = auth.uid()
        )
    );
