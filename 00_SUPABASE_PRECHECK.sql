-- Перепись: Большая экспедиция — v14.9
-- ШАГ 0. Только диагностика. Ничего не изменяет.

-- A. Какие RPC рейтинга существуют и как они исполняются.
select
  p.oid::regprocedure as function_signature,
  p.prosecdef as security_definer,
  pg_get_userbyid(p.proowner) as owner,
  pg_get_functiondef(p.oid) as definition
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.prokind='f'
  and p.proname in ('census_leaderboard','census_region_leaderboard')
order by p.proname, p.oid::regprocedure::text;

-- B. Есть ли таблица обратной связи.
select to_regclass('public.census_feedback') as feedback_table;

-- C. Есть ли закрытый bucket для скриншотов.
select id, name, public, file_size_limit, allowed_mime_types
from storage.buckets
where id='census-feedback';

-- D. Политики Storage для этого bucket.
select policyname, cmd, roles, qual, with_check
from pg_policies
where schemaname='storage' and tablename='objects'
  and (coalesce(qual,'') ilike '%census-feedback%' or coalesce(with_check,'') ilike '%census-feedback%');
