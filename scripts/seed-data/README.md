# Dữ liệu mẫu cho Bài tập 2.1

Các file CSV trong thư mục này dùng để import vào Supabase Table Editor cho bài thực hành 04.

## Bước 1 — Tạo 2 user trên Supabase

**Authentication → Users → Add user → Create new user**

| Email                    | Password    | User Metadata                                              |
| ------------------------ | ----------- | ---------------------------------------------------------- |
| `lan.nguyen@example.com` | `Test@1234` | `{ "display_name": "Nguyễn Thị Lan", "avatar_url": null }` |
| `minh.tran@example.com`  | `Test@1234` | `{ "display_name": "Trần Văn Minh", "avatar_url": null }`  |

## Bước 2 — Lấy UUID thực tế

Vào **SQL Editor**:

```sql
select id, email from auth.users
where email in ('lan.nguyen@example.com', 'minh.tran@example.com');
```

Copy 2 UUID. Trong VS Code, mở `profiles.csv` và `posts.csv`, dùng **Ctrl+H** để thay:

- `11111111-1111-1111-1111-111111111111` → UUID của Lan
- `22222222-2222-2222-2222-222222222222` → UUID của Minh

## Bước 3 — Import `profiles.csv`

**Table Editor → profiles → Insert → Import data from CSV** → upload `profiles.csv`.

> Nếu trigger `on_auth_user_created` đã tự tạo dòng `profiles`, hãy xóa 2 dòng đó trước, hoặc bỏ qua bước này (chỉ cần `display_name` được trigger ghi từ `raw_user_meta_data`).

## Bước 4 — Import `posts.csv`

**Table Editor → posts → Insert → Import data from CSV** → upload `posts.csv`.

> Cột `slug` để trống → trigger `posts_set_slug` tự sinh từ `title`.
> Cột `id`, `created_at`, `updated_at` để trống → dùng default.

## Bước 5 — Import `comments.csv` (bonus)

Sau khi `posts` đã có dữ liệu, lấy `post_id` của 2 bài đầu:

```sql
select id, slug from public.posts
where slug in (
  'bat-dau-voi-next-js-15-va-app-router',
  'supabase-rls-bao-mat-cap-do-database'
);
```

Mở `comments.csv`, thay:
- `POST1_ID` → id bài "Bắt đầu với Next.js 15..."
- `POST2_ID` → id bài "Supabase RLS..."

Rồi import vào bảng `comments`.

## Bước 6 — Verify

```sql
select p.title, pr.display_name, p.status, p.published_at
  from public.posts p
  join public.profiles pr on pr.id = p.author_id
 order by p.published_at desc nulls last;
```

Kết quả mong đợi: 4 dòng (3 published + 1 draft), tác giả là "Nguyễn Thị Lan" và "Trần Văn Minh".
