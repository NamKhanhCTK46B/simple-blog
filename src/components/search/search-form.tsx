"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

interface SearchFormProps {
  initialQuery: string;
}

export function SearchForm({ initialQuery }: SearchFormProps) {
  const router = useRouter();
  const [q, setQ] = useState(initialQuery);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const trimmed = q.trim();
    if (!trimmed) return;
    router.push(`/search?q=${encodeURIComponent(trimmed)}`);
  };

  return (
    <form onSubmit={handleSubmit} className="flex gap-2">
      <input
        type="search"
        value={q}
        onChange={(e) => setQ(e.target.value)}
        placeholder="Nhập từ khóa..."
        className="flex-1 px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500"
      />
      <button
        type="submit"
        className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
      >
        Tìm
      </button>
    </form>
  );
}
