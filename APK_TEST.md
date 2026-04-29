# APK Test Adimlari

## Build

1. `cd frontend`
2. `npm install`
3. `npm run build`
4. `npx cap copy android`
5. `npx cap sync android`
6. `npx cap open android`
7. Android Studio icinden debug APK veya release build al.

## Bu turda tamamlanan dogrulamalar

- `npm run build` basarili.
- `npx cap sync android` basarili.
- `android\\gradlew.bat assembleDebug` basarili.
- Backend yeni upload endpointleriyle yeniden baslatildi ve `POST /uploads/profile-avatar`, `POST /uploads/support-attachment`, `POST /uploads/task-proof`, `POST /uploads/qr-proof` smoke testten gecti.
- Profil fotografisi yukleme ve kaldirma akisi backend seviyesinde dogrulandi.
- Gorev teslimi fotograf kaniti ile gonderildi; kayit `pending` durumunda acildi ve odul aninda verilmedi.
- Destek talebi ek dosya ile olusturuldu; admin listesinde goruldu ve yanit gonderme basarili oldu.
- Telefon dogrulama kodu isteme ve kodu onaylama akisi basarili oldu.
- `GET /leaderboard?scope=global` ve `GET /leaderboard?scope=city&city=Adana` istekleri basarili dondu.
- `POST /qr/scan` icin gecersiz sehir denemesi 400 dondu; gecerli tarama sonrasi odul verildi.
- Isletme/partner QR hediyesi olusturma akisi basarili; ayni hesapta ikinci deneme gunluk limit nedeniyle reddedildi.
- `cityDistricts` veri seti icin Adana ve Istanbul ilce filtreleri dogrulandi.
- Canli socket testi gecti: admin yeni gorev ve QR Avi yayinladiginda kullanici soketi `task_created` ve `qr_hunt_published` eventlerini aldi.
- Polling fallback testi gecti: `GET /api/v1/app/updates?since=...` yeni gorev ve QR Avi kayitlarini dondurdu.
- Partner panelinden QR hediyesi olusturma girisi `/app/gift-qrs/create` uzerinden acilacak sekilde guncellendi.
- Kullanici AppShell route agaci derleme seviyesinde dogrulandi.
- `/app/tasks/:id` ve `/app/settings` rotalari eklendi.
- Alt menude sadece `Ana Sayfa`, `Gorevler`, `QR Avi`, `Cuzdan` kaldi.
- Profil alt menuden cikarilip sag ust avatar menusune tasindi.
- Kullanici sayfalarinda geri tusu mantigi tek noktada toplandi.
- `logout` akisi avatar menusunden App state ile entegre edildi.
- Standalone mod icin profil tercihleri ve sifre degistirme uyumu guncellendi.
- Responsive admin panel CSS ve yeni `qr-hunts` endpointleri build seviyesinde dogrulandi.
- `app/updates` polling fallback smoke testi gecti.

## Cihaz uzerinde manuel test edilmesi gerekenler

