import Link from "next/link";
import { createClient } from "@/lib/supabase/server";

const POSTS_PER_PAGE = 5;

interface HomePageProps {
  searchParams: Promise<{ page?: string }>;
}

export default async function HomePage({ searchParams }: HomePageProps) {
  const { page: pageParam } = await searchParams;
  const page = Math.max(1, Number(pageParam) || 1);
  const from = (page - 1) * POSTS_PER_PAGE;
  const to = from + POSTS_PER_PAGE - 1;

  const supabase = await createClient();

  const { data: posts, count } = await supabase
    .from("posts")
    .select(
      `
      *,
      profiles ( display_name, avatar_url )
    `,
      { count: "exact" },
    )
    .eq("status", "published")
    .order("published_at", { ascending: false })
    .range(from, to);

  const totalPages = Math.max(1, Math.ceil((count || 0) / POSTS_PER_PAGE));

  return (
    <main className="max-w-4xl mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">Bài viết mới nhất</h1>

      {posts && posts.length > 0 ? (
        <div className="space-y-6">
          {posts.map((post) => (
            <article
              key={post.id}
              className="bg-white p-6 rounded-lg shadow border border-gray-200"
            >
              <Link href={`/posts/${post.slug}`}>
                <h2 className="text-2xl font-semibold hover:text-blue-600 transition-colors">
                  {post.title}
                </h2>
              </Link>

              {post.excerpt && (
                <p className="text-gray-600 mt-2">{post.excerpt}</p>
              )}

              <div className="flex items-center gap-4 mt-4 text-sm text-gray-500">
                <span>
                  Bởi {post.profiles?.display_name || "Ẩn danh"}
                </span>
                <span>•</span>
                <span>
                  {post.published_at
                    ? new Date(post.published_at).toLocaleDateString("vi-VN")
                    : "Chưa xuất bản"}
                </span>
              </div>

              <Link
                href={`/posts/${post.slug}`}
                className="inline-block mt-4 text-blue-600 hover:text-blue-500"
              >
                Đọc tiếp →
              </Link>
            </article>
          ))}
        </div>
      ) : (
        <div className="text-center py-12 bg-gray-50 rounded-lg">
          <p className="text-gray-500">Chưa có bài viết nào.</p>
        </div>
      )}

      {totalPages > 1 && (
        <nav className="mt-8 flex justify-center items-center gap-2">
          {page > 1 && (
            <Link
              href={`/?page=${page - 1}`}
              className="px-3 py-1 border rounded hover:bg-gray-100"
            >
              ← Trước
            </Link>
          )}

          {Array.from({ length: totalPages }, (_, i) => i + 1).map((p) => (
            <Link
              key={p}
              href={`/?page=${p}`}
              className={`px-3 py-1 border rounded ${
                p === page
                  ? "bg-blue-600 text-white"
                  : "hover:bg-gray-100"
              }`}
            >
              {p}
            </Link>
          ))}

          {page < totalPages && (
            <Link
              href={`/?page=${page + 1}`}
              className="px-3 py-1 border rounded hover:bg-gray-100"
            >
              Sau →
            </Link>
          )}
        </nav>
      )}
    </main>
  );
}
