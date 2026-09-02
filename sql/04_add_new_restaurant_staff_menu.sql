-- =========================================================
-- CHOWLY — Add staff + menu for BlackBell, Shiro, Wakame
-- Run this once in the Supabase SQL Editor.
-- Placeholder names — rename any of these later in the Table
-- Editor (click the cell, type the new name, press Enter).
-- =========================================================

insert into waiter (waiter_id, restaurant_id, waiter_name, waiter_phone) values
  ('W004', 'R004', 'Tolu',   '08055555551'),
  ('W005', 'R005', 'Ifeoma', '08055555552'),
  ('W006', 'R006', 'Bayo',   '08055555553');

insert into chef (chef_id, restaurant_id, chef_name, chef_specialty) values
  ('CH004', 'R004', 'Chef Femi',  'Small Plates'),
  ('CH005', 'R005', 'Chef Aisha', 'Japanese'),
  ('CH006', 'R006', 'Chef Kenji', 'Sushi');

insert into bartender (bartender_id, restaurant_id, bartender_name, bartender_specialty) values
  ('B004', 'R004', 'Zainab', 'Cocktails'),
  ('B005', 'R005', 'Uche',   'Sake & Wine'),
  ('B006', 'R006', 'Miki',   'Cocktails');

insert into menu (menu_id, restaurant_id, menu_type, menu_description) values
  ('M004', 'R004', 'Food',   'Small Plates'),
  ('M005', 'R004', 'Drinks', 'Cocktails'),
  ('M006', 'R005', 'Food',   'Japanese Favourites'),
  ('M007', 'R006', 'Food',   'Sushi & Sashimi'),
  ('M008', 'R006', 'Drinks', 'Sake & Cocktails');

-- Placeholder items — edit names, prices and prep times in Table Editor
insert into menu_item (menu_item_id, menu_id, item_name, item_category, item_price, item_description, prep_time_minutes) values
  ('MI007', 'M004', 'Truffle Fries',    'Food',  4500, 'Placeholder — edit me',  15),
  ('MI008', 'M004', 'Beef Tartare',     'Food',  6500, 'Placeholder — edit me',  12),
  ('MI009', 'M005', 'Old Fashioned',    'Drink', 5000, 'Placeholder — edit me',   5),
  ('MI010', 'M006', 'Chicken Katsu',    'Food',  5500, 'Placeholder — edit me',  20),
  ('MI011', 'M006', 'Miso Ramen',       'Food',  5000, 'Placeholder — edit me',  18),
  ('MI012', 'M007', 'Salmon Nigiri (6pc)', 'Food', 6000, 'Placeholder — edit me', 15),
  ('MI013', 'M007', 'California Roll',  'Food',  4500, 'Placeholder — edit me',  12),
  ('MI014', 'M008', 'Hot Sake',         'Drink', 3500, 'Placeholder — edit me',   5);
