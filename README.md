# 🎮 Solo Leveling App

**Solo Leveling** animesinden ilham alan, kişisel gelişim ve fitness takibi yapan bir **gamification (oyunlaştırma) uygulaması**. Kullanıcı bir "Avcı" (Hunter) olarak görev yapar; egzersiz, diyet, zihinsel gelişim ve kişisel beceri görevlerini tamamlayarak EXP, Gold, AP kazanır ve level atlar.

> **"Sadece güçlü olan değil, sürekli gelişen ayakta kalır."**

---

## 📁 Proje Mimarisi

```
lib/
├── main.dart                         # Uygulama giriş noktası ve akıllı kayıt yönlendirmesi
├── controllers/
│   ├── system_memory.dart            # Ana oyun state'i (577 satır) — ValueNotifier reaktif durum yönetimi
│   └── memory_modules/
│       ├── memory_storage.dart       # SharedPreferences kalıcılık ve JSON serileştirme motoru
│       ├── memory_workout.dart       # Antrenman geçmişi, idman istatistikleri, AI plan üretimi ve gölge boksu
│       ├── memory_nutrition.dart     # Beslenme hesaplamaları, gece yarısı hesaplaşması, diyet & diyetisyen yönetimi
│       └── memory_combat_ranks.dart  # Stat & EXP hesaplama, level atlama, başarım, rütbe, çanta & backup
├── core/
│   ├── advanced_metabolic_engine.dart  # Bilimsel US Navy, LBM, BMR, TDEE, MET yıpranma & projeksiyon motoru
│   ├── supplement_engine.dart        # Suplement kuşanma, dinamik su artışı (+500ml) & metabolik sinerji motoru
│   ├── voice_coach_system.dart       # Dinlenme sayacı & aşırı yükleme yapay zeka sesli koç sistemi
│   ├── progressive_overload_engine.dart # Çift progresyon (Double Progression) & RIR motoru
│   ├── dynamic_difficulty_engine.dart # Dinamik zorluk adaptasyonu (DDA), deload/upgrade/maintain analizi
│   ├── system_session_manager.dart   # Deep Work & Rest Timer oturum yöneticisi, wall-clock senkronizasyonu
│   ├── audio_system.dart             # Ses efektleri yönetimi (mixWithOthers desteği)
│   ├── diyet_motoru.dart             # Makro besin (Protein/Karb/Yağ) ve kalori hesaplama motoru
│   ├── exercise_coach.dart           # Avcı Taktik Kartı ve Akıllı Egzersiz Değiştirici (Smart Swap)
│   ├── document_parser.dart          # Doküman ayrıştırma ve metin çıkarma
│   ├── sistem_gecisi.dart            # Hologram sayfa geçiş animasyonu
│   ├── translation_manager.dart      # Çift dil (TR/EN) yerelleştirme yöneticisi (55KB)
│   ├── youtube_helper.dart           # YouTube egzersiz formu arama ve video yönlendirme
│   ├── services/
│   │   ├── gemini_service.dart       # Google Gemini AI servisi (Besin analizi, diyetisyen OCR, antrenman üretimi, çalışma planı, kitap analizi & Sistem sesi)
│   │   └── notification_service.dart # Yerel bildirim ve hatırlatma servisi (Su, İdman, Gece raporu)
│   └── theme/
│       └── app_colors.dart           # Merkezi renk paleti ve tema sabitleri
├── models/
│   ├── task_model.dart               # Görev (Gorev) & Set Kaydı (SetKaydi) veri modeli
│   ├── food_model.dart               # Tüketilen yemek (TuketilenYemek) veri modeli
│   ├── workout_model.dart            # Egzersiz şablonu (EgzersizSablonu) veri modeli
│   ├── inventory_item_model.dart     # Avcı çantası eşya (InventoryItem) modeli
│   └── mental_task_model.dart        # Zihinsel görev (MentalTask) modeli — Kitap, Kodlama, Dil, Sınav, Beceri kategorileri
├── screens/
│   ├── ana_ekran.dart                # Ana navigasyon kabuğu (Bottom Navigation)
│   ├── dashboard_screen.dart         # Dashboard — Level, Stat, Başarımlar, Haftalık Boss, Zihinsel Görevler & Portal Butonları
│   ├── status_screen.dart            # Stat dağıtımı, HP/MP/Fatigue barları & Antrenman Kütüphanesi köprüsü
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
    ├── dietitian_scanner_modal.dart  # Diyetisyen menüsü OCR tarama ve çoklu gün onay modalı
    ├── advanced_exercise_selector_modal.dart # Canlı filtreli gelişmiş egzersiz enjeksiyon modalı
    ├── exercise_detail_modal.dart    # Avcı Taktik Kartı detay modalı (hedef kas, altın kurallar & Smart Swap)
    ├── rest_timer_dialog.dart        # Sesli koç entegrasyonlu ve ses anahtarlı dinlenme sayacı
    ├── sleep_tracker_card.dart       # Uyku takibi kartı (0-16 saat, HP/MP bonusu & yorgunluk arınması)
    ├── progress_gallery_modal.dart   # İlerleme fotoğrafları galerisi & kilo değişim zaman çizelgesi
    ├── global_timer_hud.dart         # Alt gezinme çubuğu üstünde canlı Deep Work / Rest Timer HUD'u
    └── study_planner_modal.dart      # AI tabanlı çalışma planlayıcı modalı (alan seçimi, süre, hedef girişi)
```

