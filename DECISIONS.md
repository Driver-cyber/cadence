# DECISIONS.md — Living Decision Log
## Cadence · Stewart Family Finance & Lists App

> **Note to Claude:** This file is the "current vibe." Always read it at session start.
> Decided = move forward. Open = ask before acting. Parked = don't touch yet.

---

## 🎯 Current State

**App status:** Feature-complete v1. Phase 1 (Supabase migration) complete, hardened, and live on `main`. PWA-ready: favicon, icons, manifest, and home-screen shortcut all set. Our Lists mobile UX polished. Supabase CDN resilience hardened for Safari standalone mode. Todo/note editing with due dates shipped. Last Session accomplishment screen and animated checkboxes shipped on feature branch (pending merge).

**Current phase:** Phase 2 planning — scope decision is the first task next session. Merge current feature branch first.

**Immediate next task:** (1) Merge `claude/supabase-phase-1-u0RKn` → `main` to ship all session 2 work (todo/note editing, due dates, Last Session screen, animated checkboxes, build tracker). Then (2) Phase 2 brainstorm — decide real-time scope (todos only vs. all tables), and whether any other features (action items tab, session history stub) belong in Phase 2 before real-time work starts.

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
| 2026-04-21 | Hash-based routing for direct screen links | `/#lists` (alias for `/#ourlist`) is Joelle's bookmark. Every screen linkable by id. No server config needed — pure client-side. `go()` updates hash; `hashchange` listener keeps back/forward working. |
| 2026-04-21 | Import flow accepts plain `--- Chad ---` / `[ ]` format | Parser handles both app export format and manual plain-text lists. Confirmed working with April 20 session RTF content. |
| 2026-04-21 | Phase 1 hardened — 5 data integrity fixes | PrepMode re-fetches todos on mount (no stale Last Session tab). Save button has double-click guard + try/catch. All fire-and-forget db writes log errors via `.then()`. `addTodo`/`addNote` show inline error on failure. `saveUpcomingNote` debounced 400ms. FloatingBubble shows "Syncing…" instead of stale count while re-fetching on open. |
| 2026-04-22 | PWA home-screen icons + favicon shipped | `favicon.svg` (Option E: geometric C ring + amber period dot), `apple-touch-icon.png`, `icon-192.png`, `icon-512.png`, `site.webmanifest`. App installable from Safari "Add to Home Screen". |
| 2026-04-22 | `start_url: "/#lists"` in manifest | Joelle's home-screen icon launches directly to Our Lists. After any manifest change, delete old icon and re-add from Safari. |
| 2026-04-22 | Supabase CDN switched to `unpkg.com` | All CDN scripts (React, Babel, Supabase) now on the same origin. Avoids Safari Privacy Protection selectively blocking `cdn.jsdelivr.net` in standalone PWA mode. |
| 2026-04-22 | Supabase offline resilience — `sb` null guard | `sb` created with optional chaining; if CDN blocked, `sb = null` and script continues. All `db` methods guard `if (!sb)`: init returns early (DEFAULT_D + empty todos), writes are no-ops, reads return INIT defaults. App is fully usable even when Supabase is unavailable. 8-second fallback timeout also added to App init. |
| 2026-04-22 | OurListsScreen home button uses `onGoHome` prop | Was setting `window.location.hash` directly (unreliable in iOS Safari standalone). Now App passes `onGoHome={() => go(0)}` as a prop — calls React state and hash atomically, same as the desktop nav button. |
| 2026-04-22 | Our Lists tab bar: counts removed from tab buttons | `(done/total)` badges inside tab buttons made them too wide on narrow iPhones. Overall count is shown in the header. Tabs now fit natively on all iPhone widths. |
| 2026-04-22 | `cadence-tracker.html` added as a founding doc | Visual priority board (walnut/amber/wheat design, Plus Jakarta Sans + Fraunces). Machine-readable `<script id="tracker-data" type="application/json">` block at bottom feeds cross-project dashboard at project-dashboard-6a7.pages.dev. Top-3 priorities kept current by Claude each session. |
| 2026-04-22 | Todo + note enhancements shipped | Tap-to-expand detail card with editable text and optional due date on todos and notes. Auto-sort: dated → undated → completed (todos); dated → undated (notes). Completed todos sink to bottom, preserved for recap. |
| 2026-04-22 | Last Session screen added as screen 1 | Replaces import flow on Welcome. Shows completed todos from most recently closed session — celebratory green banner if items done, Chad/Joelle cards with progress bars. Import flow removed from Welcome (roll-forward lives in Prep Mode). |
| 2026-04-22 | Animated CheckBox component shipped | Custom 3-layer animation: SVG spring-pop box (`cb-pop`), checkmark stroke draw (`cb-draw`), Cadence-palette particle burst (`cb-burst`). Applied to mobile OurLists, desktop OurLists, and floating bubble. Only fires on check, not on load or uncheck. |

