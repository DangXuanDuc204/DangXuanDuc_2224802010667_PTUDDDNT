# Lab 6 - User Management Role Based Flutter App

Bài này dựa trên video: **Create User Management Role Based Flutter App With ASP.NET Core Web API Backend JWT**.

Ứng dụng gồm Flutter frontend và ASP.NET Core Web API backend, dùng JWT Authentication và Role Based Authorization.

## Công nghệ

- Flutter
- Provider
- SharedPreferences
- ASP.NET Core Web API
- JWT
- SQL Server

## Backend

Project backend:

```text
D:\TH_PTUDDDNT\Lab6\backend\backend\backend.csproj
```

Connection string SQL Server:

```json
"DefaultConnection": "Server=LAPTOP-SGK3EG8L;Database=Lab6_UserManagement;Trusted_Connection=True;TrustServerCertificate=True;"
```

Chạy backend từ `D:\TH_PTUDDDNT\Lab6`:

```powershell
cd D:\TH_PTUDDDNT\Lab6
dotnet run --project backend\backend\backend.csproj --urls http://0.0.0.0:5000
```

Swagger:

```text
http://localhost:5000/swagger
```

Database được tạo tự động bằng `EnsureCreated()` và seed admin nếu chưa có.

## Frontend

Project Flutter:

```text
D:\TH_PTUDDDNT\Lab6\frontend
```

Chạy frontend:

```powershell
cd D:\TH_PTUDDDNT\Lab6\frontend
flutter pub get
flutter run
```

Base URL:

- Android emulator: `http://10.0.2.2:5000/api`
- Chrome/Web: `http://localhost:5000/api`

## Tài khoản demo

```text
Email: admin@gmail.com
Password: 123456
Role: Admin
```

## API chính

- `POST /api/Auth/register`
- `POST /api/Auth/login`
- `GET /api/Auth/profile`
- `GET /api/Users`
- `POST /api/Users`
- `GET /api/Users/{id}`
- `PUT /api/Users/{id}`
- `DELETE /api/Users/{id}`
- `PUT /api/Users/{id}/activate`
- `GET /api/Users/me`
- `PUT /api/Users/me/change-password`

## Phân quyền

- Admin: xem tất cả user, thêm user, sửa user, khóa user, kích hoạt user.
- Manager: xem user, sửa Staff/User, không sửa Admin, không tạo Admin.
- Staff/User: chỉ xem hồ sơ cá nhân và đổi mật khẩu.
