-- =============================================================
-- TEST RLS POLICIES — Bài thực hành 04, Phần 3
-- =============================================================
-- File này test tất cả policies đã tạo ở mục 3.3, 3.4, 3.5 + Bài tập 3.1.
--
-- UUID đã đồng bộ với dữ liệu trong các file CSV cùng thư mục:
--   profiles.csv : Lan, Minh
--   posts.csv    : 3 published + 1 draft
--   comments.csv : 3 comments
--
-- ID dùng trong test:
--   LAN_ID   = '8d2a964b-1ec5-4181-b2f6-130721e5f495'
--   MINH_ID  = 'd8cceca0-a953-42f1-b554-13053682950e'
--   POST1_ID = 'a23bfa18-09e2-42b8-94b6-da1ac94a5f9d'  -- "Bắt đầu với Next.js 15…"  (author: Lan,  status: published)
--   POST2_ID = 'fa18f4ed-dcbd-4b2d-8b5c-2accd5c47a7a'  -- "Supabase RLS…"             (author: Minh, status: published)
--   (Hai bài còn lại — Tailwind v4 published & "Bản nháp…" draft — đều của Minh.)
--
-- Cách dùng: Supabase Dashboard → SQL Editor → New query, copy từng block và Run.
-- Mỗi block bọc trong begin/rollback nên KHÔNG ghi dữ liệu thật.
--
-- Cách giả lập user:
--   set local role authenticated;
--   set local "request.jwt.claims" = '{"sub":"<UUID>","role":"authenticated"}';
--   → auth.uid() = <UUID>
-- Giả lập anon:
--   set local role anon;
--   reset "request.jwt.claims";
-- =============================================================


-- =============================================================
-- BLOCK 1 — profiles : ANON SELECT (Policy "Profiles are viewable by everyone")
-- Mong đợi: ≥ 2 dòng (Lan, Minh)
-- =============================================================
begin;
  set local role anon;
  reset "request.jwt.claims";

  select id, display_name
    from public.profiles
   order by display_name;            -- ✅ phải thấy Lan + Minh
rollback;


-- =============================================================
-- BLOCK 2 — profiles : ANON UPDATE bị CẤM
-- Mong đợi: 0 dòng bị update
-- =============================================================
begin;
  set local role anon;
  reset "request.jwt.claims";

  update public.profiles
     set display_name = 'HACKED'
   where id = '8d2a964b-1ec5-4181-b2f6-130721e5f495';

  select count(*) as hacked_rows
    from public.profiles
   where display_name = 'HACKED';   -- ✅ kỳ vọng 0
rollback;


-- =============================================================
-- BLOCK 3 — profiles : Lan UPDATE chính mình → OK
-- =============================================================
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"8d2a964b-1ec5-4181-b2f6-130721e5f495","role":"authenticated"}';

  update public.profiles
     set display_name = 'Nguyễn Thị Lan (đã sửa)'
   where id = '8d2a964b-1ec5-4181-b2f6-130721e5f495';

  select id, display_name
    from public.profiles
   where id = '8d2a964b-1ec5-4181-b2f6-130721e5f495';   -- ✅ tên mới
rollback;


-- =============================================================
-- BLOCK 4 — profiles : Lan UPDATE profile của Minh → 0 row
-- =============================================================
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"8d2a964b-1ec5-4181-b2f6-130721e5f495","role":"authenticated"}';

  update public.profiles
     set display_name = 'HACKED BY LAN'
   where id = 'd8cceca0-a953-42f1-b554-13053682950e';

  select display_name
    from public.profiles
   where id = 'd8cceca0-a953-42f1-b554-13053682950e';   -- ✅ vẫn 'Trần Văn Minh'
rollback;


-- =============================================================
-- BLOCK 5 — posts : ANON chỉ thấy bài 'published'
-- Mong đợi: 3 dòng published, KHÔNG có "Bản nháp — Deep dive vào React Server Components"
-- =============================================================
begin;
  set local role anon;
  reset "request.jwt.claims";

  select title, status
    from public.posts
   order by published_at nulls last;
rollback;


-- =============================================================
-- BLOCK 6 — posts : Author thấy cả draft của mình
-- Mong đợi:
--   • Lan  thấy: "Bắt đầu với Next.js 15…" (của mình) + 2 published của Minh
--          KHÔNG thấy "Bản nháp" (draft của Minh)
--   • Minh thấy: tất cả 3 bài của Minh (published + draft) + 1 published của Lan
-- =============================================================

-- 6a. Lan login
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"8d2a964b-1ec5-4181-b2f6-130721e5f495","role":"authenticated"}';

  select title, status, author_id
    from public.posts
   order by status desc, title;
   -- ✅ KHÔNG có "Bản nháp — Deep dive…"
rollback;

-- 6b. Minh login
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"d8cceca0-a953-42f1-b554-13053682950e","role":"authenticated"}';

  select title, status, author_id
    from public.posts
   order by status desc, title;
   -- ✅ CÓ "Bản nháp — Deep dive…" (vì là draft của Minh)
rollback;


