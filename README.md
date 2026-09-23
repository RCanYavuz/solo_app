# 🎮 Solo Leveling App

**Solo Leveling** animesinden ilham alan, kişisel gelişim ve fitness takibi yapan bir **gamification (oyunlaştırma) uygulaması**. Kullanıcı bir "Avcı" (Hunter) olarak görev yapar; egzersiz, diyet, zihinsel gelişim ve kişisel beceri görevlerini tamamlayarak EXP, Gold, AP kazanır ve level atlar.

> **"Sadece güçlü olan değil, sürekli gelişen ayakta kalır."**

---

## 📁 Proje Mimarisi

```
lib/
├── main.dart                         # Uygulama giriş noktası ve akıllı kayıt yönlendirmesi
├── controllers/
│   ├── system_memory.dart            # Ana oyun state'i, persistence, RPG mekanikleri, görev döngüsü, suplement hafızası
│   └── memory_modules/
│       ├── memory_storage.dart       # SharedPreferences kalıcılık ve JSON serileştirme motoru
│       ├── memory_workout.dart       # Antrenman geçmişi, idman istatistikleri ve plan yönetimi
│       ├── memory_nutrition.dart     # Beslenme hesaplamaları, gece yarısı hesaplaşması ve diyet yönetimi
│       └── memory_combat_ranks.dart  # Stat & EXP hesaplama, level atlama, başarım & rütbe sistemi
├── core/
│   ├── advanced_metabolic_engine.dart  # Bilimsel US Navy, LBM, BMR, TDEE, MET yıpranma & projeksiyon motoru
│   ├── supplement_engine.dart        # Suplement kuşanma, dinamik su artışı (+500ml) & metabolik sinerji motoru
│   ├── voice_coach_system.dart       # Dinlenme sayacı & aşırı yükleme yapay zeka sesli koç sistemi
│   ├── progressive_overload_engine.dart # Çift progresyon (Double Progression) & RIR motoru
│   ├── dynamic_difficulty_engine.dart # Dinamik zorluk adaptasyonu (DDA), deload/upgrade/maintain analizi
│   ├── audio_system.dart             # Ses efektleri yönetimi (mixWithOthers desteği)
│   ├── diyet_motoru.dart             # Makro besin (Protein/Karb/Yağ) ve kalori hesaplama motoru
│   ├── exercise_coach.dart           # Avcı Taktik Kartı ve Akıllı Egzersiz Değiştirici (Smart Swap)
│   ├── sistem_gecisi.dart            # Hologram sayfa geçiş animasyonu
│   ├── translation_manager.dart      # Çift dil (TR/EN) yerelleştirme yöneticisi
│   ├── youtube_helper.dart           # YouTube egzersiz formu arama ve video yönlendirme
│   ├── services/
│   │   ├── gemini_service.dart       # Google Gemini AI servisi (Besin analizi, diyetisyen OCR, antrenman üretimi, çalışma planı, kitap analizi & Sistem sesi)
│   │   └── notification_service.dart # Yerel bildirim ve hatırlatma servisi (Su, İdman, Gece raporu)
│   └── theme/
│       └── app_colors.dart           # Merkezi renk paleti ve tema sabitleri
├── models/
│   ├── task_model.dart               # Görev (Gorev) veri modeli
│   ├── food_model.dart               # Tüketilen yemek (TuketilenYemek) veri modeli
│   ├── workout_model.dart            # Egzersiz şablonu (EgzersizSablonu & SetKaydi) veri modeli
│   ├── inventory_item_model.dart     # Avcı çantası eşya (InventoryItem) modeli
│   └── mental_task_model.dart        # Zihinsel görev (MentalTask) modeli — Kitap, Kodlama, Dil, Sınav, Beceri kategorileri
├── screens/
│   ├── ana_ekran.dart                # Ana navigasyon kabuğu (Bottom Navigation)
│   ├── dashboard_screen.dart         # Dashboard — Level, Stat, Başarımlar, Haftalık Boss, Zihinsel Görevler & Portal Butonları
│   ├── status_screen.dart            # Stat dağıtımı, HP/MP barları & Antrenman Kütüphanesi köprüsü
│   ├── calendar_screen.dart          # Haftalık görev takvimi (Quest Log & Streak)
│   ├── diet_screen.dart              # Kalori, su, katabolizma dengeleyicisi + Canlı Kamera, Gemini AI & Diyetisyen Tarayıcı
│   ├── macro_dashboard_screen.dart   # Görsel Makro Laboratuvarı (Hedef kilo, vizyon girişi, AI harmanlama & Entegre Et)
│   ├── profile_screen.dart           # Profil, Biyometrik Radar Grafiği, Suplement Kuşanma, İlerleme Galerisi, Uyku, Bildirimler & Gemini API Key Yönetimi
│   ├── setup_screen.dart             # 4 Adımlı Kurulum Sihirbazı (Hedef kilo, vücut ölçümleri, dövüş testleri)
│   ├── welcome_screen.dart           # Sistem uyanış ve karşılama ekranı
│   ├── instruction_screen.dart       # Sistem kuralları ve avcı el kitabı
│   ├── active_workout_screen.dart    # Aktif antrenman modu (Dungeon kronometresi, set logger, dinlenme sayacı & RIR çipleri)
│   ├── workout_planner_screen.dart   # Haftalık antrenman planlayıcı & kütüphane bağlantısı
│   ├── workout_library_screen.dart   # YouTube destekli hazır antrenman kütüphanesi (875+ egzersiz)
│   ├── boxing_timer_screen.dart      # Boks ve aralıklı antrenman zamanlayıcısı (Raid senkronizasyonlu)
│   ├── deep_work_timer_screen.dart   # Bilişsel Zindan — Pomodoro odaklanma sayacı (Odak/Dinlenme fazları, zafer raporu & INT/PER ödülleri)
│   └── shop_screen.dart              # Sistem Mağazası (İksirler, Kaçamak Hakları, Eşyalar)
└── widgets/
    ├── hologram_card.dart            # Neon parlamalı hologram kart widget'ı (4px keskin kenar, HologramCard tasarım standardı)
    ├── stat_bar.dart                 # HP/MP/EXP ilerleme çubuğu widget'ı
    ├── hunter_radar_chart.dart       # 5-stat STR/AGI/VIT/INT/PER pentagon radar grafiği & sınıf belirleyici
    ├── achievement_dialog.dart       # Başarım bildirimi ve animasyonlu kutlama diyaloğu
    ├── awakening_test_dialog.dart    # 1RM Halter, Calisthenics & Dövüşçü Uyanış testleri diyaloğu
    ├── supplement_loadout_modal.dart  # Suplement kuşanma ve dinamik sinerji yönetim modalı
    ├── rir_feedback_modal.dart       # Progresif aşırı yükleme RIR bildirim modalı
    ├── dietitian_scanner_modal.dart  # Diyetisyen menüsü OCR tarama ve onay modalı
    ├── advanced_exercise_selector_modal.dart # Canlı filtreli gelişmiş egzersiz enjeksiyon modalı
    ├── exercise_detail_modal.dart    # Avcı Taktik Kartı detay modalı (hedef kas, altın kurallar & Smart Swap)
    ├── rest_timer_dialog.dart        # Sesli koç entegrasyonlu ve ses anahtarlı dinlenme sayacı
    ├── sleep_tracker_card.dart       # Uyku takibi kartı (0-16 saat, HP/MP bonusu & yorgunluk arınması)
    ├── progress_gallery_modal.dart   # İlerleme fotoğrafları galerisi & kilo değişim zaman çizelgesi
    └── study_planner_modal.dart      # AI tabanlı çalışma planlayıcı modalı (alan seçimi, süre, hedef girişi)
```

