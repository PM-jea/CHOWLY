// =========================================================
// CHOWLY — Supabase connection config
// =========================================================
const SUPABASE_URL = "https://uemcwseynlkvrqbcfqis.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_tqbkqehrFZxczK-5Otlu2A_V0rJWPD-";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// =========================================================
// CHOWLY — Paystack connection config (real card payments)
// =========================================================
// Fill in your own Paystack PUBLIC key below (starts with "pk_").
// Find it at: Paystack Dashboard -> Settings -> API Keys & Webhooks.
// Use a "Test" key while trying this out — never put your SECRET key
// (starts with "sk_") here or anywhere in this repo.
const PAYSTACK_PUBLIC_KEY = "pk_test_887ec4dc27518dcd649ea1c657bd7e58c8853cf0";
