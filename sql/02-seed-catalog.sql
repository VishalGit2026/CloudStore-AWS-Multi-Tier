USE cloudstore;
INSERT INTO categories (category_name, description) VALUES
('Laptops','Portable power for work, study and creative projects.'),
('Smartphones','Connected essentials for the everyday.'),
('Audio','Sound gear for focus, travel and downtime.'),
('Computing','Displays and desk technology for better workspaces.'),
('Accessories','Small upgrades that make a big difference.'),
('Gaming','Gear for play, performance and immersive worlds.')
ON DUPLICATE KEY UPDATE description=VALUES(description);

INSERT INTO products
(category_id,sku,brand,product_name,description,image_url,price,stock_quantity,badge,featured,is_active)
VALUES
((SELECT category_id FROM categories WHERE category_name='Laptops'),'CS-LAP-001','CLOUDSTORE SELECT','NimbusBook 14','Slim everyday laptop concept with a vivid 14-inch display, fast solid-state storage and all-day portability.','https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=900&q=85',64990,12,'BESTSELLER',TRUE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Laptops'),'CS-LAP-002','CLOUDSTORE SELECT','StudioBook Air 15','A lightweight productivity notebook concept with a spacious screen and clean aluminium-inspired finish.','https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=900&q=85',72990,8,'NEW',TRUE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Laptops'),'CS-LAP-003','CLOUDSTORE SELECT','CreatorBook Pro','A performance-focused laptop concept for editing, design workflows and demanding multitasking.','https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?auto=format&fit=crop&w=900&q=85',89990,5,'CREATOR PICK',FALSE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Smartphones'),'CS-PHN-001','CLOUDSTORE SELECT','Orbit Phone X','Modern smartphone concept with a bright edge-to-edge display, versatile camera system and fast charging.','https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=900&q=85',42990,18,'POPULAR',TRUE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Smartphones'),'CS-PHN-002','CLOUDSTORE SELECT','Orbit Phone Lite','A balanced everyday phone concept with a crisp screen, dependable battery and clean design.','https://images.unsplash.com/photo-1598327105666-5b89351aff97?auto=format&fit=crop&w=900&q=85',24990,22,NULL,FALSE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Smartphones'),'CS-PHN-003','CLOUDSTORE SELECT','Fold One','A foldable device concept designed for flexible viewing, productivity and travel.','https://images.unsplash.com/photo-1592750475338-74b7b21085ab?auto=format&fit=crop&w=900&q=85',89990,4,'LIMITED',FALSE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Audio'),'CS-AUD-001','CLOUDSTORE SELECT','Pulse ANC Headphones','Over-ear listening concept with active noise cancellation, plush cushions and immersive sound.','https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&q=85',8990,25,'BESTSELLER',TRUE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Audio'),'CS-AUD-002','CLOUDSTORE SELECT','Echo Buds Pro','Compact true-wireless earbuds concept with a pocket charging case and clear everyday audio.','https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?auto=format&fit=crop&w=900&q=85',4990,30,'NEW',TRUE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Audio'),'CS-AUD-003','CLOUDSTORE SELECT','RoomSound Mini','A compact wireless speaker concept for desks, bedrooms and relaxed listening.','https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=900&q=85',3490,16,NULL,FALSE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Computing'),'CS-CMP-001','CLOUDSTORE SELECT','ViewPoint 27 Monitor','A clean 27-inch monitor concept for multi-window work, study and entertainment setups.','https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=900&q=85',18990,9,'WORKSPACE PICK',TRUE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Computing'),'CS-CMP-002','CLOUDSTORE SELECT','MechKeys Wireless','A low-profile wireless keyboard concept with a refined desk-friendly layout.','https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=900&q=85',3290,28,NULL,FALSE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Computing'),'CS-CMP-003','CLOUDSTORE SELECT','Precision Mouse','An ergonomic wireless mouse concept for accurate everyday navigation and long work sessions.','https://images.unsplash.com/photo-1527814050087-3793815479db?auto=format&fit=crop&w=900&q=85',1790,32,'DESK ESSENTIAL',FALSE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Accessories'),'CS-ACC-001','CLOUDSTORE SELECT','PowerGo 20K','High-capacity portable power bank concept for trips, commutes and busy days.','https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?auto=format&fit=crop&w=900&q=85',2490,24,NULL,FALSE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Accessories'),'CS-ACC-002','CLOUDSTORE SELECT','Flex USB-C Hub','A compact multi-port hub concept to simplify a modern laptop workspace.','https://images.unsplash.com/photo-1625842268584-8f3296236761?auto=format&fit=crop&w=900&q=85',2190,19,'SMART PICK',FALSE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Accessories'),'CS-ACC-003','CLOUDSTORE SELECT','Arc Desk Lamp','A minimal adjustable desk-light concept for focused work and comfortable reading.','https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=900&q=85',2890,11,NULL,FALSE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Gaming'),'CS-GAM-001','CLOUDSTORE SELECT','Nova Wireless Controller','A precision game controller concept with responsive controls and an ergonomic grip.','https://images.unsplash.com/photo-1592840496694-26d035b52b48?auto=format&fit=crop&w=900&q=85',3990,14,'GAMER PICK',TRUE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Gaming'),'CS-GAM-002','CLOUDSTORE SELECT','Velocity Gaming Headset','An immersive headset concept with a comfortable fit and a clear communications mic.','https://images.unsplash.com/photo-1599669454699-248893623440?auto=format&fit=crop&w=900&q=85',5490,10,NULL,FALSE,TRUE),
((SELECT category_id FROM categories WHERE category_name='Gaming'),'CS-GAM-003','CLOUDSTORE SELECT','Glide XL Mouse Pad','A smooth extended desk mat concept for clean, consistent mouse movement.','https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?auto=format&fit=crop&w=900&q=85',1290,40,NULL,FALSE,TRUE)
ON DUPLICATE KEY UPDATE category_id=VALUES(category_id),brand=VALUES(brand),product_name=VALUES(product_name),
description=VALUES(description),image_url=VALUES(image_url),price=VALUES(price),stock_quantity=VALUES(stock_quantity),
badge=VALUES(badge),featured=VALUES(featured),is_active=VALUES(is_active);

SELECT c.category_name,COUNT(p.product_id) AS product_count
FROM categories c LEFT JOIN products p ON p.category_id=c.category_id
GROUP BY c.category_id,c.category_name ORDER BY c.category_name;
