-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Platform Settings table
CREATE TABLE platform_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert default platform commission rate
INSERT INTO platform_settings (key, value, description) 
VALUES (
    'commission_rate', 
    '{"rate": 3, "type": "percentage"}',
    'Platform commission rate in percentage'
);

-- Stores table
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID REFERENCES auth.users(id),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    logo_url TEXT,
    banner_url TEXT,
    theme_color TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    address TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    description TEXT,
    base_price DECIMAL(10,2) NOT NULL,
    sale_price DECIMAL(10,2),
    images TEXT[],
    category TEXT,
    tags TEXT[],
    specifications JSONB,
    weight INTEGER, -- in grams
    dimensions JSONB, -- {length, width, height} in cm
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(store_id, slug)
);

-- Inventory table
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    sku TEXT UNIQUE NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    low_stock_alert INTEGER DEFAULT 5,
    status TEXT CHECK (status IN ('in_stock', 'low_stock', 'out_of_stock')),
    last_restock_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Customers table
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address JSONB[],
    total_orders INTEGER DEFAULT 0,
    total_spent DECIMAL(10,2) DEFAULT 0,
    last_order_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id),
    affiliate_id UUID REFERENCES auth.users(id),
    order_number TEXT UNIQUE NOT NULL,
    status TEXT CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')),
    
    -- Payment Details (Midtrans)
    total_amount DECIMAL(10,2) NOT NULL,
    shipping_fee DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL, -- total_amount - shipping_fee
    
    -- Commission Details
    platform_commission_rate DECIMAL(4,2) NOT NULL, -- Stored rate at time of order (e.g., 3.00)
    platform_commission_amount DECIMAL(10,2) NOT NULL, -- Calculated amount
    affiliate_commission_rate DECIMAL(4,2), -- Optional affiliate rate
    affiliate_commission_amount DECIMAL(10,2), -- Optional affiliate amount
    seller_receivable_amount DECIMAL(10,2) NOT NULL, -- Final amount after commissions
    
    payment_status TEXT CHECK (payment_status IN ('pending', 'settlement', 'deny', 'cancel', 'expire', 'refund')),
    payment_method TEXT,
    midtrans_transaction_id TEXT,
    midtrans_payment_type TEXT,
    midtrans_transaction_status TEXT,
    midtrans_transaction_time TIMESTAMP WITH TIME ZONE,
    midtrans_settlement_time TIMESTAMP WITH TIME ZONE,
    
    -- Shipping Details (KirimInAja)
    shipping_address JSONB NOT NULL,
    shipping_courier TEXT,
    shipping_service TEXT,
    tracking_number TEXT,
    kiriminaja_order_id TEXT,
    shipping_status TEXT,
    shipping_etd TEXT,
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Order Items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id),
    affiliate_id UUID REFERENCES auth.users(id),
    sender_type TEXT CHECK (sender_type IN ('seller', 'customer', 'affiliate')),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for tables with updated_at
CREATE TRIGGER set_timestamp_platform_settings
    BEFORE UPDATE ON platform_settings
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_stores
    BEFORE UPDATE ON stores
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_products
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_inventory
    BEFORE UPDATE ON inventory
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_customers
    BEFORE UPDATE ON customers
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_orders
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

-- Create indexes for better query performance
CREATE INDEX idx_stores_seller_id ON stores(seller_id);
CREATE INDEX idx_products_store_id ON products(store_id);
CREATE INDEX idx_inventory_product_id ON inventory(product_id);
CREATE INDEX idx_orders_store_id ON orders(store_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_messages_store_id ON messages(store_id);
CREATE INDEX idx_messages_customer_id ON messages(customer_id);

-- Function to calculate commissions on order creation/update
CREATE OR REPLACE FUNCTION calculate_order_commissions()
RETURNS TRIGGER AS $$
DECLARE
    platform_rate DECIMAL;
BEGIN
    -- Get current platform commission rate
    SELECT (value->>'rate')::DECIMAL 
    INTO platform_rate 
    FROM platform_settings 
    WHERE key = 'commission_rate';

    -- Set platform commission
    NEW.platform_commission_rate := platform_rate;
    NEW.platform_commission_amount := (NEW.subtotal * platform_rate / 100);
    
    -- Calculate seller receivable amount
    NEW.seller_receivable_amount := NEW.subtotal - NEW.platform_commission_amount;
    
    -- If there's an affiliate, calculate their commission
    IF NEW.affiliate_id IS NOT NULL THEN
        -- For now using a fixed 5% affiliate commission
        NEW.affiliate_commission_rate := 5;
        NEW.affiliate_commission_amount := (NEW.subtotal * 5 / 100);
        -- Deduct affiliate commission from seller receivable
        NEW.seller_receivable_amount := NEW.seller_receivable_amount - NEW.affiliate_commission_amount;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for commission calculation
CREATE TRIGGER calculate_commissions_trigger
    BEFORE INSERT OR UPDATE OF subtotal ON orders
    FOR EACH ROW
    EXECUTE FUNCTION calculate_order_commissions();