### Katman Yapısı

| Katman | Bileşenler | Rol |
|--------|------------|-----|
| **Controllers** | `system_memory.dart` + 4 hafıza modülü | Oyun durumu, kalıcılık (SharedPreferences), RPG formülleri, hedef kilo & diyetisyen reçeteleri, gece yarısı hesaplaşması, zihinsel görev yönetimi |
| **Core & Services** | 13 core modül + 2 servis | US Navy & Katch-McArdle metabolik formülleri, MET idman yıpranması, yapay zeka servisleri, yerel bildirimler, dinamik zorluk adaptasyonu, akıllı egzersiz koçluğu, video sanitizasyonu, oturum yönetimi |
| **Models** | 5 model | Tip güvenli veri modelleri ve JSON serileştirme |
| **Screens** | 16 ekran | Kullanıcı arayüzü ve navigasyon akışları |
| **Widgets** | 15 widget | Diyetisyen OCR tarayıcısı, egzersiz seçicisi, uyku takibi, ilerleme galerisi, çalışma planlayıcı, canlı timer HUD, tema uyumlu UI bileşenleri |
| **Tests** | 28 test paketi (`test/`) | Yönlendirme, navigasyon, metabolik motor, diyetisyen tarayıcı, runtime koruma, AI, zihinsel gelişim, bildirim, ilerleme galerisi, oturum yönetimi ve uçtan uca akış testleri |

---

## 🎯 Temel Özellikler

### 1. 🤖 Gemini Yapay Zeka Entegrasyonu (Gemini 3.6 Flash & Next-Gen Core)
- **Doğrudan REST & Çoklu Model Desteği:** Google'ın en güncel **`gemini-3.6-flash`**, `gemini-3.5-flash` ve `gemini-3.1-pro` modelleriyle tam uyumlu, SDK bağımlılığı olmadan doğrudan çalışan yüksek hızlı REST mimarisi.
- **AI Besin & Makro Çözücü (Natural Language AI Decoder):** Yemek ekleme penceresinde serbest dille yazılan karmaşık öğünleri (*ör: "2 haşlanmış yumurta, 1 dilim tam buğday ekmeği, 50g lor ve 5 zeytin"*) Gemini yapay zekasıyla saniyeler içinde analiz eder; yemek adını, toplam kaloriyi, protein, karbonhidrat ve yağ makrolarını ayrıştırıp forma otomatik işler.
- **"Sistem" Uyanış & Canlı Teşhis (The System Voice & Live Diagnostic):** Solo Leveling evrenindeki otoriter ve disiplinli "Sistem" sesini simüle eder. Profil ekranındaki **`DIAGNOSTIC`** butonuyla avcının durumunu denetler, canlı model keşfi yapar ve `[BİLDİRİM]` formatında RPG atmosferli sistem uyanış mesajları üretir (`CORE ONLINE`).
- **AI Haftalık Antrenman Üretimi:** Avcının boy, kilo, rank, dövüş branşı, 1RM ağırlıkları, eklem sakatlıkları ve odak bölgelerine göre 7 günlük tam antrenman planını Gemini AI üretir. Hibrit fail-safe güvenliğiyle API yoksa yerel kural motoruna düşer.
- **AI Çalışma Planı Üretimi:** Seçilen uzmanlık alanına (Yazılım, Yabancı Dil, Akademik, Kitap, Finans, Kişisel Gelişim) göre Gemini AI'dan yapılandırılmış zihinsel görev listesi oluşturur.
- **AI Kitap Analizi & Çıkarım:** Girilen kitap adına göre Gemini AI'dan okuma stratejisi, bölüm özetleri ve anahtar çıkarımlar üretir.
- **AI Kişiselleştirilmiş Bitirici (AI AVCI ÖZEL BOOSTER):** Avcının rütbesi, dövüş branşı ve hedef bölgelerine göre 4-5 hareketlik yoğun bitirici seansını tek tuşla üretir.
- **Güvenli API Anahtarı Yönetimi:** Profil ekranındaki **`SET KEY`** modalı üzerinden maskeli biçimde API anahtarı girilebilir, güncellenebilir veya test edilebilir. Anahtarlar cihazın güvenli yerel hafızasında (`SharedPreferences` + `flutter_secure_storage`) saklanır.
- **Akıllı Model Kalıcılığı & Otomatik Migrasyon:** Keşfedilen çalışan model ve anahtar oturumlar arasında korunur; eski/kapatılmış model isimleri otomatik olarak en güncel `gemini-3.6-flash` motoruna taşınır.

