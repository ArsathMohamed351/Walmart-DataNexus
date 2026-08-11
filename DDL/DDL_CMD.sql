CREATE TABLE IF NOT EXISTS customers (
    customer_id BIGINT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    city VARCHAR(100),
    province VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    customer_segment VARCHAR(50),
    loyalty_tier VARCHAR(50),
    created_timestamp TIMESTAMP,
    updated_timestamp TIMESTAMP,
    is_active CHAR(1)
);

CREATE TABLE IF NOT EXISTS stores (
    store_id BIGINT PRIMARY KEY,
    store_name VARCHAR(255),
    city VARCHAR(100),
    province VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    store_type VARCHAR(50),
    store_size_sqft INT,
    opening_date DATE,
    manager_name VARCHAR(200),
    created_timestamp TIMESTAMP,
    updated_timestamp TIMESTAMP,
    is_active CHAR(1)
);

CREATE TABLE IF NOT EXISTS products (
    product_id BIGINT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    sku VARCHAR(100) UNIQUE,
    price NUMERIC(10, 2),
    cost_price NUMERIC(10, 2),
    supplier_name VARCHAR(255),
    stock_quantity INT,
    reorder_level INT,
    weight_kg NUMERIC(10, 2),
    created_timestamp TIMESTAMP,
    updated_timestamp TIMESTAMP,
    is_active CHAR(1)
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id BIGINT PRIMARY KEY,
    store_id BIGINT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    job_title VARCHAR(100),
    department VARCHAR(100),
    salary NUMERIC(10, 2),
    hire_date DATE,
    employment_type VARCHAR(50),
    created_timestamp TIMESTAMP,
    updated_timestamp TIMESTAMP,
    is_active CHAR(1),

    CONSTRAINT fk_employees_store
        FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT,
    store_id BIGINT,
    order_timestamp TIMESTAMP,
    payment_method VARCHAR(50),
    order_status VARCHAR(50),
    sales_channel VARCHAR(50),
    shipping_method VARCHAR(100),
    shipping_address VARCHAR(500),
    discount_amount NUMERIC(12, 2),
    tax_amount NUMERIC(12, 2),
    shipping_cost NUMERIC(12, 2),
    total_amount NUMERIC(12, 2),
    created_timestamp TIMESTAMP,
    updated_timestamp TIMESTAMP,
    is_active CHAR(1),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_orders_store
        FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id BIGINT PRIMARY KEY,
    order_id BIGINT,
    product_id BIGINT,
    quantity INT,
    unit_price NUMERIC(10, 2),
    discount_amount NUMERIC(12, 2),
    tax_amount NUMERIC(12, 2),
    line_amount NUMERIC(12, 2),
    created_timestamp TIMESTAMP,
    updated_timestamp TIMESTAMP,
    is_active CHAR(1),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);