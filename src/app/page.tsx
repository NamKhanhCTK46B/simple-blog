import { createClient } from "@/lib/supabase/client";

export default async function Home() {
  const supabase = await createClient();

  // Test connection by getting session
  const {
    data: { session },
  } = await supabase.auth.getSession();

  return (
    <main className="min-h-screen p-8">
      <h1 className="text-3xl font-bold mb-4">Simple Blog</h1>
      <p className="text-gray-600">
        Supabase connection:{" "}
        {session ? "✅ Logged in" : "⚪ Not logged in (OK)"}
      </p>
      <p className="text-sm text-gray-400 mt-2">
        Nếu bạn thấy dòng này, Supabase đã được cấu hình thành công!
      </p>
    </main>
  );
}
