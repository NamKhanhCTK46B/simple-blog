-- =============================================================
-- MIGRATION — Bài tập 7.2: Tính năng Like
-- =============================================================
-- Chạy 1 lần trong Supabase SQL Editor sau khi schema cơ bản đã có.
-- =============================================================

create table if not exists public.likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (post_id, user_id)
);

comment on table public.likes is 'Likes trên bài viết';

create index if not exists likes_post_id_idx on public.likes(post_id);
create index if not exists likes_user_id_idx on public.likes(user_id);

alter table public.likes enable row level security;

-- Policy: Ai cũng đọc được số lượng likes
drop policy if exists "Likes are viewable by everyone" on public.likes;
create policy "Likes are viewable by everyone"
on public.likes for select
to anon, authenticated
using (true);

-- Policy: User đã đăng nhập tự like bằng chính user_id của mình
drop policy if exists "Users can like posts" on public.likes;
create policy "Users can like posts"
on public.likes for insert
to authenticated
with check ((select auth.uid()) = user_id);

-- Policy: User chỉ unlike like của chính mình
drop policy if exists "Users can unlike their own likes" on public.likes;
create policy "Users can unlike their own likes"
on public.likes for delete
to authenticated
using ((select auth.uid()) = user_id);
