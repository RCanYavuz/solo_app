# 🎮 Solo Leveling App

**Solo Leveling** animesinden ilham alan, kişisel gelişim ve fitness takibi yapan bir **gamification (oyunlaştırma) uygulaması**. Kullanıcı bir "Avcı" (Hunter) olarak görev yapar; egzersiz, diyet ve zihinsel görevlerini tamamlayarak EXP, Gold, AP kazanır ve level atlar.

---

## 📁 Proje Mimarisi

```
lib/
├── main.dart                       # Uygulama giriş noktası ve akıllı kayıt yönlendirmesi
├── controllers/
│   └── system_memory.dart          # Tüm oyun state'i, persistence, RPG mekanikleri, görev döngüsü
├── core/
│   ├── audio_system.dart           # Ses efektleri yönetimi (mixWithOthers desteği)
│   ├── diyet_motoru.dart           # Makro besin (Protein/Karb/Yağ) ve kalori hesaplama motoru
│   ├── sistem_gecisi.dart          # Hologram sayfa geçiş animasyonu
│   └── services/
│       └── gemini_service.dart     # Google Gemini AI servisi (Doğal dil besin analizi & Sistem sesi)
├── models/
│   ├── task_model.dart             # Görev (Gorev) veri modeli
│   ├── food_model.dart             # Tüketilen yemek (TuketilenYemek) veri modeli
│   ├── workout_model.dart          # Egzersiz şablonu (EgzersizSablonu) veri modeli
│   └── inventory_item_model.dart   # Avcı çantası eşya (InventoryItem) modeli
├── screens/
│   ├── ana_ekran.dart              # Ana navigasyon kabuğu (Bottom Navigation)
│   ├── dashboard_screen.dart       # Dashboard — Level, Stat, Başarımlar, Haftalık Boss
│   ├── status_screen.dart          # Stat dağıtımı, HP/MP barları & Antrenman Kütüphanesi köprüsü
│   ├── calendar_screen.dart        # Haftalık görev takvimi (Quest Log & Streak)
│   ├── diet_screen.dart            # Kalori & yemek envanteri + Gemini AI Besin Çözücü
│   ├── macro_dashboard_screen.dart # Görsel Makro Laboratuvarı (Besin oranları, öneriler)
│   ├── profile_screen.dart         # Profil, vücut verileri + Gemini API Key Yönetimi & Tanılama
│   ├── setup_screen.dart           # İlk kurulum (Hunter adı, boy, kilo, hedef, opsiyonel API Key)
│   ├── welcome_screen.dart         # Sistem uyanış ve karşılama ekranı
│   ├── instruction_screen.dart     # Sistem kuralları ve avcı el kitabı
│   ├── active_workout_screen.dart  # Aktif antrenman modu (Dungeon Raid kronometresi)
│   ├── workout_planner_screen.dart # Haftalık antrenman planlayıcı & kütüphane bağlantısı
│   ├── workout_library_screen.dart # YouTube destekli hazır antrenman kütüphanesi
│   ├── boxing_timer_screen.dart    # Boks ve aralıklı antrenman zamanlayıcısı
│   └── shop_screen.dart            # Sistem Mağazası (İksirler, Kaçamak Hakları, Eşyalar)
└── widgets/
    ├── hologram_card.dart          # Neon parlamalı hologram kart widget'ı
    └── stat_bar.dart               # HP/MP/EXP ilerleme çubuğu widget'ı
```

### Katman Yapısı

| Katman | Bileşenler | Rol |
|--------|------------|-----|
| **Controllers** | `system_memory.dart` | Oyun durumu, kalıcılık (SharedPreferences), RPG formülleri, gece yarısı hesaplaşması |
| **Core & Services** | `gemini_service.dart`, `diyet_motoru.dart`, `audio_system.dart`, `sistem_gecisi.dart` | Yapay zeka servisleri, beslenme algoritmaları, ses efektleri, görsel geçişler |
| **Models** | `task_model.dart`, `food_model.dart`, `workout_model.dart` | Tip güvenli veri modelleri ve JSON serileştirme |
| **Screens** | 15 ekran | Kullanıcı arayüzü ve navigasyon akışları |
| **Widgets** | `hologram_card.dart`, `stat_bar.dart` | Tema uyumlu, yeniden kullanılabilir UI bileşenleri |
| **Tests** | 5 test paketi (`test/`) | Yönlendirme, navigasyon, runtime koruma, AI ve mantık testleri |

