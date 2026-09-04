# 🎮 Solo Leveling App

**Solo Leveling** animesinden ilham alan, kişisel gelişim ve fitness takibi yapan bir **gamification (oyunlaştırma) uygulaması**. Kullanıcı bir "Avcı" (Hunter) olarak görev yapar; egzersiz, diyet ve zihinsel görevlerini tamamlayarak EXP, Gold, AP kazanır ve level atlar.

## 📁 Proje Mimarisi

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── controllers/
│   └── system_memory.dart       # Tüm oyun state'i, persistence, RPG mekanikleri
├── core/
│   ├── audio_system.dart        # Ses efektleri yönetimi
│   ├── diyet_motoru.dart        # Makro besin hesaplama motoru
│   └── sistem_gecisi.dart       # Hologram sayfa geçiş animasyonu
├── models/
│   ├── task_model.dart          # Görev (Gorev) veri modeli
│   ├── food_model.dart          # Tüketilen yemek veri modeli
│   └── workout_model.dart       # Egzersiz veri modeli
├── screens/
│   ├── ana_ekran.dart           # Ana navigasyon (Bottom Navigation)
│   ├── dashboard_screen.dart    # Dashboard — Level, Stat, Başarımlar, Boss
│   ├── status_screen.dart       # HP/MP/EXP barları, stat dağıtımı
│   ├── calendar_screen.dart     # Haftalık görev takvimi (Quest Log)
│   ├── diet_screen.dart         # Günlük kalori & yemek takibi (Inventory)
│   ├── profile_screen.dart      # Profil, vücut bilgileri, hedef ayarları
│   ├── setup_screen.dart        # İlk kurulum (cinsiyet, boy, kilo, hedef)
│   ├── welcome_screen.dart      # Karşılama ekranı
│   ├── instruction_screen.dart  # Sistem kuralları / kılavuz
│   ├── active_workout_screen.dart # Aktif antrenman (Dungeon Raid)
│   ├── workout_planner_screen.dart # Haftalık antrenman planlayıcı
│   ├── workout_library_screen.dart # Egzersiz kütüphanesi
│   ├── boxing_timer_screen.dart # Boks antrenman zamanlayıcısı
│   ├── macro_dashboard_screen.dart # Makro besin analiz paneli
│   └── shop_screen.dart         # Sistem Mağazası
└── widgets/
    ├── hologram_card.dart       # Neon çerçeveli hologram kart widget'ı
    └── stat_bar.dart            # HP/MP/EXP ilerleme çubuğu widget'ı
