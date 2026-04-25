"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

interface LikeButtonProps {
  postId: string;
  initialLikeCount: number;
  initialLiked: boolean;
  isAuthenticated: boolean;
}

export function LikeButton({
  postId,
  initialLikeCount,
  initialLiked,
  isAuthenticated,
}: LikeButtonProps) {
  const router = useRouter();
  const supabase = createClient();
  const [liked, setLiked] = useState(initialLiked);
  const [count, setCount] = useState(initialLikeCount);
  const [isPending, startTransition] = useTransition();

  const handleClick = () => {
    if (!isAuthenticated) {
      router.push("/login");
      return;
    }

    const wasLiked = liked;
    setLiked(!wasLiked);
    setCount((c) => c + (wasLiked ? -1 : 1));

    startTransition(async () => {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;

      if (wasLiked) {
        await supabase
          .from("likes")
          .delete()
          .eq("post_id", postId)
          .eq("user_id", user.id);
      } else {
        await supabase.from("likes").insert({ post_id: postId, user_id: user.id });
      }
    });
  };

  return (
    <button
      onClick={handleClick}
      disabled={isPending}
      className={`flex items-center gap-2 px-4 py-2 rounded-md border transition ${
        liked
          ? "bg-red-50 border-red-300 text-red-600"
          : "bg-white border-gray-300 text-gray-700 hover:bg-gray-50"
      } disabled:opacity-50`}
    >
      <span aria-hidden>{liked ? "♥" : "♡"}</span>
      <span>{count}</span>
      <span className="text-sm">{liked ? "Đã thích" : "Thích"}</span>
    </button>
  );
}
