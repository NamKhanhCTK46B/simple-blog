"use client";

import { useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";

export default function ForgotPasswordPage() {
  const supabase = createClient();
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setMessage(null);
    setLoading(true);

    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/auth/update-password`,
    });

    if (error) setError(error.message);
    else
      setMessage(
        "Đã gửi email khôi phục. Vui lòng kiểm tra hộp thư của bạn (cả thư rác).",
      );

    setLoading(false);
  };

  return (
    <div className="min-h-[calc(100vh-4rem)] flex items-center justify-center">
      <div className="max-w-md w-full space-y-6 p-8 bg-white rounded-lg shadow">
        <div className="text-center">
          <h2 className="text-3xl font-bold">Quên mật khẩu</h2>
          <p className="mt-2 text-gray-600">
            Nhập email để nhận link đặt lại mật khẩu
          </p>
        </div>

        {message && (
          <div className="bg-green-50 text-green-700 p-3 rounded-md text-sm">
            {message}
          </div>
        )}
        {error && (
          <div className="bg-red-50 text-red-500 p-3 rounded-md text-sm">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label
              htmlFor="email"
              className="block text-sm font-medium text-gray-700"
            >
              Email
            </label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-blue-500 focus:border-blue-500"
              placeholder="email@example.com"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full py-2 px-4 rounded-md text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50"
          >
            {loading ? "Đang gửi..." : "Gửi link khôi phục"}
          </button>
        </form>

        <p className="text-center text-sm">
          <Link href="/login" className="text-blue-600 hover:text-blue-500">
            ← Quay lại đăng nhập
          </Link>
        </p>
      </div>
    </div>
  );
}