- Kullanici login olunca `/app` aciliyor mu?
- Ana sayfada admin/partner baglantisi gorunmuyor mu?
- Alt menude sadece 4 item var mi?
- Profil sag ust avatar menusunde mi?
- Avatar menusunden `Profilim`, `Cuzdanim`, `Ayarlar`, `Cikis yap` aciliyor mu?
- `/app/profile` rotasi sorunsuz aciliyor mu?
- `/app/settings` rotasi sorunsuz aciliyor mu?
- Gorev listesinden gorev detayina gecis calisiyor mu?
- `QR Avi` ve `QR tara` ekranlari aciliyor mu?
- Yeni yayinlanan QR Avi banner'i Home ekranina yenilemeden dusuyor mu?
- `Cuzdan` sayfasi aciliyor mu?
- Alt ekranlarda geri tusu once history'e, history yoksa `/app` ana ekranina donuyor mu?
- Android fiziksel geri tusu siyah ekrana dusurmeden calisiyor mu?
- Keyboard acildiginda inputlar gorunur kaliyor mu?
- Alt navigasyon icerigin ustune binmeden gorunuyor mu?
- Avatar menusu ve alt nav safe-area ile dogru hizalaniyor mu?
- Acik tema varsayilan olarak geliyor mu?
- Opsiyonel koyu tema ayar ekranindan degistirilebiliyor mu?
- Gorev detayindan `Teslim et` ekranina geciliyor mu?
- Foto kanitli teslim gonderilebiliyor mu?
- Video kanitli teslim gonderilebiliyor mu?
- Teslim sonrasi odul hemen yazilmiyor mu?
- `Teslimlerim` ekraninda pending / approved / rejected durumlari gorunuyor mu?
- `Bildirimler` ekraninda canli QR banner'i ve cevaplanan destek talepleri gorunuyor mu?
- `QuestUp Plus` ekraninda demo aktivasyon ve rozet alanlari gorunuyor mu?
- `Hediye QR` ekranlarinda create + list akisi bozulmadan aciliyor mu?
- Partner hesabi ile `QR hediyesi olustur` aksiyonu aciliyor mu ve hedef kullanici ID girilerek talep gonderilebiliyor mu?
- `Destek Talepleri` ekraninda yeni kayit acilip detay aciliyor mu?
- `Mekan Basvurusu` ekraninda form ve gecmis birlikte aciliyor mu?
- `QR birakma gorevi` atandiginda ilgili ekran aciliyor mu?

## Admin manuel test listesi

- `/admin-login` sadece admin env bilgisiyle aciliyor mu?
- Admin panel 1366x768, 1920x1080, 768px tablet ve 390px mobilde tasmadan sigiyor mu?
- Mobilde sidebar hamburger ile acilip kapanabiliyor mu?
- Kullanicilar tablosu dar ekranda kart-list duzenine geciyor mu?
- Normal kullanici `/admin` altinda bir route acmaya calistiginda engelleniyor mu?
- `AdminTaskSubmissionsPage` uzerinden onay ve red sonrasi kullanici durumlari guncelleniyor mu?
- `AdminQREventsPage` yeni etkinlik olusturup canli baslatabiliyor mu?
- `AdminQREventsPage` icinden yeni QR Avi taslagi olusturulabiliyor mu?
- `Yayinla` aksiyonu sonrasi ayni sehirdeki kullanici uygulamasina QR Avi dusuyor mu?
- `GET /api/v1/qr-hunts?city=Adana` veya ilgili sehir sorgusunda yayinlanan kayit gorunuyor mu?
- `QR scan` gecersiz sehir veya limit asimi durumunda net hata mesaji gosteriyor mu?
- Canli etkinlik baslayinca kullanici uygulamasina banner dusuyor mu?
- `AdminQRDropAssignmentsPage` QR birakma gorevini onaylayabiliyor mu?
- `AdminGiftQRReviewsPage` bot notlarini gosteriyor mu?
- `AdminSupportTicketsPage` yanit gonderip kapatabiliyor mu?
- `AdminUsersPage` Plus ac/kapat, not ekle ve askiya alma aksiyonlarini calistiriyor mu?
- `AdminShopApplicationsPage` mekan basvurusunu onaylayabiliyor mu?
- `AdminPlusMembersPage` aktif kayitlari gosteriyor mu?

## Gorsel kontrol listesi

- Uygulama web sitesi gibi degil, telefon uygulamasi gibi hissettiriyor mu?
- Header, kartlar ve alt nav ayni tasarim dilini koruyor mu?
- Kart araliklari ve bosluklar duzenli mi?
- Emoji yerine tutarli ikonlar kullaniliyor mu?
- Bot/anonim istek hissi veren metinler kaldirildi mi?
- Sosyal gorev onerisi kontrollu ve guvenli gorunuyor mu?

## Notlar

- Bu turda fiziksel Android cihaz uzerinde manuel navigasyon testi yapilmadi.
- Build seviyesi dogrulama tamamlandi; APK gorunum ve fiziksel geri tus testi cihazda ayrica onaylanmali.
- Smoke testte admin login, user login, gorev teslimi, admin onay/red, hediye QR, destek talebi, Plus, mekan basvurusu ve QR birakma akislari backend seviyesinde dogrulandi.
- Yeni smoke testte `qr-hunts` backend store, standalone admin yayinlama ve `app/updates` fallback akisi da dogrulandi.
