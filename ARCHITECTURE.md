# QuestUp Architecture

## Uygulama omurgasi

1. `frontend/`
React PWA istemcisi. Kullanici, partner ve admin deneyimlerini role-aware route yapisiyla sunar. `realtimeService` ile socket + polling fallback, responsive admin shell ve sehir bazli QR Avi akislarini da icerir.

2. `backend/`
JWT auth, bootstrap endpoint, `qr-hunts` endpointleri, `app/updates` polling endpointi, Socket.io room mantigi ve demo veriyi saglayan Express API.

3. `database/`
PostgreSQL hedef semasi, wallet, partner, QR Drop, eslesme, sezon ve fraud tablolarini icerir.

## Katmanlar

- Auth layer: JWT, `user/admin/partner` rolleri
- Quest layer: nearby tasks, Hidden QR Hunt, yayinlanabilir QR Avi, QR validation, media proof, reroll, QuestBot suggestion
- Social safety layer: friends, match visibility, trust score, reports, blocks, duo QR onayi
- Commerce layer: partner coupons, QR campaigns, sponsored tasks, wallet, referrals, season rewards
- Ops layer: QR Drop management, fraud logs, moderation queues, approval workflows, push notifications

## QR Drop flow

1. Admin veya partner QR Drop tanimlar.
2. Sistem benzersiz token uretir, token hash'i saklar, indirilebilir QR PNG verir.
3. Kullanici QR Hunt ekraninda sadece yaklasik bolge, ipucu, rarity, kalan sure ve odulu gorur.
4. Scan istegi backend'e token, kullanici ve konumla gider.
5. Scan dogrulamasi gecerliyse odul dagitimi, history yazimi ve season ilerlemesi yapilir.
6. Riskli ise fraud review kuyruguna duser.

## Canli akis

1. Kullanici login olur.
2. `GET /api/v1/app/bootstrap` ile tum kritik ekran verisi gelir.
3. `frontend/src/services/realtimeService.js` token ile socket baglantisini acar.
4. Kullanici role room ve city room'a katilir:
   - `role:user`
   - `admin`
   - `user:city:Adana`
   - `user:city:Istanbul`
5. Admin yeni QR Avi yayinladiginda ilgili city room'a:
   - `qr_hunt_published`
   - `qr_hunt_updated`
   - `qr_hunt_cancelled`
   eventleri gider.
6. Canli etkinliklerde `live_event_started` ve mevcut bildirim olaylari akmaya devam eder.
7. Socket baglantisi yoksa `GET /api/v1/app/updates?since=...` ile 15-30 saniyelik fallback polling devreye girer.

## Ekran stratejisi

- Kullanici: ana panel, harita/gorevler, QR hunt, QR scanner, cüzdan/oduller, sezon, profil
- Partner: kupon, QR kampanya, sponsorlu gorev, rapor paneli
- Admin: istatistik, QR Drop yonetimi, partner onay, proof/fraud, sezon/bildirim merkezi

## Uretim notlari

- Harita katmani icin Mapbox GL JS veya Google Maps Web SDK
- Push icin Firebase Cloud Messaging
- Medya kaniti icin signed upload + virus scan + metadata extraction
- Fraud sinyalleri icin event log + worker queue + review tooling

## 2026 modul genislemesi

### Moduler backend

- Yeni sistemler ayri controller ve route dosyalari ile eklendi:
  - `taskSubmissionsController`
  - `qrEventsController`
  - `giftQrController`
  - `plusController`
  - `supportTicketsController`
  - `shopApplicationsController`
  - `adminUsersController`
- Feature flag katmani `backend/src/config/featureFlags.js` ile merkezi olarak yonetilir.
- Uploadlar `multer` memory storage + kontrollu disk kaydi ile `backend/uploads` altina yazilir.

### Demo feature store

- `backend/src/data/demoFeatureStore.js` yeni modullerin DEMO_MODE veri omurgasidir.
- Gorev teslimleri, QR etkinlikleri, QR birakma gorevleri, hediye QR, Plus, destek ve mekan basvurulari tek yerde ama ayri domain fonksiyonlari ile tutulur.
- `extendBundleForUser()` mevcut bootstrap payload'ini bozmadan yeni modulleri bundle'a ekler.

### Frontend route izolasyonu

- Auth ekranlari AppShell disinda kalir.
- Kullanici modulleri yalnizca `/app/*` altinda acilir.
- Admin modulleri yalnizca `/admin*` altinda ve ayri `AdminShell` ile acilir.
- Kullanici bottom nav hala sadece 4 ogelidir.
- Admin tablolari dar ekranda kart-list gorunumune gecer; sidebar mobilde hamburger olarak acilir.

### Sehir verisi

- Frontend ve backend 81 sehirlik ortak bir liste kullanir.
- Profil formlari, admin QR Avi formu ve filtreleme bu liste uzerinden calisir.
- Sehir karsilastirmalari normalize edilir; farkli yazimlar filtreyi bozmaz.

### Guvenlik kurallari

- Admin endpointleri `requireAdmin` ile korunur.
- User endpointleri `requireUser` ile sadece role `user` hesaplarina acilir.
- Teslim odulleri sadece admin onayindan sonra yazilir.
- QR etkinlikleri admin baslatmadan `live` olamaz.
- Dosya uzantisi ve boyut sinirlari controller katmaninda tekrar kontrol edilir.
- Socket yoksa frontend 30 saniyede bir bootstrap yeniler.