### Katman Yapısı

| Katman | Bileşenler | Rol |
|--------|------------|-----|
| **Controllers** | `system_memory.dart` + 4 hafıza modülü | Oyun durumu, kalıcılık (SharedPreferences), RPG formülleri, hedef kilo & diyetisyen reçeteleri, gece yarısı hesaplaşması, zihinsel görev yönetimi |
| **Core & Services** | `advanced_metabolic_engine.dart`, `gemini_service.dart`, `notification_service.dart`, `dynamic_difficulty_engine.dart`, `diyet_motoru.dart`, `audio_system.dart`, `exercise_coach.dart`, `youtube_helper.dart` | US Navy & Katch-McArdle metabolik formülleri, MET idman yıpranması, yapay zeka servisleri, yerel bildirimler, dinamik zorluk adaptasyonu, akıllı egzersiz koçluğu, video sanitizasyonu |
| **Models** | `task_model.dart`, `food_model.dart`, `workout_model.dart`, `inventory_item_model.dart`, `mental_task_model.dart` | Tip güvenli veri modelleri ve JSON serileştirme |
| **Screens** | 16 ekran | Kullanıcı arayüzü ve navigasyon akışları |
| **Widgets** | 14 widget | Diyetisyen OCR tarayıcısı, egzersiz seçicisi, uyku takibi, ilerleme galerisi, çalışma planlayıcı, tema uyumlu UI bileşenleri |
| **Tests** | 26 test paketi (`test/`) | Yönlendirme, navigasyon, metabolik motor, diyetisyen tarayıcı, runtime koruma, AI, zihinsel gelişim, bildirim, ilerleme galerisi ve uçtan uca akış testleri |

---

## 🎯 Temel Özellikler

