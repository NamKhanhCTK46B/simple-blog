-- =============================================================
-- ENABLE REALTIME — Phần 6 (Bonus): Comments & Realtime
-- =============================================================
-- File này KHÔNG bắt buộc nếu bạn đã:
--   1) Chạy đầy đủ RLS policies cho comments ở mục 3.5;
--   2) Bật Realtime cho table comments qua Dashboard:
--      Database → Replication → tick `comments`.
--
-- Nếu chưa thì copy toàn bộ file này, paste vào SQL Editor và Run.
-- Idempotent — chạy nhiều lần vẫn an toàn.
-- =============================================================

-- ---------- Phần 1: RLS policies cho comments (mục 3.5) ----------

alter table public.comments enable row level security;

drop policy if exists "Comments on published posts are viewable" on public.comments;
create policy "Comments on published posts are viewable"
on public.comments for select
to anon, authenticated
using (
  exists (
    select 1 from public.posts
     where posts.id = comments.post_id
       and posts.status = 'published'
  )
);

drop policy if exists "Authenticated users can create comments" on public.comments;
create policy "Authenticated users can create comments"
on public.comments for insert
to authenticated
with check ((select auth.uid()) = author_id);

drop policy if exists "Users can delete their own comments" on public.comments;
create policy "Users can delete their own comments"
on public.comments for delete
to authenticated
using ((select auth.uid()) = author_id);


-- ---------- Phần 2: Bật Realtime cho comments (Phần 6.4) ----------

-- Replica identity FULL để payload realtime kèm cả các cột cũ khi UPDATE/DELETE
alter table public.comments replica identity full;

-- Thêm comments vào publication 'supabase_realtime' mà Realtime engine lắng nghe.
-- Bọc trong DO block để tránh lỗi "relation is already member of publication".
do $$
begin
  alter publication supabase_realtime add table public.comments;
exception
  when duplicate_object then
    raise notice 'Table public.comments đã có trong publication supabase_realtime, bỏ qua.';
end $$;

-- Verify: kỳ vọng trả về 1 dòng
select schemaname, tablename
  from pg_publication_tables
 where pubname = 'supabase_realtime'
   and tablename = 'comments';
