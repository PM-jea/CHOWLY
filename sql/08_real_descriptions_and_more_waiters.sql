-- =========================================================
-- CHOWLY — Real menu descriptions + more waiters
-- Run this once in the Supabase SQL Editor.
-- =========================================================

-- ---- 1. Replace "Placeholder — edit me" with real descriptions ----
update menu_item set item_description = 'Hand-cut fries tossed in truffle oil and parmesan, served with garlic aioli.' where menu_item_id = 'MI007';
update menu_item set item_description = 'Finely diced raw beef tenderloin with capers, shallots and egg yolk, seasoned tableside.' where menu_item_id = 'MI008';
update menu_item set item_description = 'Bourbon stirred with sugar, Angostura bitters and an orange twist, served over one large ice cube.' where menu_item_id = 'MI009';
update menu_item set item_description = 'Panko-breaded chicken cutlet, deep-fried golden and sliced, served with katsu sauce and shredded cabbage.' where menu_item_id = 'MI010';
update menu_item set item_description = 'Rich miso broth with wheat noodles, chashu pork, a soft-boiled egg, scallions and bamboo shoots.' where menu_item_id = 'MI011';
update menu_item set item_description = 'Six pieces of hand-pressed sushi rice topped with fresh sliced salmon.' where menu_item_id = 'MI012';
update menu_item set item_description = 'Crab stick, avocado and cucumber rolled inside-out with toasted sesame seeds.' where menu_item_id = 'MI013';
update menu_item set item_description = 'Warmed junmai sake, served in a traditional tokkuri flask with a small cup.' where menu_item_id = 'MI014';
update menu_item set item_description = 'Char-grilled ribeye steak, rested and sliced, served with rosemary butter.' where menu_item_id = 'MI017';
update menu_item set item_description = 'Grilled chicken thigh glazed in a sweet-savoury teriyaki sauce, served with steamed rice.' where menu_item_id = 'MI018';
update menu_item set item_description = 'Tuna mixed with spicy mayo, rolled with cucumber and topped with sesame seeds.' where menu_item_id = 'MI019';
update menu_item set item_description = 'Rich, moist layered chocolate cake with a dark chocolate ganache.' where menu_item_id = 'MI022';
update menu_item set item_description = 'Creamy matcha-flavoured ice cream, lightly sweetened.' where menu_item_id = 'MI023';
update menu_item set item_description = 'Soft, chewy rice-dough shells wrapped around a scoop of ice cream.' where menu_item_id = 'MI024';

-- ---- 2. More waiters for every restaurant ----
insert into waiter (waiter_id, restaurant_id, waiter_name, waiter_phone) values
  ('W013', 'R001', 'Uche',     '08077777771'),
  ('W014', 'R001', 'Salewa',   '08077777772'),
  ('W015', 'R002', 'Femi',     '08077777773'),
  ('W016', 'R002', 'Halima',   '08077777774'),
  ('W017', 'R003', 'Chidinma', '08077777775'),
  ('W018', 'R003', 'Obinna',   '08077777776'),
  ('W019', 'R004', 'Ngozi',    '08077777777'),
  ('W020', 'R004', 'Tunde',    '08077777778'),
  ('W021', 'R005', 'Yusuf',    '08077777779'),
  ('W022', 'R005', 'Aisha',    '08077777780'),
  ('W023', 'R006', 'Amaka',    '08077777781'),
  ('W024', 'R006', 'Chukwu',   '08077777782');
