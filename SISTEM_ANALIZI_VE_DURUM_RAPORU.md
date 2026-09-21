# 🎮 Solo Leveling App — Sistem Analizi, Test ve Durum Raporu

**Tarih:** 2026-09-21  
**Proje:** Solo Leveling Gamification & Fitness App  
**Platform:** Flutter / Dart  
**Rapor Kapsamı:** Kod tabanı analizi, otomatik test doğrulamaları (39/39 test), dövüş sporcusu ağırlık & odak bölgeleri entegrasyonu, sistem uyanış bekleme modalı, Gemini AI antrenman üretimi ve Diyetisyen listesi entegrasyon yol haritası.

---

## 📑 İçindekiler
1. [Test Sonuçları ve Doğrulama Durumu](#1-test-sonuçları-ve-doğrulama-durumu)
2. [Çalışmayan, Eksik veya Tam Çalışmayan Noktalar](#2-çalışmayan-eksik-veya-tam-çalışmayan-noktalar)
3. [Tam Çalışan Sistemler ve Buton Listesi](#3-tam-çalışan-sistemler-ve-buton-listesi)
4. [Sistem Tamamlandığında Olacak Özellikler (Nihai Vizyon)](#4-sistem-tamamlandığında-olacak-özellikler-nihai-vizyon)
5. [Aktif Yol Haritası ve Sıradaki Geliştirmeler](#5-aktif-yol-haritası-ve-sıradaki-geliştirmeler)

---

## 1. Test Sonuçları ve Doğrulama Durumu

Tüm test paketleri Flutter test altyapısı ve Dart SDK analizi ile çalıştırılarak kontrol edilmiştir.

### 🧪 Otomatik Test Paketi Sonuçları
Mevcut **11 test paketi ve toplam 55 test senaryosunun tamamı başarıyla geçmektedir**:

| Test Dosyası | Test Sayısı | Durum | Kapsam |
|---|:---:|:---:|---|
| [`test/assessment_flow_widget_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/assessment_flow_widget_test.dart) | 7 | ✅ GEÇTİ | 4 Adımlı Wizard, çoklu dövüş branşı, 1RM dövüş ağırlık testleri, odak bölgeleri, canlı rank rozeti, Profile ve Dashboard banner senkronizasyonu |
| [`test/system_features_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/system_features_test.dart) | 17 | ✅ GEÇTİ | Su takibi, çanta/envanter, makrolar, Data Vault JSON yedek/geri yükleme, zindan ödülleri, **hedef odak bölgelerine göre dinamik antrenman uyarlaması**, rank ve dövüş katsayıları |
| [`test/exercise_coach_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/exercise_coach_test.dart) | 7 | ✅ GEÇTİ | Avcı Taktik Kartı, Akıllı Alternatif Değiştirici (Smart Swap), SetKaydi serileştirmesi, RestTimer ve Detail Modal widget testleri |
| [`test/workout_experience_flow_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/workout_experience_flow_test.dart) | 4 | ✅ GEÇTİ | Dashboard taktik kartı ve swap akışı, Aktif İdman Set Logger & Rest Timer, **Zindana Ek Hareket Enjekte Etme ve Silme Akışı**, Workout Planner taktik butonları |
| [`test/youtube_helper_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/youtube_helper_test.dart) | 4 | ✅ GEÇTİ | Egzersiz başlık sanitizasyonu, [COMBAT]/[PHY] etiketleri ve set/tekrar ayıklama testleri |
| [`test/gemini_integration_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/gemini_integration_test.dart) | 2 (21 adım) | ✅ GEÇTİ | Profil ekranı API anahtarı yönetimi ve Diyet ekranı AI besin çözücü widget entegrasyonu |
| [`test/language_switch_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/language_switch_test.dart) | 5 | ✅ GEÇTİ | Türkçe/İngilizce çift dil dinamik geçişi, unvanlar, hedefler ve fallback |
| [`test/midnight_reset_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/midnight_reset_test.dart) | 2 | ✅ GEÇTİ | Gece yarısı hesaplaşmasında yalnızca değerlendirilen günün sıfırlanması ve Gemini model kalıcılığı |
| [`test/macro_lab_navigation_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/macro_lab_navigation_test.dart) | 2 | ✅ GEÇTİ | Diyet ekranından Makro Laboratuvarı geçişi ve geçersiz kalori girişinde çökme koruması |
| [`test/main_routing_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/main_routing_test.dart) | 2 | ✅ GEÇTİ | Yeni kullanıcıda `SetupScreen`, kayıtlı kullanıcıda `AnaEkran` yönlendirmesi |
| [`test/workout_library_navigation_test.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/test/workout_library_navigation_test.dart) | 2 | ✅ GEÇTİ | Status ve Workout Planner ekranlarından Antrenman Kütüphanesine geçiş ve render doğrulaması |

### 🔍 Statik Kod Analizi (`dart analyze`)
- **Hata (Error):** 0
- **Uyarı (Warning):** 0
- **Durum:** `No issues found!` (Tamamen temiz kod tabanı).

---

## 2. Çalışmayan, Eksik veya Tam Çalışmayan Noktalar

### ✅ 1. Profil Ekranı — "TAKE TEST" (Awakening Test) Butonu [TAMAMLANDI]
- **Dosya:** [`lib/screens/profile_screen.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/lib/screens/profile_screen.dart)
- **Çözüm:** `_awakeningTestDialog()` metodu modüler [`lib/widgets/awakening_test_dialog.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/lib/widgets/awakening_test_dialog.dart) ile birleştirildi. Kullanıcı Bench Press, Squat, Deadlift veya Calisthenics tekrar sayılarını girdiğinde canlı olarak toplam güç, güç/vücut ağırlığı katsayısı ve atanacak Avcı Rütbesi (E-Rank'ten S-Rank'e) hesaplanmakta, ilk uyanışta bonus +100 EXP ve +3 AP ödülü verilerek SharedPreferences ve Data Vault'a kaydedilmektedir.

### ✅ 1.1. Başlangıç Değerlendirmesi, Dövüş Ağırlık Testleri & Odak Bölgeleri [TAMAMLANDI]
- **Dosyalar:** 
  - [`lib/controllers/system_memory.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/lib/controllers/system_memory.dart)
  - [`lib/screens/setup_screen.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/lib/screens/setup_screen.dart)
  - [`lib/screens/dashboard_screen.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/lib/screens/dashboard_screen.dart)
  - [`lib/screens/profile_screen.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/lib/screens/profile_screen.dart)
  - [`lib/widgets/awakening_test_dialog.dart`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/lib/widgets/awakening_test_dialog.dart)
- **Geliştirilen Özellikler:**
  1. **4 Adımlı RPG Sihirbazı (`SetupScreen`):** Bütün soruların alt alta yığılması engellendi; 4 aşamalı temiz akışa dönüştürüldü:
     - **Phase 01 (Identity):** Avcı adı, cinsiyet, doğum tarihi, avatar ve Gemini API anahtarı.
     - **Phase 02 (Body Calibration):** Boy, kilo, hedef, zorluk seviyesi ve **Full Body Scan (Göğüs, Bel, Kol, Bacak cm)** alanları.
     - **Phase 03 (Combat & Gear):** **"Dövüş Sporları / Boks Yapıyor Musun?"** toggle'ı, **Çoklu Branş Seçimi** (Boks, Kickboks, Muay Thai, MMA, Güreş), **Öncelikli Odak & Yağ Yakım Bölgeleri** (Karın & Göbek, Göğüs vb.), ekipman türü ve eklem koruması.
     - **Phase 04 (Awakening Test):** Dövüş sporcusu için hem 4 kondisyon metriği hem de **1RM Halter/Kuvvet Egzersizleri (Bench, Squat, Deadlift)**; fitness için 1RM ve Calisthenics modu.
  2. **Dövüş Sporcusu Kuvvet Entegrasyonu (`hesaplaDovusRank`):** Halter kuvvet oranı (`Big 3 / Kilo`) dövüş skoru ile birleştirilerek yumruk patlayıcılığı ve gövde direnci puanlandı; kaldırılan ağırlıklar profildeki 1RM kartlarına da kaydedildi.
  3. **Öncelikli Odak Bölgeleri Entegrasyonu:** Karın/göbek ve göğüs yağ yakımı seçildiğinde antrenman günlerinin sonuna `[FOCUS-CORE]` ve `[FOCUS-CHEST]` bitirici protokolleri dinamik eklendi.
  4. **Sistem Uyanış Yükleme Ekranı:** "AWAKEN THE SYSTEM" tıklandığında API ve ayarları denetleyen Solo Leveling temalı *"LÜTFEN BEKLEYİNİZ"* bildirim modalı eklendi.
  5. **Dashboard Unvan Uyumsuzluğu Düzeltildi:** `TranslationManager.rankTitle` güncellenerek unvan gerçek `SystemMemory.hunterRank` ile senkronize edildi.
  6. **Retest Diyalogunda 1RM + Combat Stamina:** `AwakeningTestDialog` içinde dövüşçüler hem kondisyon hem de ağırlık testlerini girerek seviye yükseltebilecek hale getirildi.
  7. **Rütbe Atlama Kotaları & Sayaç:** Seviyeye göre sınav kotaları tamamlandığında `[ ⚔️ RANK PROMOTION TRIAL READY ]` görevi açılmaktadır.dı (E: 8 idman, D: 12 idman, C: 16 idman, B: 24 idman, A/S: 32 idman). Kota dolduğunda `DashboardScreen`'de altın rengi `[ ⚔️ RANK PROMOTION TRIAL READY ]` görevi açılır.
  6. **Data Vault Koruma:** Dövüş branşı, vücut ölçümleri (göğüs, bel, kol, bacak), test tarihleri ve idman sayaçları yedekleme/geri yükleme (Data Vault) mekanizmasına entegre edildi.

### 🟡 2. Arka Plan Servisi ve İş Yöneticisi (Background Service / Workmanager)
- **Dosya ve Satır:** [`pubspec.yaml`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/pubspec.yaml) & [`lib/controllers/system_memory.dart:923`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/lib/controllers/system_memory.dart#L923)
- **Mevcut Durum:** `flutter_background_service: ^5.1.0` ve `workmanager: ^0.5.2` bağımlılıklara eklenmiştir, ancak kod içinde başlatılmamıştır (`// Arkaplan servisine idman başladığını bildir (İleride eklenecek)`).
- **Çalışma Şekli:** Aktif antrenman ve boks sayacında `WakelockPlus` (ekranın kapanmasını engelleme) ve `WidgetsBindingObserver` (ekran kilitlenip açıldığında aradaki süreyi telafi etme) sorunsuz çalışmaktadır. Ancak uygulama tamamen arka plana atıldığında veya kapatıldığında periyodik yerel bildirim/servis mekanizması henüz aktif değildir.

### 🟡 3. Diyet Ekranı — Doğrudan Kamera ile Çekim Eksikliği
- **Dosya ve Satır:** [`lib/screens/diet_screen.dart:121`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/lib/screens/diet_screen.dart#L121)
- **Mevcut Durum:** AI Besin Çözücü modalında fotoğraf seçimi yalnızca galeriden (`ImageSource.gallery`) yapılmaktadır. Kullanıcının doğrudan kamera vizörünü açıp tabağın fotoğrafını çekmesi için Kamera/Galeri seçici modalı bulunmamaktadır.

### 🟡 4. YouTube URL Yönlendirmeleri
- **Dosya ve Satır:** [`lib/screens/workout_library_screen.dart:1044`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/lib/screens/workout_library_screen.dart#L1044)
- **Mevcut Durum:** Kütüphanedeki YouTube butonları `url_launcher` ile açılmaktadır. Cihazda internet veya uygun tarayıcı/YouTube uygulaması bulunmadığı durumlar için hata yakalama (try/catch) mevcuttur ancak internet yoksa video açılamaz.

---

## 3. Tam Çalışan Sistemler ve Buton Listesi

Uygulamanın şu anda eksiksiz ve hatasız çalışan bileşenleri ve buton işlevleri:

### 1. 🤖 Gemini Yapay Zeka Entegrasyonu (REST Tabanlı)
- **Profil Ekranı (`SET KEY`):** Kullanıcı maskeli biçimde API anahtarı girebilir, kaydedebilir ve SharedPreferences'ta saklayabilir.
- **Profil Ekranı (`DIAGNOSTIC`):** Canlı REST bağlantı testi yapar, çalışan Gemini modelini keşfeder (`gemini-3.6-flash`, `gemini-3.5-flash`, `gemini-3.1-pro`), `CORE ONLINE` sistem bildirimi üretir.
- **Diyet Ekranı (`DECODE WITH AI`):** Serbest dille yazılan karmaşık yemekleri ve tabak fotoğraflarını saniyeler içinde analiz ederek yemek adı, toplam kalori, protein, karbonhidrat ve yağ değerlerini form alanlarına otomatik doldurur.
- **Antrenman Planlayıcı (`AI SMART TRAINER`):** Avcının statüleri, rank'i ve vücut sınıfına göre Gemini'den akıllı haftalık antrenman programı türetir.
- **Profil Ekranı (`VISUAL AWAKENING`):** Profil fotoğrafını Gemini ile analiz eder, prompt oluşturur ve Pollinations AI üzerinden avcı avatarı üretir.

### 2. 💧 Su Takibi Sistemi (Hydration Core)
- **Diyet Ekranı:** Günlük su ihtiyacını (varsayılan 3000 ml) neon ilerleme çubuğuyla gösterir.
- **`+250 ml` ve `+500 ml` Butonları:** Su miktarını artırır ve hafızaya yazar.
- **Yenileme Butonu (`refresh`):** Günlük su sayacını sıfırlar.
- **Gece Yarısı Entegrasyonu:** Su hedefine ulaşılmışsa gece yarısı hesaplaşmasında ekstra **+5 HP** ve **+10 EXP** ödülü verilir ve yeni gün başlangıcında sayaç sıfırlanır.

### 3. 🎒 Avcı Çantası & Sistem Mağazası (Hunter's Bag & Shop)
- **Mağaza Ekranı:**
  - *Healing Potion (150 G):* HP'yi anında %100 doldurur.
  - *Water of Lethe (1000 G):* Dağıtılan tüm statüleri 10'a sıfırlar ve AP puanlarını iade eder.
  - *Minor Cheat / Cheat Meal / Endless Feast (200 - 2000 G):* Gece yarısı kalori aşım cezasını bypass eden `bugunCheatMealAktif` buff'ını açar.
  - *Sloth Day (1500 G):* Yapılmayan görev cezalarını engelleyen `bugunSlothDayAktif` buff'ını açar.
  - *Gaming Pass (300 G):* 2 saatlik cezasız oyun/dinlenme buff'ı verir.
  - *Material: New Gear (5000 G):* Gerçek hayat ödül hakkı sağlar.
- **Çanta Modalı (`shop_screen.dart` AppBar):** Satın alınan eşyaları `x1, x2` şeklinde istifler ve her eşyanın yanındaki **`USE` (KULLAN)** butonuyla eşyayı tüketip ilgili buff veya aksiyonu tetikler.

### 4. 🥩 Yemek Makro Takibi (P / C / F)
- **Görsel Diyet Listesi:** Tüketilen her öğünün altında `P: Xg | C: Yg | F: Zg` dökümü canlı olarak listelenir.
- **Dinamik Getters:** `SystemMemory.bugunProtein`, `bugunKarb`, `bugunYag` toplamları otomatik toplanır.
- **Silme Butonu:** Eklenen yemeği listeden çıkarır, kaloriyi ve makroları toplamdan düşer.
- **Arşiv Butonu (`history`):** Geçmiş günlerin yemeklerini ve toplam kalorilerini listeleyen açılır pencere.

### 5. 🧪 Görsel Makro Laboratuvarı (`macro_dashboard_screen.dart`)
- Diyet ekranındaki `Macro Lab` butonuyla açılır.
- Dairesel grafiklerle günlük protein, karbonhidrat, yağ hedeflerini gösterir.
- Metabolizma hızı ve hedefe (Kilo Ver, Koru, Kilo Al) göre öğün zamanlama ve dağılım analizleri sunar.

### 6. 📚 YouTube Destekli Antrenman Kütüphanesi (`workout_library_screen.dart`)
- Kas gruplarına göre kategorize edilmiş 875+ satırlık egzersiz veritabanı.
- **`ASSIGN TO PLAN`:** Seçilen şablonun tüm egzersizlerini haftanın istenen gününe toplu aktarır.
- **`Plana Ekle` (`playlist_add`):** Tekil hareketi istenen günün `Gorev` listesine aktarır.
- **YouTube Oynat Butonu:** Doğru form videosunu YouTube üzerinden açar.
- **Özel Hareket & Düzenleme Modu:** Kullanıcının kendi egzersizlerini eklemesine, sıralamasına veya varsayılana sıfırlamasına olanak tanır.

### 7. 🥊 Boks / Zindan Simülasyonu (`boxing_timer_screen.dart`)
- **Hazır Parkurlar:** İp Atlama, Koşu, Boks Torbası, Eğimli Yürüyüş parkurları.
- **Serbest Raundlar:** Raund sayısı, çalışma ve dinlenme süreleri özelleştirilebilir.
- **Zil & Geçiş Sesleri:** Raund başı ve dinlenme geçişlerinde ses efektleri çalar.
- **Kayıp Zaman Telafisi:** Ekran kilitlendiğinde geçen süreleri arka plandan çıkınca sayaca işler.
- **Ödül Mekanizması:** İdman bittiğinde `zindanAkiniBitir` çağrılır, idman dakikası ve geçmişi kaydedilir, Altın ve EXP ödülleri verilir.

### 8. ⚔️ RPG Stat Sistemi & Seviye Atlama
- **HP / MP / EXP / AP Barları:** Canlı animasyonlu progress barları.
- **AP Dağıtımı (`StatusScreen`):** AP > 0 olduğunda STR, VIT, AGI, INT, PER yanında `+` butonları belirir; stat artırıldığında AP düşer, HP/MP tavanları dinamik hesaplanır.
- **Uyku Saati (`+ / -`):** Uyunan saati günceller, gece yarısı can yenilenmesini etkiler.
- **Görev Checkbox'ları:** Görevleri tamamlandı olarak işaretler, başarı sesini çalar ve kaydeder.

### 9. 🩸 Kırmızı Geçit (Red Gate) & Gölge Modu (Stealth Mode)
- **Kırmızı Geçit:** 1 - 14 gün seçilerek başlatılır. Kalori aşımı veya görev ihmali 3 kat hasar (-60 HP) verir. EXP ve Altın çarpanları 3 katına çıkar. Can sıfırlanırsa -1 Level cezası uygulanır.
- **Kırmızı Geçitten Kaçış (`ESCAPE`):** Ağır altın veya can cezası ödenerek erken çıkış yapılır.
- **Gölge Modu (Stealth):** Yoğun günlerde cezaları ve streak kırılmasını devre dışı bırakır.

### 10. 👹 Haftalık Zindan Bossu (`dashboard_screen.dart`)
- Pazar günleri fiziksel (*Steel-Fanged Wolf*) veya zihinsel (*Ancient Lich*) boss belirir.
- Görevler ve diyet başarısıyla boss'a hasar verilir.
- Boss mağlup edildiğinde +1000 Altın, +2 AP, +500 EXP ödülü verilir.

### 11. 💾 Veri Kasası (Data Vault — Backup & Restore)
- **`EXPORT`:** Tüm oyuncu durumu, statlar, seviye, envanter, antrenman, kilo ve yemek geçmişini şifrelenmiş JSON olarak panoya kopyalar.
- **`RESTORE`:** Yapıştırılan yedek JSON metnini doğrulayarak (`importBackupJson`) oyuncu profilini sıfır hata ile eksiksiz geri yükler.

### 12. 🌐 Çift Dil Sistemi (TR / EN)
- Profil ekranındaki dil değiştirici ile tüm arayüz, stat adları, görevler ve sistem bildirimleri anında Türkçe veya İngilizce'ye çevrilir.

---

## 4. Sistem Tamamlandığında Olacak Özellikler (Nihai Vizyon)

Uygulamanın eksikleri giderilip tam sürüme ulaştığında sahip olacağı nihai özellikler:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        SOLO LEVELING APP (FULL)                       │
├────────────────────────────────────────────────────────────────────────┤
│ 1. AWAKENING TEST & RANK SİSTEMİ (1RM & Güç Tespiti) [TAMAMLANDI]      │
│    • Bench Press, Squat, Deadlift ağırlıkları girilir.                 │
│    • Vücut ağırlığına oranlanarak güç katsayısı hesaplanır.            │
│    • Avcıya resmi rütbe verilir: E -> D -> C -> B -> A -> S-Rank.       │
│                                                                        │
│ 2. DİNAMİK ANTRENMAN & KARAR MOTORU (Yeni Eklenecek Ana Omurga)        │
│    • Akıllı Onboarding: Hedefe göre dallanan dinamik soru seti.        │
│    • Seans İçi Feedback: RIR/RPE ("Kaç tekrar daha yapabilirdin?").    │
│    • Seans Sonu & Kardiyo: Konuşma testi (Zone 2), tempo, eklem konforu│
│    • Haftalık Karar Motoru: Ağırlık/hacim artışı, deload, sakatlık kor.│
│    • Uyanış Zindanı (Promotion Trial): Periyodik rank atlama sınavları.│
│                                                                        │
│ 3. ARKA PLAN BİLDİRİM SERVİSİ (Workmanager & Background Service)       │
│    • Sabah Uyanış Bildirimi: "Avcı, günlük görevlerin hazır!"          │
│    • Hidrasyon Hatırlatıcısı: "Sistem Bildirimi: Sıvı seviyeniz düşük!"│
│    • Gece Yarısı Teşhisi: Uygulama kapalıyken de ceza/ödül hesaplama. │
│                                                                        │
│ 4. CANLI KAMERA VİZÖRÜ (Direct Camera OCR / Lens)                      │
│    • Yemek eklerken doğrudan kamera ile tabak fotoğrafı çekme.         │
│    • Gemini Vision ile anında porsiyon ve makro tahmini.               │
│                                                                        │
│ 5. GİYİLEBİLİR CİHAZ & ADIMSAYAR ENTEGRASYONU (Health Connect / Kit)    │
│    • Günlük adım sayısı ve yakılan aktif kalorinin otomatik senkronu. │
│    • Kardiyo görevlerinin adımsayar ile otomatik tamamlanması.         │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 5. 🧠 Dinamik Antrenman & Soru-Karar Motoru Mimari Planı (Handover Entegrasyonu)

`antrenman-motoru-prompt-seti.md` dokümanı ve yapılan istişareler doğrultusunda, antrenman motorunun akıllı ve yaşayan bir sisteme dönüştürülmesi için 5 ana aşamalı master plan:

### 🧩 Aşama 1: Akıllı Onboarding & Başlangıç Rank Tayini (Giriş Akışı)
- **Tek Akış, Koşullu Dallanma:** 3 ayrı form yerine tek akışta:
  - *Ortak Sorular:* Yaş, boy, kilo, antrenman geçmişi (Başlangıç / Orta / İleri), haftalık gün sayısı, ekipman durumu (Tam Donanımlı Salon / Dambıl-Ev / Sadece Vücut Ağırlığı), eklem/sakatlık kısıtları.
  - *Hedefe Özel Dinamik Sorular (Koşullu):*
    - **Kas Kazanma (Hypertrophy):** Tercih edilen split türü (Push-Pull-Legs / Upper-Lower / Full Body), öncelikli odak bölgesi.
    - **Yağ Yakma (Fat Loss):** Tercih edilen kardiyo türü (Koşu, İp Atlama, Yürüyüş), haftalık kardiyo toleransı.
    - **Fiziği Koruma (Maintain):** Güç koruma odağı, zaman verimliliği tercihi.
- **Başlangıç Avcı Lisansı:** Onboarding tamamlandığında kullanıcının verileri değerlendirilir, başlangıç Hunter Rank'i (ör: *E-Rank Hunter*) atanır ve kütüphaneden seviyeye uygun başlangıç programı haftalık plana otomatik dizilir.

---

### 🏋️ Aşama 2: Seans İçi (Micro) ve Seans Sonu Geri Bildirim Sistemi
Kullanıcıyı soru yorgunluğuna sokmadan (maksimum 1-2 soru/hareket, 2-3 soru/seans sonu) veri toplama:
1. **Ağırlık Seansları:**
   - *Egzersiz Sonu (RIR / RPE):* Jargonsuz pratik soru: *"Bu seti bitirdiğinde tükenişe varmadan önce temiz formda kaç tekrar daha yapabilirdin?"* (0-1: Ağır/Maksimal, 2-3: İdeal Gelişim, 4+: Çok Kolay).
   - *Seans Sonu:* Toplam efor hissiyatı (1-10) ve Eklem Konforu (*"Herhangi bir ekleminde batma/ağrı oldu mu?"* -> Omuz, Diz, Bel, Yok).
2. **Kardiyo Seansları:**
   - *Konuşma Testi (Zone 2 Doğrulaması):* *"Kardiyo sırasında kesintisiz cümle kurabiliyor muydun?"* (Evet rahatça / Zorlukla / Sadece tek tük kelimeler).
   - *Tempo & Mesafe Uyumu:* Belirlenen hedef süre/hız tutturuldu mu?

---

### ⚙️ Aşama 3: Karar Destek Kuralları (Progressive Overload & Deload Rule-Engine)
Kullanıcıdan toplanan verilere göre sistemin uygulayacağı deterministik kurallar:
- **Kural 1 (Ağırlık/Tekrar Artışı):** Bir egzersizde üst üste 2 seans RIR $\ge 3$ (hareket çok kolay) girilmişse $\rightarrow$ Bir sonraki hafta ağırlık $+2.5 - 5$ kg veya $+2$ tekrar artırılır.
- **Kural 2 (Kardiyo İlerlemesi):** Konuşma testi "rahatça konuşabiliyordum" ve seans tamamlanmışsa $\rightarrow$ Mesafe/süre $\%10$ veya hız $+0.5$ km/s artırılır.
- **Kural 3 (Kilo Trendi x Performans Çapraz Kontrolü):**
  - *Yağ Yakmada* kilo 2 haftadır düşmüyor ama ağırlık performansı stabilse $\rightarrow$ Günlük kardiyo/adım kotası $+15$ dk artırılır.
  - *Kas Kazanmada* kilo artmıyor ve ağırlıklar tıkanmışsa $\rightarrow$ Kalori hedefi $+200$ kcal güncellenir.
- **Kural 4 (Eklem Koruma & Egzersiz Değişimi):** Bir eklemde (ör. Omuz) batma bildirildiyse $\rightarrow$ O hareket yerine kütüphaneden eklem dostu varyasyon atanır (ör. Barbell Bench Press yerine Dumbbell Floor Press veya Neutral Grip Press). 2 varyasyondan sonra ağrı sürerse hareket dinlendirmeye alınır.
- **Kural 5 (Deload Tetikleyicisi):** Üst üste 2 hafta boyunca RIR sürekli 0-1 çıkıyor, ağırlıklar düşüyor ve yorgunluk $\ge 8$ ise $\rightarrow$ Sistem otomatik olarak 1 haftalık "Hafifletilmiş Deload Zindanı" (hacim $\%40$ düşürülür) başlatır.

---

### 🏆 Aşama 4: "Uyanış Zindanı" (Promotion Trial) & Periyodik Rank Atlama
- **İlerleme Kotası:** Her rütbe için belirli bir başarılı antrenman tamamlama kotası konulur:
  - *E $\rightarrow$ D Rank:* 8 Başarılı İdman
  - *D $\rightarrow$ C Rank:* 12 Başarılı İdman
  - *C $\rightarrow$ B Rank:* 16 Başarılı İdman
  - *B $\rightarrow$ A Rank:* 24 Başarılı İdman
  - *A $\rightarrow$ S-Rank:* Ulusal Güç Sınavı (Big 3 Total $\ge 4.5\times$ BW)
- **Terfi Zindanı (Promotion Trial):** Kota dolduğunda Dashboard'da `[ RANK PROMOTION TRIAL READY ]` bildirimi yanar. Avcı teste girer. Testi geçtiğinde rank yükselir, kütüphaneden daha zorlu bileşik hareketler ve süpersetler programa enjekte edilir, devasa AP ve unvan ödülü verilir.

---

## 5. 🚀 Aktif Yol Haritası ve Sıradaki Geliştirmeler

Kullanıcı ile onaylanan güncel master geliştirme sırası:

### 📌 FAZ 1: Gemini AI Destekli Kişiselleştirilmiş Antrenman Programı & YouTube Rehberi

#### ✅ Tamamlanan Temel Sistemler:
- **Kişiye Özel JSON Üretimi (`GeminiService.haftalikProgramUret`):** Gemini'ye avcının boy, kilo, güncel rank'i (E->S), 1RM kuvvet değerleri, dövüş branşları (Boks/MMA vb.), sakatlık kısıtları (omuz, diz vb.) ve öncelikli yağ yakım odakları (karın/göbek, göğüs) aktarılarak structured 7 günlük antrenman JSON planı oluşturulur.
- **Fail-Safe Hibrit Altyapı:** API anahtarı veya internet bağlantısı yoksa mevcut yerel algoritmik kural motoru devreye girer; uygulama asla internetsiz kalıp çökmez.
- **Tek Tuşla Yenileme Butonu:** Antrenman Planlayıcı ekranında `[ 🤖 SİSTEM AI İLE PROGRAMI YENİLE ]` butonu ile antrenman programı anında yapay zekaya revize ettirilebilir.
- **Tek Dokunuşla YouTube Video Rehberi (`YoutubeHelper`):** Egzersiz adını set/tekrar ve köşeli parantez etiketlerinden akıllıca temizleyen, Dashboard, Takvim, Antrenman Planlayıcı, Aktif İdman ve Kütüphane ekranlarından doğrudan YouTube mobil/web form videosunu açan sistem tamamlandı.
- **Solo Leveling Avcı Taktik Kartı & Akıllı Alternatif Değiştirici (Smart Swap):** Egzersize dokunulduğunda hedef kas, dövüş faydası, 3 altın kural ve dolu makine/ağrı durumunda 3 muadil hareket önerisi ve tek tuşla değiştirme.
- **Set, Ağırlık, Tekrar Takibi & Dinlenme Sayacı (Rest Timer):** Aktif idmanda set bazlı kg/tekrar loglama (`SetKaydi`) ve 30-120sn sesli Solo Leveling dinlenme sayacı.
- **Zindana Dinamik Ek Hareket Enjekte Etme & Kaldırma:** Aktif raid esnasında üst çubuktan (`+ EKLE`) ve liste sonundan (`+ EK HAREKET ENJEKTE ET`) kategorilere göre filtrelenen hızlı hareket seçim penceresi ve tek tıkla zindandan görev kaldırma.

#### ⏳ FAZ 1 İÇİN EKLENECEKLER & GELİŞTİRİLECEKLER (Sırada Bekleyenler):
1. **Daha Kapsamlı & Dolu Antrenman Hacmi (Antrenmanları Uzatma & Çeşitlendirme):**
   - *Sorun / Tespit:* Mevcut antrenman seansları çok kısa kalmakta, gün başına düşen hareket sayısı ve varyasyon az gelmektedir.
   - *Çözüm Planı:* 
     - Gemini AI prompt şablonu ve yerel kural motoru güncellenecek.
     - Gün başına standart 3-4 hareket yerine; **1-2 Ana Bileşik Hareket (Compound)** + **2-3 İzolasyon/Aksesuar Hareketi** + **1-2 Dövüş/Kondisyon/Core Bitirici Protokolü (Finisher)** şeklinde seans başına **5-7 doyurucu hareket** içeren zengin program hacmi standardı getirilecek.
2. **Antrenman Ekleme Ekranının Yeniden Düzenlenmesi (Gelişmiş Egzersiz Ekleme Modalı):**
   - *Sorun / Tespit:* Antrenmana kullanıcı manuel hareket eklemek istediğinde mevcut ekleme arayüzü kısıtlı ve pratik değildir.
   - *Çözüm Planı:*
     - Basit tek satırlı dialog yerine, 875+ hareketlik kütüphane ile entegre modern bir **"Egzersiz Ekleme Paneli"** tasarlanacak.
     - Kas grubuna göre (Göğüs, Sırt, Bacak, Omuz, Kol, Karın, Boks/Dövüş) hızlı filtreleme ve anında arama çubuğu.
     - Set sayısı, hedef tekrar ve opsiyonel hedef ağırlık belirleme alanları.
     - Seçilen hareketin YouTube önizlemesi ve taktik kartıyla birlikte tek dokunuşla ilgili güne enjekte edilmesi.

---

### 📌 FAZ 2: Diyetisyen Listesi Analizi & Dinamik İdman Yıpranma/Protein Dengeleyicisi [SIRADAKİ MASTER FAZ]
- **Diyetisyen Haftalık Listesi Yükleme (Fotoğraf / Metin):** Diyetisyenin verdiği basılı veya dijital listenin fotoğrafı çekilerek veya metni yapıştırılarak Gemini Vision ile taranır ve sisteme haftalık makro/öğün hedefi olarak kaydedilir.
- **Dinamik İdman Yıpranma Takibi (Workload Compensator):** O gün yapılan boks, kum torbası veya ağır squat/deadlift idmanının süresi ve yoğunluğuna göre harcanan ekstra kalori ve kas yıkımı hesaplanır.
- **Sistem İkazı & Ek Besin Önerisi:** Yemek ve Ana ekranda:
  *`[SİSTEM UYARISI: Bugün 90 dk yüksek yoğunluklu boks idmanı tamamlandı. Kas katabolizmasını önlemek için diyetisyen listenize +30g protein ve +450 kcal eklenmesi emredildi.]`* kartı çıkar.

---
*Bu doküman projenin kök dizininde [`SISTEM_ANALIZI_VE_DURUM_RAPORU.md`](file:///c:/Users/R%C4%B1za%20Can%20Yavuz/Desktop/%C4%B0%C5%9Fler%20Projeler/%C3%96zel%20olan%20i%C5%9Fler/solo_app/SISTEM_ANALIZI_VE_DURUM_RAPORU.md) adıyla en son sistem durumuna göre güncellenmiştir.*

