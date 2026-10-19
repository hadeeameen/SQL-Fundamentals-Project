INSERT INTO customers VALUES
(1, 'Arun', 'Kochi', '2025-01-10'),
(2, 'Meera', 'Kozhikode', '2025-01-15'),
(3, 'Rahul', 'Kochi', '2025-02-01'),
(4, 'Anu', 'Chennai', '2025-02-10'),
(5, 'Vishnu', 'Bengaluru', '2025-03-05'),
(6, 'Sara', 'Kochi', '2025-03-12'),
(7, 'Nikhil', 'Chennai', '2025-04-01'),
(8, 'Diya', 'Kozhikode', '2025-04-15');

INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 50000),
(2, 'Headphones', 'Electronics', 2000),
(3, 'T-Shirt', 'Fashion', 800),
(4, 'Shoes', 'Fashion', 2500),
(5, 'Cookware Set', 'Home', 3000),
(6, 'Novel', 'Books', 500);

INSERT INTO orders VALUES
(101, 1, '2025-01-12', 'completed'),
(102, 2, '2025-01-20', 'completed'),
(103, 1, '2025-02-15', 'completed'),
(104, 3, '2025-02-20', 'completed'),
(105, 4, '2025-03-10', 'completed'),
(106, 5, '2025-03-15', 'completed'),
(107, 2, '2025-04-05', 'completed'),
(108, 6, '2025-04-10', 'completed'),
(109, 1, '2025-04-20', 'completed'),
(110, 7, '2025-05-01', 'cancelled'),
(111, 8, '2025-05-12', 'completed'),
(112, 3, '2025-05-20', 'completed');

INSERT INTO order_items VALUES
(1, 101, 1, 1, 50000),
(2, 101, 2, 2, 2000),
(3, 102, 3, 3, 800),
(4, 103, 2, 1, 2000),
(5, 103, 4, 1, 2500),
(6, 104, 5, 2, 3000),
(7, 105, 3, 2, 800),
(8, 106, 1, 1, 50000),
(9, 107, 4, 2, 2500),
(10, 108, 6, 4, 500),
(11, 109, 1, 1, 50000),
(12, 109, 5, 1, 3000),
(13, 110, 1, 1, 50000),
(14, 111, 3, 5, 800),
(15, 112, 2, 2, 2000);