# Lab 5 Flutter Todo App with NodeJS MongoDB Backend JWT

## Backend

```bash
cd backend
npm install
npm run dev
```

API chạy tại:

```text
http://localhost:5000
```

Các route chính:

```text
POST /api/auth/register
POST /api/auth/login
GET /api/todos
POST /api/todos
PUT /api/todos/:id
PATCH /api/todos/:id/toggle
DELETE /api/todos/:id
```

## Frontend

```bash
cd frontend
flutter pub get
flutter run
```

Base URL dùng cho Android emulator:

```text
http://10.0.2.2:5000/api
```
