import { PostForm } from "@/components/dashboard/post-form";

export default function NewPostPage() {
  return (
    <main className="max-w-4xl mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">Viết bài mới</h1>
      <PostForm />
    </main>
  );
}
