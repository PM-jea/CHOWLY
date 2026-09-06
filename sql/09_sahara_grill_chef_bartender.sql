-- =========================================================
-- CHOWLY — Add chef + bartender for Sahara Grill
-- Sahara Grill (R003) got a menu and waiters earlier, but never
-- got a chef or bartender — that's why those dropdowns were empty
-- when assigning an order. Run this once in the SQL Editor.
-- =========================================================

insert into chef (chef_id, restaurant_id, chef_name, chef_specialty) values
  ('CH007', 'R003', 'Chef Musa', 'Grill');

insert into bartender (bartender_id, restaurant_id, bartender_name, bartender_specialty) values
  ('B007', 'R003', 'Fatima', 'Local Drinks');
