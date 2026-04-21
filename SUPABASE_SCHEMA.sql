-- ============================================================
-- CADENCE — Supabase Schema
-- Run this in the Supabase SQL editor to set up all tables.
-- Family app: no auth, single family scoped by family_id.
-- ============================================================

-- Enable UUID generation
create extension if not exists "pgcrypto";

-- ============================================================
-- SESSIONS
-- One row per money date session.
-- ============================================================
create table sessions (
  id          uuid primary key default gen_random_uuid(),
  family_id   text not null default 'stewarts',
  session_date date not null default current_date,
  label       text,                        -- e.g. "April 2026 Money Date"
  created_at  timestamptz default now(),
  completed_at timestamptz                 -- null = in progress
);

-- ============================================================
-- TODOS
-- Chad and Joelle's per-session to-do items.
-- ============================================================
create table todos (
  id          uuid primary key default gen_random_uuid(),
  family_id   text not null default 'stewarts',
  session_id  uuid references sessions(id) on delete cascade,
  person      text not null check (person in ('chad', 'joelle')),
  text        text not null,
  done        boolean not null default false,
  sort_order  int not null default 0,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- ============================================================
-- PRIORITIES
-- The 3 shared monthly priority statements.
-- ============================================================
create table priorities (
  id          uuid primary key default gen_random_uuid(),
  family_id   text not null default 'stewarts',
  session_id  uuid references sessions(id) on delete cascade,
  slot        int not null check (slot in (1, 2, 3)),
  text        text not null default '',
  updated_at  timestamptz default now(),
  unique (session_id, slot)
);

-- ============================================================
-- NOTES
-- Free-form session notes (tangents, thoughts, reminders).
-- ============================================================
create table notes (
  id          uuid primary key default gen_random_uuid(),
  family_id   text not null default 'stewarts',
  session_id  uuid references sessions(id) on delete cascade,
  text        text not null,
  sort_order  int not null default 0,
  created_at  timestamptz default now()
);

-- ============================================================
-- UPCOMING_NOTES
-- The 5 editable reminder notes on the Upcoming Changes screen.
-- Not tied to a session — persists across sessions.
-- ============================================================
create table upcoming_notes (
  id          uuid primary key default gen_random_uuid(),
  family_id   text not null default 'stewarts',
  slot        int not null check (slot between 1 and 5),
  text        text not null default '',
  updated_at  timestamptz default now(),
  unique (family_id, slot)
);

-- Seed 5 empty slots
insert into upcoming_notes (family_id, slot, text) values
  ('stewarts', 1, ''),
  ('stewarts', 2, ''),
  ('stewarts', 3, ''),
  ('stewarts', 4, ''),
  ('stewarts', 5, '');

-- ============================================================
-- BUDGET_DATA
-- Single-row JSON blob for the live financial data (D object).
-- Updated by Prep Mode. One row per family, updated in place.
-- ============================================================
create table budget_data (
  id          uuid primary key default gen_random_uuid(),
  family_id   text not null unique default 'stewarts',
  data        jsonb not null default '{}',
  updated_at  timestamptz default now(),
  updated_by  text default 'chad'          -- who last ran Prep Mode
);

-- Seed with empty override (app uses DEFAULT_D when data = {})
insert into budget_data (family_id, data) values ('stewarts', '{}');

-- ============================================================
-- ROW LEVEL SECURITY
-- Permissive for now (family app, no individual auth).
-- Everyone with the anon key can read/write stewarts data.
-- Tighten later if you add login.
-- ============================================================
alter table sessions       enable row level security;
alter table todos          enable row level security;
alter table priorities     enable row level security;
alter table notes          enable row level security;
alter table upcoming_notes enable row level security;
alter table budget_data    enable row level security;

-- Allow all operations for anon key (family-only app)
create policy "Family access" on sessions       for all using (family_id = 'stewarts') with check (family_id = 'stewarts');
create policy "Family access" on todos          for all using (family_id = 'stewarts') with check (family_id = 'stewarts');
create policy "Family access" on priorities     for all using (family_id = 'stewarts') with check (family_id = 'stewarts');
create policy "Family access" on notes          for all using (family_id = 'stewarts') with check (family_id = 'stewarts');
create policy "Family access" on upcoming_notes for all using (family_id = 'stewarts') with check (family_id = 'stewarts');
create policy "Family access" on budget_data    for all using (family_id = 'stewarts') with check (family_id = 'stewarts');

-- ============================================================
-- REAL-TIME
-- Enable real-time for the tables Cadence subscribes to.
-- ============================================================
alter publication supabase_realtime add table todos;
alter publication supabase_realtime add table priorities;
alter publication supabase_realtime add table notes;
alter publication supabase_realtime add table upcoming_notes;

-- ============================================================
-- HELPFUL VIEWS
-- ============================================================

-- Latest session with todo counts
create view latest_session_summary as
select
  s.id,
  s.session_date,
  s.label,
  s.completed_at,
  count(t.id) filter (where t.person = 'chad') as chad_total,
  count(t.id) filter (where t.person = 'chad' and t.done) as chad_done,
  count(t.id) filter (where t.person = 'joelle') as joelle_total,
  count(t.id) filter (where t.person = 'joelle' and t.done) as joelle_done
from sessions s
left join todos t on t.session_id = s.id
where s.family_id = 'stewarts'
group by s.id
order by s.session_date desc
limit 1;

-- ============================================================
-- INTEGRATION NOTES FOR CLAUDE CODE
-- ============================================================
-- 1. Install: npm install @supabase/supabase-js
--    OR for the static HTML version, add to <head>:
--    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
--
-- 2. Initialize:
--    const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
--
-- 3. Replace localStorage pattern. Example for todos:
--
--    // OLD (localStorage):
--    const items = JSON.parse(localStorage.getItem('moneydate_list') || '{"chad":[],"joelle":[]}')
--    localStorage.setItem('moneydate_list', JSON.stringify(items))
--
--    // NEW (Supabase):
--    const { data } = await supabase
--      .from('todos')
--      .select('*')
--      .eq('session_id', currentSessionId)
--      .order('sort_order')
--
--    await supabase.from('todos').upsert({ ...todo, session_id: currentSessionId })
--
-- 4. Real-time subscription example:
--    supabase.channel('todos')
--      .on('postgres_changes', { event: '*', schema: 'public', table: 'todos' }, payload => {
--        // update React state here
--      })
--      .subscribe()
--
-- 5. On app load: find or create today's session:
--    let { data: session } = await supabase
--      .from('sessions')
--      .select()
--      .eq('family_id', 'stewarts')
--      .is('completed_at', null)
--      .order('created_at', { ascending: false })
--      .limit(1)
--      .single()
--
--    if (!session) {
--      const { data } = await supabase.from('sessions').insert({
--        family_id: 'stewarts',
--        session_date: new Date().toISOString().split('T')[0]
--      }).select().single()
--      session = data
--    }