---

## 🎯 Temel Özellikler

### 1. 🤖 Gemini Yapay Zeka Entegrasyonu (Gemini 3.6 Flash & Next-Gen Core)
- **Doğrudan REST & Çoklu Model Desteği:** Google'ın en güncel **`gemini-3.6-flash`**, `gemini-3.5-flash` ve `gemini-3.1-pro` modelleriyle tam uyumlu, SDK bağımlılığı olmadan doğrudan çalışan yüksek hızlı REST mimarisi.
- **AI Besin & Makro Çözücü (Natural Language AI Decoder):** Yemek ekleme penceresinde serbest dille yazılan karmaşık öğünleri (*ör: "2 haşlanmış yumurta, 1 dilim tam buğday ekmeği, 50g lor ve 5 zeytin"*) Gemini yapay zekasıyla saniyeler içinde analiz eder; yemek adını, toplam kaloriyi, protein, karbonhidrat ve yağ makrolarını ayrıştırıp forma otomatik işler.
- **"Sistem" Uyanış & Canlı Teşhis (The System Voice & Live Diagnostic):** Solo Leveling evrenindeki otoriter ve disiplinli "Sistem" sesini simüle eder. Profil ekranındaki **`DIAGNOSTIC`** butonuyla avcının durumunu denetler, canlı model keşfi yapar ve `[BİLDİRİM]` formatında RPG atmosferli sistem uyanış mesajları üretir (`CORE ONLINE`).
- **Güvenli API Anahtarı Yönetimi:** Profil ekranındaki **`SET KEY`** modalı üzerinden maskeli biçimde API anahtarı girilebilir, güncellenebilir veya test edilebilir. Anahtarlar Git depolarına sızmaz; tarayıcının ve cihazın güvenli yerel hafızasında (`SharedPreferences`) saklanır.
- **Akıllı Model Kalıcılığı & Otomatik Migrasyon:** Keşfedilen çalışan model ve anahtar oturumlar arasında korunur; eski/kapatılmış model isimleri (`gemini-1.5-flash` vb.) otomatik olarak en güncel `gemini-3.6-flash` motoruna taşınır.

### 2. 🧪 Görsel Makro Laboratuvarı (Macro Lab) (YENİ)
- `diet_screen.dart` ve `diyet_motoru.dart` ile tam entegre çalışan analitik ekran.
- Kullanıcının vücut tipi, metabolizma hızı ve hedefine göre önerilen protein, yağ ve karbonhidrat dengesini dairesel grafik ve animasyonlu göstergelerle sunar.
- Öğün zamanlama önerileri ve kalori dağılım analizleri içerir.

### 3. 📚 YouTube Destekli Antrenman Kütüphanesi (Workout Library) (YENİ)
- `StatusWindow` ve `WorkoutPlannerScreen` AppBar'larından doğrudan erişilebilir.
- Kas gruplarına göre kategorize edilmiş 875+ satırlık kapsamlı hareket rehberi.
- YouTube üzerinden doğru form videolarına tek tuşla yönlendirme ve kişiselleştirilmiş programlara hareket aktarma imkanı.

### 4. 🧭 Akıllı Yönlendirme & Yaşam Döngüsü (Smart Routing)
- Kullanıcı daha önce kayıt olmuşsa açılışta doğrudan `AnaEkran`'a geçer; kayıt bulunmadığında ilk kurulum ekranı (`SetupScreen`) açılır.
- **Gece Yarısı Görev Döngüsü:** Tarih değiştiğinde yalnızca tamamlanan günün görevleri sıfırlanır, haftanın diğer günlerinin kayıtları korunur.

