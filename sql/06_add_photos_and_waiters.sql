-- =========================================================
-- CHOWLY — Add menu item photos + more waiters
-- Run this once in the Supabase SQL Editor, after everything
-- else has already been run.
-- =========================================================

-- ---- 1. New column for a photo per menu item ----
alter table menu_item add column if not exists item_image_url text;

-- ---- 2. Photo for every existing menu item ----
-- All photos are freely-licensed (Creative Commons) images from
-- Wikimedia Commons, not the real restaurants' own photography.
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Jollof_rice_with_dodo.jpg' where menu_item_id = 'MI001';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Grilled_Chicken_Breasts_(28905381261).jpg' where menu_item_id = 'MI002';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Cherry_beer_margarita_in_a_glass_with_lime_and_straw_and_maraschino_(18492281828).jpg' where menu_item_id = 'MI003';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Suya_in_skewers.jpg' where menu_item_id = 'MI004';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Zobo(hibiscus)_drink.jpg' where menu_item_id = 'MI005';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Goat_meat_pepper_soup_served_with_bread.jpg' where menu_item_id = 'MI006';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/French_Fries.jpg' where menu_item_id = 'MI007';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Classic_steak_tartare.jpg' where menu_item_id = 'MI008';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Whiskey_Old_Fashioned.jpg' where menu_item_id = 'MI009';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Chicken_katsu.JPG' where menu_item_id = 'MI010';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Miso_Ramen.JPG' where menu_item_id = 'MI011';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Salmon_nigiri_sushi.jpg' where menu_item_id = 'MI012';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Three_California_rolls.jpg' where menu_item_id = 'MI013';
update menu_item set item_image_url = 'https://commons.wikimedia.org/wiki/Special:FilePath/Japanese_sake_bottles_and_glasses.jpg' where menu_item_id = 'MI014';

-- ---- 3. More waiters for the original 3 restaurants ----
-- (R004/R005/R006 already got their own waiters in an earlier script)
insert into waiter (waiter_id, restaurant_id, waiter_name, waiter_phone) values
  ('W007', 'R001', 'Ifeoma',   '08066666661'),
  ('W008', 'R002', 'Tobi',     '08066666662'),
  ('W009', 'R002', 'Grace',    '08066666663'),
  ('W010', 'R003', 'Kunle',    '08066666664'),
  ('W011', 'R003', 'Blessing', '08066666665'),
  ('W012', 'R003', 'Ahmed',    '08066666666');
