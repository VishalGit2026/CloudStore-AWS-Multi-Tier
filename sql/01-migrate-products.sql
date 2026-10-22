-- Run this migration ONCE against the existing `cloudstore` database.
USE cloudstore;
ALTER TABLE products
  ADD COLUMN brand VARCHAR(80) NULL AFTER sku,
  ADD COLUMN image_url VARCHAR(500) NULL AFTER description,
  ADD COLUMN badge VARCHAR(30) NULL AFTER image_url,
  ADD COLUMN featured BOOLEAN NOT NULL DEFAULT FALSE AFTER badge;
