# API Endpoints

## Health

### `GET /api/v1/health`

Response:

```json
{
  "success": true,
  "message": "API calisiyor",
  "data": {
    "mode": "DEMO_MODE"
  }
}
```

## Auth

### `POST /api/v1/auth/register`

Request:

```json
{
  "email": "user@example.com",
  "password": "12345678",
  "confirm_password": "12345678"
}
```

Response:

```json
{
  "success": true,
  "message": "Kayit basarili. Lutfen giris yapin.",
  "data": {
    "email": "user@example.com"
  }
}
```

### `POST /api/v1/auth/login`

Request:

```json
{
  "email": "user@example.com",
  "password": "12345678"
}
```

Response:

```json
{
  "success": true,
  "message": "Giris basarili",
  "data": {
    "token": "<jwt>",
    "user": {
      "id": "user-id",
      "email": "user@example.com",
      "role": "user",
      "profileCompleted": false
    }
  }
}
```

### `POST /api/v1/auth/admin-login`

Admin ve partner hesaplari icindir.

Request:

```json
{
  "email": "admin@questup.local",
  "password": "123456"
}
```

### `POST /api/v1/auth/complete-profile`

Headers:

- `Authorization: Bearer <token>`

Request:

```json
{
  "display_name": "Ece",
  "username": "ecequest",
  "city": "Adana",
  "district": "Seyhan",
  "interests": ["cafe", "explore"],
  "profile_completed": true
}
```

### `GET /api/v1/auth/me`

Headers:

- `Authorization: Bearer <token>`

### `POST /api/v1/auth/logout`

Headers:

- `Authorization: Bearer <token>`

Response:

```json
{
  "success": true,
  "message": "Cikis yapildi",
  "data": {}
}
```

## Optional / legacy auth

Bu endpointler kod tabaninda duruyor ama ana kullanici akisi bunlara bagli degil:

- `POST /api/v1/auth/google-login`
- `POST /api/v1/auth/request-login-code`
- `POST /api/v1/auth/verify-login-code`
- `POST /api/v1/auth/send-verification-code`
- `POST /api/v1/auth/verify-email`
- `POST /api/v1/auth/resend-verification-code`
- `POST /api/v1/auth/forgot-password`
- `POST /api/v1/auth/verify-reset-code`
- `POST /api/v1/auth/reset-password`
- `POST /api/v1/auth/change-password`
- `GET /api/v1/auth/profile`
- `PUT /api/v1/auth/profile`
- `POST /api/v1/auth/sync-contacts`

## User app

- `GET /api/v1/app/bootstrap`
- `GET /api/v1/app/updates?since=<iso-date>`
- `GET /api/v1/app/version`
- `GET /api/v1/app/nearby`
- `GET /api/v1/app/notifications`
- `GET /api/v1/app/algorithms`
- `GET /api/v1/qr-hunts`
- `GET /api/v1/qr-hunts/:id`

## Partner

- `GET /api/v1/partner/dashboard`
- `GET /api/v1/partner/campaigns`

## Admin

- `GET /api/v1/admin/dashboard`
- `GET /api/v1/admin/overview`
- `GET /api/v1/admin/qr-drops/fraud`

## User modules

### Gorev teslimi

- Amac: gorevleri fotoğraf veya video kaniti ile teslim etmek, odulu sadece admin onayindan sonra vermek.
- Ekranlar:
  - `TaskSubmitPage`
  - `MySubmissionsPage`
- Endpointler:
  - `POST /api/v1/task-submissions`
  - `GET /api/v1/my-submissions`
- Kullanici akisi:
  - gorev detayi -> `Teslim et`
  - kanit yukle
  - durum `pending`
- Guvenlik:
  - ayni gorev ikinci kez teslim edilemez
  - fotoğraf/video zorunlu
  - boyut ve uzanti kontrolu zorunlu

### Hediye QR

- Amac: kullanicinin admin onayli hediye QR olusturmasi.
- Ekranlar:
  - `GiftQRCreatePage`
  - `MyGiftQRsPage`
  - `AdminGiftQRReviewsPage`
- Endpointler:
  - `POST /api/v1/user-gift-qrs`
  - `GET /api/v1/my-gift-qrs`
  - `GET /api/v1/admin/gift-qrs`
  - `POST /api/v1/admin/gift-qrs/:id/approve`
  - `POST /api/v1/admin/gift-qrs/:id/reject`
- Admin akisi:
  - bot notu ve risk skoru ile inceleme
  - onayla -> QR aktif + Plus Destekci
  - reddet -> sebep kullaniciya gonderilir

### Destek talepleri

- Amac: kullanici sorularini uygulama icinden acmak ve cevabi yine uygulamada gormek.
- Ekranlar:
  - `SupportTicketsPage`
  - `SupportTicketDetailPage`
  - `AdminSupportTicketsPage`