### 5. ⚔️ RPG Stat Sistemi
- **HP / MP:** Sağlık ve Mana puanları (görev başarısı, diyet ve uykuya bağlı).
- **Level / EXP:** Deneyim puanı ve seviye atlama (EXP eşiği her level'da × 1.5 ölçeklenir).
- **AP (Ability Points):** Her level atlayışında +3 AP kazanılır; STR, AGI, VIT, INT, PER özelliklerine dağıtılır.
- **5 Ana Stat:**
  - **STR (Kuvvet):** Fiziksel güç antrenmanlarıyla artar.
  - **AGI (Çeviklik):** Bacak ve kardiyo egzersizleriyle gelişir.
  - **VIT (Dayanıklılık):** Mükemmel antrenman ve dinlenme ile yükselir, HP barını büyütür.
  - **INT (Zeka):** Okuma ve zihinsel görevlerle gelişir, MP barını büyütür.
  - **PER (Algı):** Meditasyon ve strateji pratikleriyle artar.
- **Altın (Gold):** Görevler ve zindan akınlarıyla kazanılır, Sistem Mağazasında harcanır.

### 6. 📋 Günlük Görevler & Streak Takibi
- 7 günlük haftalık program: Her gün için özelleştirilmiş **Fiziksel** ve **Zihinsel** görevler.
- Günlük görevlerin tamamı bittiğinde **Flawless Streak** artar.
- İhmal edilen görevler HP/MP cezalarına ve streak kırılmasına yol açar.

### 7. 🩸 Kırmızı Geçit (Red Gate) — Cehennem Modu
- Seçilen gün sayısı boyunca avcıyı kilit altına alan yüksek zorluklu meydan okuma.
- **3× Ceza Katsayısı:** Kalori aşımı veya görev ihmali ölümcül hasar verir (-60 HP).
- **3× Ödül Katsayısı:** Katlanan EXP ve Altın çarpanları.
- **Ölüm Riski:** HP sıfırlanırsa -1 Level cezası uygulanır.
- Başarıyla tamamlandığında devasa AP, Altın ve EXP ödülü verilir.

### 8. 🌙 Gölge Modu (Stealth Mode)
- Gerçek hayat yoğunluğunda cezaları geçici olarak devre dışı bırakır.
- Streak dondurulur, boss cezaları uygulanmaz.

### 9. 👹 Haftalık Zindan Bossu
- Her Pazar günü avcının karşısına çıkan haftalık Boss (Level × 100 HP).
- Fiziksel (*Steel-Fanged Wolf*) veya Zihinsel (*Ancient Lich*) patron türü.
- Görevler ve diyet başarısıyla boss'a hasar verilir; yenilirse devasa ganimet (+1000 Gold, +2 AP, +500 EXP) kazanılır.

### 10. 🛒 Sistem Mağazası (System Shop)

| Eşya | Fiyat | Etki |
|------|-------|------|
| Healing Potion | 150 G | HP'yi anında tamamen doldurur |
| Water of Lethe | 1000 G | Dağıtılan tüm Stat puanlarını sıfırlar ve AP iade eder |
| Minor Cheat | 200 G | Küçük atıştırmalık (ör: çikolata) cezasız tüketilir |
| Cheat Meal | 500 G | Bir serbest öğün hakkı (burger, pizza vb.) |
| Endless Feast | 2000 G | 1 tam gün serbest beslenme hakkı |
| Gaming Pass (2 Hr) | 300 G | 2 saatlik cezasız oyun/dizi hakkı |
| Sloth Day | 1500 G | Günlük görevler cezasız atlanır |
| Material: New Gear | 5000 G | Gerçek hayat ödülü (kıyafet, ekipman vb.) |

### 11. 🎵 Ses & Atmosfer Motoru
- Level Up, Quest Complete, Bell, Transition ve Dungeon ses efektleri.
- `mixWithOthers` protokolü sayesinde arka planda çalan Spotify veya YouTube müziğini kesmeden mikslenir.

---

## ⚡ Son Eklenen Özellikler & Sistem İyileştirmeleri (YENİ)

> [!WARNING]
> **DİKKAT — TEST AŞAMASI BİLDİRİMİ:**
> Aşağıdaki sistem özellikleri, arayüz bileşenleri ve mantık entegrasyonları kod seviyesinde tamamlanıp projeye eklenmiştir. Ancak başka bir test ajanı (agent) tarafından detaylı uçtan uca (E2E) fonksiyonel ve kullanıcı akış testleri gerçekleştirileceğinden, **şu ana kadar yapılan bu yeni eklemeler kullanıcı tarafında henüz test edilmemiştir / test aşamasındadır.**

### 1. 💧 Su Takibi Sistemi (Hydration Core)
- **Arayüz (`diet_screen.dart`):** Günlük tüketilen su miktarını ve hedefini (varsayılan 3000 ml) gösteren neon Solo Leveling temalı ilerleme çubuğu.
- **Hızlı Giriş Aksiyonları:** `+250 ml`, `+500 ml` butonları ve sayacı sıfırlama seçeneği.
- **Gece Yarısı Ödül & Ceza Entegrasyonu:** `SystemMemory._gunSonuHesaplasmasi` motorunda su hedefi kontrol edilir; hedefi tutturan avcıya ekstra **+5 HP** ve **+10 EXP** ödülü verilir ve yeni gün başlangıcında sayaç sıfırlanır.

### 2. 🎒 Avcı Çantası & Eşya Kullanımı (Hunter's Bag / Inventory)
- **Çanta Modalı (`shop_screen.dart`):** Mağaza ekranının AppBar'ına eklenen çanta ikonu ile satın alınan tüm eşyaların adetleriyle listelendiği modal pencere.
- **Envanter İstifleme (Stacking):** Satın alınan iksir ve buff biletleri `SystemMemory.canta` listesine eklenir ve mevcut eşyaların adetleri artırılır.
- **Canlı Eşya Kullanımı ("USE"):** Çantadaki eşyaya basıldığında `SystemMemory.esyaKullan` tetiklenir:
  - `hp_full`: Canı anında 100% doldurur (`acilSifa`).
  - `stat_reset`: Dağıtılmış statları sıfırlayarak tüm AP puanlarını iade eder.
  - `cheat_meal` / `minor_cheat` / `endless_feast`: O geceki kalori aşım cezasını bypass eden `bugunCheatMealAktif` buff'ını açar.
  - `sloth_day`: O günkü yapılmayan görev cezalarını engelleyen `bugunSlothDayAktif` buff'ını açar.

### 3. 🥩 Yemek Makro Takibi & Kalıcı Veri Modeli (P / C / F)
- **Model Genişletmesi (`food_model.dart`):** `TuketilenYemek` sınıfına kalori haricinde `protein`, `karbonhidrat` ve `yag` değişkenleri ile JSON serileştirme desteği eklendi.
- **AI & Manuel Entegrasyon:** Gemini AI tarafından çözümlenen veya kullanıcının elle girdiği makro değerleri kaydedilip SharedPreferences hafızasına yazılır.
- **Görsel Diyet Listesi:** Diyet ekranında tüketilen yemeklerin altında `P: Xg | C: Yg | F: Zg` dökümü canlı olarak listelenir; `SystemMemory.bugunProtein`, `bugunKarb`, `bugunYag` toplamları hesaplanır.

### 4. 📅 Antrenman Kütüphanesinden Haftalık Plana Aktarma (Assign to Plan)
- **Tekil Egzersiz Aktarımı (`workout_library_screen.dart`):** Kütüphanedeki her hareket satırına eklenen `Plana Ekle` (`playlist_add`) butonu ile haftanın istenen günü seçilerek hareket o günün `Gorev` listesine anında eklenebilir.
- **Toplu Şablon Aktarımı:** Şablon kartı üzerindeki `ASSIGN TO PLAN` butonu ile şablondaki tüm egzersizler tek seferde seçilen günün antrenman programına aktarılabilir.

### 5. 🥊 Boks / Zindan Simülasyonu Ödül Mekanizması (Combat Sim Rewards)
- **Antrenman Tamamlama Kaydı (`boxing_timer_screen.dart`):** Parkur ve raundlar bittiğinde `SystemMemory.zindanAkiniBitir` çağrılır.
- **Dungeon Raid Ödülleri:** Tamamlanan antrenman süresi `toplamIdmanDakikasi` ve `idmanGecmisi` kayıtlarına işlenir. Avcıya geçen dakika başına Altın (Red Gate'te 5 kat) ve EXP kazandırılır, ödül özeti ekrandaki dialog penceresinde sunulur.

### 6. 💾 Veri Kasası / JSON Yedekleme & Geri Yükleme (Data Vault)
- **Profil Kartı (`profile_screen.dart`):** Profil ekranına eklenen `DATA VAULT / ARCHIVE` hologram kartı.
- **Arşiv Dışa Aktarma (Export):** Tek tuşla tüm oyuncu profili, statlar, seviye, envanter, antrenman ve kilo geçmişini şifrelenmiş JSON olarak panoya kopyalar veya görüntüler.
- **Arşiv İçe Aktarma (Restore):** Yapıştırılan yedek JSON metnini doğrulayarak (`importBackupJson`) oyuncunun tüm profilini başka bir cihaza veya sıfır kurulum üzerine eksiksiz geri yükler.

---

## 🏆 Başarım Sistemi (Achievements)

| Başarım | Kademeler |
|---------|-----------|
| Iron Will (Streak) | 7 / 14 / 30 / 60 / 100 / 365 Gün |
| Unbreakable (Görev) | 50 / 100 / 250 / 500 / 1000 / 5000 Görev |
| Awakening (Level) | 10 / 20 / 30 / 50 / 80 / 100 Seviye |
| Warrior (STR) | 30 / 50 / 100 / 150 / 200 / 300 STR |
| Shadow Step (AGI) | 30 / 50 / 100 / 150 / 200 / 300 AGI |
| Sage (INT) | 30 / 50 / 100 / 150 / 200 / 300 INT |
| Merchant (Altın) | 2K / 5K / 10K / 50K / 100K / 500K Altın |
| Fat Burner / Titan (Kilo) | 5 / 10 / 15 / 20 / 30 / 50 KG Değişim |

---

## 🧪 Otomatik Test Paketi

Proje güvenilirliği için 10 adet kapsamlı otomatik test hazırlanmıştır:

| Test Dosyası | Kapsam |
|--------------|--------|
| [`test/main_routing_test.dart`](test/main_routing_test.dart) | Kayıtlı ve yeni kullanıcı başlangıç yönlendirmesi doğrulaması |
| [`test/workout_library_navigation_test.dart`](test/workout_library_navigation_test.dart) | Status & Workout Planner üzerinden kütüphaneye geçiş ve render testi |
| [`test/macro_lab_navigation_test.dart`](test/macro_lab_navigation_test.dart) | Diyet ekranından Makro Lab geçişi ve `FormatException` çökme koruması |
| [`test/midnight_reset_test.dart`](test/midnight_reset_test.dart) | Gece yarısı tek gün sıfırlama ve aktif model kalıcılık testi |
| [`test/gemini_integration_test.dart`](test/gemini_integration_test.dart) | Profil API anahtarı yönetimi ve Diyet ekranı AI besin çözücü widget testi |

Testleri çalıştırmak için:
```bash
flutter test
```

---

## 🛠️ Teknoloji Stack

- **Platform:** Flutter (Dart SDK `^3.11.3`, Flutter `3.47.2+`)
- **Yapay Zeka:** Google Gemini REST API (`gemini-3.6-flash`, `gemini-3.5-flash`, `gemini-3.1-pro`) & `http: ^1.2.0`
- **Durum Yönetimi:** `ValueNotifier` + reactive state
- **Veri Kalıcılığı:** `shared_preferences: ^2.5.5`
- **Tipografi:** Google Fonts (`Orbitron`, `Rajdhani`)
- **Ses Sistemi:** `audioplayers: ^6.6.0`
- **Takvim & Arayüz:** `table_calendar: ^3.1.2`, `image_picker: ^1.2.1`
- **Dış Bağlantılar:** `url_launcher: ^6.2.5`
- **Kod Kalitesi:** `flutter_lints: ^6.0.0` (0 linter uyarısı)

---

## 🚀 Kurulum ve Çalıştırma

```bash
# 1. Depoyu klonlayın ve klasöre girin
cd solo_app

# 2. Paket bağımlılıklarını indirin
flutter pub get

# 3. Testleri doğrulayın
flutter test

# 4. Uygulamayı Chrome üzerinde başlatın
flutter run -d chrome
```

---

## 📜 Lisans

Bu proje Solo Leveling temalı kişisel gelişim ve RPG motivasyon aracı olarak geliştirilmektedir.
