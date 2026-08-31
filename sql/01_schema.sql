-- =========================================================
-- CHOWLY — Database Schema (Supabase / PostgreSQL)
-- Run this whole file once in the Supabase SQL Editor.
-- =========================================================
-- This keeps the reference tables (Customer, Restaurant, Waiter, Chef,
-- Bartender, Menu, MenuItem) using the same short text codes as the
-- original engineered model (C001, R001, W001...), since those rows are
-- loaded by a human before the app runs.
--
-- Order, OrderItem, Complaint and Payment switch to auto-incrementing
-- integer IDs (bigserial) instead of manually assigned codes (O001...),
-- because these rows are created live by the running application, not
-- typed in by a person — the database should hand out the next ID
-- itself. This is documented as a model change in the write-up.
-- =========================================================

-- Clean slate if re-running during development
drop table if exists payment cascade;
drop table if exists complaint cascade;
drop table if exists order_item cascade;
drop table if exists "order" cascade;
drop table if exists menu_item cascade;
drop table if exists menu cascade;
drop table if exists bartender cascade;
drop table if exists chef cascade;
drop table if exists waiter cascade;
drop table if exists restaurant cascade;
drop table if exists customer cascade;

-- ---------------------------------------------------------
-- CUSTOMER
-- ---------------------------------------------------------
create table customer (
  customer_id   text primary key,
  customer_name text not null,
  customer_phone text not null,
  customer_email text
);

-- ---------------------------------------------------------
-- RESTAURANT
-- ---------------------------------------------------------
create table restaurant (
  restaurant_id     text primary key,
  restaurant_name   text not null,
  restaurant_location text not null,
  restaurant_phone  text
);

-- ---------------------------------------------------------
-- WAITER
-- ---------------------------------------------------------
create table waiter (
  waiter_id     text primary key,
  restaurant_id text not null references restaurant(restaurant_id),
  waiter_name   text not null,
  waiter_phone  text
);

-- ---------------------------------------------------------
-- CHEF
-- ---------------------------------------------------------
create table chef (
  chef_id       text primary key,
  restaurant_id text not null references restaurant(restaurant_id),
  chef_name     text not null,
  chef_specialty text
);

-- ---------------------------------------------------------
-- BARTENDER
-- ---------------------------------------------------------
create table bartender (
  bartender_id      text primary key,
  restaurant_id     text not null references restaurant(restaurant_id),
  bartender_name    text not null,
  bartender_specialty text
);

-- ---------------------------------------------------------
-- MENU
-- ---------------------------------------------------------
create table menu (
  menu_id       text primary key,
  restaurant_id text not null references restaurant(restaurant_id),
  menu_type     text not null,       -- 'Food' or 'Drinks'
  menu_description text
);

-- ---------------------------------------------------------
-- MENU ITEM
-- MODEL CHANGE: added prep_time_minutes.
-- The written requirements state every item "carries a name, a price
-- and a preparation time" — the original engineered model did not have
-- this field, so it is added here. It is what the app uses to compute
-- an order's waiting time.
-- ---------------------------------------------------------
create table menu_item (
  menu_item_id    text primary key,
  menu_id         text not null references menu(menu_id),
  item_name       text not null,
  item_category   text,
  item_price      numeric(10,2) not null,
  item_description text,
  prep_time_minutes integer not null default 10
);

