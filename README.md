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

### ⏳ Faz 1 Kapsamında Sırada Eklenecekler:
1. **Daha Kapsamlı & Dolu Antrenman Hacmi (Antrenmanları Uzatma & Çeşitlendirme):**
   - *Sorun / Tespit:* Mevcut antrenman seansları çok kısa kalmakta, gün başına düşen hareket sayısı ve set çeşitliliği az gelmektedir.
   - *Planlanan Çözüm:* Gemini AI prompt motoru ve yerel kural şablonları güncellenerek; gün başına **1-2 Ana Bileşik Hareket (Compound)** + **2-3 İzolasyon & Destek Hareketi** + **1-2 Dövüş/Kondisyon/Core Bitirici Protokolü (Finisher)** şeklinde **seans başına 5-7 doyurucu hareket** içeren zengin program hacmi standardı getirilecektir.
2. **Antrenman Ekleme Ekranının Yeniden Düzenlenmesi (Gelişmiş Egzersiz Ekleme Modalı):**
   - *Sorun / Tespit:* Kullanıcı haftalık plana veya aktif antrenmana kendi istediği hareketleri eklemek istediğinde mevcut tek satırlık ekleme alanı yetersiz ve kullanışsız kalmaktadır.
   - *Planlanan Çözüm:* 875+ hareketlik kütüphane ile entegre modern bir **"Egzersiz Ekleme Modalı"** tasarlanacaktır. Kas grubuna göre filtreleme (Göğüs, Sırt, Bacak, Omuz, Kol, Karın, Boks/Dövüş), hızlı arama çubuğu, set sayısı, hedef tekrar ve hedef ağırlık girişleri, YouTube önizlemesi ve tek dokunuşla programa ekleme özelliği sunulacaktır.

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

Proje güvenilirliği için **11 test paketi ve toplam 54 test senaryosu** hazırlanmıştır (%100 Başarılı):

| Test Dosyası | Kapsam |
|--------------|--------|
| [`test/assessment_flow_widget_test.dart`](test/assessment_flow_widget_test.dart) | 4 Adımlı Wizard, çoklu dövüş branşı, 1RM dövüş ağırlık testleri, odak bölgeleri, unvan senkronizasyonu |
| [`test/system_features_test.dart`](test/system_features_test.dart) | Su takibi, çanta, makrolar, Data Vault, odak bölgelerine göre dinamik antrenman uyarlaması |
| [`test/exercise_coach_test.dart`](test/exercise_coach_test.dart) | Avcı Taktik Kartı, Akıllı Alternatif Değiştirici (Smart Swap), SetKaydi serileştirmesi, RestTimer ve Detail Modal |
| [`test/workout_experience_flow_test.dart`](test/workout_experience_flow_test.dart) | Dashboard taktik kartı ve swap akışı, Aktif İdman Set Logger & Rest Timer diyaloğu, Workout Planner butonları |
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
