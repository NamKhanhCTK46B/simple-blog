import { createClient } from "@/lib/supabase/server";
import { notFound } from "next/navigation";
import type { Metadata } from "next";
import ReactMarkdown from "react-markdown";
import { CommentForm } from "@/components/posts/comment-form";
import { RealtimeComments } from "@/components/posts/realtime-comments";
import { LikeButton } from "@/components/posts/like-button";

interface PostPageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({
  params,
}: PostPageProps): Promise<Metadata> {
  const { slug } = await params;
  const supabase = await createClient();

  const { data: post } = await supabase
    .from("posts")
    .select("title, excerpt")
    .eq("slug", slug)
    .eq("status", "published")
    .single();

  return {
    title: post?.title || "Bài viết",
    description: post?.excerpt || "",
  };
}

export default async function PostPage({ params }: PostPageProps) {
  const { slug } = await params;
  const supabase = await createClient();

  const { data: post, error } = await supabase
    .from("posts")
    .select(`*, profiles ( display_name, avatar_url )`)
    .eq("slug", slug)
    .eq("status", "published")
    .single();

  if (error || !post) notFound();

  const [{ data: comments }, { count: likeCount }, { data: { user } }] =
    await Promise.all([
      supabase
        .from("comments")
        .select(`*, profiles ( display_name, avatar_url )`)
        .eq("post_id", post.id)
        .order("created_at", { ascending: true }),
      supabase
        .from("likes")
        .select("*", { count: "exact", head: true })
        .eq("post_id", post.id),
      supabase.auth.getUser(),
    ]);

  let initialLiked = false;
  if (user) {
    const { data: existing } = await supabase
      .from("likes")
      .select("post_id")
      .eq("post_id", post.id)
      .eq("user_id", user.id)
      .maybeSingle();
    initialLiked = !!existing;
  }

  return (
    <main className="max-w-3xl mx-auto px-4 py-8">
      <article>
        <header className="mb-8">
          <h1 className="text-4xl font-bold mb-4">{post.title}</h1>

          <div className="flex items-center gap-4 text-gray-500">
            <span>Bởi {post.profiles?.display_name || "Ẩn danh"}</span>
            <span>•</span>
            <time>
              {post.published_at
                ? new Date(post.published_at).toLocaleDateString("vi-VN", {
                    year: "numeric",
                    month: "long",
                    day: "numeric",
                  })
                : ""}
            </time>
          </div>
        </header>

        <div className="max-w-none mb-8 leading-relaxed text-gray-800">
          <ReactMarkdown
            components={{
              h1: (props) => (
                <h1 className="text-3xl font-bold mt-6 mb-3" {...props} />
              ),
              h2: (props) => (
                <h2 className="text-2xl font-bold mt-6 mb-3" {...props} />
              ),
              h3: (props) => (
                <h3 className="text-xl font-semibold mt-4 mb-2" {...props} />
              ),
              p: (props) => <p className="mb-4" {...props} />,
              ul: (props) => (
                <ul className="list-disc pl-6 mb-4 space-y-1" {...props} />
              ),
              ol: (props) => (
                <ol className="list-decimal pl-6 mb-4 space-y-1" {...props} />
              ),
              a: (props) => (
                <a
                  className="text-blue-600 hover:underline"
                  target="_blank"
                  rel="noreferrer"
                  {...props}
                />
              ),
              code: (props) => (
                <code
                  className="bg-gray-100 px-1 rounded text-sm font-mono"
                  {...props}
                />
              ),
              pre: (props) => (
                <pre
                  className="bg-gray-900 text-gray-100 p-4 rounded-md overflow-x-auto mb-4"
                  {...props}
                />
              ),
              img: (props) => (
                // eslint-disable-next-line @next/next/no-img-element, jsx-a11y/alt-text
                <img
                  className="max-w-full h-auto rounded-md my-4"
                  {...props}
                />
              ),
              blockquote: (props) => (
                <blockquote
                  className="border-l-4 border-gray-300 pl-4 italic text-gray-600 my-4"
                  {...props}
                />
              ),
            }}
          >
            {post.content || ""}
          </ReactMarkdown>
        </div>

        <div className="mb-12">
          <LikeButton
            postId={post.id}
            initialLikeCount={likeCount || 0}
            initialLiked={initialLiked}
            isAuthenticated={!!user}
          />
        </div>
      </article>

      <section className="border-t pt-8">
        <h2 className="text-2xl font-bold mb-6">
          Bình luận ({comments?.length || 0})
        </h2>

        {user ? (
          <div className="mb-8">
            <CommentForm postId={post.id} />
          </div>
        ) : (
          <p className="text-gray-500 mb-8">
            <a href="/login" className="text-blue-600 hover:text-blue-500">
              Đăng nhập
            </a>{" "}
            để bình luận.
          </p>
        )}

        <RealtimeComments postId={post.id} initialComments={comments || []} />
      </section>
    </main>
  );
}
