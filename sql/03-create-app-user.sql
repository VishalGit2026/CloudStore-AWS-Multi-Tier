-- CloudStore restricted application user
-- Fresh environment provisioning only.
-- Never commit a real password.

CREATE USER IF NOT EXISTS 'cloudstore_app'@'10.20.%'
IDENTIFIED BY 'REPLACE_WITH_A_LONG_UNIQUE_PASSWORD'
REQUIRE SSL;

GRANT SELECT ON cloudstore.categories
TO 'cloudstore_app'@'10.20.%';

GRANT SELECT ON cloudstore.products
TO 'cloudstore_app'@'10.20.%';

GRANT UPDATE (stock_quantity)
ON cloudstore.products
TO 'cloudstore_app'@'10.20.%';

GRANT SELECT, INSERT ON cloudstore.customers
TO 'cloudstore_app'@'10.20.%';

GRANT UPDATE (full_name, phone)
ON cloudstore.customers
TO 'cloudstore_app'@'10.20.%';

GRANT SELECT, INSERT ON cloudstore.orders
TO 'cloudstore_app'@'10.20.%';

GRANT UPDATE (total_amount)
ON cloudstore.orders
TO 'cloudstore_app'@'10.20.%';

GRANT SELECT, INSERT ON cloudstore.order_items
TO 'cloudstore_app'@'10.20.%';

SHOW GRANTS FOR 'cloudstore_app'@'10.20.%';