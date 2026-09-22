# Solo Leveling Fitness — 6 Yeni Özellik İçin Uygulama Planı

Bu belge, Solo Leveling Fitness uygulamasına entegre edilecek 6 yeni özelliğin mimari, teknik ve arayüz detaylarını içermektedir.

---

## 1. Genel Kapsam ve Özellikler

1. **Push Bildirimler & Hatırlatmalar (Notification System):** Su, idman zamanı, gece yarısı hesaplaşması ve streak kurtarma hatırlatıcıları.
2. **Uyku Takip Widget'ı (Sleep Tracker UI):** Dashboard üzerinde Solo Leveling temalı interaktif uyku süresi/kalitesi giriş kartı.
3. **Takvimde İdman Geçmişi Gösterimi (Calendar Workout History):** `CalendarScreen` üzerinde idman yapılan günlerin neon göstergelerle işaretlenmesi ve tıklandığında idman özetinin açılması.
4. **Başarım Popup Animasyonu (Sinematik Achievement Modal):** Basit SnackBar yerine ses efektli, neon parıltılı ve kademe yıldızlı Solo Leveling sistem pop-up'ı.
5. **İlerleme Fotoğrafları (Transformation Gallery):** Profil ekranında kilo/tarih etiketli gelişim fotoğrafları, zaman çizelgesi ve Önce/Sonra (Before/After) karşılaştırma vizörü.
6. **Dinamik Zorluk Ayarlama (DDA Engine - Dynamic Difficulty Adjustment):** Son 7-14 günlük performans ve streak verilerine göre zorluk seviyesini akıllıca adapte eden motor.

---

## 2. Modül Detayları

### Modül 1: Push Bildirimler & Hatırlatmalar (Local Notification Service)
- **Hedef:** Kullanıcıya uygulama kapalıyken veya arka plandayken düzenli aralıklarla su içme, antrenman vaktini haber verme ve gece hesaplaşması hatırlatmaları göndermek.
- **Teknoloji:** `flutter_local_notifications` paketi.
- **Bileşenler:**
  - `lib/core/services/notification_service.dart`: Bildirim kanalları (`solo_water_channel`, `solo_workout_channel`, `solo_system_channel`).
  - `suHatirlaticisiAyarla()`: Belirlenen periyotlarda (örn. her 2 saatte bir) su içme bildirimi.
  - `idmanHatirlaticisiAyarla(TimeOfDay)`: İdman günlerinde belirlenen saatte zindan çağrısı.
  - `geceRaporuBildirimi(String ozet)`: Gece yarısı hesaplaşması rapor bildirimi.
  - `testBildirimiGonder()`: Ayarlar / Profil ekranından anında test bildirimi tetikleme.
- **Arayüz Entegrasyonu:** `ProfileScreen` bildirim tercihleri anahtarları (Su bildirimleri, İdman saati seçimi).

### Modül 2: Uyku Takip Widget'ı (Sleep Tracker UI)
- **Hedef:** Dashboard'da eksik olan uyku takip arayüzünü Solo Leveling "RECOVERY CHAMBER" estetiğiyle sunmak.
- **Bileşenler:**
  - `lib/widgets/sleep_tracker_card.dart`:
    - +/- interaktif butonlar ve uyku süresi göstergesi.
    - Dinamik durum: `<6h` (Yetersiz - MP Cezası uyarısı), `7-9h` (Optimal Yenilenme - +2 MP & Yorgunluk Düşüşü), `>9h` (Derin İyileşme).
  - `SystemMemory.uyunanSaat` güncellemesi ve kalıcı depolama.
  - Gece hesaplaşması algoritması ile doğrudan senkronizasyon.

### Modül 3: Takvimde İdman Geçmişi Gösterimi (Calendar Workout History)
- **Hedef:** Avcının geriye dönük antrenman disiplinini takvim üzerinde neon göstergelerle takip edebilmesi.
- **Bileşenler:**
  - `lib/screens/calendar_screen.dart`:
    - `SystemMemory.idmanGecmisi` kayıtlarının taranarak antrenman yapılan günlerin parlak neon mavi/altın rozetlerle işaretlenmesi.
    - Güne tıklandığında açılan `_idmanGecmisDetayModal`: Antrenman süresi, tamamlanan hareket sayısı, yakılan tahmini kalori ve EXP dökümü.

### Modül 4: Sinematik Başarım Popup Animasyonu (Achievement Modal)
- **Hedef:** Başarım kazanıldığında gösterilen basit SnackBar yerine Solo Leveling atmosferine yakışır sinematik bir modal pencere.
- **Bileşenler:**
  - `lib/widgets/achievement_dialog.dart`:
    - `[ SYSTEM ANNOUNCEMENT: ACHIEVEMENT ASCENDED ]` başlığı.
    - Parıltılı animasyon, kademe yıldızları (★★★★☆☆).
    - Kazanılan unvan ve stat bonusları.
    - Açılışta `AudioSystem.playLevelUp()` ses efekti.

### Modül 5: İlerleme Fotoğrafları (Transformation Gallery)
- **Hedef:** Avcının fiziksel değişimini fotoğraflarla kronolojik olarak kayıt altına alması.
- **Bileşenler:**
  - `lib/widgets/progress_gallery_modal.dart`:
    - Kronolojik fotoğraf albümü (Tarih, kilo, not etiketleri).
    - **Before / After Split Viewer:** İlk günkü fotoğraf ile en son günkü fotoğrafı yan yana koyup karşılaştırma olanağı.
  - `SystemMemory` ve `MemoryStorage` içerisinde görsel metadata serileştirme desteği.

### Modül 6: Dinamik Zorluk Ayarlama Motoru (DDA Engine)
- **Hedef:** Avcının performansına göre antrenman hacmini ve görev hedeflerini akıllıca adapte etmek.
- **Bileşenler:**
  - `lib/core/dynamic_difficulty_engine.dart`:
    - Son 7 günün görev tamamlama oranı >= %90 ve streak bozulmadıysa kademe artırma önerisi (Normal -> Yüksek -> Cehennem).
    - Tamamlama oranı < %50 veya ardışık ceza durumunda deload / toparlanma önerisi.
  - Dashboard üzerinde beliren "SYSTEM EVOLUTION / DDA ÖNERİSİ" diyalog kartı.

---

## 3. Kalite ve Doğrulama Standartları
- Mevcut 102/102 testin tamamı çalışır kalacaktır.
- `dart analyze .` çıktısında 0 hata/uyarı korunacaktır.
- Her modül için birim ve widget testleri eklenecektir.
