-- =============================================================
-- MIGRATION — Bài tập 7.4: Full-text search bài viết
-- =============================================================
-- Tạo cột `search_vector` (tsvector) tự cập nhật từ title + excerpt + content,
-- index GIN để query nhanh, và RPC `search_posts(query)` để gọi từ client.
-- =============================================================

-- 1) Cột tsvector + trigger
alter table public.posts
  add column if not exists search_vector tsvector;

create or replace function public.posts_search_vector_update()
returns trigger
language plpgsql
as $$
begin
  new.search_vector :=
       setweight(to_tsvector('simple', coalesce(new.title, '')),   'A')
    || setweight(to_tsvector('simple', coalesce(new.excerpt, '')), 'B')
    || setweight(to_tsvector('simple', coalesce(new.content, '')), 'C');
  return new;
end;
$$;

drop trigger if exists posts_search_vector_trigger on public.posts;
create trigger posts_search_vector_trigger
before insert or update of title, excerpt, content
on public.posts
for each row execute procedure public.posts_search_vector_update();

-- 2) Backfill cho dữ liệu cũ
update public.posts
   set search_vector =
        setweight(to_tsvector('simple', coalesce(title, '')),   'A')
     || setweight(to_tsvector('simple', coalesce(excerpt, '')), 'B')
     || setweight(to_tsvector('simple', coalesce(content, '')), 'C');

-- 3) Index GIN
create index if not exists posts_search_vector_idx
  on public.posts using gin (search_vector);

-- 4) RPC: search_posts(q)
--    Trả về bài viết public.posts đã published, kèm rank và snippet highlight.
create or replace function public.search_posts(q text)
returns table (
  id          uuid,
  author_id   uuid,
  title       text,
  slug        text,
  excerpt     text,
  status      post_status,
  published_at timestamptz,
  headline    text,
  rank        real
)
language sql
stable
as $$
  select
    p.id,
    p.author_id,
    p.title,
    p.slug,
    p.excerpt,
    p.status,
    p.published_at,
    ts_headline(
      'simple',
      coalesce(p.excerpt, p.content, ''),
      plainto_tsquery('simple', q),
      'StartSel=<mark>,StopSel=</mark>,MaxWords=30,MinWords=10'
    ) as headline,
    ts_rank(p.search_vector, plainto_tsquery('simple', q)) as rank
  from public.posts p
  where p.status = 'published'
    and p.search_vector @@ plainto_tsquery('simple', q)
  order by rank desc, p.published_at desc nulls last;
$$;

-- 5) Cho phép anon + authenticated gọi RPC này
grant execute on function public.search_posts(text) to anon, authenticated;