-- =============================================================
-- BLOCK 7 — posts : ANON INSERT bị CẤM
-- =============================================================
begin;
  set local role anon;
  reset "request.jwt.claims";

  insert into public.posts (author_id, title, content, status)
  values ('8d2a964b-1ec5-4181-b2f6-130721e5f495',
          'Bài viết do anon tạo', 'Nội dung lén lút', 'published');
  -- ❌ ERROR: new row violates row-level security policy
rollback;


-- =============================================================
-- BLOCK 8 — posts : Lan INSERT bài cho chính mình → OK
-- =============================================================
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"8d2a964b-1ec5-4181-b2f6-130721e5f495","role":"authenticated"}';

  insert into public.posts (author_id, title, content, status)
  values ('8d2a964b-1ec5-4181-b2f6-130721e5f495',
          'Bài test RLS Insert', 'Hello', 'draft')
  returning id, title, status;       -- ✅ insert OK
rollback;


-- =============================================================
-- BLOCK 9 — posts : Lan INSERT mạo danh Minh → CẤM
-- =============================================================
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"8d2a964b-1ec5-4181-b2f6-130721e5f495","role":"authenticated"}';

  insert into public.posts (author_id, title, content, status)
  values ('d8cceca0-a953-42f1-b554-13053682950e',
          'Bài mạo danh Minh', 'X', 'draft');
  -- ❌ ERROR: violates RLS (with check (auth.uid() = author_id))
rollback;


-- =============================================================
-- BLOCK 10 — posts : Lan UPDATE bài của Lan → OK; UPDATE bài của Minh → 0 row
-- =============================================================
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"8d2a964b-1ec5-4181-b2f6-130721e5f495","role":"authenticated"}';

  -- Bài của Lan: id = a23bfa18… (Bắt đầu với Next.js 15)
  update public.posts
     set title = title || ' (Lan updated)'
   where id = 'a23bfa18-09e2-42b8-94b6-da1ac94a5f9d';

  -- Bài của Minh: id = fa18f4ed… (Supabase RLS)
  update public.posts
     set title = 'HACKED'
   where id = 'fa18f4ed-dcbd-4b2d-8b5c-2accd5c47a7a';

  select id, title, author_id
    from public.posts
   where id in ('a23bfa18-09e2-42b8-94b6-da1ac94a5f9d',
                'fa18f4ed-dcbd-4b2d-8b5c-2accd5c47a7a');
   -- ✅ Bài của Lan có hậu tố "(Lan updated)";
   --    Bài của Minh giữ nguyên "Supabase RLS — Bảo mật cấp độ database"
rollback;


-- =============================================================
-- BLOCK 11 — posts : Lan DELETE bài của Minh → 0 row
-- =============================================================
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"8d2a964b-1ec5-4181-b2f6-130721e5f495","role":"authenticated"}';

  delete from public.posts
   where author_id = 'd8cceca0-a953-42f1-b554-13053682950e';

  select count(*) as minh_posts_remaining
    from public.posts
   where author_id = 'd8cceca0-a953-42f1-b554-13053682950e';
  -- ✅ vẫn = 3 (1 draft + 2 published của Minh)
rollback;


-- =============================================================
-- BLOCK 12 — comments : ANON chỉ thấy comment trên bài 'published'
-- Mong đợi: cả 3 comment trong CSV đều thấy được (vì 2 post mẹ đều published)
-- =============================================================
begin;
  set local role anon;
  reset "request.jwt.claims";

  select c.content, p.title as post_title, p.status
    from public.comments c
    join public.posts p on p.id = c.post_id
   order by c.created_at;
   -- ✅ post.status luôn = 'published'
rollback;


-- =============================================================
-- BLOCK 13 — comments : ANON INSERT bị CẤM
-- =============================================================
begin;
  set local role anon;
  reset "request.jwt.claims";

  insert into public.comments (post_id, author_id, content)
  values ('a23bfa18-09e2-42b8-94b6-da1ac94a5f9d',
          '8d2a964b-1ec5-4181-b2f6-130721e5f495',
          'Spam!');
  -- ❌ ERROR: violates RLS
rollback;


-- =============================================================
-- BLOCK 14 — comments : Minh INSERT đúng author_id → OK; mạo danh Lan → CẤM
-- =============================================================

-- 14a. Minh comment với author_id = mình → OK
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"d8cceca0-a953-42f1-b554-13053682950e","role":"authenticated"}';

  insert into public.comments (post_id, author_id, content)
  values ('a23bfa18-09e2-42b8-94b6-da1ac94a5f9d',
          'd8cceca0-a953-42f1-b554-13053682950e',
          'Comment hợp lệ của Minh')
  returning id, content;            -- ✅ OK
rollback;

-- 14b. Minh mạo danh Lan → CẤM
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"d8cceca0-a953-42f1-b554-13053682950e","role":"authenticated"}';

  insert into public.comments (post_id, author_id, content)
  values ('a23bfa18-09e2-42b8-94b6-da1ac94a5f9d',
          '8d2a964b-1ec5-4181-b2f6-130721e5f495',
          'Comment mạo danh Lan');
  -- ❌ ERROR: violates RLS
