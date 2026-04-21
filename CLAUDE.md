# CLAUDE.md — Project Constitution
## Cadence · Stewart Family Finance & Lists App

> *"Ordo ab chao." Financial health comes from rhythm and repetition, not one-time fixes.*
> *"Measure twice, cut once." Propose before building. Wait for approval before acting.*

---

## 🧠 Session Protocol

**Read first:** Always check `DECISIONS.md` before touching any code. It is the ground truth for current state, open questions, and what's decided.

**Propose before you build:** For any change involving more than one area of the app, or any new feature, write a short plan and wait for explicit approval (`y`, `go`, or `looks good`) before writing code. No exceptions.

**Ask before assuming:** If a request contradicts something in DECISIONS.md, surface it. "Are we pivoting?" is always the right question.

**Token discipline:** Do not read files speculatively. Ask for the specific file if unsure. The app is ~1,900 lines — don't load it unless the task requires it.

---

## 🎯 North Star

**Cadence** is a personal finance and shared family lists app for Chad and Joelle Stewart. It replaces spreadsheet-based budget reviews with a structured, interactive "Money Date" — a regular session where they review finances together, set priorities, track todos, and build on previous sessions.

**The name reflects the philosophy:** financial health comes from rhythm and repetition, not one-time fixes.

**The design ethos:** *Ordo ab chao* — taking messy real-world finances and making them feel manageable, even enjoyable. Warm but honest. We language ("we're in surplus"). Anti-anxiety. Designed for two.

**Success in v1 (current):** Chad and Joelle can run a Money Date session on any device, check off todos, review their financial picture, and pick up where they left off next time.

**Success in v2 (next):** Real-time sync via Supabase so both see changes live across devices without refresh.

---

## 🛠 Tech Stack

| Layer | Choice | Rationale |
|---|---|---|
| **Frontend** | React 18 + Babel CDN | No build step. Component model without npm. Ships as a single HTML file. |
| **Styling** | CSS-in-JS / inline styles within React | Collocated with components, no stylesheet to maintain. |
| **State** | `localStorage` (current) → Supabase (next) | Shipped fast on localStorage. Migration to Supabase adds cross-device sync. |
| **Database** | Supabase (PostgreSQL) | Schema already written (`SUPABASE_SCHEMA.sql`). Phase 1: replace localStorage calls. |
| **Hosting** | Cloudflare Pages | Auto-deploys on GitHub push. Zero config. |
| **Version control** | GitHub | Repo: `Driver-cyber/cadence` (or similar) |
| **Build process** | None (current) | Static HTML. A minimal build step may be added for Supabase env injection. |

**Non-negotiables:**
- No auth. Family-only app. Shared access is the point.
- `family_id = 'stewarts'` scopes all Supabase data.
- Single HTML file architecture is preserved until a build step is explicitly decided.
- React + Babel CDN — do not introduce a bundler without a conversation first.

---

## 📁 File Structure

```
/
├── Cadence.html           # The entire app — React components, styles, logic
├── SUPABASE_SCHEMA.sql    # Ready-to-run schema (already written)
├── HANDOFF.md             # Project history and context (do not edit programmatically)
├── CLAUDE.md              # This file
├── DECISIONS.md           # Living decision log
└── README.md              # (to be created)
```

---

## 🗺 App Structure

### Main Screens (nav order)
1. **Welcome / Home** — Session start, import last session, prep next session
2. **Big Picture** — Account balances, net cash position, debt overview
3. **Cash Flow** — Income breakdown, fixed bills, monthly surplus/deficit
4. **Spending** — Variable spending by category with interactive sliders (what-if calculator)
5. **Debt** — Credit card payoff simulator with timeline projections
6. **Goals** — Savings goals with progress bars and contribution simulator
7. **Big Decisions** — 5 major life topics with data panels and discussion prompts
8. **Upcoming Changes** — Smart auto-generated bulletins + 5 editable reminder notes
9. **Our Lists** — Shared family todo list (mobile-optimized), 4 tabs: Chad / Joelle / All / Goals & Notes

### Floating Bubble (✅)
- Accessible from every screen via persistent button
- 3 tabs: Chad todos / Joelle todos / Goals & Notes
- Export button copies full session as formatted text
- Syncs same data source as Our Lists screen

### Prep Mode (🔧)
- Accessed from Home screen, separate from session flow
- 5 tabs: Balances / Income / Bills / Last Session / Upcoming Notes
- Edits live data used by all main screens
- Last Session tab: mark todos done, roll incomplete forward
- Save & Apply writes to storage and reloads with fresh data

