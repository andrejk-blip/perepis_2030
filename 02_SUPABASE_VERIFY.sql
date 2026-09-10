-- Перепись: Большая экспедиция — v14.9
-- ШАГ 2. Проверка после миграции. Ничего не изменяет.

-- A. Рейтинг: SECURITY DEFINER должен быть true, если функция не содержала явного auth.uid().
select
  p.oid::regprocedure as function_signature,
  p.prosecdef as security_definer,
  case when pg_get_functiondef(p.oid) ~* 'auth[.]uid\s*\(' then 'ATTENTION: explicit auth.uid()' else 'OK: no explicit auth.uid()' end as uid_filter_check
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.prokind='f'
  and p.proname in ('census_leaderboard','census_region_leaderboard')
order by p.proname, p.oid::regprocedure::text;

-- B. Обратная связь.
select
  to_regclass('public.census_feedback') as feedback_table,
  to_regprocedure('public.census_submit_feedback(jsonb)') as feedback_rpc;

-- C. Bucket должен быть private (public=false).
select id, public, file_size_limit, allowed_mime_types
from storage.buckets where id='census-feedback';

-- D. У игроков должна быть только политика INSERT в собственную папку.
select policyname, cmd, roles, with_check
from pg_policies
where schemaname='storage' and tablename='objects'
  and policyname='census_feedback_upload_own';

-- E. Последние обращения (видно владельцу проекта в SQL Editor).
select id, created_at, nickname, region_name, kind, status,
       left(message,180) as message_preview, screenshot_path
from public.census_feedback
order by id desc
limit 20;
