# 🎮 Solo Leveling App

**Solo Leveling** animesinden ilham alan, kişisel gelişim ve fitness takibi yapan bir **gamification (oyunlaştırma) uygulaması**. Kullanıcı bir "Avcı" (Hunter) olarak görev yapar; egzersiz, diyet ve zihinsel görevlerini tamamlayarak EXP, Gold, AP kazanır ve level atlar.

---

## 📁 Proje Mimarisi

```
lib/
├── main.dart                       # Uygulama giriş noktası ve akıllı kayıt yönlendirmesi
├── controllers/
│   └── system_memory.dart          # Tüm oyun state'i, persistence, RPG mekanikleri, görev döngüsü, suplement hafızası
├── core/
│   ├── advanced_metabolic_engine.dart # Bilimsel US Navy, LBM, BMR, TDEE, MET yıpranma & projeksiyon motoru
│   ├── supplement_engine.dart      # Suplement kuşanma, dinamik su artışı (+500ml) & metabolik sinerji motoru
│   ├── voice_coach_system.dart     # Dinlenme sayacı & aşırı yükleme yapay zeka sesli koç sistemi
│   ├── progressive_overload_engine.dart # Çift progresyon (Double Progression) & RIR motoru
│   ├── audio_system.dart           # Ses efektleri yönetimi (mixWithOthers desteği)
│   ├── diyet_motoru.dart           # Makro besin (Protein/Karb/Yağ) ve kalori hesaplama motoru
│   ├── exercise_coach.dart         # Avcı Taktik Kartı ve Akıllı Egzersiz Değiştirici (Smart Swap)
│   ├── sistem_gecisi.dart          # Hologram sayfa geçiş animasyonu
│   ├── translation_manager.dart    # Çift dil (TR/EN) yerelleştirme yöneticisi
│   ├── youtube_helper.dart         # YouTube egzersiz formu arama ve video yönlendirme
│   └── services/
│       └── gemini_service.dart     # Google Gemini AI servisi (Doğal dil besin analizi, diyetisyen OCR & Sistem sesi)
├── models/
│   ├── task_model.dart             # Görev (Gorev) veri modeli
│   ├── food_model.dart             # Tüketilen yemek (TuketilenYemek) veri modeli
│   ├── workout_model.dart          # Egzersiz şablonu (EgzersizSablonu & SetKaydi) veri modeli
│   └── inventory_item_model.dart   # Avcı çantası eşya (InventoryItem) modeli
├── screens/
│   ├── ana_ekran.dart              # Ana navigasyon kabuğu (Bottom Navigation)
│   ├── dashboard_screen.dart       # Dashboard — Level, Stat, Başarımlar, Haftalık Boss
│   ├── status_screen.dart          # Stat dağıtımı, HP/MP barları & Antrenman Kütüphanesi köprüsü
│   ├── calendar_screen.dart        # Haftalık görev takvimi (Quest Log & Streak)
│   ├── diet_screen.dart            # Kalori, su, katabolizma dengeleyicisi + Canlı Kamera, Gemini AI & Diyetisyen Tarayıcı
│   ├── macro_dashboard_screen.dart # Görsel Makro Laboratuvarı (Hedef kilo, vizyon girişi, AI harmanlama & Entegre Et)
│   ├── profile_screen.dart         # Profil, Biyometrik Radar Grafiği, Suplement Kuşanma + Gemini API Key Yönetimi & Tanılama
│   ├── setup_screen.dart           # 4 Adımlı Kurulum Sihirbazı (Hedef kilo, vücut ölçümleri, dövüş testleri)
│   ├── welcome_screen.dart         # Sistem uyanış ve karşılama ekranı
│   ├── instruction_screen.dart     # Sistem kuralları ve avcı el kitabı
│   ├── active_workout_screen.dart  # Aktif antrenman modu (Dungeon kronometresi, set logger, dinlenme sayacı & RIR çipleri)
│   ├── workout_planner_screen.dart # Haftalık antrenman planlayıcı & kütüphane bağlantısı
│   ├── workout_library_screen.dart # YouTube destekli hazır antrenman kütüphanesi (875+ egzersiz)
│   ├── boxing_timer_screen.dart    # Boks ve aralıklı antrenman zamanlayıcısı (Raid senkronizasyonlu)
│   └── shop_screen.dart            # Sistem Mağazası (İksirler, Kaçamak Hakları, Eşyalar)
└── widgets/
    ├── supplement_loadout_modal.dart # Suplement kuşanma ve dinamik sinerji yönetim modalı
    ├── hunter_radar_chart.dart     # 5-stat STR/AGI/VIT/INT/PER pentagon radar grafiği & sınıf belirleyici
    ├── rir_feedback_modal.dart     # Progresif aşırı yükleme RIR bildirim modalı
    ├── dietitian_scanner_modal.dart # Diyetisyen menüsü OCR tarama ve onay modalı
    ├── advanced_exercise_selector_modal.dart # Canlı filtreli gelişmiş egzersiz enjeksiyon modalı
    ├── rest_timer_dialog.dart      # Sesli koç entegrasyonlu ve ses anahtarlı dinlenme sayacı
    ├── hologram_card.dart          # Neon parlamalı hologram kart widget'ı
    └── stat_bar.dart               # HP/MP/EXP ilerleme çubuğu widget'ı
```

