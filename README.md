# Chowly — Table-side Ordering

A restaurant ordering app built on top of the Chowly data model (see the
Engineered Model assignment). A customer browses the menu, places an
order, tracks its status, can complain and rate a delayed order, and
pays (demo payment) before leaving. A waiter claims new orders, assigns
a chef and bartender, and marks orders served.

## Stack

- **Frontend:** static HTML/CSS/vanilla JavaScript — no build step
- **Database + API:** [Supabase](https://supabase.com) (Postgres, with
  its auto-generated REST API used directly from the browser)
- **Hosting:** GitHub Pages

No custom backend server was written — the frontend talks to Supabase
directly using the `@supabase/supabase-js` client library, secured by
Row Level Security policies defined in `sql/01_schema.sql`.

## Setup

1. Create a Supabase project (or use an existing one).
2. Open the Supabase SQL Editor and run, in order:
   - `sql/01_schema.sql`
   - `sql/02_seed.sql`
3. In `js/config.js`, replace the two placeholder values with your
   project's URL and anon public key (Project Settings → API).
4. Open `index.html` in a browser, or push this repo to GitHub and
   enable GitHub Pages (Settings → Pages → deploy from `main` branch,
   root folder).

## Project structure

```
index.html        All views (customer + waiter), one HTML file
css/style.css      All styling
js/config.js       Supabase project credentials (fill in your own)
js/app.js          All application logic
sql/01_schema.sql  Table definitions + Row Level Security policies
sql/02_seed.sql    Reference data: restaurants, staff, menu
```

See the accompanying write-up document for the data model, the AI
collaboration notes, and a full usage walkthrough.
