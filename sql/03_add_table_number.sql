-- =========================================================
-- CHOWLY — Migration: add table_number
-- Run this once in the Supabase SQL Editor, after 01_schema.sql
-- and 02_seed.sql have already been run.
-- =========================================================
-- Lets each order record which physical table it came from, so a
-- QR code scanned at a table can pre-fill the restaurant and tag
-- every order placed from it with that table's number.
-- =========================================================

alter table "order" add column if not exists table_number integer;
