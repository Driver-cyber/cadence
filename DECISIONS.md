# DECISIONS.md — Living Decision Log
## Cadence · Stewart Family Finance & Lists App

> **Note to Claude:** This file is the "current vibe." Always read it at session start.
> Decided = move forward. Open = ask before acting. Parked = don't touch yet.

---

## 🎯 Current State

**App status:** Feature-complete v1. Phase 1 (Supabase migration) complete and live on `main`.

**Current phase:** Phase 2 planning — real-time subscriptions so Chad and Joelle see each other's changes live without refresh.

**Immediate next task:** Decide Phase 2 scope and approach (see Parking Lot). Red-team Phase 1 before committing to Phase 2.

---

## ✅ Decisions Made (Don't Relitigate These)

| Date | Decision | Rationale |
|---|---|---|
| 2026-04-21 | App name: **Cadence** | Reflects the core philosophy — financial health from rhythm and repetition |
| 2026-04-21 | Single HTML file architecture | Zero infrastructure, easy iteration, easy deploy. Preserved until build step is explicitly decided. |
| 2026-04-21 | React 18 + Babel CDN (no bundler) | No build step needed. Component model without npm overhead. |
| 2026-04-21 | No auth — shared anon access | Family-only app. Shared URL is the point. `family_id = 'stewarts'` scopes all data. |
| 2026-04-21 | Supabase as target database | Schema already written and ready (`SUPABASE_SCHEMA.sql`). PostgreSQL, real-time capable. |
| 2026-04-21 | localStorage → Supabase migration (not a rewrite) | Replace storage calls incrementally. App architecture stays the same. |
| 2026-04-21 | Phase 1: replace localStorage. Phase 2: add real-time subscriptions. | Phased to reduce risk. Phase 1 is the immediate task. |
| 2026-04-21 | Supabase keys as inlined JS constants (no build step yet) | Simplest path. Build step added later if env injection is needed. |
| 2026-04-21 | DEFAULT_D + override pattern for budget data | Baked-in defaults survive sessions without prep. Prep Mode overlays changes. |
| 2026-04-21 | Prep Mode is pre-session, Edit Mode is in-session | Clean separation. Prep is Chad's job before the date. Edit Mode is a future feature. |
| 2026-04-21 | Cloudflare Pages + GitHub auto-deploy | Already configured. Zero build config. |
| 2026-04-21 | Design system locked | Outfit + Playfair Display. Cream/Ink/Green/Coral/Amber/Purple palette. Do not introduce new colors without discussion. |
| 2026-04-21 | Tagline: **"A Family Budget App"** | Used on Welcome screen and `<title>` tag as "Cadence · A Family Budget App". Tagline only — not part of the brand name. |
| 2026-04-21 | Mobile-first for Our Lists, desktop-first for budget screens | Joelle uses lists on iPhone. Budget review happens on desktop during Money Date. |
| 2026-04-21 | Phase 1 complete: all `moneydate_*` localStorage keys → Supabase | Session-scoped: todos, priorities, notes. Family-scoped: upcoming_notes, budget_data. `moneydate_screen` stays in localStorage (nav state only). |
| 2026-04-21 | Session definition: open until Prep Mode Save & Apply closes it | Prep Mode is the session boundary. One open session at a time. On load: reuse open session or auto-create one. |
| 2026-04-21 | Supabase anon key committed to source | Anon key is public by design; RLS `family_id = 'stewarts'` protects data. Acceptable for a private family app. |

---

## 🔜 Open Questions (Decide Before Acting)

| Question | Context |
|---|---|
| PrepMode "Last Session" tab staleness | `INIT.todos` is populated at app load. If todos were added mid-session before opening Prep Mode, the Last Session tab shows the load-time snapshot, not current state. Does this need a re-fetch on PrepMode open? |
| UpcomingChanges debounce | `saveUpcomingNote` fires on every keystroke. Fine for now (5 fields, low traffic), but worth deciding if we ever see flicker or race conditions. |
| Phase 2 scope | Real-time on todos only? Or todos + priorities + notes + upcoming_notes? Starting narrow is safer. |

---

## 💡 Parking Lot (Future)

| Idea | Notes |
|---|---|
| **Real-time sync (Phase 2)** | **Active next phase.** Supabase `postgres_changes` channel subscriptions on todos, priorities, notes. Start with todos only; expand if stable. Do after Phase 1 is confirmed working in production. |
| Edit Mode (in-session data editing) | Let Chad update a balance mid-session without going to Prep Mode. Needs a lightweight UI — not a full Prep Mode clone. |
| Session history | Store each completed session. View past sessions. Foundation for trend tracking. |
| Bank CSV import | Drag-and-drop CSV, auto-categorize, update spending averages. Needs session history first. |
| Multi-month spending trends | Track spending by category across sessions. Needs session history. |
| Build step for env injection | `package.json` + Cloudflare Pages build for Supabase key management. Triggered when key security becomes a concern. |
| README.md | Simple setup doc for the repo. Low priority. |

---

## 📋 Financial Snapshot (as of April 2026)
*Baked into DEFAULT_D. Update via Prep Mode — don't edit source directly.*

| Item | Value |
|---|---|
| Monthly income | $8,530 |
| Fixed bills | $4,628 |
| Variable spending (avg) | $2,971 |
| Monthly deficit | ~$1,231 |
| Net cash | $8,752 |
| Total liquid | $16,744 |
| Chase Sapphire (2575) | $5,886 |
| Chase Ink (0388) | $2,105 |
| Total CC debt | $7,992 |

**Known upcoming changes:**
- Brightwheel childcare doubling in May 2026 (~$732/mo, Levi enrolled)
- Joelle's Premier Northwest income ($150/mo) removed — she stopped working there
- Sapphire $1k signup bonus nearly triggered

---

## 📝 Change Log

**[2026-04-21]** — Phase 1 complete. localStorage → Supabase migration shipped and merged to main. `db` module added with full CRUD for all five data types. `currentSessionId` tracks open session. Session persists until Prep Mode Save & Apply. Cross-device data persistence now live.

**[2026-04-21]** — Founding docs written. App is Cadence v1 (production-ready). Supabase migration is the active task. All architectural decisions locked.

**Previous versions:**
- v1: Original 7-screen Money Date app
- v2: Upcoming Changes screen, Notes & Priorities tab, session import/recap
- v3: Prep Mode (5 tabs), Our List screen, localStorage-backed live data
- v4: Our Lists (4 tabs), mobile-optimized iPhone layout, bubble sync
- Final/Current: Renamed to Cadence, production-ready

---

*When something shifts mid-build — a pivot, a new constraint, a better idea — add it here before touching the code.*
