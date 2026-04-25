-- =============================================================
-- MIGRATION — Bài tập 7.3: Storage cho ảnh bài viết
-- =============================================================
-- Tạo bucket 'post-images' (public) và policies cho phép user upload
-- ảnh vào folder mang chính user.id của họ.
--
-- Chạy 1 lần trong Supabase SQL Editor.
-- =============================================================

-- 1) Tạo bucket public (nếu chưa có)
insert into storage.buckets (id, name, public)
values ('post-images', 'post-images', true)
on conflict (id) do nothing;

-- 2) Policies trên storage.objects cho bucket 'post-images'
--    Quy ước path: <user_id>/<filename>
drop policy if exists "Public can read post images" on storage.objects;
create policy "Public can read post images"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'post-images');

drop policy if exists "Authenticated users can upload to own folder" on storage.objects;
create policy "Authenticated users can upload to own folder"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'post-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "Users can update own files" on storage.objects;
create policy "Users can update own files"
on storage.objects for update
to authenticated
using (
  bucket_id = 'post-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists "Users can delete own files" on storage.objects;
create policy "Users can delete own files"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'post-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);