---

## 🔜 Open Questions (Decide Before Acting)

| Question | Context |
|---|---|
| Phase 2 real-time scope | Todos only first (lowest risk, highest value)? Or add priorities + notes to the same subscription? Narrow scope is safer — can expand if stable. |
| Action items tab | Chad's April 20 idea: a dedicated place for "upcoming budget considerations" (holidays, debt payoffs, seasonal spending). Is this Phase 2? A new screen? An enhancement to Upcoming Changes? |
| Any features before real-time? | Session history stub, Edit Mode, or action items tab — should any of these come before real-time subscriptions or run in parallel? |

---

## 💡 Parking Lot (Future)

| Idea | Notes |
|---|---|
| **Real-time sync (Phase 2)** | **Active — scope decision is next session's first task.** Supabase `postgres_changes` channel on todos table; expand to priorities + notes if stable. Scope question is open (see above). |
| Action items / upcoming budget tab | Chad's April 20 idea. A place for forward-looking budget considerations — holidays, debt payoffs, big upcoming expenses. Could be a new screen, an enhancement to Upcoming Changes, or a new tab in Our Lists. Worth scoping in Phase 2 brainstorm. |
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

**[2026-04-22]** — Build tracker added. `cadence-tracker.html` created as a founding doc — walnut/amber/wheat visual priority board with machine-readable JSON block feeding cross-project dashboard. CLAUDE.md updated with tracker check in Session Protocol and tracker maintenance rule. Initial top-3: (1) merge feature branch, (2) Phase 2 real-time sync, (3) session history UI. Todo/note editing with due dates, Last Session screen, and animated CheckBox component shipped on current feature branch.

**[2026-04-22]** — PWA mobile hardening. Fixed blank screen in Safari standalone mode: Supabase CDN switched from `cdn.jsdelivr.net` to `unpkg.com`; `sb` creation now uses optional chaining so a blocked CDN no longer crashes the script; all `db` methods guard against `sb = null`. Added 8-second fallback so `db.init()` timeout doesn't leave app frozen. Fixed Our Lists home button to use `onGoHome` prop (was setting hash directly — unreliable in standalone). Tab bar counts removed from tab pills so all 4 tabs fit on any iPhone. `site.webmanifest` `start_url` changed to `/#lists` so Joelle's home-screen icon launches directly to lists.

**[2026-04-21]** — Phase 1 hardened. 5 red-team fixes shipped and merged to main: PrepMode Last Session tab now re-fetches todos on mount; Save button has double-click guard (saving state + try/catch); all fire-and-forget db writes log errors; `addTodo`/`addNote` show inline "Failed to save" on failure; `saveUpcomingNote` debounced 400ms; FloatingBubble shows "Syncing…" instead of stale count while loading on open.

**[2026-04-21]** — Hash routing added. Every screen directly linkable via `/#screen-id`. `/#lists` is Joelle's bookmark for Our Lists. Import flow confirmed accepting plain `--- Chad ---` / `[ ]` text format — April 20 session successfully rolled forward.

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