rollback;


-- =============================================================
-- BLOCK 15 — comments : Minh DELETE comment của Lan → 0 row
-- (Trong comments.csv, Lan có 1 comment "Mình đã follow guide…")
-- =============================================================
begin;
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"d8cceca0-a953-42f1-b554-13053682950e","role":"authenticated"}';

  delete from public.comments
   where author_id = '8d2a964b-1ec5-4181-b2f6-130721e5f495';

  select count(*) as lan_comments_remaining
    from public.comments
   where author_id = '8d2a964b-1ec5-4181-b2f6-130721e5f495';
  -- ✅ phải = 1 (RLS chặn xóa)
rollback;


-- =============================================================
-- BLOCK 16 — Bài tập 3.1: Policy "Authors can view comments on their own posts (kể cả draft)"
-- =============================================================
-- ⚠ TRƯỚC khi chạy block test bên dưới, cần TẠO policy mới (chạy 1 LẦN, KHÔNG rollback):
--
--   create policy "Authors can view comments on their own posts"
--   on public.comments for select
--   to authenticated
--   using (
--     exists (
--       select 1 from public.posts
--        where posts.id = comments.post_id
--          and posts.author_id = (select auth.uid())
--     )
--   );
--
-- Trong CSV hiện tại, bài DRAFT ("Bản nháp — Deep dive vào React Server Components") thuộc về MINH.
-- Vậy: Lan comment vào bài draft của Minh → chỉ Minh được thấy comment này.
-- =============================================================
begin;
  -- 16.1 — Setup: lấy id bài draft của Minh + thêm 1 comment của Lan
  --        (chạy với role mặc định = postgres/owner để bỏ qua RLS lúc seed test)
  with draft_post as (
    select id from public.posts
     where status = 'draft'
       and author_id = 'd8cceca0-a953-42f1-b554-13053682950e'
     limit 1
  )
  insert into public.comments (post_id, author_id, content)
  select id,
         '8d2a964b-1ec5-4181-b2f6-130721e5f495',
         'Comment của Lan trên bài draft của Minh (test policy 3.1)'
    from draft_post
  returning id, post_id;

  -- 16.2 — ANON: KHÔNG được thấy (bài là draft)
  set local role anon;
  reset "request.jwt.claims";
  select count(*) as anon_sees_draft_comments
    from public.comments c
    join public.posts p on p.id = c.post_id
   where p.status = 'draft';                          -- ✅ kỳ vọng 0

  -- 16.3 — Lan (người comment, KHÔNG phải author bài): không thấy
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"8d2a964b-1ec5-4181-b2f6-130721e5f495","role":"authenticated"}';
  select count(*) as lan_sees_draft_comments
    from public.comments c
    join public.posts p on p.id = c.post_id
   where p.status = 'draft';                          -- ✅ kỳ vọng 0

  -- 16.4 — Minh (author bài draft): THẤY ĐƯỢC nhờ policy mới
  set local role authenticated;
  set local "request.jwt.claims" =
    '{"sub":"d8cceca0-a953-42f1-b554-13053682950e","role":"authenticated"}';
  select c.content
    from public.comments c
    join public.posts p on p.id = c.post_id
   where p.status = 'draft'
     and p.author_id = 'd8cceca0-a953-42f1-b554-13053682950e';
  -- ✅ trả về dòng comment "Comment của Lan trên bài draft của Minh…"
rollback;


-- =============================================================
-- TÓM TẮT KỲ VỌNG
-- =============================================================
-- BLOCK | Nội dung                                              | Kỳ vọng
-- ------+-------------------------------------------------------+--------------------
--   1   | anon SELECT profiles                                  | 2 dòng
--   2   | anon UPDATE profiles                                  | 0 row affected
--   3   | Lan UPDATE chính mình                                 | OK, tên đổi
--   4   | Lan UPDATE Minh                                       | 0 row affected
--   5   | anon SELECT posts                                     | chỉ 3 bài 'published'
--   6a  | Lan SELECT posts                                      | KHÔNG có "Bản nháp"
--   6b  | Minh SELECT posts                                     | CÓ "Bản nháp" (draft của mình)
--   7   | anon INSERT post                                      | ERROR violates RLS
--   8   | Lan INSERT post (author_id = Lan)                     | OK
--   9   | Lan INSERT post (author_id = Minh)                    | ERROR violates RLS
--  10   | Lan UPDATE bài của Lan/Minh                           | của Lan OK; của Minh 0 row
--  11   | Lan DELETE bài của Minh                               | 0 row affected
--  12   | anon SELECT comments                                  | thấy cả 3 (post mẹ published)
--  13   | anon INSERT comment                                   | ERROR violates RLS
--  14a  | Minh INSERT comment đúng author_id                    | OK
--  14b  | Minh INSERT comment mạo danh Lan                      | ERROR violates RLS
--  15   | Minh DELETE comment của Lan                           | 0 row affected
--  16   | Policy "author xem comment trên draft của mình"       | Minh thấy; Lan/anon không