### Katman Yapısı

| Katman | Bileşenler | Rol |
|--------|------------|-----|
| **Controllers** | `system_memory.dart` | Oyun durumu, kalıcılık (SharedPreferences), RPG formülleri, hedef kilo & diyetisyen reçeteleri, gece yarısı hesaplaşması |
| **Core & Services** | `advanced_metabolic_engine.dart`, `gemini_service.dart`, `diyet_motoru.dart`, `audio_system.dart`, `exercise_coach.dart`, `youtube_helper.dart` | US Navy & Katch-McArdle metabolik formülleri, MET idman yıpranması, yapay zeka servisleri, akıllı egzersiz koçluğu, video sanitizasyonu |
| **Models** | `task_model.dart`, `food_model.dart`, `workout_model.dart`, `inventory_item_model.dart` | Tip güvenli veri modelleri ve JSON serileştirme |
| **Screens** | 15 ekran | Kullanıcı arayüzü ve navigasyon akışları |
| **Widgets** | `dietitian_scanner_modal.dart`, `advanced_exercise_selector_modal.dart`, `hologram_card.dart`, `stat_bar.dart` | Diyetisyen OCR tarayıcısı, egzersiz seçicisi, tema uyumlu UI bileşenleri |
| **Tests** | 15 test paketi (`test/`) | Yönlendirme, navigasyon, metabolik motor, diyetisyen tarayıcı, runtime koruma, AI ve uçtan uca akış testleri |

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

### 7. 🥊 Dövüş Sporları & Boksör Motoru (Combat Athlete System)
- **Çoklu Branş Seçimi:** Boks, Kickboks, Muay Thai, MMA, Güreş / BJJ branşlarını tekli veya çoklu seçebilme.
- **Dövüşçü Uyanış & Güç Değerlendirmesi:** Patlayıcı şınav (plyo push-up), 3 dk raund kondisyonu (burpee/sprawl), plank ve barfiks dayanıklılığı.
- **1RM Ağırlık Entegrasyonu:** Barbell Bench Press, Squat, Deadlift 1RM ağırlıkları dövüşçü testine dahil edilir; vücut ağırlığına oranlı kuvvet bonusuyla yumruk patlayıcılığı ve gövde direnci ödüllendirilir.
- **Özel Dövüş Antrenmanları:** Gölge boksu, reaksiyon/çeviklik, torba kombinasyonları ve rotasyonel core antrenmanları.

### 8. 🎯 Öncelikli Odak & Yağ Yakım Protokolü (Target Focus Zones)
- Avcının karın/göbek, göğüs, kol, omuz, bacak gibi yağlanma veya hacim önceliği olan bölgelerini seçebilmesi.
- Antrenman günlerinin sonuna `[FOCUS-CORE]`, `[FOCUS-CHEST]`, `[FOCUS-ARMS]` gibi amaca özel bitirici süpersetlerin otomatik eklenmesi.

### 9. 🛡️ Genişletilmiş Eklem Sakatlık Koruması (Joint Protection)
- Omuz, diz, bel, bilek, dirsek veya boyun hassasiyetlerinde omurgaya ve ekleme aşırı yük bindiren hareketlerin eklem dostu alternatiflerle (Neutral Grip DB Press, Box Squat/Leg Press, Destekli T-Bar Row) otomatik ikame edilmesi.

### 10. 📋 Günlük Görevler & Streak Takibi
- 7 günlük haftalık program: Her gün için özelleştirilmiş **Fiziksel** ve **Zihinsel** görevler.
- Günlük görevlerin tamamı bittiğinde **Flawless Streak** artar.
- İhmal edilen görevler HP/MP cezalarına ve streak kırılmasına yol açar.

### 11. 🩸 Kırmızı Geçit (Red Gate) — Cehennem Modu
- Seçilen gün sayısı boyunca avcıyı kilit altına alan yüksek zorluklu meydan okuma.
- **3× Ceza Katsayısı:** Kalori aşımı veya görev ihmali ölümcül hasar verir (-60 HP).
- **3× Ödül Katsayısı:** Katlanan EXP ve Altın çarpanları.
- **Ölüm Riski:** HP sıfırlanırsa -1 Level cezası uygulanır.
- Başarıyla tamamlandığında devasa AP, Altın ve EXP ödülü verilir.

### 12. 🌙 Gölge Modu (Stealth Mode)
- Gerçek hayat yoğunluğunda cezaları geçici olarak devre dışı bırakır.
- Streak dondurulur, boss cezaları uygulanmaz.