### Import Flow
- Paste previous session export text on Welcome screen
- Parses todo completion status
- Shows per-person recap with progress bars
- Option to roll incomplete items forward

---

## 🗃 Data Architecture

### Budget Data Pattern
`DEFAULT_D` is baked into the source — it contains the full financial picture as of the last Prep Mode save. Prep Mode writes a partial override to storage (`moneydate_data`). On load, `DEFAULT_D` is merged with stored overrides to produce the live `D` object.

### Item Schema (todos)
```js
{ text: String, done: Boolean, id: Number /* Date.now() */ }
```

### Current localStorage Keys
```
moneydate_screen          → current screen index (integer)
moneydate_data            → overrides for D object (JSON)
moneydate_list            → { chad: TodoItem[], joelle: TodoItem[] }
moneydate_priorities      → string[3] — shared monthly priorities
moneydate_notes_list      → NoteItem[] — session notes
moneydate_upcoming_notes  → string[5] — reminder board notes
```

### Supabase Target Tables
`sessions`, `todos`, `priorities`, `notes`, `upcoming_notes`, `budget_data`
Full schema in `SUPABASE_SCHEMA.sql`. RLS is permissive (anon key, family_id scoped). Real-time enabled on todos, priorities, notes, upcoming_notes.

---

## 🔜 Module Status

| Module | Status | Notes |
|---|---|---|
| Welcome / Home screen | ✅ | Session start, import, prep access |
| Big Picture screen | ✅ | Accounts, net cash, debt |
| Cash Flow screen | ✅ | Income, bills, surplus/deficit |
| Spending screen | ✅ | Category sliders, what-if calculator |
| Debt screen | ✅ | CC payoff simulator |
| Goals screen | ✅ | Savings goals, contribution sim |
| Big Decisions screen | ✅ | 5 life topics with data panels |
| Upcoming Changes screen | ✅ | Smart bulletins + 5 editable notes |
| Our Lists screen | ✅ | 4-tab family todo list, mobile-optimized |
| Floating Bubble | ✅ | Persistent, synced, export |
| Prep Mode | ✅ | 5-tab data editor, save & apply |
| Import Flow | ✅ | Paste export, recap, roll forward |
| Supabase client setup | 🔜 | Replace localStorage — Phase 1 |
| Real-time todo sync | 🔜 | Subscribe to todos table — Phase 2 |
| Build step (env injection) | 🔜 | For Supabase keys via Cloudflare Pages |
| Edit Mode (in-session) | 🔜 | Edit data during session, not just Prep Mode |
| Session history | 🔜 | Store + view past sessions |
| Bank CSV import | 🔜 | Auto-categorize spending from bank export |
| Multi-month tracking | 🔜 | Trend spending data across sessions |

---

## 🎨 Design Language

**Vibe:** Warm but honest. Anti-anxiety. We language. Designed for two.

**Color palette:**
| Token | Hex | Use |
|---|---|---|
| Cream | `#FAF7F2` | Background |
| Ink | `#1C1C1E` | Primary text |
| Green | `#2A8B68` | Positive, surplus, done |
| Coral | `#D4544A` | Deficit, debt, alert |
| Amber | `#C07A12` | Caution, mid-state |
| Purple | `#6B5EA8` | Goals, aspirational |
| Border | `#E8E3DB` | Cards, dividers |
| Muted | `#6B6B70` | Secondary text |

**Typography:**
- `Outfit` — UI, body, numbers (weights 300–800)
- `Playfair Display` — Section headings, serif moments (weight 600–700, italic variant)

**Principles:**
- Data presented to feel manageable, not overwhelming
- No red alerts without a green path forward shown alongside
- Mobile-first for Our Lists (Joelle uses on iPhone); desktop-first for budget screens (Money Date sessions)

---

## 🚫 Explicitly Out of Scope (Current)

| Feature | Reason | Revisit |
|---|---|---|
| Multi-family / multi-user auth | Family-only app, shared URL is the point | Future |
| Native mobile app | PWA-style web app is sufficient | Future |
| Third-party bank connections (Plaid etc.) | Complexity and cost. CSV import is the right v1 bridge | Post-session-history |
| Public-facing product | This is a private family tool | Never (unless pivoted) |

---

## 🔧 Maintenance Protocol

- After any significant feature: Claude asks "Should I update DECISIONS.md?"
- Session start: read DECISIONS.md first, no exceptions.
- Multi-area change: propose a plan, wait for `y` or `go`.
- Financial data changes: always go through Prep Mode pattern, never hardcode without noting in DECISIONS.md.
- Supabase migration: do not touch localStorage keys without updating both the migration plan in DECISIONS.md and the schema in SUPABASE_SCHEMA.sql.