### 1. 🤖 Gemini Yapay Zeka Entegrasyonu (Gemini 3.6 Flash & Next-Gen Core)
- **Doğrudan REST & Çoklu Model Desteği:** Google'ın en güncel **`gemini-3.6-flash`**, `gemini-3.5-flash` ve `gemini-3.1-pro` modelleriyle tam uyumlu, SDK bağımlılığı olmadan doğrudan çalışan yüksek hızlı REST mimarisi.
- **AI Besin & Makro Çözücü (Natural Language AI Decoder):** Yemek ekleme penceresinde serbest dille yazılan karmaşık öğünleri (*ör: "2 haşlanmış yumurta, 1 dilim tam buğday ekmeği, 50g lor ve 5 zeytin"*) Gemini yapay zekasıyla saniyeler içinde analiz eder; yemek adını, toplam kaloriyi, protein, karbonhidrat ve yağ makrolarını ayrıştırıp forma otomatik işler.
- **"Sistem" Uyanış & Canlı Teşhis (The System Voice & Live Diagnostic):** Solo Leveling evrenindeki otoriter ve disiplinli "Sistem" sesini simüle eder. Profil ekranındaki **`DIAGNOSTIC`** butonuyla avcının durumunu denetler, canlı model keşfi yapar ve `[BİLDİRİM]` formatında RPG atmosferli sistem uyanış mesajları üretir (`CORE ONLINE`).
- **AI Haftalık Antrenman Üretimi:** Avcının boy, kilo, rank, dövüş branşı, 1RM ağırlıkları, eklem sakatlıkları ve odak bölgelerine göre 7 günlük tam antrenman planını Gemini AI üretir. Hibrit fail-safe güvenliğiyle API yoksa yerel kural motoruna düşer.
- **AI Çalışma Planı Üretimi (`aiCalismaPlaniUret`):** Seçilen uzmanlık alanına (Yazılım, Yabancı Dil, Akademik, Kitap, Finans, Kişisel Gelişim) göre Gemini AI'dan yapılandırılmış zihinsel görev listesi oluşturur.
- **AI Kitap Analizi & Çıkarım (`aiKitapCikarimiUret`):** Girilen kitap adına göre Gemini AI'dan okuma stratejisi, bölüm özetleri ve anahtar çıkarımlar üretir.
- **AI Kişiselleştirilmiş Bitirici (`AI AVCI ÖZEL BOOSTER`):** Avcının rütbesi, dövüş branşı ve hedef bölgelerine göre 4-5 hareketlik yoğun bitirici seansını tek tuşla üretir.
- **Güvenli API Anahtarı Yönetimi:** Profil ekranındaki **`SET KEY`** modalı üzerinden maskeli biçimde API anahtarı girilebilir, güncellenebilir veya test edilebilir. Anahtarlar Git depolarına sızmaz; cihazın güvenli yerel hafızasında (`SharedPreferences`) saklanır.
- **Akıllı Model Kalıcılığı & Otomatik Migrasyon:** Keşfedilen çalışan model ve anahtar oturumlar arasında korunur; eski/kapatılmış model isimleri (`gemini-1.5-flash` vb.) otomatik olarak en güncel `gemini-3.6-flash` motoruna taşınır.