-- ---------------------------------------------------------
-- ORDER
-- MODEL CHANGES:
--  1. order_id is now bigserial (see note at top of file).
--  2. waiter_id, chef_id and bartender_id are now NULLABLE.
--     In the original model these were required at the moment an order
--     is created, but a customer places an order before any staff
--     member has touched it — a waiter only claims it, then assigns a
--     chef/bartender, afterwards. Making these nullable is what lets
--     the story (place -> claim -> assign -> serve) actually work.
--  3. order_status now uses: 'Placed', 'Preparing', 'Served'
--     ('Preparing' begins once a waiter has assigned a chef/bartender;
--     'Served' matches the requirement wording "marks the order as
--     served", replacing the original 'Completed').
--  4. waiting_time_minutes is computed by the app when the order is
--     placed, as the longest prep_time_minutes among the items
--     ordered (kitchen items are assumed to be prepared in parallel).
-- ---------------------------------------------------------
create table "order" (
  order_id       bigserial primary key,
  customer_id    text not null references customer(customer_id),
  restaurant_id  text not null references restaurant(restaurant_id),
  waiter_id      text references waiter(waiter_id),
  chef_id        text references chef(chef_id),
  bartender_id   text references bartender(bartender_id),
  order_date     timestamptz not null default now(),
  order_status   text not null default 'Placed'
                 check (order_status in ('Placed','Preparing','Served')),
  waiting_time_minutes integer
);

-- ---------------------------------------------------------
-- ORDER ITEM (bridge table, Order <-> MenuItem, M:M)
-- ---------------------------------------------------------
create table order_item (
  order_item_id  bigserial primary key,
  order_id       bigint not null references "order"(order_id) on delete cascade,
  menu_item_id   text not null references menu_item(menu_item_id),
  quantity       integer not null check (quantity > 0),
  subtotal       numeric(10,2) not null
);

-- ---------------------------------------------------------
-- COMPLAINT
-- ---------------------------------------------------------
create table complaint (
  complaint_id    bigserial primary key,
  order_id        bigint not null references "order"(order_id) on delete cascade,
  customer_id     text not null references customer(customer_id),
  complaint_desc  text not null,
  rating          integer not null check (rating between 1 and 5),
  complaint_date  timestamptz not null default now()
);

-- ---------------------------------------------------------
-- PAYMENT
-- The payment is a simulated/demo payment, clearly labelled as such in
-- the app UI. It is still a real row in a real table, satisfying the
-- "real storage" requirement — only the money is pretend.
-- ---------------------------------------------------------
create table payment (
  payment_id      bigserial primary key,
  order_id        bigint not null references "order"(order_id) on delete cascade,
  payment_amount  numeric(10,2) not null,
  payment_method  text not null check (payment_method in ('Card','Cash','Transfer')),
  payment_date    timestamptz not null default now(),
  payment_status  text not null default 'Paid' check (payment_status in ('Pending','Paid'))
);

-- ---------------------------------------------------------
-- Row Level Security
-- No login system exists for this assignment ("a simple switch is
-- enough" between customer/waiter views), so the anon public API key
-- is used for every request. RLS is enabled with permissive policies
-- so that key can read/write the tables the app needs. This is a
-- deliberate simplification for a coursework demo, documented in the
-- write-up as something a production version would replace with real
-- authentication and tighter per-role policies.
-- ---------------------------------------------------------
alter table customer enable row level security;
alter table restaurant enable row level security;
alter table waiter enable row level security;
alter table chef enable row level security;
alter table bartender enable row level security;
alter table menu enable row level security;
alter table menu_item enable row level security;
alter table "order" enable row level security;
alter table order_item enable row level security;
alter table complaint enable row level security;
alter table payment enable row level security;

create policy "public read" on customer for select using (true);
create policy "public write" on customer for insert with check (true);
create policy "public update" on customer for update using (true);

create policy "public read" on restaurant for select using (true);
create policy "public read" on waiter for select using (true);
create policy "public read" on chef for select using (true);
create policy "public read" on bartender for select using (true);
create policy "public read" on menu for select using (true);
create policy "public read" on menu_item for select using (true);

create policy "public read" on "order" for select using (true);
create policy "public write" on "order" for insert with check (true);
create policy "public update" on "order" for update using (true);

create policy "public read" on order_item for select using (true);
create policy "public write" on order_item for insert with check (true);

create policy "public read" on complaint for select using (true);
create policy "public write" on complaint for insert with check (true);

create policy "public read" on payment for select using (true);
create policy "public write" on payment for insert with check (true);
create policy "public update" on payment for update using (true);
