import { RegisterForm } from "@/components/auth/register-form";

export default function RegisterPage() {
  return (
    <div className="min-h-[calc(100vh-4rem)] flex items-center justify-center">
      <div className="max-w-md w-full space-y-8 p-8 bg-white rounded-lg shadow">
        <div className="text-center">
          <h2 className="text-3xl font-bold">Đăng ký tài khoản</h2>
          <p className="mt-2 text-gray-600">Tạo tài khoản để bắt đầu viết blog</p>
        </div>
        <RegisterForm />
      </div>
    </div>
  );
}
