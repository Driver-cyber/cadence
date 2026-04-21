# Cadence — Project Handoff & Memory State
*Generated April 21, 2026 · For use in Claude Code project CLAUDE.md / constitution files*

---

## What Is Cadence?

Cadence is a personal finance app built for Chad and Joelle Stewart. It replaces spreadsheet-based budget reviews with a structured, interactive "Money Date" — a regular session (weekly or monthly) where they review finances together, set priorities, track todos, and build on previous sessions.

The name reflects the core philosophy: **financial health comes from rhythm and repetition**, not one-time fixes. "Ordo ab chao" (order from chaos) is the design ethos — taking messy real-world finances and making them feel manageable, even enjoyable.

---

## Architecture (Current State)

**Single HTML file** — `Cadence.html`
- React 18 + Babel standalone (no build step)
- All state in `localStorage` (migration to Supabase planned)
- Deployed target: Cloudflare Pages (static hosting from GitHub)
- Database target: Supabase (PostgreSQL, real-time)

**No backend yet.** Everything runs client-side. All data is persisted in browser localStorage. The Supabase migration will add cross-device real-time sync.

---

## App Structure

### Main Screens (nav order)
1. **Welcome / Home** — Entry point with session start, import last session, prep next session
2. **Big Picture** — All account balances, net cash position, debt overview
3. **Cash Flow** — Income breakdown, fixed bills, monthly surplus/deficit
4. **Spending** — Variable spending by category with interactive sliders (what-if calculator)
5. **Debt** — Credit card payoff simulator with timeline projections
6. **Goals** — Savings goals with progress bars and contribution simulator
7. **Big Decisions** — 5 big topics (Minivan, Baby #3, Passport Trip, School, Job Search) with data panels and discussion prompts
8. **Upcoming Changes** — Smart auto-generated bulletins + 5 editable reminder notes
9. **Our Lists** — Family shared todo list (mobile-optimized), 4 tabs: Chad / Joelle / All / Goals & Notes

### Floating Bubble (✅)
- Accessible from every screen
- 3 tabs: Chad todos / Joelle todos / Goals & Notes
- Export button copies full session as formatted text
- Syncs same localStorage as Our Lists screen

### Prep Mode (🔧)
- Accessed from Home screen, separate from session flow
- 5 tabs: Balances / Income / Bills / Last Session / Upcoming Notes
- Edits live data used by all main screens
- Last Session tab: mark todos done, roll incomplete forward
- Save & Apply writes to localStorage and reloads with fresh data

### Import Flow
- Paste previous session export text on Welcome screen
- Parses todo completion status
- Shows per-person recap with progress bars
- Option to roll incomplete items forward

---

## Data Architecture

### Current: localStorage Keys
```
moneydate_screen          → current screen index (integer)
moneydate_data            → overrides for D object (JSON)
moneydate_list            → { chad: TodoItem[], joelle: TodoItem[] }
moneydate_priorities      → string[3] — shared monthly priorities
moneydate_notes_list      → NoteItem[] — session notes
moneydate_upcoming_notes  → string[5] — reminder board notes
moneydate_checks          → legacy (action item checkboxes, deprecated)
```

### TodoItem shape
```json
{ "text": "string", "done": false, "id": 1713123456789 }
```

### Budget Data (DEFAULT_D) shape
```js
{
  date: string,
  accounts: {
    billing, groceries, propertyTax, emergency,
    ordoWATB, baselane,          // liquid
    totalLiquid, sapphire, ink,  // computed + CC
    totalDebt, netCash           // computed
  },
  income: {
    total: number,
    sources: [{ label, amt, acct, when, note? }]
  },
  fixedBills: number,
  variableSpend: number,
  deficit: number,              // negative = surplus
  spending: [{ cat, mo, note, color, lever }],
  goals: [{ name, saved, target, icon, note }]
}
```

When Prep Mode saves, it writes a partial override to `moneydate_data` in localStorage. On load, `DEFAULT_D` is merged with the saved overrides to produce the live `D` object used by all screens.

---

## Current Financial Data (as of April 2026)
*This is baked into DEFAULT_D in the source — update via Prep Mode or source edit*

| Item | Value |
|---|---|
| Monthly income | $8,530 |
| Fixed bills | $4,628 |
| Variable spending (avg) | $2,971 |
| Monthly deficit | ~$1,231 |
| Net cash position | $8,752 |
| Total liquid | $16,744 |
| Total CC debt | $7,992 |
| Sapphire balance | $5,886 |
| Ink balance | $2,105 |

**Key data changes from original session:**
- Joelle's Premier Northwest income ($150/mo) removed — she stopped working there
- Brightwheel childcare flagged to double in May 2026 (Levi enrolled, ~$732/mo)
- Upcoming Changes screen has 5 auto-generated smart bulletins based on this data

---

## People & Accounts

| Person | Role |
|---|---|
| Chad | Primary income (Barrett & Co.), app primary user / prep mode |
| Joelle | Secondary user, primarily uses Our Lists on iPhone |

**Accounts:**
- Billing (OnPoint CCU) — main checking, payroll destination
- Groceries (PSCCU) — second checking, overdrafted 13x YTD
- Property Tax savings — dedicated, currently $2,400
- Emergency Fund (OnPoint) — $6,057 in account, $4k allocated to goal
- ORDO WATB — business account, ORDO income lands here
- Baselane — rental property income
- Chase Sapphire (2575) — ~$5,887 balance, $1k signup bonus nearly triggered
- Chase Ink (0388) — ~$2,106 balance

---

## Supabase Migration Plan

### Target Tables
See `SUPABASE_SCHEMA.sql` for ready-to-run SQL.

**Phase 1 (ship this):** Replace all localStorage calls with Supabase reads/writes. No auth — family-only app, use anon key with permissive RLS. Single `family_id = 'stewarts'` scopes all data.

**Phase 2 (when needed):** Add real-time subscriptions so Chad and Joelle see changes instantly across devices without refresh.

### Environment Variables Needed
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

Since this is a static HTML file (no build step), these will be inlined as JS constants at the top of the file. When deploying via Cloudflare Pages, they can be set as environment variables and injected at build time if a simple build script is added.

---

## Deployment

### Current
- Static HTML file, runs in any browser
- No server, no API, no build step

### Target
```
GitHub repo (Driver-cyber/cadence or similar)
  └── Cadence.html       ← main app
  └── SUPABASE_SCHEMA.sql
  └── HANDOFF.md
  └── README.md

Cloudflare Pages
  └── connects to GitHub repo
  └── auto-deploys on push to main
  └── serves Cadence.html at custom URL
```

### Steps to deploy
1. Copy `Cadence.html` into your GitHub repo
2. Connect repo to Cloudflare Pages (Build command: none, Output directory: /)
3. Set custom domain if desired
4. Run `SUPABASE_SCHEMA.sql` in Supabase SQL editor
5. Add Supabase JS client + replace localStorage calls (Claude Code task)

---

## Key Design Decisions

| Decision | Rationale |
|---|---|
| Single HTML file | Zero infrastructure to start, easy to iterate, easy to deploy |
| React + Babel CDN | No build step needed, familiar component model |
| localStorage first | Ship fast, migrate to Supabase when cross-device sync needed |
| DEFAULT_D + override pattern | Baked-in data for sessions without prep, Prep Mode overlays changes |
| Mobile-first Our Lists | Joelle uses on iPhone; desktop for budget date sessions |
| Prep Mode separate from session | Data editing is Chad's job, done before the date |
| No auth | Family-only app, shared access is the point |

---

## Versions Built

| Version | File | Key additions |
|---|---|---|
| v1 | Stewart Family Money Date.html | Original 7-screen money date app |
| v2 | Stewart Family Money Date v2.html | Upcoming Changes screen, Notes & Priorities tab, session import/recap |
| v3 | Stewart Family Money Date v3.html | Prep Mode (5 tabs), Our List screen, localStorage-backed live data |
| v4 | Stewart Family Money Date v4.html | Our Lists (4 tabs), mobile-optimized iPhone layout, bubble sync |
| Final | Cadence.html | Renamed to Cadence, production-ready |

---

## Next Claude Code Tasks (Priority Order)

1. **Add Supabase client** — install `@supabase/supabase-js`, replace all localStorage calls
2. **Real-time todo sync** — subscribe to `todos` table changes, update UI live
3. **Build step** — add a minimal `package.json` + Cloudflare Pages build for env injection
4. **Edit Mode** — in-session data editing (vs. Prep Mode which is pre-session)
5. **Session history** — store each completed session, view past sessions
6. **Bank CSV import** — drag-and-drop CSV from bank, auto-categorize, update spending averages
7. **Multi-month tracking** — track spending trends across sessions over time

---

## Tone & Brand

- **Warm but honest** — no sugar-coating the numbers, but always framing positively
- **We language** — "we're in surplus" not "you're in deficit"
- **Designed for two** — everything assumes both partners are present
- **Anti-anxiety** — data is presented in a way that feels manageable, not overwhelming
- **Color palette:** Cream (#FAF7F2), Ink (#1C1C1E), Green (#2A8B68), Coral (#D4544A), Amber (#C07A12), Purple (#6B5EA8)
- **Fonts:** Outfit (UI), Playfair Display (headings/serif moments)
