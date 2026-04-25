import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { ProfileForm } from "@/components/profile/profile-form";

export default async function ProfilePage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();

  return (
    <main className="max-w-2xl mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">Hồ sơ của tôi</h1>
      <div className="bg-white p-6 rounded-lg shadow">
        <p className="mb-4 text-gray-600">
          <strong>Email:</strong> {user.email}
        </p>
        <ProfileForm
          initialDisplayName={profile?.display_name || ""}
          initialAvatarUrl={profile?.avatar_url || ""}
        />
      </div>
    </main>
  );
}