### 13. 👹 Haftalık Zindan Bossu
- Her Pazar günü avcının karşısına çıkan haftalık Boss (Level × 100 HP).
- Fiziksel (*Steel-Fanged Wolf*) veya Zihinsel (*Ancient Lich*) patron türü.
- Görevler ve diyet başarısıyla boss'a hasar verilir; yenilirse devasa ganimet (+1000 Gold, +2 AP, +500 EXP) kazanılır.

### 14. 🛒 Sistem Mağazası (System Shop)

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

### 15. 🎵 Ses & Atmosfer Motoru
- Level Up, Quest Complete, Bell, Transition ve Dungeon ses efektleri.
- `mixWithOthers` protokolü sayesinde arka planda çalan Spotify veya YouTube müziğini kesmeden mikslenir.

---

## ⚡ Son Eklenen Özellikler & Sistem İyileştirmeleri

### 1. 🧙 4 Adımlı Avcı Uyanış Sihirbazı (SetupScreen Wizard)
- Tek sayfada yığılan form yerine 4 aşamalı temiz, sinematik Solo Leveling akışı:
  - **Phase 01 (Identity):** Avcı adı, cinsiyet, doğum tarihi, avatar ve Gemini API anahtarı.
  - **Phase 02 (Body Calibration):** Boy, kilo, hedef, zorluk ve **Full Body Scan (Göğüs, Bel, Kol, Bacak cm)**.
  - **Phase 03 (Combat & Gear):** Çoklu dövüş branşları, öncelikli yağ yakım odakları ve eklem koruması.
  - **Phase 04 (Awakening Test):** Kondisyon + 1RM Halter testleri ve canlı hesaplanan avcı rütbesi.
- **Sistem Uyanış Yükleme Modalı:** "AWAKEN THE SYSTEM" butonuna basıldığında API anahtarını ve ayarları denetleyen *"LÜTFEN BEKLEYİNİZ"* ekranı.

### 2. 🤖 Gemini AI Destekli Kişiselleştirilmiş Antrenman Motoru (Hibrit Mimari)
- **`GeminiService.haftalikProgramUret`:** Avcının boy, kilo, rank, dövüş branşı, 1RM ağırlıkları, eklem sakatlıkları ve odak bölgelerine göre 7 günlük tam antrenman planını Gemini AI üretir.
- **Hibrit Fail-Safe Güvenliği:** API anahtarı veya internet bağlantısı olmadığında sistem yerel kural motoruna geçerek programı kurar (asla çökmez).
- **`[ TÜM HAFTAYI YENİLE ]` Butonu:** `WorkoutPlannerScreen` üzerinden avcı tek tıkla özel not (örn: *"omzum yorgun bacağa odaklan"*) ekleyerek programını yapay zekaya yeniletebilir.

### 3. 🥊 Dövüşçü 1RM Kuvvet & Rank Katsayısı
- `hesaplaDovusRank` içine vücut ağırlığına oranlı Big 3 kuvvet katkısı entegre edildi:
  $$\text{Strength Ratio} = \frac{\text{Bench} + \text{Squat} + \text{Deadlift}}{\text{Vücut Ağırlığı}}$$
- Dövüş testi kaydedildiğinde `maxBench`, `maxSquat` ve `maxDeadlift` değerleri de profildeki 1RM kartlarına kalıcı işlenir.

### 4. 📺 Tek Dokunuşla YouTube Egzersiz Formu Rehberi (Akıllı Sanitize & Video Yönlendirme)
- **Akıllı Başlık Temizleme (`YoutubeHelper.gorevAdiniTemizle`):** Sistem etiketlerini (`[COMBAT]`, `[PHY]`, `[CORE / ABS]`), set ve tekrar bilgilerini (`(4 Set x 8 Tekrar)`, `(3 Min)`) otomatik temizleyerek optimize edilmiş `"hareket adı egzersizi nasıl yapılır form"` YouTube arama sorgusunu hazırlar.
- **Tüm Egzersiz Ekranlarında Canlı Buton:**
  - **Dashboard (Bugünün Görevleri):** Her fiziksel görevin yanında YouTube ve Taktik Bilgi butonu.
  - **Takvim (CalendarScreen):** Seçilen günün görevlerinde YouTube butonu.
  - **Antrenman Planlayıcı (WorkoutPlannerScreen):** Planlanan her egzersizin yanında YouTube ve Taktik Değiştirme butonu.
  - **Aktif Zindan Baskını (ActiveWorkoutScreen):** İdman esnasında hareketi hatırlamak için anında erişim.
  - **Antrenman Kütüphanesi (WorkoutLibraryScreen):** Kütüphanedeki tüm hazır hareketlerde tek tıkla video başlatma.
- **Doğrudan Harici Uygulama Açılışı:** YouTube mobil uygulaması veya tarayıcıda ilgili yapılış/form videosu anında açılır.

