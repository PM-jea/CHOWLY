-- =========================================================
-- CHOWLY — Real payments + more menu categories
-- Run this once in the Supabase SQL Editor.
-- =========================================================

-- ---- 1. Store the Paystack transaction reference on card payments ----
alter table payment add column if not exists payment_reference text;

-- ---- 2. New "Mains" items in existing categories ----
insert into menu_item (menu_item_id, menu_id, item_name, item_category, item_price, item_description, prep_time_minutes, item_image_url) values
  ('MI015', 'M001', 'Fried Rice',       'Food', 3800, 'Nigerian-style fried rice with mixed vegetables', 18, 'https://commons.wikimedia.org/wiki/Special:FilePath/Plates_of_Jollof_Rice,_Fried_Rice_and_Chicken.jpg'),
  ('MI016', 'M003', 'Grilled Fish',     'Food', 5200, 'Whole grilled tilapia with pepper sauce', 25, 'https://commons.wikimedia.org/wiki/Special:FilePath/Plated_grilled_fish.jpg'),
  ('MI017', 'M004', 'Ribeye Steak',     'Food', 12000, 'Placeholder — edit me', 22, 'https://commons.wikimedia.org/wiki/Special:FilePath/Longhorn_Steakhouse_Ribeye_steak.jpg'),
  ('MI018', 'M006', 'Chicken Teriyaki', 'Food', 6200, 'Placeholder — edit me', 20, 'https://commons.wikimedia.org/wiki/Special:FilePath/Chicken_teriyaki.jpg'),
  ('MI019', 'M007', 'Spicy Tuna Roll',  'Food', 5500, 'Placeholder — edit me', 15, 'https://commons.wikimedia.org/wiki/Special:FilePath/Spicy_tuna_rolls_(3273982724).jpg');

-- ---- 3. New "Desserts" category + item for each restaurant ----
insert into menu (menu_id, restaurant_id, menu_type, menu_description) values
  ('M009', 'R001', 'Food', 'Desserts'),
  ('M010', 'R002', 'Food', 'Desserts'),
  ('M013', 'R004', 'Food', 'Desserts'),
  ('M014', 'R005', 'Food', 'Desserts'),
  ('M015', 'R006', 'Food', 'Desserts');

insert into menu_item (menu_item_id, menu_id, item_name, item_category, item_price, item_description, prep_time_minutes, item_image_url) values
  ('MI020', 'M009', 'Chin Chin',            'Food', 1500, 'Crunchy fried pastry bites, lightly sweetened', 5, 'https://commons.wikimedia.org/wiki/Special:FilePath/Nigerian_ChinChin.jpg'),
  ('MI021', 'M010', 'Puff Puff',            'Food', 1500, 'Soft, golden deep-fried dough balls', 8, 'https://commons.wikimedia.org/wiki/Special:FilePath/Milky_Puff-puff.jpg'),
  ('MI022', 'M013', 'Chocolate Cake',       'Food', 4500, 'Placeholder — edit me', 5, 'https://commons.wikimedia.org/wiki/Special:FilePath/Chocolate_cake.jpg'),
  ('MI023', 'M014', 'Green Tea Ice Cream',  'Food', 3500, 'Placeholder — edit me', 3, 'https://commons.wikimedia.org/wiki/Special:FilePath/Ice-cream.jpg'),
  ('MI024', 'M015', 'Mochi Ice Cream',      'Food', 3500, 'Placeholder — edit me', 3, 'https://commons.wikimedia.org/wiki/Special:FilePath/Ice-cream.jpg');

-- ---- 4. Give Sahara Grill (R003) an actual menu — it had none until now ----
insert into menu (menu_id, restaurant_id, menu_type, menu_description) values
  ('M011', 'R003', 'Food',   'Grill'),
  ('M012', 'R003', 'Drinks', 'Beverages');

insert into menu_item (menu_item_id, menu_id, item_name, item_category, item_price, item_description, prep_time_minutes, item_image_url) values
  ('MI025', 'M011', 'Beef Suya',              'Food',  4500, 'Spiced grilled beef skewers', 18, 'https://commons.wikimedia.org/wiki/Special:FilePath/Suya_in_skewers.jpg'),
  ('MI026', 'M011', 'Grilled Chicken Platter', 'Food',  5500, 'Herb-marinated grilled chicken', 25, 'https://commons.wikimedia.org/wiki/Special:FilePath/Grilled_Chicken_Breasts_(28905381261).jpg'),
  ('MI027', 'M012', 'Zobo',                    'Drink', 1200, 'Hibiscus drink, chilled',  3, 'https://commons.wikimedia.org/wiki/Special:FilePath/Zobo(hibiscus)_drink.jpg');