### 2. ⚔️ RPG Stat Sistemi & Rütbe Yükseliş Ödülleri
- **HP / MP:** Sağlık ve Mana puanları (görev başarısı, diyet, uyku ve zihinsel aktiviteye bağlı).
- **Level / EXP:** Deneyim puanı ve seviye atlama (EXP eşiği her level'da × 1.5 ölçeklenir).
- **AP (Ability Points):** Her level atlayışında +3 AP kazanılır; STR, AGI, VIT, INT, PER özelliklerine dağıtılır.
- **Yorgunluk (Fatigue):** 0-100 arası yıpranma ölçer; idman ile artar, uyku ile azalır, DDA motorunu tetikler.
- **Rütbe Yükseliş Ödülleri (Hunter Rank Ascension):** Uyanış ve Rütbe Terfi Sınavlarında (`Unranked → E → D → C → B → A → S`) kademe atlandığında:
  - **E-Rank:** +5 AP, +200 EXP, +500 Altın
  - **D-Rank:** +8 AP, +400 EXP, +1.000 Altın
  - **C-Rank:** +12 AP, +800 EXP, +2.000 Altın
  - **B-Rank:** +18 AP, +1.500 EXP, +4.000 Altın
  - **A-Rank:** +25 AP, +3.000 EXP, +8.000 Altın
  - **S-Rank:** +40 AP, +6.000 EXP, +15.000 Altın
- **Akıllı Stat Dağıtım Motoru:** Otomatik (dövüş branşı ve sınıfa göre optimize) veya manuel dağıtım.
- **5 Ana Stat:** STR (Kuvvet), AGI (Çeviklik), VIT (Dayanıklılık — HP büyütür), INT (Zeka — MP büyütür), PER (Algı).
- **Altın (Gold):** Görevler ve zindan akınlarıyla kazanılır, Sistem Mağazasında harcanır.

### 3. 🧠 Çok Yönlü Avcı Gelişim Sistemi (Multi-Path Growth)
- **Zihinsel Görev Motoru (`MentalTask`):** Kitap okuma, kodlama/yazılım, yabancı dil, sınav hazırlığı, beceri geliştirme ve genel kişisel gelişim kategorilerinde görev oluşturma ve takip.
- **AI Çalışma Planlayıcı (`StudyPlannerModal`):** 6 uzmanlık alanı, 4 süre seçeneği, Gemini AI ile yapılandırılmış plan + çevrimdışı yedek.
- **Bilişsel Zindan — Deep Work Timer:** Pomodoro tabanlı odaklanma sayacı (25/45/60/90 dakika), Odak & Dinlenme fazları, otomatik INT/PER stat artışı ve EXP ödülü.
- **Kitap Takibi & Sayfa Hedefleri:** Kitap başlığı, hedef sayfa sayısı, tamamlanan kitaplar listesi ve toplam okunan sayfa istatistikleri.
- **Dashboard Entegrasyonu:** Filtreleme çipleri (Tümü / Fiziksel / Zihinsel), "🧠 Bilişsel Zindan" ve "📋 Çalışma Planla" portal butonları.
- **Dinlenme Günü Kartı:** Antrenman planı olmayan günlerde aktif dinlenme ve pasif iyileşme önerileri.

### 4. 🧪 Görsel Makro Laboratuvarı (Macro Lab)
- Kullanıcının vücut tipi, metabolizma hızı ve hedefine göre önerilen protein, yağ ve karbonhidrat dengesini dairesel grafik ve animasyonlu göstergelerle sunar.
- Öğün zamanlama önerileri, kalori dağılım analizleri ve US Navy biyometrik kart.
- Hedef kilo projeksiyonu, avcının beslenme vizyonu girişi ve AI harmanlama.

### 5. 📚 YouTube Destekli Antrenman Kütüphanesi (Workout Library)
- Kas gruplarına göre kategorize edilmiş **875+** satırlık kapsamlı hareket rehberi.
- YouTube üzerinden doğru form videolarına tek tuşla yönlendirme ve kişiselleştirilmiş programlara hareket aktarma.

### 6. 🧭 Akıllı Yönlendirme & Yaşam Döngüsü (Smart Routing)
- Kayıtlı kullanıcı → doğrudan `AnaEkran`, yeni kullanıcı → 4 adımlı `SetupScreen`.
- **Gece Yarısı Görev Döngüsü:** Tarih değiştiğinde yalnızca tamamlanan günün görevleri sıfırlanır, haftanın diğer günlerinin kayıtları korunur.
- **Çoklu gün kopukluğu koruması:** Uygulama birden fazla gün açılmazsa ek HP cezası ve streak sıfırlama.

### 7. 🥊 Dövüş Sporları & Boksör Motoru (Combat Athlete System)
- **Çoklu Branş Seçimi:** Boks, Kickboks, Muay Thai, MMA, Güreş / BJJ.
- **Dövüşçü Uyanış & Güç Değerlendirmesi:** Patlayıcı şınav, 3 dk raund kondisyonu, plank ve barfiks dayanıklılığı.
- **1RM Ağırlık Entegrasyonu:** Barbell Bench Press, Squat, Deadlift 1RM ağırlıkları dövüşçü testine dahil.
- **Branşa Özel 5-6 Raundluk Gölge Boksu Stilleri:** Her raundu ayrı kombinasyon ve stil içeren profesyonel dövüş simülasyonu.

### 8. 🎯 Öncelikli Odak & Yağ Yakım Protokolü (Target Focus Zones)
- Avcının karın, göğüs, kol, omuz, bacak gibi yağlanma veya hacim önceliği olan bölgelerini seçebilmesi.
- Amaca özel bitirici süpersetlerin otomatik eklenmesi.

### 9. 🛡️ Genişletilmiş Eklem Sakatlık Koruması (Joint Protection)
- Omuz, diz, bel, bilek, dirsek veya boyun hassasiyetlerinde otomatik eklem dostu alternatif hareket ikamesi.

### 10. 📋 Günlük Görevler & Streak Takibi
- 7 günlük haftalık program: Her gün için özelleştirilmiş Fiziksel ve Zihinsel görevler.
- Günlük görevlerin tamamı bittiğinde Flawless Streak artar.
- İhmal edilen görevler HP/MP cezalarına ve streak kırılmasına yol açar.

### 11. 🩸 Kırmızı Geçit (Red Gate) — Cehennem Modu
- Seçilen gün sayısı boyunca avcıyı kilit altına alan yüksek zorluklu meydan okuma.
- **3× Ceza Katsayısı:** Kalori aşımı veya görev ihmali ölümcül hasar verir (-60 HP).
- **3× Ödül Katsayısı:** Katlanan EXP ve Altın çarpanları.
- **Ölüm Riski:** HP sıfırlanırsa -1 Level cezası.
- Başarıyla tamamlandığında devasa AP, Altın ve EXP ödülü + tam iyileşme.

### 12. 🌙 Gölge Modu (Stealth Mode)
- Gerçek hayat yoğunluğunda cezaları geçici olarak devre dışı bırakır.
- Streak dondurulur, boss cezaları uygulanmaz.

### 13. 👹 Haftalık Zindan Bossu
- Her Pazar günü avcının karşısına çıkan haftalık Boss (Level × 100 HP).
- Fiziksel (*Steel-Fanged Wolf*) veya Zihinsel (*Ancient Lich*) patron türü.
- Görevler ve diyet başarısıyla boss'a hasar verilir; yenilirse devasa ganimet (+1000 Gold, +2 AP, +500 EXP).

### 14. 🛒 Sistem Mağazası (System Shop)

| Eşya | Fiyat | Etki |
|------|-------|------|
| Healing Potion | 150 G | HP'yi anında tamamen doldurur |
| Water of Lethe | 1000 G | Dağıtılan tüm Stat puanlarını sıfırlar ve AP iade eder |
| Minor Cheat | 200 G | Küçük atıştırmalık cezasız tüketilir |
| Cheat Meal | 500 G | Bir serbest öğün hakkı |
| Endless Feast | 2000 G | 1 tam gün serbest beslenme hakkı |
| Gaming Pass (2 Hr) | 300 G | 2 saatlik cezasız oyun/dizi hakkı |
| Sloth Day | 1500 G | Günlük görevler cezasız atlanır |
| Material: New Gear | 5000 G | Gerçek hayat ödülü (kıyafet, ekipman vb.) |

### 15. 🎵 Ses & Atmosfer Motoru
- Level Up, Quest Complete, Bell, Transition, Dungeon Start ve Startup ses efektleri.
- `mixWithOthers` protokolü sayesinde arka planda çalan müziği kesmeden mikslenir.

### 16. 😴 Uyku Takibi & Toparlanma Sistemi (Sleep Tracker)
- **Uyku Saat Giriş Kartı:** 0-16 saat arası hassas uyku girişi.
- **Duruma Göre Dinamik Geri Bildirim:**
  - 0-5 saat: ⚠️ YETERSİZ — Yorgunluk artışı & MP kaybı.
  - 6 saat: ⚖️ MİNİMAL — Bazal toparlanma.
  - 7-9 saat: ✨ OPTİMAL — +2 MP & Tam Yorgunluk Arınması.
  - 10+ saat: 🛡️ DERİN HİBERNASYON — Maksimum hücre onarımı.
- **Gece Yarısı Entegrasyonu:** Uyku verisi HP/MP regenerasyonuna, yorgunluk azalmasına ve fatigue değerine doğrudan etki eder.

### 17. 📸 İlerleme Galerisi & Dönüşüm Kasası (Progress Gallery)
- Kamera veya galeriden vücut fotoğrafı çekme, kilo ve not ile birlikte kaydetme.
- Tarih sıralı fotoğraf galerisi ve kilo değişim takibi.
- Tab navigasyonuyla galeri ve istatistik görünümleri.

### 18. 🔔 Yerel Bildirim & Hatırlatma Sistemi (Notification Service)
- **Su Hatırlatıcısı:** Ayarlanabilir saatlik aralıklarla su içme hatırlatıcısı.
- **İdman Hatırlatıcısı:** Belirlenen saat ve dakikada antrenman hatırlatıcısı.
- **Gece Hesaplaşma Raporu:** Günlük performans değerlendirmesi hatırlatıcısı.
- **Solo Leveling Temalı Mesajlar:** RPG atmosferli `[SİSTEM BİLDİRİMİ]` formatında bildirimler.

### 19. 📊 Dinamik Zorluk Adaptasyonu (Dynamic Difficulty — DDA)
- **Otomatik Analiz:** Streak, yorgunluk (fatigue), HP ve idman geçmişine göre zorluk önerisi.
- **3 Aksiyon Modu:** Upgrade (zorluk artırma), Deload (aktif dinlenme & fatigue sıfırlama), Maintain (optimum denge).

### 20. 🧙 4 Adımlı Avcı Uyanış Sihirbazı (SetupScreen Wizard)
- **Phase 01 (Identity):** Avcı adı, cinsiyet, doğum tarihi, avatar ve Gemini API anahtarı.
- **Phase 02 (Body Calibration):** Boy, kilo, hedef, zorluk ve Full Body Scan (Göğüs, Bel, Kol, Bacak cm).
- **Phase 03 (Combat & Gear):** Çoklu dövüş branşları, öncelikli yağ yakım odakları ve eklem koruması.
- **Phase 04 (Awakening Test):** Kondisyon + 1RM Halter testleri ve canlı hesaplanan avcı rütbesi.
- **3 Test Modu:** Barbell 1RM, Calisthenics Reps ve Combat Stamina testleri.

---

## ⚡ Tamamlanan Geliştirme Fazları

### ✅ Faz 1: Antrenman Zekası & Zindan Sistemi

1. **Gemini AI Destekli Kişiselleştirilmiş Antrenman** — 7 günlük dinamik plan üretimi & yerel kural motoru fail-safe fallback.
2. **Tek Dokunuşla YouTube Video Rehberi** — Akıllı başlık sanitizasyonu, tüm ekranlarda canlı form videosu.
3. **Avcı Taktik Kartı & Akıllı Alternatif Değiştirici (Smart Swap)** — Hedef kas, dövüş katkısı, 3 altın kural ve anlık swap.
4. **Set, Ağırlık ve Tekrar Takip Kaydedicisi** — Aktif zindan idmanında set bazlı kg/tekrar loglama.
5. **Set Arası Dinlenme Sayacı & Yapay Zeka Sesli Koç** — 30-120sn geri sayım, 3-2-1 sesli direktifler.
6. **Dinamik Ek Hareket Enjekte Etme & Kaldırma** — Kategorilere göre filtrelenen hareket seçici.
7. **6-8 Hareket Uzatılmış İdman Standardı & Zorunlu Kardiyo Katmanı.**
8. **Çift Seçenekli Şablon Yükleme & Kardiyo Şablonları** — Saitama, Full Body, Combat Striker, Gölge Boksu vb.
9. **AI Kişiselleştirilmiş Bitirici (AI AVCI ÖZEL BOOSTER).**
10. **Dövüş Sporlarına Göre 5-6 Raundluk Gölge Boksu Stilleri & Kombinasyonları.**
11. **İdmanı Uzatma, Dinamik Hacim Kademeleri & Kardiyo Kategori Seçicisi.**
12. **Dungeon & Boks Sayacı Mutlak Duvar Saati Senkronizasyonu & Canlı Raid HUD.**
13. **Gelişmiş Egzersiz Seçici Modal** — 875+ kütüphaneden canlı arama, kategori filtreleri.

### ✅ Faz 2: Bilimsel Metabolik Motor, Diyetisyen Analizi & Hedef Kilo Entegrasyonu

1. **US Navy Vücut Kompozisyonu & LBM Hesabı** — Logaritmik yağ oranı, Katch-McArdle & Mifflin-St Jeor BMR, Dinamik TDEE.
2. **MET Bazlı İdman Yıpranması & Katabolizma Koruması** — Boks: 10.5 MET, Güreş: 11.5 MET, protein/karb telafisi.
3. **Diyetisyen Listesi Tarayıcısı & Reçete Kilidi** — Gemini Vision OCR + çoklu gün takvim eşleme.
4. **Hedef Kilo Projeksiyonu & Metabolik Tempo Hesabı.**
5. **Avcının Beslenme Vizyonu & AI Harmanlama & Sistem Stratejik Direktifi.**
6. **"BU HEDEFLERİ SİSTEME ENTEGRE ET" Butonu.**

### ✅ Faz 3: Akıllı Antrenman Zekası & Progresif Aşırı Yükleme Motoru

1. **Çift Progresyon Kural Motoru** — RIR 4+ (ağırlık artışı), RIR 2-3 (tekrar artışı), RIR 0-1 (toparlanma).
2. **Eklem Koruma Protokolü & Güvenli İkame.**
3. **Holografik Sistem Penceresi (RirFeedbackModal).**
4. **Kalıcı Aşırı Yükleme Hafızası (`overloadGecmisi`).**

### ✅ Faz 4: Çok Yönlü Avcı Gelişim Sistemi & Sistem İyileştirmeleri

1. **Zihinsel Görev Motoru (`MentalTask`)** — 6 kategori, kitap & sayfa takibi, JSON serileştirme.
2. **AI Çalışma Planlayıcı (`StudyPlannerModal`)** — 6 uzmanlık alanı + çevrimdışı yedek.
3. **Bilişsel Zindan — Deep Work Timer** — Pomodoro, EXP/INT/PER ödülleri, seans takibi.
4. **AI Kitap Analizi** — Okuma stratejisi, bölüm özetleri & çıkarımlar.
5. **Dashboard Filtreleme & Portal Butonları** — Çipler, dinlenme günü kartı.
6. **Uyku Takibi Sistemi (`SleepTrackerCard`)** — HP/MP/Fatigue etkisi.
7. **İlerleme Galerisi (`ProgressGalleryModal`)** — Fotoğraf + kilo + not.
8. **Yerel Bildirim Servisi (`NotificationService`)** — Su, idman, gece raporu.
9. **Dinamik Zorluk Adaptasyonu (`DynamicDifficultyEngine`)** — Upgrade/Deload/Maintain.
10. **Başarım Diyaloğu** — Kademeli ses efektli animasyonlu kutlama.
11. **Uyanış Testi Genişletmesi** — 3 test modu, profil ekranından yeniden test.
12. **UI Standardizasyonu** — `HologramCard` teması, `AppColors` merkezi renk sistemi.
13. **Oturum Yöneticisi (`SystemSessionManager`)** — Deep Work & Rest Timer wall-clock senkronizasyonu.
14. **Global Timer HUD** — Alt navigasyon çubuğunda canlı sayaç göstergesi.

---

## 📊 Sistem Analiz ve Durum Raporu (System Diagnostic Status)

| Modül / Özellik | Durum | Kapsam & Gerçekleştirilen Fonksiyonlar |
|-----------------|-------|---------------------------------------|
| **Gemini AI Core (REST)** | ✅ | Gemini 3.6 Flash & Next-Gen Core, çoklu model, API Key yönetimi |
| **Avcı Uyanış Sihirbazı** | ✅ | 4 Adımlı sinematik Wizard, Full Body Scan, Dövüş testleri, 1RM |
| **Antrenman Motoru (AI)** | ✅ | Haftalık 7 günlük dinamik program üretimi, yerel kural fail-safe fallback |
| **YouTube Form Rehberi** | ✅ | Akıllı başlık sanitizasyonu, tüm ekranlarda tek tıkla video |
| **Avcı Taktik Kartı & Swap** | ✅ | Hedef kas, dövüş katkısı, 3 altın kural ve anlık 3 alternatif swap |
| **Set Logger & Rest Timer** | ✅ | Set/kg/tekrar loglama, 30-120sn sesli geri sayım |
| **Progresif Aşırı Yükleme (RIR)** | ✅ | Double Progression, RIR 0-1/2-3/4+, Eklem Koruma, RirFeedbackModal |
| **Dinamik Zindan Genişletme** | ✅ | Zindana anında ek hareket ekleme/kaldırma, 875+ kütüphane |
| **Uzatılmış İdman & Kardiyo** | ✅ | 6-8 hareket standardı, zorunlu kardiyo, Hacim & Raund seçicileri |
| **Gölge Boksu & Dövüş Sim** | ✅ | Branşa özel 5 raundluk gölge boksu stilleri |
| **Dungeon & Boks Senkronizasyonu** | ✅ | Duvar saati senkronizasyonu, canlı Raid HUD, erken kapanma koruması |
| **Gelişmiş Egzersiz Seçici** | ✅ | Canlı arama, kategori çipleri, set/tekrar ve kardiyo dakika filtreleri |
| **Bilimsel Metabolik Motor** | ✅ | US Navy yağ %, LBM, Katch-McArdle & Mifflin BMR, Dinamik TDEE |
| **MET Yıpranma & Katabolizma** | ✅ | MET formülü ile kalori ve kas koruyucu protein/karb telafisi |
| **Diyetisyen Menü Tarayıcısı** | ✅ | Fotoğraf/metin Gemini OCR, çoklu gün takvim eşleme, taban hedef kilitleme |
| **Hedef Kilo Projeksiyonu** | ✅ | Delta kilo, haftalık tempo, tahmini hafta ve kalori farkı hesabı |
| **Kullanıcı Vizyonu & Not Girişi** | ✅ | Kör otomasyonu önleyen serbest metin diyet stratejisi alanı |
| **AI Harmanlama & Direktif** | ✅ | Kullanıcı fikri + biyometrik senteziyle RPG Sistem Direktifi |
| **Sisteme Entegre Et Butonu** | ✅ | Hesaplanan hedefleri tek tıkla aktif takip sistemine bağlama |
| **Suplement Kuşanma (Loadout)** | ✅ | 4 ekipman yuvası, metabolik sinerji, dinamik su artışı (+500ml) & tolerans |
| **Yapay Zeka Sesli Koç (Voice)** | ✅ | Dinlenme başlama, 3-2-1 geri sayım, overload direktifleri |
| **Canlı Kamera Vizörü (Lens)** | ✅ | Cihaz kamerası ile doğrudan tabak fotoğrafı çekme ve OCR tarama |
| **Biyometrik Radar Grafiği** | ✅ | 5-stat pentagon siber radar poligonu ve sınıf tayini |
| **Su Takibi (Hydration)** | ✅ | Günlük su sayacı, hızlı giriş butonları ve gece yarısı ödül/ceza |
| **Avcı Çantası & Envanter** | ✅ | Eşya satın alma, çantadan canlı eşya kullanımı |
| **Veri Kasası (Data Vault)** | ✅ | JSON arşiv dışa/içe aktarma ile tam veri yedekleme |
| **Çift Dil Desteği (TR/EN)** | ✅ | Tüm sistem unvanları, diyaloglar, modallar, arama ipuçları ve dinamik dil anahtarı |
| **Zihinsel Görev Motoru** | ✅ | MentalTask model, 6 kategori, kitap & sayfa takibi, INT/PER ödülleri |
| **AI Çalışma Planlayıcı** | ✅ | StudyPlannerModal, 6 uzmanlık alanı, Gemini AI plan üretimi + çevrimdışı yedek |
| **Bilişsel Zindan (Deep Work)** | ✅ | Pomodoro sayacı, odak/dinlenme fazları, EXP/INT/PER ödülleri, seans takibi |
| **AI Kitap Analizi** | ✅ | Okuma stratejisi, bölüm özetleri & çıkarımlar |
| **Dashboard Filtreleme** | ✅ | Tümü/Fiziksel/Zihinsel çipleri, portal butonları, dinlenme günü kartı |
| **Uyku Takibi (Sleep)** | ✅ | 0-16 saat girişi, HP/MP/Fatigue etkisi, duruma göre renk kodlu geri bildirim |
| **İlerleme Galerisi** | ✅ | Fotoğraf + kilo kaydı, galeri & istatistik tab'ları, tarih sıralı görünüm |
| **Yerel Bildirimler** | ✅ | Su, idman, gece raporu hatırlatıcıları, Android kanal desteği |
| **Dinamik Zorluk (DDA)** | ✅ | Upgrade/Deload/Maintain analizi, streak & fatigue tabanlı akıllı öneriler |
| **Başarım Diyaloğu** | ✅ | Kademeli başarım bildirimi, animasyonlu kutlama ve ses efektleri |
| **Uyanış Testi** | ✅ | 3 test modu (1RM/Calisthenics/Combat), profil ekranından yeniden test |
| **Oturum Yöneticisi** | ✅ | Deep Work & Rest Timer wall-clock senkronizasyonu, wakelock |
| **Global Timer HUD** | ✅ | Alt navigasyonda canlı sayaç göstergesi (odak/dinlenme) |

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

Proje güvenilirliği için **28 test paketi** hazırlanmış ve çalıştırılmıştır:

| # | Test Dosyası | Kapsam |
|---|-------------|--------|
| 1 | `supplement_and_radar_test.dart` | Suplement kuşanma/çıkarma, dinamik su artışı, tolerans, radar çizimi |
| 2 | `progressive_overload_engine_test.dart` | Çift progresyon, RIR seviyeleri, eklem koruma, JSON, widget testleri |
| 3 | `advanced_metabolic_engine_test.dart` | US Navy yağ %, LBM, BMR, TDEE, MET yıpranması, hedef kilo projeksiyonu |
| 4 | `dietitian_scanner_widget_test.dart` | Diyetisyen tarayıcı modalı, form alanları, Makro Lab biyometrik kart |
| 5 | `assessment_flow_widget_test.dart` | 4 Adımlı Wizard, çoklu dövüş branşı, 1RM testleri, odak bölgeleri |
| 6 | `system_features_test.dart` | Su takibi, çanta, makrolar, Data Vault, dinamik antrenman uyarlaması |
| 7 | `exercise_coach_test.dart` | Taktik Kartı, Smart Swap, SetKaydi serileştirmesi, RestTimer |
| 8 | `workout_experience_flow_test.dart` | Dashboard taktik kartı, Aktif İdman Set Logger, Ek Hareket Enjekte |
| 9 | `dungeon_boxing_sync_test.dart` | Sayaç senkronizasyonu, canlı raid HUD, erken kapanma koruması |
| 10 | `advanced_exercise_selector_modal_test.dart` | 875+ kütüphane, canlı arama, kategori filtreleri |
| 11 | `youtube_helper_test.dart` | Başlık sanitizasyonu, etiket ve set/tekrar ayıklama |
| 12 | `gemini_integration_test.dart` | API anahtarı, AI besin çözücü, AI antrenman fail-safe fallback |
| 13 | `language_switch_test.dart` | TR/EN çift dil geçişi, unvanlar, hedefler, dil fallback |
| 14 | `midnight_reset_test.dart` | Gece yarısı tek gün sıfırlama ve model kalıcılık |
| 15 | `main_routing_test.dart` | Kayıtlı ve yeni kullanıcı yönlendirmesi |
| 16 | `workout_library_navigation_test.dart` | Kütüphaneye geçiş ve render |
| 17 | `macro_lab_navigation_test.dart` | Makro Lab geçişi ve FormatException koruması |
| 18 | `mental_growth_system_test.dart` | Zihinsel görev ekleme/silme/tamamlama, Deep Work ödülleri, MentalTask JSON |
| 19 | `mental_growth_ui_test.dart` | Dashboard filtreleme, portal butonları, dinlenme günü kartı |
| 20 | `achievement_dialog_test.dart` | Başarım diyaloğu açılma, animasyon, mesaj ayrıştırma |
| 21 | `calendar_workout_history_test.dart` | Takvim geçmişe yönelik antrenman verisi |
| 22 | `dynamic_difficulty_test.dart` | DDA analizi, upgrade/deload/maintain |
| 23 | `notification_feature_test.dart` | Bildirim servisi başlatma, test modu, hatırlatıcılar |
| 24 | `progress_gallery_test.dart` | İlerleme galerisi fotoğraf ekleme/silme, tab navigasyonu |
| 25 | `sleep_tracker_test.dart` | Uyku kartı, saat güncelleme, HP/MP etki |
| 26 | `system_improvements_test.dart` | Sistem genel iyileştirme ve regresyon |
| 27 | `rank_ascension_rewards_test.dart` | Rütbe yükselişi AP/EXP/Gold kademe ödülleri, otomatik stat dağıtım |
| 28 | `system_timer_session_test.dart` | Deep Work & Rest Timer oturum yönetimi, wall-clock senkronizasyonu |

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
| **Dosya Seçici** | `file_picker` | `^11.0.3` |
| **Arşiv İşleme** | `archive` | `^4.3.0` |
| **Dış Bağlantılar** | `url_launcher` | `^6.2.5` |
| **Yerel Bildirimler** | `flutter_local_notifications` | `^22.3.1` |
| **Zaman Dilimleri** | `timezone` | `^0.11.1` |
| **Arka Plan Servis** | `flutter_background_service` | `^5.1.0` |
| **Ekran Uyanıklığı** | `wakelock_plus` | `^1.2.8` |
| **Uygulama İkonu** | `flutter_launcher_icons` | `^0.13.1` |
| **Kod Kalitesi** | `flutter_lints` | `^6.0.0` |

---

## 🚀 Kurulum ve Çalıştırma

```bash
# 1. Depoyu klonlayın ve klasöre girin
git clone <repo-url>
cd solo_app

# 2. Paket bağımlılıklarını indirin
flutter pub get

# 3. Testleri doğrulayın (28 test paketi)
flutter test

# 4. Uygulamayı cihaz üzerinde başlatın
flutter run

# 5. APK oluşturmak için
flutter build apk --release
```

---

## 📜 Lisans

Bu proje Solo Leveling temalı kişisel gelişim ve RPG motivasyon aracı olarak geliştirilmektedir.