- Endpointler:
  - `POST /api/v1/support-tickets`
  - `GET /api/v1/my-support-tickets`
  - `GET /api/v1/my-support-tickets/:id`
  - `GET /api/v1/admin/support-tickets`
  - `GET /api/v1/admin/support-tickets/:id`
  - `POST /api/v1/admin/support-tickets/:id/reply`
  - `POST /api/v1/admin/support-tickets/:id/close`
  - `POST /api/v1/admin/support-tickets/:id/approve`

### Plus

- Amac: satin alinabilir Plus altyapisi ve demo aktivasyon destegi.
- Ekranlar:
  - `PlusPage`
  - `AdminPlusMembersPage`
- Endpointler:
  - `GET /api/v1/plus/status`
  - `POST /api/v1/plus/activate-demo`
  - `GET /api/v1/admin/plus-members`
  - `POST /api/v1/admin/users/:id/toggle-plus`

### Mekan basvurulari

- Amac: partner mekan ve dukkan basvurularini admin onayina dusurmek.
- Ekranlar:
  - `ShopApplicationPage`
  - `AdminShopApplicationsPage`
- Endpointler:
  - `POST /api/v1/shop-applications`
  - `GET /api/v1/my-shop-applications`
  - `GET /api/v1/admin/shop-applications`
  - `POST /api/v1/admin/shop-applications/:id/approve`
  - `POST /api/v1/admin/shop-applications/:id/reject`

### Canli QR etkinlikleri

- Amac: adminin canli QR etkinligini baslatmasi ve kullaniciya anlik duyurmasi.
- Ekranlar:
  - `QRHuntPage` banner
  - `NotificationsPanel`
  - `AdminQREventsPage`
  - `AdminQRDropAssignmentsPage`
- Endpointler:
  - `GET /api/v1/admin/qr-events`
  - `POST /api/v1/admin/qr-events`
  - `POST /api/v1/admin/qr-events/:id/start`
  - `POST /api/v1/admin/qr-events/:id/stop`
  - `GET /api/v1/my-qr-drop-assignment`
  - `POST /api/v1/qr-drop-assignments/:id/submission`
  - `GET /api/v1/admin/qr-drop-assignments`
  - `POST /api/v1/admin/qr-drop-assignments/:id/approve`
  - `POST /api/v1/admin/qr-drop-assignments/:id/reject`
- Realtime olaylari:
  - `qr_event_started`
  - `qr_event_stopped`
  - `live_event_started`
  - `qr_drop_assignment_created`
  - `task_submission_reviewed`
  - `support_ticket_replied`
  - `gift_qr_approved`
  - `plus_status_updated`
  - `notification_created`

### Yayinlanabilir QR Avi

- Amac: adminin sehir bazli QR Avi taslagi olusturmasi, yayinlamasi ve kullaniciya anlik dusurmesi.
- Ekranlar:
  - `AdminQREventsPage`
  - `QRHuntPage`
  - `HomePage`
- User endpointleri:
  - `GET /api/v1/qr-hunts?city=<city>`
  - `GET /api/v1/qr-hunts/:id`
- Admin endpointleri:
  - `GET /api/v1/admin/qr-hunts`
  - `POST /api/v1/admin/qr-hunts`
  - `PUT /api/v1/admin/qr-hunts/:id`
  - `POST /api/v1/admin/qr-hunts/:id/publish`
  - `POST /api/v1/admin/qr-hunts/:id/unpublish`
  - `DELETE /api/v1/admin/qr-hunts/:id`
- Bootstrap alanlari:
  - `activeQrHunts`
  - `activeEvents`
  - `userCity`
- Polling fallback:
  - `GET /api/v1/app/updates?since=<iso-date>`
- Realtime olaylari:
  - `qr_hunt_published`
  - `qr_hunt_updated`
  - `qr_hunt_cancelled`

### Admin kullanici yonetimi

- Ekran:
  - `AdminUsersPage`
- Endpointler:
  - `GET /api/v1/admin/users/search?q=`
  - `GET /api/v1/admin/users`
  - `GET /api/v1/admin/users/:id`
  - `POST /api/v1/admin/users/:id/toggle-plus`
  - `POST /api/v1/admin/users/:id/suspend`
  - `POST /api/v1/admin/users/:id/activate`
  - `POST /api/v1/admin/users/:id/notes`
  - `POST /api/v1/admin/users/:id/flag-risk`

## QR Hunt

- `GET /api/v1/qr-drops`
- `GET /api/v1/qr-drops/:id`
- `POST /api/v1/qr-drops`
- `PUT /api/v1/qr-drops/:id`
- `DELETE /api/v1/qr-drops/:id`
- `POST /api/v1/qr-drops/scan`
