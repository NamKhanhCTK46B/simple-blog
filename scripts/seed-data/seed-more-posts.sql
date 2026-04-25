-- =============================================================
-- SEED — Thêm bài viết mẫu để test phân trang
-- =============================================================
-- Dùng cùng 2 author từ profiles.csv:
--   LAN_ID  = 8d2a964b-1ec5-4181-b2f6-130721e5f495
--   MINH_ID = d8cceca0-a953-42f1-b554-13053682950e
--
-- Insert 12 bài 'published' + 2 bài 'draft'.
-- Cộng với 3 bài published cũ → 15 bài → 3 trang (5/trang).
--
-- Trigger posts_set_slug sẽ tự sinh slug từ title.
-- Chạy trong Supabase SQL Editor.
-- =============================================================

insert into public.posts (author_id, title, content, excerpt, status, published_at) values
  ('8d2a964b-1ec5-4181-b2f6-130721e5f495',
   'Server Components và lợi ích đối với hiệu năng',
   E'# Server Components\n\nReact Server Components (RSC) cho phép render UI hoàn toàn ở phía server, giảm đáng kể lượng JavaScript gửi xuống trình duyệt.\n\n## Lợi ích\n\n- Bundle nhỏ hơn → trang load nhanh hơn.\n- Truy cập trực tiếp database mà không cần API layer.\n- Caching tự nhiên ở cấp độ component.',
   'Hiểu cách Server Components giảm bundle JavaScript và tăng tốc trang web.',
   'published', now() - interval '14 days'),

  ('8d2a964b-1ec5-4181-b2f6-130721e5f495',
   'TypeScript 5.5 — Những tính năng đáng chú ý',
   E'# TypeScript 5.5\n\nPhiên bản 5.5 mang đến nhiều cải tiến về performance và type inference.\n\n## Highlights\n\n- Inferred type predicates.\n- Regular expression syntax checking.\n- Isolated declarations.',
   'Tổng quan các tính năng mới của TypeScript 5.5 dành cho developer hằng ngày.',
   'published', now() - interval '13 days'),

  ('d8cceca0-a953-42f1-b554-13053682950e',
   'Hành trình tự học lập trình từ con số 0',
   E'# Tự học lập trình\n\nKhông cần bằng cấp, bạn vẫn có thể bắt đầu hành trình lập trình bằng cách chọn đúng lộ trình.\n\n## Lộ trình gợi ý\n\n1. HTML/CSS căn bản.\n2. JavaScript ES6+.\n3. Một framework (React/Vue).\n4. Backend cơ bản (Node.js).',
   'Lộ trình tự học lập trình hiệu quả từ kinh nghiệm cá nhân.',
   'published', now() - interval '12 days'),

  ('d8cceca0-a953-42f1-b554-13053682950e',
   'PostgreSQL JSONB và khi nào nên dùng',
   E'# JSONB trong PostgreSQL\n\nJSONB là kiểu dữ liệu mạnh mẽ cho phép lưu JSON kèm index. Phù hợp cho schema bán cấu trúc.\n\n## Khi nào nên dùng\n\n- Metadata không cố định.\n- Tích hợp dữ liệu từ nhiều nguồn.\n\n## Khi nào không nên\n\n- Dữ liệu có schema rõ ràng → dùng cột thường.',
   'Tìm hiểu kiểu JSONB của PostgreSQL và các tình huống sử dụng phù hợp.',
   'published', now() - interval '11 days'),

  ('8d2a964b-1ec5-4181-b2f6-130721e5f495',
   'Docker cho người mới — 30 phút bắt đầu',
   E'# Docker 101\n\nDocker giúp đóng gói ứng dụng cùng môi trường chạy, đảm bảo "works on my machine" không còn là vấn đề.\n\n## Khái niệm chính\n\n- Image: bản thiết kế.\n- Container: instance đang chạy.\n- Dockerfile: công thức tạo image.',
   'Khởi động với Docker chỉ trong 30 phút cho người mới hoàn toàn.',
   'published', now() - interval '10 days'),

  ('d8cceca0-a953-42f1-b554-13053682950e',
   'Tối ưu Core Web Vitals cho ứng dụng Next.js',
   E'# Core Web Vitals\n\nLCP, FID, CLS là 3 chỉ số quan trọng Google dùng để đánh giá trải nghiệm người dùng.\n\n## Cách cải thiện\n\n- LCP: tối ưu ảnh, dùng Image của Next.\n- FID/INP: giảm JavaScript, code-splitting.\n- CLS: đặt size cố định cho ảnh/iframe.',
   'Mẹo cải thiện LCP, FID và CLS cho ứng dụng Next.js của bạn.',
   'published', now() - interval '9 days'),

  ('8d2a964b-1ec5-4181-b2f6-130721e5f495',
   'Git Workflow nhóm nhỏ — chiến lược nhánh hiệu quả',
   E'# Git Workflow\n\nVới nhóm 2-5 người, GitHub Flow đủ đơn giản và hiệu quả.\n\n## Quy trình\n\n1. Tạo nhánh từ main.\n2. Commit thường xuyên, push.\n3. Mở pull request, review.\n4. Merge sau khi pass CI.',
   'Chiến lược Git nhánh đơn giản và hiệu quả cho nhóm nhỏ 2-5 người.',
   'published', now() - interval '8 days'),

  ('d8cceca0-a953-42f1-b554-13053682950e',
   'REST API vs GraphQL — chọn cái nào?',
   E'# REST vs GraphQL\n\nMỗi style có ưu nhược điểm riêng, không có "tốt hơn" tuyệt đối.\n\n## REST\n\n- Quen thuộc, dễ cache.\n- Có thể over-fetch.\n\n## GraphQL\n\n- Client tự chọn field.\n- Setup phức tạp hơn.',
   'So sánh REST API và GraphQL — khi nào nên chọn cái nào.',
   'published', now() - interval '7 days'),

  ('8d2a964b-1ec5-4181-b2f6-130721e5f495',
   'CSS Container Queries — responsive level mới',
   E'# Container Queries\n\nKhác với media query dựa trên viewport, container query phản hồi theo kích thước container cha.\n\n## Ví dụ\n\n```css\n@container (min-width: 400px) {\n  .card { display: grid; }\n}\n```',
   'Container queries — bước tiến mới của responsive design ở cấp component.',
   'published', now() - interval '6 days'),

  ('d8cceca0-a953-42f1-b554-13053682950e',
   'Bun runtime — đối thủ mới của Node.js?',
   E'# Bun\n\nBun là JavaScript runtime viết bằng Zig, nhanh hơn Node.js đáng kể trong nhiều benchmark.\n\n## Ưu điểm\n\n- Tốc độ khởi động cực nhanh.\n- Built-in bundler, test runner, package manager.\n- Tương thích phần lớn npm package.',
   'Bun runtime — JavaScript engine mới hứa hẹn nhanh hơn Node.js nhiều lần.',
   'published', now() - interval '5 days'),

  ('8d2a964b-1ec5-4181-b2f6-130721e5f495',
   'Edge Functions — chạy code gần user',
   E'# Edge Functions\n\nChạy serverless function tại các điểm CDN giúp giảm latency đáng kể.\n\n## Use case\n\n- A/B testing.\n- Authentication checks.\n- Personalization theo region.',
   'Edge Functions cho phép chạy code gần user, giảm độ trễ từ hàng trăm ms xuống vài chục ms.',
   'published', now() - interval '4 days'),

  ('d8cceca0-a953-42f1-b554-13053682950e',
   'Accessibility (a11y) — checklist 10 điểm cho dev',
   E'# A11y Checklist\n\n1. Mọi ảnh có alt text.\n2. Heading theo cấu trúc h1 → h6.\n3. Form input có label rõ ràng.\n4. Contrast tối thiểu 4.5:1.\n5. Focus state nhìn thấy.\n6. Keyboard navigation hoạt động.\n7. ARIA dùng đúng nơi.\n8. Tránh autoplay video có âm thanh.\n9. Tôn trọng prefers-reduced-motion.\n10. Test với screen reader.',
   '10 điểm kiểm tra accessibility cơ bản mọi developer nên áp dụng.',
   'published', now() - interval '2 days'),

  -- 2 bài draft (không lên trang chủ, chỉ author thấy)
  ('8d2a964b-1ec5-4181-b2f6-130721e5f495',
   'Bản nháp — Web Components và Custom Elements',
   E'# Web Components\n\nĐang viết...\n\nWeb Components là tập hợp tính năng cho phép tạo thẻ HTML tái sử dụng được.',
   'Tổng quan Web Components — đang biên soạn.',
   'draft', null),

  ('d8cceca0-a953-42f1-b554-13053682950e',
   'Bản nháp — Pattern State Management 2026',
   E'# State Management 2026\n\nĐang viết...\n\nXu hướng quản lý state đang chuyển từ Redux sang Zustand, Jotai và Server State.',
   'Khảo sát các pattern quản lý state phổ biến năm 2026.',
   'draft', null);

-- Verify: đếm bài published
select count(*) as published_count
  from public.posts
 where status = 'published';
-- Kỳ vọng: 15 (3 cũ + 12 mới) → 3 trang phân trang
