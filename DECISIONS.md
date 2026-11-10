# DECISIONS.md — Living Decision Log
## Cadence · Stewart Family Finance & Lists App

> **Note to Claude:** This file is the "current vibe." Always read it at session start.
> Decided = move forward. Open = ask before acting. Parked = don't touch yet.

---

## 🎯 Current State

**App status:** **Cash-flow pivot in progress (Session 7).** Chad lost his job and had been budgeting in a Google Sheet — a **within-month running-balance forecast** on Billing (0970), which Cadence never modeled. Transforming Cadence to match.
- **Phase A — DEPLOYED (PR #24, merged):** new **"This Month"** screen walks Billing forward through paychecks/bills/weekly grocery transfers, shows the **low point / overdraft risk** + a **float suggestion**. Data re-seeded to **November 2026**. Prep Mode extended (bill day-of-month, income day + allocate, weekly grocery transfer, new accounts incl. HELOC).
- **Phase B — shipped to branch** `claude/cadence-claude-export-feature-5bxn1a` (restarted from fresh main): the **Goals** screen is now **Goals & Progress** — shows the **monthly surplus** and how much is allocated this month, lets them **log contributions** to goals (with quick +100/+250/+500 chips, undo, celebrate toast), tracks **progress bars + % + recent-activity log**, and supports add/edit/delete goals. Goal + contribution history persist in `budget_data` (no schema change); Prep Mode `handleSave` now preserves `goals`.

**Current phase:** Session 7. Priority stack (per Chad): **#1 coverage** ✅ (This Month), **#2 surplus → goals + progress** ✅ (Goals & Progress, on branch), **#3 recurring-bills tracker** (next). Prep/update flow is the center of gravity; old "present mode" screens kept but deprioritized (stale April narrative over Nov numbers — prose/remodel pass later).

**Immediate next task:** (1) Review/merge the Phase B PR to deploy Goals & Progress. (2) Chad (Supabase un-paused) → Prep Mode: set real first-paycheck date/amount + balances → Save & Apply; sanity-check This Month + Goals on the live site. (3) Phase C: recurring-bills tracker (re-examine fixed bills, cut/switch payment method). (4) Later: refresh/retire old present-mode screens.

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
| 2026-04-28 | Our Lists mobile: removed `position:fixed` | Was covering App nav/footer with a fixed overlay — architecturally wrong. App shell now hides nav/footer for `S.id === 'ourlist'` (same as Home), component renders in normal flow with `height: 100dvh`. |
| 2026-04-28 | iOS Safari blank screen: `webkitTransform` repaint hack | After every screen change (`idx` update), a one-frame `webkitTransform: translateZ(0)` on the scroll container flushes the GPU compositor layer. Prevents blank screen without remounting components (remounting caused state loss in Our Lists). `key={S.id}` approach was tried and reverted. |
| 2026-04-28 | Pull-to-refresh via `PullToRefresh` component | Wraps content area. Detects downward swipe from `scrollTop=0` via non-passive `touchmove`. Shows `↓` indicator, flips to `↑` at 72px threshold, reloads on release. Gives PWA users a reliable re-sync without a hard refresh. |
| 2026-04-28 | `shipped[]` array added to tracker `columns[0]` | 13 items newest-first, each with `date`, `what`, `tags`, and optional `learned`. Feeds the Galaxy tab in the cross-project dashboard at project-dashboard-6a7.pages.dev. |
| 2026-05-05 | Prep Mode Bills tab split into Fixed + Variable | Bills was a single lump-sum input. Now two full tabs: Fixed (editable bill list, auto-summed) and Variable (editable category list). Up/down reorder, delete, and add on both. |
| 2026-05-05 | `fixedBillsList` seeded with 23 recurring bills | $4,542/mo total from original spreadsheet Monthly Cost column. Stored in `DEFAULT_D.fixedBillsList` and Supabase `budget_data`. Each bill has `name`, `amount`, `note`. |
| 2026-05-05 | `mergeD` date override bug fixed | `mergeD` was always overriding `saved.date` with `DEFAULT_D.date` — causing the home-screen date to be stuck on "April 20, 2026" even after editing. Removed the forced override. |
| 2026-05-05 | Session date input added to Balances tab in Prep Mode | `<input type="date">` at top of Balances tab. Saves to `D.date`, which Welcome screen displays. Defaults to the currently saved date. |
| 2026-05-05 | `EditableRow` helper component — shared card UI for both Prep Mode lists | Name + note (both editable text inputs) + amount input + ▲▼ reorder + × delete. Used in both Fixed and Variable tabs to keep patterns consistent. |
| 2026-06-26 | "Export for Claude" button added to floating bubble | Second export action (purple, above the existing "Export session"). Copies a pre-written framing prompt + a JSON snapshot of live `D` (income, fixed/variable, accounts, debt, goals, action items) plus todos/priorities/notes. Format chosen: prompt + JSON. Placement chosen: floating bubble only. Lets Chad/Joelle hand their Money Date data to a Claude chat. Existing "Export session" (lists only) unchanged. |
| 2026-11-10 | **Pivot: cash-flow timeline is the new center of gravity** | Chad's lived budgeting (Google Sheet) is a within-month running-balance forecast on Billing (0970), not a static monthly snapshot. The app's #1 job is now "will Billing cover the bills, or do we float?". Confirmed with Chad: timeline first · main-checking only · revive Supabase. Old money-date "present mode" kept but deprioritized. |
| 2026-11-10 | New "This Month" screen + `buildFlow` engine | Screen 1 walks Billing day-by-day (income +, bills −, weekly grocery −), worst-case intra-day ordering, surfaces low point + float suggestion. HELOC/multi-account stays a glance for now (main-checking-first per Chad). |
| 2026-11-10 | Remodel is additive, not a rewrite | New fields (`cycle`, `grocery`, `day`/`paused` on bills, `day`/`allocate` on income, new accounts) added alongside existing `D` fields so legacy screens keep running. Data re-seeded to Nov 2026. Prose refresh of old screens deferred. |
| 2026-11-10 | Bills carry `day`; `paused`/`day:null` excluded from the walk | Timing is what drives overdraft. Paused items (therapy, audiobooks) stay listed + counted in the fixed total but don't debit the forecast. |
| 2026-11-10 | Phase B: Goals screen becomes a surplus→progress **tracker** | Replaces the old what-if slider sim. Shows monthly surplus, lets them log contributions, tracks progress + celebrates it. Chad's #2 priority. |
| 2026-11-10 | Goal contributions persist in `budget_data` (no new table) | Each goal gets a timestamped `contributions[]` log; `saved` is the running total. Avoids a Supabase schema migration. Prep Mode `handleSave` must pass through `goals` so it isn't wiped. |

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

*Snapshot as of **November 2026** (from Chad's working Google Sheet). Income is largely theoretical — first paycheck lands ~end of Nov.*

| Item | Value |
|---|---|
| Monthly income (expected) | ~$8,300 ($3,650 on 15th + $3,650 on 30th + ~$1,000 usable ADU rent) |
| Fixed bills | ~$5,082/mo (24 items, now with day-of-month) |
| Variable (weekly grocery transfer) | $510/wk into the grocery account |
| Billing (0970) starting balance | $27 |
| E-Save (emergency) | $2,694.54 |
| Baselane | $4,030 |
| OP Fun Savings | $977 |
| CC debt (Sapphire $298 · Ink $218 · Apple $42) | ~$557 |
| HELOC | ~$38,899 ($600/mo payment) |

**Key reality:** On paper the month roughly nets out, but **bills clear before the paychecks land**, so Billing goes underwater mid/late month — the exact "good on paper, no money in the bank" problem. The new "This Month" screen makes that timing visible and suggests a float.

**Known changes / notes:**
- Chad lost his job; income is the biggest unknown — update real paycheck date/amount in Prep Mode.
- Therapy (Jaclin) and Audiobooks.com are paused — marked `paused`, excluded from the walk.
- Home-project goals from the sheet: Kitchen remodel (~$15.1k), Roof (~$20k), Car fund, Emergency fund.

---

## 📝 Change Log

**[2026-11-10]** — Session 7, **Phase B: Goals & Progress** (shipped to branch). The old slider-simulator `Goals` screen is replaced (SCREENS `goals` → `GoalsProgress`; old `Goals` left defined but unused). New screen: a **monthly-surplus** hero (income − fixed − variable = D.deficit, +$1,010/mo on the Nov plan) with "allocated this month" + "still free to allocate"; an **overall progress** bar across all goals; per-goal cards with a **contribution input** (+100/+250/+500 quick chips, Enter to add, **undo last**), progress bar/%/remaining, contribution count; **add / edit (icon, name, target) / delete** goals; a **celebrate toast** on each contribution and a 🎉 reached state; and a **recent-progress** activity log. Persistence: goals + `contributions[]` (timestamped) live in `budget_data` JSON — no schema change; `GoalsProgress.persist()` re-saves the full budget blob, and Prep Mode `handleSave` now includes `goals: D.goals` so a Save & Apply can't wipe progress. Verified: full Babel compile clean. Phase A (PR #24) is merged/deployed. PR for Phase B not yet opened.

**[2026-11-10]** — Session 7, **the cash-flow pivot (Phase A)**. Context: Chad lost his job and had moved off Cadence to a Google Sheet that models a **within-month running-balance forecast** on the Billing (0970) checking account — the thing Cadence never did. Agreed direction (approved): cash-flow timeline first · main-checking only · revive Supabase. Shipped to branch (restarted from fresh main after #23 merged):
- **New "This Month" screen** (SCREENS index 1, id `flow`, `CashFlowTimeline`). Pure engine `buildFlow(D, asOfDay)` walks the Billing balance from today through month-end, applying income (+), fixed bills (−) and weekly grocery transfers (−), outflows-before-income within a day (worst case). Surfaces the **low point / overdraft risk**, a **float suggestion** (largest positive savings account), tiles (billing now, income left, bills due, grocery left, projected end), a hand-rolled **SVG balance chart** with a danger zone below zero, the full **event walk**, and a quick debt glance (CC + HELOC). Verified: compiles via Babel; engine math checked in isolation (at day 10 → low −$1,754, end +$1,896).
- **Data re-seeded to November 2026** in `DEFAULT_D`: real accounts (Billing, Grosh, E-Save, Baselane, OP Fun, Personal Clearing, Prop-tax), CC (Sapphire/Ink/Apple), HELOC ~$38.9k; 24 fixed bills **with `day` + `paused`**; income as 15th/30th paychecks ($3,650) + ADU rent ($1,000, `allocate`); `grocery.weekly` $510; new `cycle` field. Additive — old fields kept so legacy screens don't break.
- **Prep Mode extended:** bill day-of-month (optional field on `EditableRow`), income `day` + `allocate` toggle, weekly grocery-transfer input, new accounts (E-Save/Fun/Clearing/Apple/HELOC) on Balances, totals updated. `mergeD` + `handleSave` carry `grocery`/`cycle`.
- **Welcome copy** refreshed to point at "This Month" + Prep.
- **Known debt:** old present-mode screens (Big Picture, Cash Flow, Spending, Debt, Big Decisions, Upcoming) still carry April-era narrative text over the new numbers — a few lines read oddly (e.g. Sapphire-bonus card). Deprioritized per Chad; flagged for a later prose/remodel pass. PR not yet opened.

**[2026-06-26]** — Session 6. Added an **"Export for Claude"** button to the floating bubble (purple, above the existing "Export session"). It copies a ready-to-paste block: a warm framing prompt (introduces Chad & Joelle, frames the Money Date, asks the "looks fine on paper but the bank's empty" question, requests "we" language) followed by a full JSON snapshot of the live `D` object — monthly income/fixed/variable/net, all accounts, income sources with timing, the 23-bill list, variable spending categories (flagged adjustable), debt, goals, action items — plus current todos, priorities, and notes. New `shareForClaude` fn + `copiedAI` state in `FloatingBubble`. Existing `share` (lists only) untouched. Confirmed PR #21 already merged, so no tangle. On branch `claude/cadence-claude-export-feature-5bxn1a`; PR opened — merge to deploy.

**[2026-05-05]** — Session 5 close. Confirmed all session 4 PRs (#17–#20) merged to main. Prep Mode overhauled in PR #21: Bills tab split into Fixed and Variable; `fixedBillsList` seeded with 23 recurring bills from original spreadsheet ($4,542/mo); both lists support full editing (name, note, amount), up/down reorder, delete, and add via shared `EditableRow` component; session date input added to Balances tab; `mergeD` bug fixed where saved date was always overridden by DEFAULT_D.date. PR #21 open — next step is merge, then Chad runs Prep Mode to update balances and bill amounts before Money Date.

**[2026-04-28]** — Session 4 close. iOS Safari PWA navigation bugs fixed across PRs #17–19: removed `position:fixed` from Our Lists mobile layout (App shell now owns nav/footer); added `PullToRefresh` component with pull-to-refresh gesture (swipe 72px → reload); replaced `key={S.id}` remounting with `webkitTransform` repaint hack (no state loss, reliable GPU flush). `Welcome` screen updated to `minHeight: 100dvh` as defensive measure. Tracker `shipped[]` enriched: 13 items with dates, tags, and `learned` fields for Galaxy dashboard. PR #19 open — merge to deploy.

**[2026-04-23]** — Session 3 close. All session 2 work confirmed merged to `main` (PRs #13–15). Fixed `cadence-tracker.html` missing `columns` key for cross-project dashboard link. Tracker priorities rotated: "Merge branch" removed (done), Phase 2 scope decision is now #1, real-time sync is #2, session history is #3. DECISIONS.md updated to reflect clean `main` state and Phase 2 as the active next task.

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
