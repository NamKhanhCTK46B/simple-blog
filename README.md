# Simple Blog

Simple Blog là dự án web sử dụng **Next.js 16** và **Supabase**. Ở trạng thái hiện tại, dự án tập trung vào việc cấu hình kết nối Supabase và kiểm tra phiên đăng nhập (session) ở trang chủ.

## Công nghệ sử dụng

- Next.js 16 (App Router)
- React 19
- TypeScript 5
- Supabase (`@supabase/supabase-js`, `@supabase/ssr`)
- ESLint 9

## Tính năng hiện có

- Khởi tạo Supabase client cho:
  - Trình duyệt (`src/lib/supabase/client.ts`)
  - Server (`src/lib/supabase/server.ts`)
- Middleware làm mới phiên đăng nhập (`src/lib/supabase/middleware.ts`, `src/middleware.ts`)
- Trang chủ hiển thị trạng thái session để kiểm tra kết nối Supabase (`src/app/page.tsx`)

## Yêu cầu môi trường

- Node.js 20+ (khuyến nghị dùng bản LTS)
- npm

## Cài đặt và chạy dự án

```bash
npm install
npm run dev
```

Truy cập: [http://localhost:3000](http://localhost:3000)

## Cấu hình biến môi trường

Tạo file `.env.local` ở thư mục gốc dự án và khai báo:

```bash
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

> Lưu ý: Chỉ dùng giá trị mẫu như trên trong tài liệu. Không đưa API key thật hoặc thông tin nhạy cảm vào README hay commit.

## Scripts chính

```bash
npm run dev    # Chạy môi trường phát triển
npm run lint   # Kiểm tra lint
npm run build  # Build production
npm run start  # Chạy bản production sau khi build
```

## Cấu trúc thư mục chính

```text
src/
  app/
    layout.tsx
    page.tsx
  lib/
    supabase/
      client.ts
      middleware.ts
      server.ts
  middleware.ts
```

## Lưu ý bảo mật

- Không commit file `.env.local`.
- Không công khai khóa hoặc thông tin nhạy cảm trong README, issue, PR hoặc lịch sử commit.
