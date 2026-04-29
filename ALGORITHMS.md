# Algorithms

## Gorev eslesme algoritmasi

1. Kullanici nearby visibility ve open consent acik mi kontrol edilir.
2. 18 yas altinda ise sadece safe-mode task pool kullanilir.
3. Sehir uyumu, yas bandi, trust score, son report durumu ve mesafe puanlanir.
4. Ayni gorev tipine ilgi ve son tamamlama davranisi ile skor zenginlestirilir.
5. Eslesme sadece ortak QR veya iki tarafli check-in ile dogrulanir.

## Konuma gore gorev algoritmasi

1. Konum izni yoksa genel gorev havuzu doner.
2. Kullanici snapshot son dogruluk seviyesine gore normalize edilir.
3. Haversine ile partner ve gorev mesafeleri hesaplanir.
4. Guvenlik notu, acik saat, etkinlik durumu ve zorlukla birlikte siralanir.

## QR Drop / scan dogrulama algoritmasi

1. Token hash ile QR Drop bulunur.
2. Aktiflik, baslangic ve bitis zamani kontrol edilir.
3. Global usage limit ve per-user limit kontrol edilir.
4. `completed_tasks`, `qr_scan_history` ve `user_task_history` icinde tekrar kontrolu yapilir.
5. Kullanici lokasyonu radius icinde mi ve kullanici sehri ile gorev sehri uyumlu mu bakilir.
6. Hiz anomalisi, ayni cihaz zinciri ve brute-force scan denemesi ile risk skoru hesaplanir.
7. Risk esigi gecmezse odul verilir, wallet transaction ve season progress guncellenir.
8. Risk esigi gecerse `fraud_events` kuyruguna kayit dusulur.

## QuestBot algoritmasi

1. Girdi: yas, seviye, enerji, ilgi alani, sehir, konum izni, nearby partner yogunlugu
2. Policy filter: riskli, rizasiz, yasa disi, cinsel veya tehlikeli gorevleri eler
3. Candidate scorer: gunun saati, streak riski, sezon hedefi ve task fatigue hesabi
4. Toning layer: genc, hizli ama saygili dil
5. Notification layer: yeni gorevler ve streak motivasyonu

## Gorev tekrar engelleme

1. `completed_tasks` ayni gorevin yeniden acilmasini engeller.
2. `qr_scan_history` ayni QR'dan ikinci kez odul alinmasini engeller.
3. `user_task_history` son gorev kategorilerini izler, kategori tekrarini seyreltir.
4. `duo_match_history` ayni grup/duo kombinasyonlarini kontrol eder.
5. Legendary drop'lar slot sinirina ve rarity havuzuna gore filtrelenir.

## Fraud onleme sistemi

- Medya hash tekrari
- Bulanik medya tespiti
- EXIF tarih/saat farki
- Sahte GPS ve hiz anomalisi
- Ayni cihazdan cok hesap
- Ayni QR token ile asiri deneme
- Lokasyon radius mismatch
- Reward payout oncesi manual veya otomatik risk skoru

## Partner kampanya akisi

1. Partner QR kampanyasi olusturur.
2. Kampanya admin onayina duser.
3. Onay sonrasi QR PNG indirilebilir olur.
4. Partner, okutma sayisi ve kupon performansini panelden izler.

## Bildirim sistemi

- In-app toast
- Socket.io realtime event
- FCM push
- Bildirim turleri: yeni gorev, onay, red, eslesme, challenge, sezon, QR nearby, QR reward won