### 5. 📋 Solo Leveling "Avcı Taktik Kartı" & Akıllı Alternatif Değiştirici (Smart Swap)
- **`ExerciseCoach` & `ExerciseDetailModal`:**
  - Egzersiz kartına veya bilgi butonuna dokunulduğunda açılan sinematik Solo Leveling modalı.
  - **Hedef Kaslar & Dövüşe Katkısı:** Hedeflenen anatomik kas grupları ve dövüş sporlarındaki (yumruk hızı, gard direnci, takedown patlayıcılığı) somut faydaları.
  - **3 Kritik Altın Kural:** Doğru duruş, nefes zamanlaması ve sakatlık önleme teknikleri.
  - **Akıllı Egzersiz Değiştirici (Smart Swap):** Salondaki makine doluysa veya eklem ağrısı varsa tek dokunuşla muadil hareket listesi açılır (Örn: Bench Press yerine Floor Press / Şınav) ve program anında güncellenir.
  - **YouTube Rehberi Entegrasyonu:** Tek tıkla ilgili yapılış/form videosu başlar.

### 6. ⏱️ Set Arası Dinlenme Sayacı (Hunter MP Recovery Timer)
- **`RestTimerDialog`:** Aktif idman esnasında bir set veya hareket tamamlandığında devreye giren dairesel Solo Leveling geri sayım sayacı.
- **Hızlı Süre Seçenekleri:** 30s, 60s, 90s, 120s hızlı butonları ve `+15 SN` ekleme aksiyonu.
- **Sesli & Görsel Uyarı:** Dinlenme bittiğinde ses efekti (`AudioSystem.playBell()`) çalar ve sistem *"SIRADAKİ SETE HAZIRSIN, AVCI!"* ikazı verir.

### 7. 📈 Set, Ağırlık ve Tekrar Takip Kaydedicisi (Progressive Overload Logger)
- **`SetKaydi` Modeli:** Her egzersizin altında `Set 1: [80 kg] x [10 rep] [✓]` şeklinde set bazlı ağırlık ve tekrar takibi.
- **Ağırlık Düzenleme Modalı:** Tek dokunuşla ağırlık (kg) ve tekrar sayısını güncelleme imkanı.
- **Kalıcı JSON Depolama:** Yapılan tüm setler hafızaya ve idman geçmişine kaydedilir.

### 8. 💧 Su Takibi Sistemi (Hydration Core)
- **Arayüz (`diet_screen.dart`):** Günlük tüketilen su miktarını ve hedefini (varsayılan 3000 ml) gösteren neon Solo Leveling temalı ilerleme çubuğu.
- **Hızlı Giriş Aksiyonları:** `+250 ml`, `+500 ml` butonları ve sayacı sıfırlama seçeneği.
- **Gece Yarısı Ödül & Ceza Entegrasyonu:** Su hedefini tutturan avcıya ekstra **+5 HP** ve **+10 EXP** ödülü verilir ve yeni gün başlangıcında sayaç sıfırlanır.

### 9. 🎒 Avcı Çantası & Eşya Kullanımı (Hunter's Bag / Inventory)
- **Çanta Modalı (`shop_screen.dart`):** Satın alınan tüm eşyaların adetleriyle listelendiği modal pencere.
- **Canlı Eşya Kullanımı ("USE"):** `hp_full` (tam can doldurma), `stat_reset` (AP iadesi), `cheat_meal` (kalori affı), `sloth_day` (görev muafiyeti).

### 10. 🥩 Yemek Makro Takibi & Kalıcı Veri Modeli (P / C / F)
- `TuketilenYemek` sınıfında kalori haricinde `protein`, `karbonhidrat` ve `yag` takibi.
- Canlı döküm: `P: Xg | C: Yg | F: Zg` ve `SystemMemory.bugunProtein`, `bugunKarb`, `bugunYag` toplamları.

### 11. 💾 Veri Kasası / JSON Yedekleme & Geri Yükleme (Data Vault)
- **Arşiv Dışa Aktarma (Export):** Tek tuşla tüm oyuncu profili, statlar, seviye, envanter, antrenman ve kilo geçmişini şifrelenmiş JSON olarak panoya kopyalar.
- **Arşiv İçe Aktarma (Restore):** Yapıştırılan yedek JSON metnini doğrulayarak (`importBackupJson`) oyuncunun tüm profilini eksiksiz geri yükler.

---

## 🎯 Faz 1 Geliştirmeleri & Sırada Eklenecekler (Workouts & Planning Backlog)