### 2. ⚔️ RPG Stat Sistemi
- **HP / MP:** Sağlık ve Mana puanları (görev başarısı, diyet, uyku ve zihinsel aktiviteye bağlı).
- **Level / EXP:** Deneyim puanı ve seviye atlama (EXP eşiği her level'da × 1.5 ölçeklenir).
- **AP (Ability Points):** Her level atlayışında +3 AP kazanılır; STR, AGI, VIT, INT, PER özelliklerine dağıtılır.
- **Yorgunluk (Fatigue):** 0-100 arası yıpranma ölçer; dinlenme ve uyku ile azalır, aşırı idmanla artar.
- **5 Ana Stat:**
  - **STR (Kuvvet):** Fiziksel güç antrenmanlarıyla artar.
  - **AGI (Çeviklik):** Bacak ve kardiyo egzersizleriyle gelişir.
  - **VIT (Dayanıklılık):** Mükemmel antrenman ve dinlenme ile yükselir, HP barını büyütür.
  - **INT (Zeka):** Okuma, kodlama ve zihinsel görevlerle gelişir, MP barını büyütür.
  - **PER (Algı):** Meditasyon, strateji pratikleri ve derin odaklanmayla artar.
- **Altın (Gold):** Görevler ve zindan akınlarıyla kazanılır, Sistem Mağazasında harcanır.

### 3. 🧠 Çok Yönlü Avcı Gelişim Sistemi (Multi-Path Growth)
- **Zihinsel Görev Motoru (`MentalTask`):** Kitap okuma, kodlama/yazılım, yabancı dil, sınav hazırlığı, beceri geliştirme ve genel kişisel gelişim kategorilerinde görev oluşturma ve takip.
- **AI Çalışma Planlayıcı (`StudyPlannerModal`):** Uzmanlık alanı seçimi, hedef süresi ve kişisel not girişiyle Gemini AI'dan yapılandırılmış çalışma planı oluşturma. 6 alan: Yazılım & Kodlama, Yabancı Dil, Akademik & Sınav, Kitap Okuma & Analiz, Finans & Strateji, Kişisel Gelişim & Felsefe.
- **Bilişsel Zindan — Deep Work Timer (`DeepWorkTimerScreen`):** Pomodoro tabanlı odaklanma sayacı (25/45/60/90 dakika), Odak & Dinlenme fazları, otomatik seans yönetimi, tamamlanan seansların otomatik INT/PER stat artışı ve EXP ödülü.
- **Kitap Takibi & Sayfa Hedefleri:** Kitap başlığı ve hedef sayfa sayısı belirleme, tamamlanan kitaplar listesi ve toplam okunan sayfa istatistikleri.
- **Dashboard Entegrasyonu:** Zihinsel görevler Dashboard'da filtreleme çipleri (Tümü / Fiziksel / Zihinsel) ile gösterilir. "🧠 Bilişsel Zindan" ve "📋 Çalışma Planla" portal butonlarıyla ilgili ekranlara hızlı erişim.
- **Dinlenme Günü Kartı:** Antrenman planı olmayan günlerde aktif dinlenme ve pasif iyileşme önerileri sunan özel Dashboard kartı.

### 4. 🧪 Görsel Makro Laboratuvarı (Macro Lab)
- `diet_screen.dart` ve `diyet_motoru.dart` ile tam entegre çalışan analitik ekran.
- Kullanıcının vücut tipi, metabolizma hızı ve hedefine göre önerilen protein, yağ ve karbonhidrat dengesini dairesel grafik ve animasyonlu göstergelerle sunar.
- Öğün zamanlama önerileri ve kalori dağılım analizleri içerir.
- US Navy biyometrik kart ile vücut yağ oranı ve LBM değerleri görselleştirilir.

### 5. 📚 YouTube Destekli Antrenman Kütüphanesi (Workout Library)
- `StatusWindow` ve `WorkoutPlannerScreen` AppBar'larından doğrudan erişilebilir.
- Kas gruplarına göre kategorize edilmiş **875+** satırlık kapsamlı hareket rehberi.
- YouTube üzerinden doğru form videolarına tek tuşla yönlendirme ve kişiselleştirilmiş programlara hareket aktarma imkanı.

### 6. 🧭 Akıllı Yönlendirme & Yaşam Döngüsü (Smart Routing)
- Kullanıcı daha önce kayıt olmuşsa açılışta doğrudan `AnaEkran`'a geçer; kayıt bulunmadığında ilk kurulum ekranı (`SetupScreen`) açılır.
- **Gece Yarısı Görev Döngüsü:** Tarih değiştiğinde yalnızca tamamlanan günün görevleri sıfırlanır, haftanın diğer günlerinin kayıtları korunur.

### 7. 🥊 Dövüş Sporları & Boksör Motoru (Combat Athlete System)
- **Çoklu Branş Seçimi:** Boks, Kickboks, Muay Thai, MMA, Güreş / BJJ branşlarını tekli veya çoklu seçebilme.
- **Dövüşçü Uyanış & Güç Değerlendirmesi:** Patlayıcı şınav (plyo push-up), 3 dk raund kondisyonu (burpee/sprawl), plank ve barfiks dayanıklılığı.
- **1RM Ağırlık Entegrasyonu:** Barbell Bench Press, Squat, Deadlift 1RM ağırlıkları dövüşçü testine dahil edilir; vücut ağırlığına oranlı kuvvet bonusuyla yumruk patlayıcılığı ve gövde direnci ödüllendirilir.
- **Özel Dövüş Antrenmanları:** Gölge boksu, reaksiyon/çeviklik, torba kombinasyonları ve rotasyonel core antrenmanları.
- **Branşa Özel 5-6 Raundluk Gölge Boksu Stilleri:** Boks (Peek-a-boo & Out-boxer), Kickboks (Dutch Volume & Low Kick), Muay Thai (8 Uzuv Teep/Dirsek), MMA (Seviye Değişimi & Sprawl) ve Güreş için her raundu ayrı kombinasyon ve stil içeren profesyonel dövüş simülasyonu.

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

### 16. 😴 Uyku Takibi & Toparlanma Sistemi (Sleep Tracker)
- **Uyku Saat Giriş Kartı (`SleepTrackerCard`):** 0-16 saat arası hassas uyku girişi.
- **Duruma Göre Dinamik Geri Bildirim:**
  - 0-5 saat: ⚠️ YETERSİZ — Yorgunluk artışı & MP kaybı.
  - 6 saat: ⚖️ MİNİMAL — Bazal toparlanma.
  - 7-9 saat: ✨ OPTİMAL — +2 MP & Tam Yorgunluk Arınması.
  - 10+ saat: 🛡️ DERİN HİBERNASYON — Maksimum hücre onarımı.
- **Gece Yarısı Entegrasyonu:** Uyku verisi HP/MP regenerasyonuna ve yorgunluk hesabına doğrudan etki eder.

### 17. 📸 İlerleme Galerisi & Dönüşüm Kasası (Progress Gallery)
- **Fotoğraf Kayıt (`ProgressGalleryModal`):** Kamera veya galeriden vücut fotoğrafı çekme, kilo ve not ile birlikte kaydetme.
- **Zaman Çizelgesi Görünümü:** Tarih sıralı fotoğraf galerisi ve kilo değişim takibi.
- **Önce/Sonra Karşılaştırması:** Tab navigasyonuyla galeri ve istatistik görünümleri.

### 18. 🔔 Yerel Bildirim & Hatırlatma Sistemi (Notification Service)
- **Su Hatırlatıcısı:** Ayarlanabilir saatlik aralıklarla (varsayılan 2 saat) su içme hatırlatıcısı.
- **İdman Hatırlatıcısı:** Belirlenen saat ve dakikada antrenman hatırlatıcısı.
- **Gece Hesaplaşma Raporu:** Günlük performans değerlendirmesi ve stat güncellemesi hatırlatıcısı.
- **Solo Leveling Temalı Mesajlar:** RPG atmosferli `[SİSTEM BİLDİRİMİ]` formatında bildirimler.

### 19. 📊 Dinamik Zorluk Adaptasyonu (Dynamic Difficulty — DDA)
- **Otomatik Analiz (`DynamicDifficultyEngine`):** Streak, yorgunluk, HP ve idman geçmişine göre zorluk önerisi.
- **3 Aksiyon Modu:**
  - **Upgrade:** Avcı güçlendiyse zorluk artırma önerisi.
  - **Deload:** Aşırı yıpranma tespit edildiğinde aktif dinlenme & deload protokolü.
  - **Maintain:** Optimum denge korunuyorsa mevcut zorluk sürdürülür.

### 20. 🧙 4 Adımlı Avcı Uyanış Sihirbazı (SetupScreen Wizard)
- Tek sayfada yığılan form yerine 4 aşamalı temiz, sinematik Solo Leveling akışı:
  - **Phase 01 (Identity):** Avcı adı, cinsiyet, doğum tarihi, avatar ve Gemini API anahtarı.
  - **Phase 02 (Body Calibration):** Boy, kilo, hedef, zorluk ve **Full Body Scan (Göğüs, Bel, Kol, Bacak cm)**.
  - **Phase 03 (Combat & Gear):** Çoklu dövüş branşları, öncelikli yağ yakım odakları ve eklem koruması.
  - **Phase 04 (Awakening Test):** Kondisyon + 1RM Halter testleri ve canlı hesaplanan avcı rütbesi.
- **3 Test Modu:** Barbell 1RM, Calisthenics Reps ve Combat Stamina testleri (`AwakeningTestDialog`).
- **Sistem Uyanış Yükleme Modalı:** "AWAKEN THE SYSTEM" butonuna basıldığında API anahtarını ve ayarları denetleyen *"LÜTFEN BEKLEYİNİZ"* ekranı.

---

## ⚡ Tamamlanan Geliştirme Fazları

### ✅ Faz 1: Antrenman Zekası & Zindan Sistemi (%100 TAMAMLANDI)

1. **Gemini AI Destekli Kişiselleştirilmiş Antrenman:** Avcının boy, kilo, rank, sakatlık kısıtı ve odak bölgelerine göre haftalık 7 günlük plan üretimi & fail-safe yerel kural motoru.
2. **Tek Dokunuşla YouTube Video Rehberi:** Dashboard, Takvim, Antrenman Planlayıcı, Aktif İdman ve Kütüphanedeki tüm hareketlerde canlı YouTube arama ve form videosu açma.
3. **Solo Leveling Avcı Taktik Kartı & Akıllı Alternatif Değiştirici (Smart Swap):** Egzersize dokunulduğunda açılan hedef kas, dövüş faydası, 3 altın kural ve salondaki yoğunluk/ağrı durumunda 3 muadil hareket önerisi ve tek tıkla swap.
4. **Set, Ağırlık ve Tekrar Takip Kaydedicisi:** Aktif zindan idmanında set bazlı kg/tekrar loglama (`SetKaydi`).
5. **Set Arası Dinlenme Sayacı & Yapay Zeka Sesli Koç (Rest Timer & Voice Coach):** 30-120sn geri sayım sayacı, dinlenme başlangıcı, 3-2-1 geri sayımı, tükeniş ve aşırı yükleme sesli direktifleri (TTS / Text-to-Speech). *(Not: Kullanıcıdan mikrofona gelen sesli komut algılama / Speech-to-Text özelliği mevcut sürümde bulunmamakta olup, gelecek sürümlerin yol haritasındadır.)*
6. **Zindana Dinamik Ek Hareket Enjekte Etme & Kaldırma:** Aktif Zindan Baskını ekranında üst bardaki `+ EKLE` butonu ve listenin altındaki `+ EK HAREKET ENJEKTE ET` butonuyla kategorilere göre (Göğüs, Sırt, Omuz/Kol, Bacak, Karın, Dövüş/Boks) filtrelenen hazır hareketleri veya serbest görevleri seansa anında dahil edebilme ve görev kartından kaldırma desteği.
7. **6-8 Hareket Uzatılmış İdman Standardı & Zorunlu Kardiyo Katmanı:** Tüm varsayılan ve Gemini tarafından üretilen programlar 4-5 set ve 6-8 hareketlik uzatılmış hacme geçirildi. Her idman gününün sonuna kesintisiz ve net bir `[CARDIO]` misyonu yerleştirildi.
8. **Çift Seçenekli Şablon Yükleme (+ İdmana Ekle / 🔄 Sıfırla ve Kur) & Yeni Kardiyo Şablonları:** Saitama, Full Body, Cardio & MetCon Burn, Combat Striker Finisher, Gölge Boksu & Kombinasyonlar, Avcı 5K/10K Koşu & HIIT ve Tabata & MetCon Extreme Burn şablonları hem Append hem Replace modlarıyla.
9. **Kişiye Özel Yapay Zeka Bitirici (`🤖 AI AVCI ÖZEL BOOSTER`):** Avcının rütbesi, dövüş branşı ve hedef odak bölgelerine göre 4-5 hareketlik yoğun bitirici seansını tek tuşla idmana ekleyen Gemini REST ve akıllı yerel algoritma motoru.
10. **Dövüş Sporlarına Göre 5-6 Raundluk Gölge Boksu Stilleri & Kombinasyonları.**
11. **İdmanı Uzatma, Dinamik Hacim Kademeleri & Kardiyo Kategori Seçicisi:** Standart (4 Set), Uzatılmış (6 Set), Şampiyon (8 Set) ve Ekstrem (10 Set) hızlı seviyeleri, 15 sete ve 50 tekrara kadar sayaçlar.
12. **Dungeon & Boks Sayacı Mutlak Duvar Saati (Wall-Clock) Senkronizasyonu & Canlı Raid HUD.**
13. **Gelişmiş Egzersiz Seçici Modal (`AdvancedExerciseSelectorModal`):** 875+ kütüphaneden canlı arama, kategori çipleri, set/tekrar ve kardiyo dakika filtreleri.

---

### ✅ Faz 2: Bilimsel Metabolik Motor, Diyetisyen Analizi & Hedef Kilo Entegrasyonu (%100 TAMAMLANDI)

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

### ✅ Faz 3: Akıllı Antrenman Zekası & Progresif Aşırı Yükleme Motoru (%100 TAMAMLANDI)

1. **📈 Çift Progresyon Kural Motoru (`ProgressiveOverloadEngine`):**
   - **RIR 4+ (Çok Kolay / Hafif Yük):** Ağırlık otomatik olarak üst gövdede **+2.5 kg**, bacakta **+5.0 kg** (vücut ağırlığı egzersizlerinde **+2 tekrar**) artırılır.
   - **RIR 2-3 (Optimum Hipertrofi):** Ağırlık korunur, bir sonraki seans için **+1 tekrar** hedefi konur. 12 tekrar barajına ulaşıldığında ağırlık artırılıp tekrar 8'e dengelenir.
   - **RIR 0-1 (Tükeniş / Limit):** Ağırlık ve tekrar korunur, toparlanma ve protein alımı emredilir.
2. **⚠️ Eklem Koruma Protokolü & Güvenli İkame:**
   - Egzersiz esnasında omuz, diz, bel veya dirsekte batma/ağrı bildirildiğinde sistem `ExerciseCoach` üzerinden anında eklem dostu alternatif hareket atar.
3. **⚡ Holografik Sistem Penceresi (`RirFeedbackModal`):**
   - Egzersiz onaylandığında veya tüm setler bittiğinde açılan 1 dokunuşluk Solo Leveling Sistem Bildirimi.
4. **💾 Kalıcı Aşırı Yükleme Hafızası (`SystemMemory.overloadGecmisi`):**
   - Avcının her hareketteki son ağırlığı, tekrarı, RIR puanı ve sistem direktifleri şifrelenmiş veri kasasında saklanır.

---

### ✅ Faz 4: Çok Yönlü Avcı Gelişim Sistemi & Sistem İyileştirmeleri (%100 TAMAMLANDI)

1. **🧠 Zihinsel Görev Motoru (`MentalTask` Model):**
   - `id`, `title`, `category` (Book/Coding/Language/Exam/Skill/General), `targetMinutes`, `completedMinutes`, `rewardExp`, `rewardInt`, `rewardPer`, `bookTitle`, `targetPages`, `completedPages`, `notes` alanlarıyla tam yapılandırılmış zihinsel görev modeli.
   - JSON serileştirme ve `copyWith` desteği.
2. **📋 AI Çalışma Planlayıcı (`StudyPlannerModal`):**
   - 6 uzmanlık alanı: Yazılım & Kodlama, Yabancı Dil, Akademik & Sınav, Kitap Okuma & Analiz, Finans & Strateji, Kişisel Gelişim & Felsefe.
   - 4 süre seçeneği: 25, 45, 60, 90 dakika.
   - Serbest hedef metin girişi ve Gemini AI ile yapılandırılmış çalışma planı üretimi.
   - Çevrimdışı yedek algoritmik plan üretimi (fail-safe).
3. **⏱️ Bilişsel Zindan — Deep Work Timer (`DeepWorkTimerScreen`):**
   - Preset protokoller ile odaklanma ve dinlenme fazları (varsayılan 5 dk dinlenme).
   - Canlı geri sayım, seans tamamlama sayacı, toplam odaklanılan dakika istatistikleri.
   - Tamamlanan seanslar otomatik olarak `SystemMemory.deepWorkTamamlandi()` ile ödüllendirilir: `dakika × 3` EXP, INT artışı (`dakika/25`), PER artışı (`dakika/30`), `dakika × 2` Gold.
4. **📖 AI Kitap Analizi (`aiKitapCikarimiUret`):**
   - Girilen kitap adına göre Gemini AI'dan okuma stratejisi, bölüm özetleri ve anahtar çıkarımlar üretimi.
   - Çevrimdışı yedek: Kitap adı bazlı varsayılan analiz şablonu.
5. **📊 Dashboard Filtreleme & Portal Butonları:**
   - Görev filtreleme çipleri: Tümü / Fiziksel / Zihinsel.
   - Portal butonları: 🧠 Bilişsel Zindan (DeepWorkTimerScreen) ve 📋 Çalışma Planla (StudyPlannerModal).
   - Dinlenme Günü kartı: Antrenman planı olmayan günlerde aktif dinlenme & pasif iyileşme önerileri.
6. **😴 Uyku Takibi Sistemi (`SleepTrackerCard`):**
   - Profil ekranına entegre uyku saat girişi, duruma göre renkli geri bildirimler.
   - HP/MP regenerasyonuna ve yorgunluk azalmasına doğrudan etki.
7. **📸 İlerleme Galerisi (`ProgressGalleryModal`):**
   - Fotoğraf + kilo + not ile dönüşüm kaydı.
   - Galeri ve istatistik tab görünümleri.
8. **🔔 Yerel Bildirim Servisi (`NotificationService`):**
   - Su hatırlatıcısı (ayarlanabilir aralık), idman hatırlatıcısı (ayarlanabilir saat), gece raporu hatırlatıcısı.
   - Android bildirim kanalları ve zaman dilimi desteği (`timezone`, `flutter_local_notifications`).
9. **📊 Dinamik Zorluk Adaptasyonu (`DynamicDifficultyEngine`):**
   - Streak, yorgunluk, HP ve idman geçmişi analizi ile upgrade/deload/maintain önerisi.
   - Ses efektleri ile önerilerin desteklenmesi.
10. **🏆 Başarım Diyaloğu (`AchievementDialog`):**
    - Kademeli başarım bildirimi animasyonu, ses efektleri ve kutlama ekranı.
11. **🧪 Uyanış Testi Genişletmesi (`AwakeningTestDialog`):**
    - 3 test modu: Barbell 1RM, Calisthenics Reps ve Combat Stamina.
    - Profil ekranından erişilebilir yeniden test mekanizması.
12. **🎨 UI Standardizasyonu:**
    - Welcome ve Instruction ekranları `HologramCard` temasına uyarlandı.
    - Merkezi `AppColors` tema dosyasından yönetilen tutarlı renk sistemi (Koyu arka plan `#030712`, Buz Mavisi `#38BDF8`, 4px keskin kenarlı HologramCard standardı).

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
| **Yapay Zeka Sesli Koç (Voice)** | ✅ **YAPILDI** | Dinlenme sayacı başlama, 3-2-1 geri sayım, zafer uyarıları & overload direktifleri (TTS). Mikrofondan ses tanıma (STT) yol haritasında. |
| **Canlı Kamera Vizörü (Lens)** | ✅ **YAPILDI** | Cihaz kamerası ile doğrudan tabak fotoğrafı çekme ve OCR tarama |
| **Biyometrik Radar Grafiği** | ✅ **YAPILDI** | 5-stat STR/AGI/VIT/INT/PER pentagon siber radar poligonu ve sınıf tayini |
| **Su Takibi (Hydration)** | ✅ **YAPILDI** | Günlük su sayacı, hızlı giriş butonları ve gece yarısı ödül/ceza |
| **Avcı Çantası & Envanter** | ✅ **YAPILDI** | Eşya satın alma, çantadan canlı eşya kullanımı (`hp_full`, `cheat_meal` vb.) |
| **Veri Kasası (Data Vault)** | ✅ **YAPILDI** | Şifrelenmiş JSON arşiv dışa/içe aktarma ile tam veri yedekleme |
| **Çift Dil Desteği (TR/EN)** | ✅ **YAPILDI** | Tüm sistem unvanları, hedefler, diyaloglar, modallar, arama ipuçları ve dinamik dil anahtarı ile %100 temiz iki dilli mimari |
| **Zihinsel Görev Motoru** | ✅ **YAPILDI** | `MentalTask` model, 6 kategori, kitap & sayfa takibi, INT/PER ödülleri |
| **AI Çalışma Planlayıcı** | ✅ **YAPILDI** | `StudyPlannerModal`, 6 uzmanlık alanı, Gemini AI plan üretimi, çevrimdışı yedek |
| **Bilişsel Zindan (Deep Work)** | ✅ **YAPILDI** | Pomodoro sayacı, odak/dinlenme fazları, EXP/INT/PER ödülleri, seans takibi |
| **AI Kitap Analizi** | ✅ **YAPILDI** | `aiKitapCikarimiUret`, okuma stratejisi, bölüm özetleri & çıkarımlar |
| **Dashboard Filtreleme** | ✅ **YAPILDI** | Tümü/Fiziksel/Zihinsel çipleri, portal butonları, dinlenme günü kartı |
| **Uyku Takibi (Sleep)** | ✅ **YAPILDI** | 0-16 saat girişi, HP/MP/Yorgunluk etkisi, duruma göre renk kodlu geri bildirim |
| **İlerleme Galerisi** | ✅ **YAPILDI** | Fotoğraf + kilo kaydı, galeri & istatistik tab'ları, tarih sıralı görünüm |
| **Yerel Bildirimler** | ✅ **YAPILDI** | Su, idman, gece raporu hatırlatıcıları, Android kanal desteği |
| **Dinamik Zorluk (DDA)** | ✅ **YAPILDI** | Upgrade/Deload/Maintain analizi, streak & yorgunluk tabanlı akıllı öneriler |
| **Başarım Diyaloğu** | ✅ **YAPILDI** | Kademeli başarım bildirimi, animasyonlu kutlama ve ses efektleri |
| **Uyanış Testi** | ✅ **YAPILDI** | 3 test modu (1RM/Calisthenics/Combat), profil ekranından yeniden test |

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

Proje güvenilirliği için **26 test paketi** ve **127 testin tamamı** hazırlanmış ve çalıştırılmıştır (%100 Başarılı / 127 Passed, 0 Failed):

| # | Test Dosyası | Kapsam |
|---|-------------|--------|
| 1 | `test/supplement_and_radar_test.dart` | Suplement kuşanma/çıkarma, dinamik su artışı (+500ml), tolerans bonusları, akıllı öneriler, sesli koç sinyalleri/sessize alma ve 5-stat biyometrik radar çizimi |
| 2 | `test/progressive_overload_engine_test.dart` | Çift progresyon (Double Progression), RIR 4+ (+2.5kg/+5kg), RIR 2-3 (+1 rep), RIR 0-1 (toparlanma), eklem koruma ikamesi, `OverloadKaydi` JSON ve `RirFeedbackModal` widget testleri |
| 3 | `test/advanced_metabolic_engine_test.dart` | US Navy vücut yağı, LBM, Katch-McArdle BMR, TDEE, MET yıpranması, hedef kilo projeksiyonu ve sisteme entegrasyon testleri |
| 4 | `test/dietitian_scanner_widget_test.dart` | Diyetisyen tarayıcı modalı, form alanları ve Makro Lab US Navy biyometrik kart render testleri |
| 5 | `test/assessment_flow_widget_test.dart` | 4 Adımlı Wizard, çoklu dövüş branşı, 1RM dövüş ağırlık testleri, odak bölgeleri, unvan senkronizasyonu |
| 6 | `test/system_features_test.dart` | Su takibi, çanta, makrolar, Data Vault, odak bölgelerine göre dinamik antrenman uyarlaması |
| 7 | `test/exercise_coach_test.dart` | Avcı Taktik Kartı, Akıllı Alternatif Değiştirici (Smart Swap), SetKaydi serileştirmesi, RestTimer ve Detail Modal |
| 8 | `test/workout_experience_flow_test.dart` | Dashboard taktik kartı ve swap akışı, Aktif İdman Set Logger & Rest Timer, Zindana Ek Hareket Enjekte Etme ve Silme, Workout Planner butonları |
| 9 | `test/dungeon_boxing_sync_test.dart` | Zindan & Combat Sim sayaç senkronizasyonu, canlı raid HUD banner'ı ve zindanın erken kapanmasını önleme testleri |
| 10 | `test/advanced_exercise_selector_modal_test.dart` | 875+ kütüphaneden canlı arama, kategori filtreleri, set/tekrar ve kardiyo dakika seçicileri ile plana/zindana enjeksiyon |
| 11 | `test/youtube_helper_test.dart` | Egzersiz başlık sanitizasyonu, [COMBAT]/[PHY] etiketleri ve set/tekrar ayıklama testleri |
| 12 | `test/gemini_integration_test.dart` | Profil API anahtarı, AI besin çözücü ve AI haftalık antrenman fail-safe fallback testi |
| 13 | `test/language_switch_test.dart` | Türkçe/İngilizce çift dil geçişi, unvanlar, hedefler ve dil fallback |
| 14 | `test/midnight_reset_test.dart` | Gece yarısı tek gün sıfırlama ve aktif model kalıcılık testi |
| 15 | `test/main_routing_test.dart` | Kayıtlı ve yeni kullanıcı başlangıç yönlendirmesi doğrulaması |
| 16 | `test/workout_library_navigation_test.dart` | Status & Workout Planner üzerinden kütüphaneye geçiş ve render testi |
| 17 | `test/macro_lab_navigation_test.dart` | Diyet ekranından Makro Lab geçişi ve `FormatException` çökme koruması |
| 18 | `test/mental_growth_system_test.dart` | Zihinsel görev ekleme/silme/tamamlama, Deep Work ödülleri, kitap takibi, MentalTask JSON serileştirme ve AI çalışma planı yedek motoru |
| 19 | `test/mental_growth_ui_test.dart` | Dashboard filtreleme çipleri, zihinsel görev kartları, portal butonları, dinlenme günü kartı ve DeepWorkTimer widget testleri |
| 20 | `test/achievement_dialog_test.dart` | Başarım diyaloğu açılma, animasyon ve mesaj ayrıştırma testleri |
| 21 | `test/calendar_workout_history_test.dart` | Takvim ekranı geçmişe yönelik antrenman verisi testleri |
| 22 | `test/dynamic_difficulty_test.dart` | Dinamik zorluk adaptasyonu (DDA) analizi, upgrade/deload/maintain testleri |
| 23 | `test/notification_feature_test.dart` | Yerel bildirim servisi başlatma, test modu, su/idman/gece hatırlatıcı testleri |
| 24 | `test/progress_gallery_test.dart` | İlerleme galerisi fotoğraf ekleme/silme, kilo takibi ve tab navigasyonu testleri |
| 25 | `test/sleep_tracker_test.dart` | Uyku takibi kartı, saat güncelleme, durum metni ve HP/MP etki testleri |
| 26 | `test/system_improvements_test.dart` | Sistem genel iyileştirme ve regresyon testleri |

Testleri çalıştırmak için:
```bash
flutter test
```

---

## 🛠️ Teknoloji Stack

| Katman | Teknoloji | Versiyon |
|--------|-----------|----------|
| **Platform** | Flutter (Dart SDK) | `^3.11.3` (Flutter `3.47.2+`) |
| **Yapay Zeka** | Google Gemini REST API | `gemini-3.6-flash`, `gemini-3.5-flash`, `gemini-3.1-pro` |
| **HTTP İstemcisi** | `http` | `^1.2.0` |
| **Durum Yönetimi** | `ValueNotifier` + reactive state | Built-in |
| **Veri Kalıcılığı** | `shared_preferences` | `^2.5.5` |
| **Güvenli Depolama** | `flutter_secure_storage` | `^9.2.2` |
| **Tipografi** | Google Fonts (`Orbitron`, `Rajdhani`) | `^8.2.1` |
| **Ses Sistemi** | `audioplayers` | `^6.6.0` |
| **Takvim** | `table_calendar` | `^3.1.2` |
| **Kamera & Galeri** | `image_picker` | `^1.2.1` |
| **Dış Bağlantılar** | `url_launcher` | `^6.2.5` |
| **Yerel Bildirimler** | `flutter_local_notifications` | `^22.3.1` |
| **Zaman Dilimleri** | `timezone` | `^0.11.1` |
| **Arka Plan Servis** | `flutter_background_service` | `^5.1.0` |
| **Ekran Uyanıklığı** | `wakelock_plus` | `^1.2.8` |
| **Uygulama İkonu** | `flutter_launcher_icons` | `^0.13.1` |
| **Kod Kalitesi** | `flutter_lints` | `^6.0.0` (0 linter uyarısı) |

---

## 🚀 Kurulum ve Çalıştırma

```bash
# 1. Depoyu klonlayın ve klasöre girin
git clone <repo-url>
cd solo_app

# 2. Paket bağımlılıklarını indirin
flutter pub get

# 3. Testleri doğrulayın (26 test paketi)
flutter test

# 4. Uygulamayı cihaz üzerinde başlatın
flutter run

# 5. APK oluşturmak için
flutter build apk --release
```

---

## 📜 Lisans

Bu proje Solo Leveling temalı kişisel gelişim ve RPG motivasyon aracı olarak geliştirilmektedir.
