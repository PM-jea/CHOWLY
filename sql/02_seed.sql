-- =========================================================
-- CHOWLY — Seed Data
-- Run this after 01_schema.sql. This is the "loaded by you" reference
-- data: restaurants, staff, and menu. Customers, orders, complaints and
-- payments are created live by using the app, not seeded here.
-- =========================================================

insert into restaurant (restaurant_id, restaurant_name, restaurant_location, restaurant_phone) values
  ('R001', 'The Spice Room', 'Lagos',     '08011111111'),
  ('R002', 'Ocean Bites',    'Abuja',     '08022222222'),
  ('R003', 'Sahara Grill',   'P.Harcourt','08033333333');

insert into waiter (waiter_id, restaurant_id, waiter_name, waiter_phone) values
  ('W001', 'R001', 'Emeka',  '08044444441'),
  ('W002', 'R001', 'Chinedu','08044444442'),
  ('W003', 'R002', 'Amina',  '08044444443');

insert into chef (chef_id, restaurant_id, chef_name, chef_specialty) values
  ('CH001', 'R001', 'Chef Kofi', 'Grills'),
  ('CH002', 'R001', 'Chef Yemi', 'Pastries'),
  ('CH003', 'R002', 'Chef Bola', 'Seafood');

insert into bartender (bartender_id, restaurant_id, bartender_name, bartender_specialty) values
  ('B001', 'R001', 'Dayo',  'Cocktails'),
  ('B002', 'R002', 'Segun', 'Wines'),
  ('B003', 'R001', 'Ngozi', 'Mocktails');

insert into menu (menu_id, restaurant_id, menu_type, menu_description) values
  ('M001', 'R001', 'Food',   'Main Dishes'),
  ('M002', 'R001', 'Drinks', 'Beverages'),
  ('M003', 'R002', 'Food',   'Local Dishes');

-- prep_time_minutes is new versus the original model (see 01_schema.sql)
insert into menu_item (menu_item_id, menu_id, item_name, item_category, item_price, item_description, prep_time_minutes) values
  ('MI001', 'M001', 'Jollof Rice',     'Food',  3500, 'Spicy tomato rice',      20),
  ('MI002', 'M001', 'Grilled Chicken', 'Food',  5000, 'Herb-marinated',         25),
  ('MI003', 'M002', 'Chapman',         'Drink', 2000, 'Classic cocktail',        5),
  ('MI004', 'M001', 'Suya Platter',    'Food',  4500, 'Spiced grilled beef skewers', 18),
  ('MI005', 'M002', 'Zobo',            'Drink', 1200, 'Hibiscus drink, chilled',  3),
  ('MI006', 'M003', 'Pepper Soup',     'Food',  4000, 'Catfish pepper soup',     22);