### ✅ Faz 1 Kapsamında Tamamlanan Sistemler:
1. **Gemini AI Destekli Kişiselleştirilmiş Antrenman:** Avcının boy, kilo, rank, sakatlık kısıtı ve odak bölgelerine göre haftalık 7 günlük plan üretimi & fail-safe yerel kural motoru.
2. **Tek Dokunuşla YouTube Video Rehberi:** Dashboard, Takvim, Antrenman Planlayıcı, Aktif İdman ve Kütüphanedeki tüm hareketlerde canlı YouTube arama ve form videosu açma.
3. **Solo Leveling Avcı Taktik Kartı & Akıllı Alternatif Değiştirici (Smart Swap):** Egzersize dokunulduğunda açılan hedef kas, dövüş faydası, 3 altın kural ve salondaki yoğunluk/ağrı durumunda 3 muadil hareket önerisi ve tek tıkla swap.
4. **Set, Ağırlık ve Tekrar Takip Kaydedicisi:** Aktif zindan idmanında set bazlı kg/tekrar loglama (`SetKaydi`).
5. **Set Arası Dinlenme Sayacı (Rest Timer):** 30-120sn sesli ve görsel Solo Leveling geri sayım sayacı.
6. **Zindana Dinamik Ek Hareket Enjekte Etme & Kaldırma:** Aktif Zindan Baskını ekranında üst bardaki `+ EKLE` butonu ve listenin altındaki `+ EK HAREKET ENJEKTE ET` butonuyla kategorilere göre (Göğüs, Sırt, Omuz/Kol, Bacak, Karın, Dövüş/Boks) filtrelenen hazır hareketleri veya serbest görevleri seansa anında dahil edebilme ve görev kartından kaldırma desteği.
7. **6-8 Hareket Uzatılmış İdman Standardı & Zorunlu Kardiyo Katmanı:** Tüm varsayılan ve Gemini tarafından üretilen programlar 4-5 set ve 6-8 hareketlik uzatılmış hacme geçirildi. Her idman gününün sonuna kesintisiz ve net bir `[CARDIO]` misyonu yerleştirildi.
8. **Çift Seçenekli Şablon Yükleme (+ İdmana Ekle / 🔄 Sıfırla ve Kur) & Yeni Kardiyo Şablonları:** Saitama, Full Body, Cardio & MetCon Burn, Combat Striker Finisher, **Gölge Boksu & Kombinasyonlar (5 Raund)**, **`🏃 Avcı 5K/10K Koşu & HIIT`** ve **`⚡ Tabata & MetCon Extreme Burn`** şablonları hem mevcut idmanı silmeden üzerine ekleme (`+ Append`) hem de tek başına o idmanı yapma (`🔄 Replace`) modlarıyla donatıldı.
9. **Kişiye Özel Yapay Zeka Bitirici (`🤖 AI AVCI ÖZEL BOOSTER`):** Avcının rütbesi, dövüş branşı ve hedef odak bölgelerine göre 4-5 hareketlik yoğun bitirici seansını (kardiyo dahil) tek tuşla idmana ekleyen Gemini REST ve akıllı yerel algoritma motoru kuruldu.
10. **Dövüş Sporlarına Göre 5-6 Raundluk Gölge Boksu Stilleri & Kombinasyonları:** Boks (Peek-a-boo & Out-boxer), Kickboks (Dutch Volume & Low Kick), Muay Thai (8 Uzuv Teep/Dirsek), MMA (Seviye Değişimi & Sprawl) ve Güreş için her raundu ayrı kombinasyon ve stil içeren profesyonel dövüş simülasyonu.
11. **İdmanı Uzatma, Dinamik Hacim Kademeleri & Kardiyo Kategori Seçicisi:** Zindana hareket eklerken sabit `3x10` kaldırıldı; kullanıcıya `Standart (4 Set)`, `Uzatılmış (6 Set)`, `Şampiyon (8 Set)` ve `Ekstrem (10 Set)` hızlı seviyeleri, 15 sete ve 50 tekrara kadar sayaçlar, bağımsız **`Kardiyo`** kategorisi ve akıllı süre/mesafe formatlayıcısı sunuldu.
12. **Dungeon & Boks Sayacı Mutlak Duvar Saati (Wall-Clock) Senkronizasyonu & Canlı Raid HUD:** Zindan sayacı `_dungeonBaslangicZamani` mutlak duvar saatine bağlandı. Combat Sim açıldığında en üstte canlı `[ ⚔️ ACTIVE RAID IN PROGRESS | HH:MM:SS ]` HUD banner'ı eklendi. Boks bitişinde zindanın erkenden sonlandırılması engellendi; savaş exp ve stat ödülü verilip zindana kesintisiz dönüş sağlandı.
13. **Antrenman Ekleme Ekranının Yeniden Düzenlenmesi (`AdvancedExerciseSelectorModal`):** 875+ egzersiz kütüphanesiyle tam entegre, anlık filtrelemeli canlı arama çubuğu (`TextField`), kategori filtre çipleri (Göğüs, Sırt, Omuz/Kol, Bacak, Karın, Dövüş, Kardiyo, Calisthenics), YouTube video formu önizleme butonu, dinamik set/tekrar/dakika seçicileri ve tek dokunuşla ekleme modalı hem `ActiveWorkoutScreen` hem de `WorkoutPlannerScreen`'e entegre edildi.

---

### 🧬 Faz 2: Bilimsel Metabolik Motor, Diyetisyen Analizi & Hedef Kilo Entegrasyonu (%100 TAMAMLANDI)