```

### Katman Yapısı

| Katman | Dosyalar | Rol |
|--------|----------|-----|
| **Controllers** | `system_memory.dart` | Tüm oyun state'i, persistence, RPG mekanikleri |
| **Core** | `audio_system.dart`, `diyet_motoru.dart`, `sistem_gecisi.dart` | Ses, beslenme hesaplama, sayfa geçişleri |
| **Models** | `task_model.dart`, `food_model.dart`, `workout_model.dart` | Veri modelleri (Görev, Yemek, Egzersiz) |
| **Screens** | 15 ekran dosyası | UI katmanı |
| **Widgets** | `hologram_card.dart`, `stat_bar.dart` | Yeniden kullanılabilir UI bileşenleri |

---

## 🎯 Temel Özellikler

### 1. RPG Stat Sistemi
- **HP / MP** — Sağlık ve Mana puanları (görev başarısı/cezaları ile değişir)
- **Level / EXP** — Deneyim puanı ve seviye atlama (EXP eşiği her level'da × 1.5 artar)
- **AP (Ability Points)** — Level atlayınca +3 AP, stat'lara dağıtılır
- **5 Stat**: STR (Kuvvet), AGI (Çeviklik), VIT (Dayanıklılık), INT (Zeka), PER (Algı)
- **Altın** — Oyun içi para birimi, mağazada harcanır
- **Fatigue** — Yorgunluk sistemi

### 2. Günlük Görev Sistemi (Daily Quests)
- 7 günlük haftalık plan → Her gün **Fiziksel** ve **Zihinsel** görevler
- Görevler tamamlandığında: **+HP, +EXP, +Altın, +Stat** kazanımı
- Kaçırılan görevler: **-HP veya -MP cezası**
- **Streak sistemi**: Kesintisiz günler takip edilir, kırılırsa sıfırlanır

### 3. 🩸 Kırmızı Geçit (Red Gate) — Cehennem Modu
- Kullanıcı belirli bir süre (gün sayısı) cehennem moduna girer
- **3× ceza katsayısı** (ör. kalori aşımı: -60 HP vs normal -20)
- **3× ödül katsayısı** (EXP ve Altın çarpanları artık)
- 3 farklı antrenman planı: "Full Body + Cardio", "Push/Pull/Legs", "Saitama Hell"
- HP = 0 olursa **ölüm**: -1 Level, EXP sıfırlanır, Red Gate sona erer
- Başarıyla tamamlanırsa: **Devasa ödüller** (AP × gün, Altın × 1500/gün, EXP × 300/gün)

### 4. 🌙 Gölge Modu (Stealth Mode)
- Tüm cezalar devre dışı kalır
- Streak donmuş kalır (kırılmaz)
- Boss savaşı görmezden gelinir

### 5. 👹 Haftalık Boss Savaşı
- Her **Pazar** bir Weekly Boss belirir (level × 100 HP)
- Boss türü: Fiziksel (Steel-Fanged Wolf) veya Zihinsel (Ancient Lich)
- Görev tamamlama ve diyet başarısına göre hasar verilir
- Yenilirse: **+1000 G, +2 AP, +500 EXP**
- Yenilemezse: **HP'nin yarısı ceza olarak düşer**

### 6. 🍗 Beslenme Takibi
- Mifflin-St Jeor formülüyle **BMR** hesaplama
- Hedef bazlı kalori ayarı: Yağ yakma (-500 / -1000 / -1500) veya Kas inşa (+300 / +500 / +1000)
- Günlük kalori takibi ve yemek geçmişi
- Makro hesaplama motoru (protein / yağ / karbonhidrat)

### 7. ⚖️ Tartı ve Kilo Takibi
- Kilo değişimi hedefe göre ödül veya ceza verir
- Kilo geçmişi kaydedilir (tarih + kilo + günlük kalori)

### 8. 🏋️ Antrenman Sistemi
- **Zindan Akını (Dungeon Raid)**: Süre bazlı antrenman kaydı
- **Workout Library**: Egzersiz kütüphanesi (YouTube bağlantılı)
- **Boxing Timer**: Boks antrenman zamanlayıcısı
- Aktif antrenman süresi takibi

### 9. 🛒 Mağaza (System Shop)

| Ürün | Fiyat | Etki |
|------|-------|------|
| Healing Potion | 150 G | HP'yi tamamen doldurur |
| Water of Lethe | 1000 G | Stat puanlarını sıfırlar, AP iade eder |
| Minor Cheat | 200 G | Küçük atıştırmalık (çikolata vb.) cezasız |
| Cheat Meal | 500 G | Bir öğün serbest (burger menü vb.) |
| Endless Feast | 2000 G | 1 tam gün serbest beslenme |
| Gaming Pass (2 Hr) | 300 G | 2 saat oyun/dizi cezasız |
| Sloth Day | 1500 G | Günlük görevler cezasız atlanır |
| Material: New Gear | 5000 G | Gerçek hayat ödülü (kıyafet, oyun vb.) |

### 10. 🎵 Ses Sistemi
- Başarı, Level Up, Bell, Geçiş, Startup sesleri
- Arka plan müziğini kesmeme özelliği (`mixWithOthers`)

---

## 🎮 Oyun Mekanikleri Akışı

```
Kullanıcı Girişi          Sistem Motoru              Sonuçlar
─────────────────    ──────────────────────    ──────────────────
Görev Tamamla    ──→  Gün Sonu Hesaplaşması ──→  Level Up
Yemek Kaydet     ──→  EXP / Altın Dağıtımı  ──→  Ödül / Ceza
Tartıya Çık      ──→  Stat Değişimleri       ──→  Streak Update
Antrenman Yap    ──→  Boss Hasar Hesabı      ──→  Boss Kill / Fail
```

---

## 🏆 Başarım Sistemi (Achievements)

| Başarım | Kademeler |
|---------|-----------|
| Iron Will (Streak) | 7 / 14 / 30 / 60 / 100 / 365 Gün |
| Unbreakable (Görev) | 50 / 100 / 250 / 500 / 1000 / 5000 Görev |
| Awakening (Level) | 10 / 20 / 30 / 50 / 80 / 100 Level |
| Warrior (STR) | 30 / 50 / 100 / 150 / 200 / 300 STR |
| Shadow Step (AGI) | 30 / 50 / 100 / 150 / 200 / 300 AGI |
| Sage (INT) | 30 / 50 / 100 / 150 / 200 / 300 INT |
| Merchant (Altın) | 2K / 5K / 10K / 50K / 100K / 500K Gold |
| Fat Burner / Titan (Kilo) | 5 / 10 / 15 / 20 / 30 / 50 KG |

Her başarım Roma rakamlarıyla (I, II, III...) kademe atlar ve ilerleme çubuğuyla gösterilir.

---

## 🛠️ Teknoloji Stack

- **Framework**: Flutter (Dart SDK ^3.11.3)
- **State**: ValueNotifier + setState
- **Persistence**: SharedPreferences
- **Fonts**: Google Fonts (Orbitron, Rajdhani)
- **Audio**: audioplayers
- **Calendar**: table_calendar
- **Image**: image_picker
- **Links**: url_launcher

---

## 🚀 Kurulum

```bash
# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

---

## 📜 Lisans

Bu proje kişisel kullanım amaçlı geliştirilmektedir.
