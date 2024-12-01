# Seller Dashboard Database Schema

## Core Tables

### stores
```sql
stores {
  id: uuid primary key
  seller_id: uuid foreign key -> users.id
  name: text
  slug: text unique // for subdomain e.g. brand.pooja.id
  description: text
  logo_url: text
  banner_url: text
  theme_color: text
  contact_email: text
  contact_phone: text
  address: text
  created_at: timestamp
  updated_at: timestamp
}
```

### products
```sql
products {
  id: uuid primary key
  store_id: uuid foreign key -> stores.id
  name: text
  slug: text
  description: text
  base_price: decimal
  sale_price: decimal
  images: text[] // Array of image URLs
  category: text
  tags: text[]
  specifications: jsonb // Flexible product specs
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

### inventory
```sql
inventory {
  id: uuid primary key
  product_id: uuid foreign key -> products.id
  sku: text unique
  quantity: integer
  low_stock_alert: integer
  status: text // in_stock, low_stock, out_of_stock
  last_restock_date: timestamp
  created_at: timestamp
  updated_at: timestamp
}
```

### orders
```sql
orders {
  id: uuid primary key
  store_id: uuid foreign key -> stores.id
  customer_id: uuid foreign key -> customers.id
  affiliate_id: uuid foreign key -> users.id nullable // if order came through affiliate
  order_number: text unique
  status: text // pending, confirmed, processing, shipped, delivered, cancelled
  total_amount: decimal
  shipping_fee: decimal
  commission_amount: decimal // for affiliate
  payment_status: text
  payment_method: text
  shipping_address: jsonb
  tracking_number: text nullable
  notes: text
  created_at: timestamp
  updated_at: timestamp
}
```

### order_items
```sql
order_items {
  id: uuid primary key
  order_id: uuid foreign key -> orders.id
  product_id: uuid foreign key -> products.id
  quantity: integer
  unit_price: decimal
  subtotal: decimal
  created_at: timestamp
}
```

### customers
```sql
customers {
  id: uuid primary key
  store_id: uuid foreign key -> stores.id
  name: text
  email: text
  phone: text
  address: jsonb[]
  total_orders: integer
  total_spent: decimal
  last_order_date: timestamp
  created_at: timestamp
  updated_at: timestamp
}
```

### messages
```sql
messages {
  id: uuid primary key
  store_id: uuid foreign key -> stores.id
  customer_id: uuid foreign key -> customers.id nullable
  affiliate_id: uuid foreign key -> users.id nullable
  sender_type: text // seller, customer, affiliate
  message: text
  is_read: boolean
  created_at: timestamp
}
```

## Relationships Overview

1. Each store belongs to a seller (user)
2. Products belong to a store
3. Inventory tracks stock for each product
4. Orders belong to a store and customer
5. Order items link products to orders
6. Customers belong to a store
7. Messages can be between store-customer or store-affiliate

## Key Features Supported

1. **Product Management**
   - CRUD operations for products
   - Image management
   - Pricing control
   - Category and tag organization

2. **Inventory Control**
   - Stock tracking
   - Low stock alerts
   - SKU management

3. **Order Processing**
   - Order status tracking
   - Payment status monitoring
   - Shipping integration
   - Affiliate commission tracking

4. **Customer Management**
   - Customer profiles
   - Order history
   - Communication history
   - Address management

5. **Communication**
   - Chat with customers
   - Chat with affiliates
   - Message history

6. **Analytics Support**
   - Sales tracking
   - Customer metrics
   - Inventory analytics
   - Performance monitoring