1. **🔬 US Navy Vücut Kompozisyonu & LBM Hesabı (`AdvancedMetabolicEngine`):**
   - Boy, kilo, bel çevresi ve cinsiyet verileriyle logaritmik vücut yağ oranı hesabı.
   - Yağsız kas kütlesi (**LBM**) ve sınıflandırma (*Atletik, Fit, Standart, Yüksek Yağ*).
   - **Katch-McArdle ($BMR = 370 + 21.6 \times LBM$) & Mifflin-St Jeor Hibrit BMR:** LBM verisiyle gerçek kas dokusuna dayalı bazal metabolizma.
   - **Dinamik TDEE:** Haftalık idman gün sayısı ve dövüşçü moduna göre $1.20 - 1.85$ arası katsayılarla gerçek günlük enerji tüketimi.
2. **🥊 MET Bazlı İdman Yıpranması & Katabolizma Koruması (`hesaplaIdmanYipranmasi`):**
   - Boks/Kickboks/MMA: **10.5 MET**, Güreş/BJJ: **11.5 MET**, Kardiyo/HIIT: **9.5 MET**, Ağırlık: **6.5 MET**.
   - Formül: $\text{Yakılan Kalori} = \left(\frac{MET \times 3.5 \times \text{Kilo}}{200}\right) \times \text{Süre Dakika} \times \text{RPE}$
   - İdman sonrası kas yıkımını önleyen dinamik protein telafisi ($+15$g ile $+45$g arası) ve glikojen doldurucu karbonhidrat telafisi.
   - Aktif Zindan ve Boks sayacı tamamlandığında otomatik hafızaya işlenir ve Diyet ekranında canlı dengelenir.
3. **📋 Diyetisyen Listesi Tarayıcısı & Reçete Kilidi (`DietitianScannerModal`):**
   - Diyetisyenin verdiği basılı veya dijital listenin fotoğrafı çekilerek veya metni yapıştırılarak Gemini Vision ile taranır.
   - Ayrıştırılan kalori ve makrolar (`SystemMemory.gunlukHedefKalori`) sistemin resmi taban reçetesi olarak kilitlenir.
4. **🎯 Hedef Kilo Projeksiyonu & Metabolik Tempo Hesabı:**
   - Mevcut kilo ile hedef kilo arasındaki delta farkı tespiti.
   - Sağlıklı haftalık tempo ($0.50$ kg/hafta) ve disiplinli ulaşma süresi (hafta) hesabı.
   - Günlük kalori dengesi ($-550$ kcal açık veya $+350$ kcal fazlalık) projeksiyonu.
5. **🧠 Avcının Beslenme Vizyonu & Fikir Girişi (Serbest Metin):**
   - Sistemin dayatma yapmasını önleyen ve avcının kendi özel düşüncesini, tercihlerini veya kısıtlarını aktarabildiği serbest metin alanı.
6. **🔮 Gemini AI ile Harmanlama & Sistem Stratejik Direktifi:**
   - Avcının fikri + biyometrik verileri Gemini AI tarafından sentezlenir.
   - Solo Leveling RPG tonunda motivasyonel Sistem Direktifi ve revize makro önerileri üretir.
7. **⚡ "BU HEDEFLERİ SİSTEME ENTEGRE ET" Butonu:**
   - Hesaplanan veya AI ile harmanlanan hedef kilo ve günlük kaloriyi tek dokunuşla tüm aktif takip sistemine, diyet ekranına ve veri kasasına bağlar.

---

### 🏋️‍♂️ Faz 3: Akıllı Antrenman Zekası & Progresif Aşırı Yükleme Motoru (%100 TAMAMLANDI)

1. **📈 Çift Progresyon Kural Motoru (`ProgressiveOverloadEngine`):**
   - **RIR 4+ (Çok Kolay / Hafif Yük):** Avcının gücü uyandığında ağırlık otomatik olarak üst gövdede **+2.5 kg**, bacakta **+5.0 kg** (vücut ağırlığı egzersizlerinde **+2 tekrar**) artırılır.
   - **RIR 2-3 (Optimum Hipertrofi):** Ağırlık korunur, bir sonraki seans için **+1 tekrar** hedefi konur. 12 tekrar barajına ulaşıldığında ağırlık artırılıp tekrar 8'e dengelenir.
   - **RIR 0-1 (Tükeniş / Limit):** Ağırlık ve tekrar korunur, toparlanma ve protein alımı emredilir.
2. **⚠️ Eklem Koruma Protokolü & Güvenli İkame:**
   - Egzersiz esnasında omuz, diz, bel veya dirsekte batma/ağrı bildirildiğinde sistem `ExerciseCoach` üzerinden anında eklem dostu alternatif hareket (örn: Dumbbell Floor Press, Trap Bar Deadlift, Goblet Squat) atar.
3. **⚡ Holografik Sistem Penceresi (`RirFeedbackModal`):**
   - Egzersiz onaylandığında veya tüm setler bittiğinde açılan 1 dokunuşluk Solo Leveling Sistem Bildirimi. Avcı dilerse dilediği an kart üzerindeki hız simgesiyle manuel de bildirebilir.
