-- ============================================================
-- Sunrise Supermarket Seed Data
-- 6 customers (1 with no orders, to demonstrate LEFT JOIN)
-- 8 products across 4 categories
-- 15 orders across Jan-Mar 2026
-- 27 order items
-- ============================================================

INSERT INTO customers (customer_id, customer_name, email, city) VALUES
(1, 'Alice Uwase',     'alice.uwase@example.com',     'Kigali'),
(2, 'Jean Bosco',      'jean.bosco@example.com',      'Kigali'),
(3, 'Marie Claire',    'marie.claire@example.com',    'Musanze'),
(4, 'Eric Niyonzima',  'eric.niyonzima@example.com',  'Huye'),
(5, 'Grace Mukamana',  'grace.mukamana@example.com',  'Kigali'),
(6, 'David Habimana',  'david.habimana@example.com',  'Rubavu');

INSERT INTO products (product_id, product_name, category, price) VALUES
(1, 'Coca-Cola 500ml',        'Beverages', 1.20),
(2, 'Fanta Orange 500ml',     'Beverages', 1.20),
(3, 'Minute Maid Juice 1L',   'Beverages', 2.50),
(4, 'White Bread',            'Bakery',    1.80),
(5, 'Chocolate Croissant',    'Bakery',    1.50),
(6, 'Fresh Milk 1L',          'Dairy',     1.10),
(7, 'Cheddar Cheese 200g',    'Dairy',     3.20),
(8, 'Potato Chips 150g',      'Snacks',    2.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1,  1, '2026-01-05'),
(2,  2, '2026-01-06'),
(3,  1, '2026-01-12'),
(4,  3, '2026-01-15'),
(5,  4, '2026-01-18'),
(6,  2, '2026-01-25'),
(7,  5, '2026-02-01'),
(8,  1, '2026-02-03'),
(9,  3, '2026-02-10'),
(10, 4, '2026-02-14'),
(11, 2, '2026-02-20'),
(12, 5, '2026-02-25'),
(13, 1, '2026-03-02'),
(14, 3, '2026-03-08'),
(15, 5, '2026-03-15');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES
(1,  1,  1, 3),
(2,  1,  4, 2),
(3,  2,  2, 5),
(4,  2,  6, 1),
(5,  3,  3, 2),
(6,  4,  5, 4),
(7,  4,  7, 1),
(8,  5,  1, 1),
(9,  5,  8, 2),
(10, 6,  6, 3),
(11, 7,  2, 2),
(12, 7,  3, 1),
(13, 8,  7, 2),
(14, 8,  4, 1),
(15, 9,  1, 4),
(16, 10, 5, 2),
(17, 10, 8, 1),
(18, 11, 3, 3),
(19, 12, 6, 2),
(20, 12, 2, 1),
(21, 13, 7, 1),
(22, 13, 1, 2),
(23, 14, 8, 3),
(24, 15, 4, 2),
(25, 15, 5, 1),
(26, 1,  6, 1),
(27, 9,  3, 2);
