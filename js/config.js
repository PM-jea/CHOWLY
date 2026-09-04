// =========================================================
// CHOWLY — Supabase connection config
// =========================================================
const SUPABASE_URL = "https://uemcwseynlkvrqbcfqis.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_tqbkqehrFZxczK-5Otlu2A_V0rJWPD-";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