4. **💾 Kalıcı Aşırı Yükleme Hafızası (`SystemMemory.overloadGecmisi`):**
   - Avcının her hareketteki son ağırlığı, tekrarı, RIR puanı ve sistem direktifleri şifrelenmiş veri kasasında saklanır; `ActiveWorkoutScreen` içinde egzersiz kartının altında canlı sistem hedefi çipi olarak gösterilir.

---

## 📊 Sistem Analiz ve Durum Raporu (System Diagnostic Status)

| Modül / Özellik | Durum | Kapsam & Gerçekleştirilen Fonksiyonlar |
|-----------------|-------|---------------------------------------|
| **Gemini AI Core (REST)** | ✅ **YAPILDI** | Gemini 3.6 Flash & Next-Gen Core, çoklu model desteği, API Key yönetimi |
| **Avcı Uyanış Sihirbazı** | ✅ **YAPILDI** | 4 Adımlı sinematik Wizard, Full Body Scan, Dövüş testleri, 1RM Halter |
| **Antrenman Motoru (AI)** | ✅ **YAPILDI** | Haftalık 7 günlük dinamik program üretimi, yerel kural fail-safe fallback |
| **YouTube Form Rehberi** | ✅ **YAPILDI** | Akıllı başlık sanitizasyonu, tüm ekranlarda tek tıkla video başlatma |
| **Avcı Taktik Kartı & Swap** | ✅ **YAPILDI** | Hedef kas, dövüş katkısı, 3 altın kural ve anlık 3 alternatif hareket değişimi |
| **Set Logger & Rest Timer** | ✅ **YAPILDI** | Set/kg/tekrar loglama, 30-120sn sesli geri sayım sayacı |
| **Progresif Aşırı Yükleme (RIR)** | ✅ **YAPILDI** | `ProgressiveOverloadEngine`, Double Progression, RIR 0-1/2-3/4+, Eklem Koruma, `RirFeedbackModal` |
| **Dinamik Zindan Genişletme** | ✅ **YAPILDI** | Zindana anında ek hareket ekleme/kaldırma, 875+ kütüphane entegrasyonu |
| **Uzatılmış İdman & Kardiyo** | ✅ **YAPILDI** | 6-8 hareket standardı, zorunlu kardiyo katmanı, Hacim & Raund seçicileri |
| **Gölge Boksu & Dövüş Sim** | ✅ **YAPILDI** | Branşa özel 5 raundluk gölge boksu stilleri ve kombinasyonları |
| **Dungeon & Boks Senkronizasyonu** | ✅ **YAPILDI** | Duvar saati senkronizasyonu, canlı Raid HUD banner'ı, erken kapanma koruması |
| **Gelişmiş Egzersiz Seçici** | ✅ **YAPILDI** | Canlı arama, kategori çipleri, set/tekrar ve kardiyo dakika filtreleri |
| **Bilimsel Metabolik Motor** | ✅ **YAPILDI** | US Navy yağ %, LBM, Katch-McArdle & Mifflin BMR, Dinamik TDEE |
| **MET Yıpranma & Katabolizma** | ✅ **YAPILDI** | MET formülü ile kalori ve kas koruyucu protein/karb telafisi |
| **Diyetisyen Menü Tarayıcısı** | ✅ **YAPILDI** | Fotoğraf/metin Gemini OCR, taban hedef kilitleme ve reçete yönetimi |
| **Hedef Kilo Projeksiyonu** | ✅ **YAPILDI** | Delta kilo, haftalık tempo, tahmini hafta ve kalori farkı hesabı |
| **Kullanıcı Vizyonu & Not Girişi** | ✅ **YAPILDI** | Kör otomasyonu önleyen serbest metin diyet stratejisi alanı |
| **AI Harmanlama & Direktif** | ✅ **YAPILDI** | Kullanıcı fikri + biyometrik matematiğin senteziyle RPG Sistem Direktifi |
| **Sisteme Entegre Et Butonu** | ✅ **YAPILDI** | Hesaplanan hedefleri tek tıkla aktif takip sistemine bağlama aksiyonu |
| **Suplement Kuşanma (Loadout)** | ✅ **YAPILDI** | 4 ekipman yuvası, metabolik sinerji, dinamik su artışı (+500ml) & tolerans |
| **Yapay Zeka Sesli Koç (Voice)** | ✅ **YAPILDI** | Dinlenme sayacı başlama, 3-2-1 geri sayım, zafer uyarıları & overload direktifleri |
| **Canlı Kamera Vizörü (Lens)** | ✅ **YAPILDI** | Cihaz kamerası ile doğrudan tabak fotoğrafı çekme ve OCR tarama |
| **Biyometrik Radar Grafiği** | ✅ **YAPILDI** | 5-stat STR/AGI/VIT/INT/PER pentagon siber radar poligonu ve sınıf tayini |
| **Su Takibi (Hydration)** | ✅ **YAPILDI** | Günlük su sayacı, hızlı giriş butonları ve gece yarısı ödül/ceza |
| **Avcı Çantası & Envanter** | ✅ **YAPILDI** | Eşya satın alma, çantadan canlı eşya kullanımı (`hp_full`, `cheat_meal` vb.) |
| **Veri Kasası (Data Vault)** | ✅ **YAPILDI** | Şifrelenmiş JSON arşiv dışa/içe aktarma ile tam veri yedekleme |
| **Çift Dil Desteği (TR/EN)** | ✅ **YAPILDI** | Tüm sistem unvanları, hedefler, diyaloglar ve dinamik dil anahtarı |

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

