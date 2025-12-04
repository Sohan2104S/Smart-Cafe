
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100),
    age INT
);

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(50),
    category VARCHAR(30),
    price DECIMAL(5,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(7,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    item_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

CREATE TABLE ratings (
    rating_id INT PRIMARY KEY,
    customer_id INT,
    item_id INT,
    rating INT,
    review TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);
