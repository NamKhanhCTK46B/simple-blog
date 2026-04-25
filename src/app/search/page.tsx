import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { SearchForm } from "@/components/search/search-form";

interface SearchPageProps {
  searchParams: Promise<{ q?: string }>;
}

interface SearchResult {
  id: string;
  title: string;
  slug: string;
  excerpt: string | null;
  published_at: string | null;
  headline: string | null;
  rank: number;
}

export default async function SearchPage({ searchParams }: SearchPageProps) {
  const { q } = await searchParams;
  const query = q?.trim() || "";

  const supabase = await createClient();
  let results: SearchResult[] = [];
  let errorMsg: string | null = null;

  if (query) {
    const { data, error } = await supabase.rpc("search_posts", { q: query });
    if (error) {
      errorMsg = error.message;
    } else {
      results = data || [];
    }
  }

  return (
    <main className="max-w-3xl mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Tìm kiếm bài viết</h1>

      <SearchForm initialQuery={query} />

      {errorMsg && (
        <div className="mt-4 bg-red-50 text-red-600 p-3 rounded-md text-sm">
          Lỗi tìm kiếm: {errorMsg}. Hãy đảm bảo đã chạy migration-search.sql.
        </div>
      )}

      {query && !errorMsg && (
        <div className="mt-6">
          <p className="text-gray-600 mb-4">
            {results.length} kết quả cho <strong>&quot;{query}&quot;</strong>
          </p>

          {results.length > 0 ? (
            <div className="space-y-4">
              {results.map((r) => (
                <article
                  key={r.id}
                  className="bg-white p-5 rounded-lg shadow border border-gray-200"
                >
                  <Link href={`/posts/${r.slug}`}>
                    <h2 className="text-xl font-semibold hover:text-blue-600">
                      {r.title}
                    </h2>
                  </Link>
                  {r.headline ? (
                    <p
                      className="text-gray-600 mt-2 [&_mark]:bg-yellow-200 [&_mark]:px-1 [&_mark]:rounded"
                      dangerouslySetInnerHTML={{ __html: r.headline }}
                    />
                  ) : (
                    r.excerpt && (
                      <p className="text-gray-600 mt-2">{r.excerpt}</p>
                    )
                  )}
                  <p className="text-xs text-gray-400 mt-2">
                    {r.published_at
                      ? new Date(r.published_at).toLocaleDateString("vi-VN")
                      : ""}
                  </p>
                </article>
              ))}
            </div>
          ) : (
            <div className="text-center py-12 bg-gray-50 rounded-lg">
              <p className="text-gray-500">Không tìm thấy bài viết phù hợp.</p>
            </div>
          )}
        </div>
      )}
    </main>
  );
}