Proje güvenilirliği için **17 test paketi ve toplam 94 test senaryosu** hazırlanmıştır (%100 Başarılı / Yeşil):

| Test Dosyası | Kapsam |
|--------------|--------|
| [`test/supplement_and_radar_test.dart`](test/supplement_and_radar_test.dart) | Suplement kuşanma/çıkarma, dinamik su artışı (+500ml), tolerans bonusları, akıllı öneriler, sesli koç sinyalleri/sessize alma ve 5-stat biyometrik radar çizimi |
| [`test/progressive_overload_engine_test.dart`](test/progressive_overload_engine_test.dart) | Çift progresyon (Double Progression), RIR 4+ (+2.5kg/+5kg), RIR 2-3 (+1 rep), RIR 0-1 (toparlanma), eklem koruma ikamesi, `OverloadKaydi` JSON ve `RirFeedbackModal` widget testleri |
| [`test/advanced_metabolic_engine_test.dart`](test/advanced_metabolic_engine_test.dart) | US Navy vücut yağı, LBM, Katch-McArdle BMR, TDEE, MET yıpranması, hedef kilo projeksiyonu ve sisteme entegrasyon testleri |
| [`test/dietitian_scanner_widget_test.dart`](test/dietitian_scanner_widget_test.dart) | Diyetisyen tarayıcı modalı, form alanları ve Makro Lab US Navy biyometrik kart render testleri |
| [`test/assessment_flow_widget_test.dart`](test/assessment_flow_widget_test.dart) | 4 Adımlı Wizard, çoklu dövüş branşı, 1RM dövüş ağırlık testleri, odak bölgeleri, unvan senkronizasyonu |
| [`test/system_features_test.dart`](test/system_features_test.dart) | Su takibi, çanta, makrolar, Data Vault, odak bölgelerine göre dinamik antrenman uyarlaması |
| [`test/exercise_coach_test.dart`](test/exercise_coach_test.dart) | Avcı Taktik Kartı, Akıllı Alternatif Değiştirici (Smart Swap), SetKaydi serileştirmesi, RestTimer ve Detail Modal |
| [`test/workout_experience_flow_test.dart`](test/workout_experience_flow_test.dart) | Dashboard taktik kartı ve swap akışı, Aktif İdman Set Logger & Rest Timer, **Zindana Ek Hareket Enjekte Etme ve Silme**, Workout Planner butonları |
| [`test/dungeon_boxing_sync_test.dart`](test/dungeon_boxing_sync_test.dart) | Zindan & Combat Sim sayaç senkronizasyonu, canlı raid HUD banner'ı ve zindanın erken kapanmasını önleme testleri |
| [`test/advanced_exercise_selector_modal_test.dart`](test/advanced_exercise_selector_modal_test.dart) | 875+ kütüphaneden canlı arama, kategori filtreleri, set/tekrar ve kardiyo dakika seçicileri ile plana/zindana enjeksiyon |
| [`test/youtube_helper_test.dart`](test/youtube_helper_test.dart) | Egzersiz başlık sanitizasyonu, [COMBAT]/[PHY] etiketleri ve set/tekrar ayıklama testleri |
| [`test/gemini_integration_test.dart`](test/gemini_integration_test.dart) | Profil API anahtarı, AI besin çözücü ve **AI haftalık antrenman fail-safe fallback testi** |
| [`test/language_switch_test.dart`](test/language_switch_test.dart) | Türkçe/İngilizce çift dil geçişi, unvanlar, hedefler ve dil fallback |
| [`test/midnight_reset_test.dart`](test/midnight_reset_test.dart) | Gece yarısı tek gün sıfırlama ve aktif model kalıcılık testi |
| [`test/main_routing_test.dart`](test/main_routing_test.dart) | Kayıtlı ve yeni kullanıcı başlangıç yönlendirmesi doğrulaması |
| [`test/workout_library_navigation_test.dart`](test/workout_library_navigation_test.dart) | Status & Workout Planner üzerinden kütüphaneye geçiş ve render testi |
| [`test/macro_lab_navigation_test.dart`](test/macro_lab_navigation_test.dart) | Diyet ekranından Makro Lab geçişi ve `FormatException` çökme koruması |

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
