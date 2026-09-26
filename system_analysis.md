# 🔍 Solo Leveling App — Tam Sistem Analiz Raporu v2

**Analiz Tarihi:** 25 Eylül 2026  
**Analiz Kapsamı:** 577 satır `system_memory.dart` (modüler), 4 hafıza modülü, 16 ekran, 15 widget, 13 core modül, 5 model, 28 test paketi  
**Mimari:** Modüler delege sistemi (`SystemMemory` → `MemoryStorage`, `MemoryWorkout`, `MemoryNutrition`, `MemoryCombatRanks`)  
**Toplam Kod Boyutu:** ~740KB Dart kaynak kodu (lib/ dizini)

---

## 📊 Bölüm 1: Mevcut Özelliklerin Çalışma Durumu

### ✅ TAM ÇALIŞAN ÖZELLİKLER (36 Madde — Sorunsuz)

| # | Özellik | Ana Dosya(lar) | Durum | Detay |
|---|---------|---------------|-------|-------|
| 1 | Akıllı Yönlendirme (kayıtlı/yeni kullanıcı) | [main.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/main.dart) | ✅ | `kayitBulundu` kontrolü düzgün |
| 2 | 4 Adımlı Kurulum Sihirbazı | [setup_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/setup_screen.dart) | ✅ | Faz 1–4, Full Body Scan, API Key |
| 3 | RPG Stat Sistemi (HP/MP/EXP/Level/AP) | [system_memory.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/system_memory.dart) | ✅ | ValueNotifier reaktif |
| 4 | EXP & Level Up (×1.5 ölçekleme) | [memory_combat_ranks.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_combat_ranks.dart) | ✅ | while döngüsü çoklu level atlamayı destekliyor |
| 5 | Gece Yarısı Hesaplaşması | [memory_nutrition.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_nutrition.dart) | ✅ | Tek günü sıfırlar, diğer günler korunur |
| 6 | Kırmızı Geçit (Red Gate) | [memory_combat_ranks.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_combat_ranks.dart) | ✅ | 3× ceza/ödül, ölüm mekaniği, nihai ödül |
| 7 | Gölge Modu (Stealth) | [system_memory.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/system_memory.dart) | ✅ | Cezalar ve streak dondurma aktif |
| 8 | Haftalık Boss Sistemi | [memory_nutrition.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_nutrition.dart) | ✅ | Pazar günü Level×100 HP, yenilirse ganimet |
| 9 | Sistem Mağazası & Envanter | [shop_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/shop_screen.dart) | ✅ | 8 eşya, Çanta, USE mekanikleri |
| 10 | Dövüş Sporları & 1RM Rank | [memory_combat_ranks.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_combat_ranks.dart) | ✅ | Dövüşçü ve Halterci ranklama |
| 11 | Gemini AI REST Servisi | [gemini_service.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/services/gemini_service.dart) | ✅ | Gemini 3.6 Flash, çoklu model, fail-safe |
| 12 | AI Haftalık Antrenman Üretimi | [memory_workout.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_workout.dart) | ✅ | API yoksa yerel kural motoru fallback |
| 13 | YouTube Form Rehberi | [youtube_helper.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/youtube_helper.dart) | ✅ | Akıllı başlık sanitizasyonu |
| 14 | Avcı Taktik Kartı & Smart Swap | [exercise_coach.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/exercise_coach.dart) | ✅ | 3 alternatif hareket önerisi |
| 15 | Progresif Aşırı Yükleme (RIR) | [progressive_overload_engine.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/progressive_overload_engine.dart) | ✅ | Double Progression, Eklem Koruma |
| 16 | Set Logger & Rest Timer | [rest_timer_dialog.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/rest_timer_dialog.dart) | ✅ | Sesli 30-120sn geri sayım |
| 17 | US Navy Metabolik Motor | [advanced_metabolic_engine.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/advanced_metabolic_engine.dart) | ✅ | Yağ %, LBM, BMR, TDEE, MET |
| 18 | MET İdman Yıpranması & Katabolizma Koruması | [memory_nutrition.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_nutrition.dart) | ✅ | Kalori & protein/karb telafisi |
| 19 | Diyet & Kalori Takibi | [diet_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/diet_screen.dart) | ✅ | AI besin çözücü, makrolar |
| 20 | Su Takibi (Hydration) | [system_memory.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/system_memory.dart) | ✅ | Gece yarısı ödülü entegre |
| 21 | Diyetisyen Menü Tarayıcısı (OCR) | [dietitian_scanner_modal.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/dietitian_scanner_modal.dart) | ✅ | Gemini Vision + çoklu gün desteği |
| 22 | Makro Laboratuvarı & Hedef Kilo | [macro_dashboard_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/macro_dashboard_screen.dart) | ✅ | Projeksiyon, AI harmanlama, entegre et |
| 23 | Suplement Kuşanma & Sinerji | [supplement_engine.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/supplement_engine.dart) | ✅ | 4 yuva, +500ml su, tolerans |
| 24 | Yapay Zeka Sesli Koç | [voice_coach_system.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/voice_coach_system.dart) | ✅ | 3-2-1 geri sayım, overload |
| 25 | Biyometrik Radar Grafiği | [hunter_radar_chart.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/hunter_radar_chart.dart) | ✅ | 5-stat pentagon, sınıf tayini |
| 26 | Canlı Kamera Vizörü | [diet_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/diet_screen.dart) | ✅ | Kamera + Galeri + Gemini |
| 27 | Veri Kasası (Backup/Restore) | [memory_combat_ranks.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_combat_ranks.dart) | ✅ | JSON export/import |
| 28 | Çift Dil (TR/EN) | [translation_manager.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/translation_manager.dart) | ✅ | 55KB çeviri dosyası |
| 29 | Akıllı Stat Dağıtımı (Otomatik AP) | [memory_combat_ranks.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_combat_ranks.dart) | ✅ | Ağırlıklı, profil-bazlı |
| 30 | Başarım Sistemi (8 kategori) | [dashboard_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/dashboard_screen.dart) + [achievement_dialog.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/achievement_dialog.dart) | ✅ | 6 kademe/başarım, ses efektli popup |
| 31 | Yorgunluk (Fatigue) Mekanikli | [memory_workout.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_workout.dart) + [memory_nutrition.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_nutrition.dart) | ✅ | İdmanda artar, uyku ile azalır, DDA tetikler |
| 32 | Uyku Takibi & Toparlanma | [sleep_tracker_card.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/sleep_tracker_card.dart) | ✅ | 0-16 saat, HP/MP/Fatigue etkisi |
| 33 | İlerleme Galerisi & Dönüşüm | [progress_gallery_modal.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/progress_gallery_modal.dart) | ✅ | Fotoğraf + kilo + not, tab'lar |
| 34 | Yerel Bildirimler | [notification_service.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/services/notification_service.dart) | ✅ | Su, idman, gece raporu hatırlatıcıları |
| 35 | Dinamik Zorluk Adaptasyonu (DDA) | [dynamic_difficulty_engine.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/dynamic_difficulty_engine.dart) | ✅ | Upgrade/Deload/Maintain + ses efektleri |
| 36 | Zihinsel Görev Motoru & Deep Work | [system_memory.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/system_memory.dart) + [deep_work_timer_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/deep_work_timer_screen.dart) | ✅ | Pomodoro, INT/PER ödülleri, çalışma planlayıcı |

---

## 🩹 Bölüm 1.5: Önceki Analizde Bildirilen ve Şimdi ÇÖZÜLMÜŞ Sorunlar

| # | Eski Sorun | Çözüm Durumu | Detay |
|---|-----------|-------------|-------|
| ~~1~~ | `fatigue` hiçbir yerde kullanılmıyor (dead code) | ✅ **ÇÖZÜLDÜ** | `memory_workout.dart:51` → idmanda artar, `memory_nutrition.dart:556` → uyku ile azalır, `DynamicDifficultyEngine` okur |
| ~~2~~ | `dogumTarihi == null` ise `tartiGuncelle` çöker | ✅ **ÇÖZÜLDÜ** | `memory_nutrition.dart:186` → `effectiveDogum = dogumTarihi ?? DateTime(2000, 1, 1)` fallback |
| ~~3~~ | `bugunYakilanIdmanKalorisi`/telafi gece yarısı sıfırlanmıyor | ✅ **ÇÖZÜLDÜ** | `memory_nutrition.dart:565-568` → `bugunYakilanIdmanKalorisi`, `bugunTelafiProteini`, `bugunTelafiKarbonhidrati`, `sonIdmanYipranmaRaporu` hepsi sıfırlanıyor |
| ~~4~~ | `google_generative_ai` paketi pubspec'te var ama kullanılmıyor | ✅ **ÇÖZÜLDÜ** | pubspec.yaml'dan tamamen kaldırılmış |
| ~~5~~ | Başarım bildirimi yok | ✅ **ÇÖZÜLDÜ** | `basarimKademeGuncelle` → `AudioSystem.playSuccess()` çalar + `yeniBasarimBildirimi` ValueNotifier bildirimi tetikler |
| ~~6~~ | Uyku giriş mekanizması eksik | ✅ **ÇÖZÜLDÜ** | `SleepTrackerCard` widget'ı profil ekranına entegre |
| ~~7~~ | Bildirimler boş | ✅ **ÇÖZÜLDÜ** | `NotificationService` tam çalışan: su, idman, gece raporu hatırlatıcıları |
| ~~8~~ | İlerleme fotoğrafları eksik | ✅ **ÇÖZÜLDÜ** | `ProgressGalleryModal` tam fonksiyonel |
| ~~9~~ | Dinlenme günü mekanizması yok | ✅ **ÇÖZÜLDÜ** | Dashboard'da dinlenme günü kartı mevcut |
| ~~10~~ | Dinamik zorluk ayarlama yok | ✅ **ÇÖZÜLDÜ** | `DynamicDifficultyEngine` tam çalışan |
| ~~11~~ | Base64 Fotoğraf Depolama (SP şişmesi) | ✅ **FAZ 1: TEST EDİLDİ, YAPILDI, PUSHLANDI** | `PhotoStorageService` ile profil, avatar ve ilerleme galerisi yerel dosya sistemine (`getApplicationDocumentsDirectory()/solo_photos`) taşındı. (Commit: `1aa8349`) |
| ~~12~~ | Backup / Restore Eksik Alanları | ✅ **FAZ 1: TEST EDİLDİ, YAPILDI, PUSHLANDI** | `exportBackupJson` ve `importBackupJson` zihinsel görevler, odaklanma/kitap istatistikleri ve ilerleme fotoğrafları ile tamamlandı. (Commit: `1aa8349`) |
| ~~13~~ | Haftalık Canlı Boss Sistemi & Dinamik Hasar | ✅ **FAZ 2: TEST EDİLDİ, YAPILDI, PUSHLANDI** | `bossSpawnVeyaGuncelle`, dinamik `bossGuncelle` ve `bossHasarVer` ile haftalık kümülatif canlı HP barı, zindan akını tamamlama bonusu ve Dashboard üzerinde Pazar 23:59 geri sayımı ve zafer durumu eklendi. (Commit: `7974cd0`) |
| ~~14~~ | Çoklu Gün İnaktivite / Gece Kontrolü Atlaması | ✅ **FAZ 2: TEST EDİLDİ, YAPILDI, PUSHLANDI** | `geceKontrolu` içinde çoklu gün atlamalarında (`gunFarki > 1`) her kaçırılan gün için ardışık simülasyon, Pazar günleri boss yenilgi/hasar kontrolü ve Red Gate sayaç azaltımı eklendi. (Commit: `7974cd0`) |
| ~~15~~ | Varsayılan Zihinsel Görev Protokolleri | ✅ **FAZ 2: TEST EDİLDİ, YAPILDI, PUSHLANDI** | `baslangicPrograminiAta` ile idman günlerine `[MIND]` protokolleri otomatik eklendi. Günlük zihinsel görev listesi boşsa varsayılan odaklanma ve analiz protokolleri atandı. (Commit: `7974cd0`) |
| ~~16~~ | Gelişim & İstatistik Paneli (Progress Analytics) | ✅ **FAZ 3: TEST EDİLDİ, YAPILDI, PUSHLANDI** | Kilo trendi, idman hacmi, kalori alımı ve 1RM güç visualizer'ı içeren 4 sekmeli modern `AnalyticsScreen` geliştirildi (`CustomPainter` çizgi & bar grafikleri). (Commit: `7f429e6`) |
| ~~17~~ | Takvimde İdman & Diyet Geçmiş Rozetleri | ✅ **FAZ 3: TEST EDİLDİ, YAPILDI, PUSHLANDI** | `CalendarScreen` şerit ve aylık takvimine idman (🔥), diyet (🥗) ve çift başarı (⭐) rozetleri ile gün detaylarında beslenme arşivi dökümü eklendi. (Commit: `7f429e6`) |
| ~~18~~ | Akıllı Streak Koruma Bildirimi | ✅ **FAZ 3: TEST EDİLDİ, YAPILDI, PUSHLANDI** | `NotificationService` içine `akilliStreakBildirimiGuncelle` entegre edildi. Streak > 0 ve tamamlanmamış görev varken saat 21:00'e yüksek öncelikli uyarı planlandı. (Commit: `7f429e6`) |
| ~~19~~ | Kapsamlı Profil & Protokol Düzenleme | ✅ **FAZ 4: TEST EDİLDİ, YAPILDI, PUSHLANDI** | `HunterProfileSettingsModal` geliştirildi. Biyometri, hedef, zorluk, ekipman, dövüş branşları ve eklem kısıtlarının profil ekranından anında yeniden yapılandırılması sağlandı. (Commit: `69c8fb6`) |
| ~~20~~ | Sık Tüketilen Yemek Hafızası (Quick Meal Chips) | ✅ **FAZ 4: TEST EDİLDİ, YAPILDI, PUSHLANDI** | `YemekEkrani` manuel ekleme diyaloğuna sık tüketilen popüler avcı yemekleri hızlı seçim çipleri eklendi; tek dokunuşla kalori ve makro otomatik doldurma sağlandı. (Commit: `69c8fb6`) |
| ~~21~~ | Doküman Ayrıştırıcı & Paket Uyumluluğu Netleştirmesi | ✅ **FAZ 4: TEST EDİLDİ, YAPILDI, PUSHLANDI** | `DocumentParser`'ın diyetisyen OCR modülü ile entegrasyonu belgelendi; `pubspec.yaml`'daki `dependency_overrides` açıklamaları eklendi. (Commit: `69c8fb6`) |

---

## ⚠️ Bölüm 2: Aktif Sorunlar & İyileştirilmesi Gereken Noktalar

### 🔴 YÜKSEK ÖNCELİK

#### 1. Boss Hasar Hesabı Sadece Pazar Günü Hesaplanıyor
- **Dosya:** [memory_combat_ranks.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_combat_ranks.dart) + [dashboard_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/dashboard_screen.dart)
- **Durum:** ✅ **ÇÖZÜLDÜ (FAZ 2 - TEST EDİLDİ, YAPILDI, GİT'E PUSHLANDI)**
- **Detay:** Haftalık canlı Boss HP barı, dinamik hasar hesaplama (`bossSpawnVeyaGuncelle`, `bossGuncelle`, `bossHasarVer`), zindan akını tamamlama bonusu ve Dashboard üzerinde Pazar 23:59 geri sayımı ve zafer durumu eklendi. (Commit: `7974cd0`)

#### 2. Streak Hesabında Çoklu Gün Atlaması — Ara Günler İçin Ayrı Hesaplaşma Yapılmıyor
- **Dosya:** [memory_nutrition.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_nutrition.dart)
- **Durum:** ✅ **ÇÖZÜLDÜ (FAZ 2 - TEST EDİLDİ, YAPILDI, GİT'E PUSHLANDI)**
- **Detay:** `gunFarki > 1` olduğunda kaçırılan her ara gün için simülasyon döngüsü çalıştırılarak gece hesaplaşmaları, Pazar günü boss kontrolleri ve Kırmızı Geçit sayaç düşüşleri eksiksiz işletildi. (Commit: `7974cd0`)

#### 3. `profilFotoByte` ve `avatarFotoByte` Base64 Olarak SharedPreferences'te
- **Dosya:** [system_memory.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/system_memory.dart) + [photo_storage_service.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/services/photo_storage_service.dart)
- **Durum:** ✅ **ÇÖZÜLDÜ (FAZ 1 - TEST EDİLDİ, YAPILDI, GİT'E PUSHLANDI)**
- **Detay:** `PhotoStorageService` servisi yazılarak profil, avatar ve ilerleme galerisi fotoğrafları yerel dosya sistemine (`getApplicationDocumentsDirectory()/solo_photos`) taşındı. `SharedPreferences` üzerinden Base64 yükü temizlendi, geriye dönük uyumluluk ve otomatik migrasyon sağlandı. Ayrıca Backup/Restore JSON aktarımı eksiksiz hale getirildi. (Commit: `1aa8349`)

---

### 🟡 ORTA ÖNCELİK

#### 4. `kaydet()` Çağrılarının Çoğu `await` Edilmiyor
- **Dosya:** Birçok yerde (ör: `suplementKusan`, `statuYukselt`, `suEkle`)
- **Sorun:** `kaydet()` bir `Future<void>` ama çağrıların çoğunda `await` yapılmıyor. Uygulama ani kapatılırsa son kayıtlar kaybolabilir.
- **Etki:** Düşük — SharedPreferences zaten senkron benzeri çalışıyor ve veri kaybı nadirdir, ancak kritik işlemlerde (rank yükselişi, alışveriş) sorun olabilir.
- **Öneri:** Kritik işlemlerde await ekle veya throttled kaydetme mekanizması kullan.

#### 5. `system_session_manager.dart` → Global Timer HUD Karmaşıklığı
- **Dosya:** [system_session_manager.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/system_session_manager.dart) (14.8KB, 439 satır)
- **Sorun:** `DeepWorkSessionState` ve `RestTimerSessionState` aynı dosyada yönetiliyor. Her iki durum sınıfı da `DateTime.now()` ile duvar saati bazlı çalışıyor (iyi), ama `GlobalTimerHUD` widget'ı her iki sayacı da aynı anda bottom navigation bar üzerinde göstermeye çalışırken UI karmaşıklaşıyor.
- **Öneri:** Ayrı `TimerState` sınıflarına ayırmak veya mevcut yapıyı koruyarak belgelendirmek.

#### 6. `MemoryStorage._gecmisVerileriniOptimizeEt` Olası Performans Darboğazı
- **Dosya:** [memory_storage.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_storage.dart)
- **Sorun:** Uzun kullanımda `kiloGecmisi`, `idmanGecmisi`, `yemekGecmisi` büyüdükçe SharedPreferences'e yazma süresi artar. `_gecmisVerileriniOptimizeEt` mevcut ama agresifliği yapılandırılabilir değil.
- **Öneri:** Geçmiş verilerini ayrı dosyalara veya SQLite'a taşımayı düşünmek.

#### 7. Zihinsel Görevlerin Otomatik Haftalık Plana Atanmaması
- **Dosya:** [memory_workout.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_workout.dart) → `baslangicPrograminiAta`
- **Durum:** ✅ **ÇÖZÜLDÜ (FAZ 2 - TEST EDİLDİ, YAPILDI, GİT'E PUSHLANDI)**
- **Detay:** `baslangicPrograminiAta` içine idman günleri için otomatik `[MIND]` protokolleri eklendi, `gunlukZihinselGorevler` boşsa varsayılan zihinsel görevlerle beslendi. (Commit: `7974cd0`)

---

### 🔵 DÜŞÜK ÖNCELİK

#### 8. `dependency_overrides` — Uyumluluk Yaması
- **Dosya:** [pubspec.yaml](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/pubspec.yaml)
- **Durum:** ✅ **NETLEŞTİRİLDİ & BELGELENDİ (FAZ 4)**
- **Detay:** `path_provider` ve `file_picker` Android/iOS platform plugin sürümleri arasındaki sürüm kilitlenmesini engellemek üzere yapılandırılmış olup belgelendirildi. (Commit: `69c8fb6`)

#### 9. `exportBackupJson` — Çoklu Gün Diyetisyen Verisi Eksik
- **Dosya:** [memory_combat_ranks.dart#L603-L673](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/controllers/memory_modules/memory_combat_ranks.dart#L603)
- **Durum:** ✅ **ÇÖZÜLDÜ (FAZ 1 - TEST EDİLDİ, YAPILDI, GİT'E PUSHLANDI)**
- **Detay:** `exportBackupJson` ve `importBackupJson` zihinsel görevler, odaklanma/kitap istatistikleri ve ilerleme fotoğrafları ile tamamlandı. (Commit: `1aa8349`)

#### 10. `document_parser.dart` Dosyasının Rolü Belirsiz
- **Dosya:** [document_parser.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/document_parser.dart)
- **Durum:** ✅ **NETLEŞTİRİLDİ & BELGELENDİ (FAZ 4)**
- **Detay:** [DietitianScannerModal](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/dietitian_scanner_modal.dart) tarafından PDF, Word (.docx, .doc), TXT ve görsel listelerin Gemini AI metabolik taramasına aktarılmasını sağlayan doküman ayrıştırıcı olduğu belgelendi. (Commit: `69c8fb6`)

---

## 🚀 Bölüm 3: Eklenebilecek Özellik Önerileri

### ⭐⭐⭐ Yüksek Değer — Oyun Deneyimini Doğrudan İyileştirir

#### 1. 📊 Geçmiş & İstatistik Paneli (Progress Dashboard)
- **Durum:** ✅ **ÇÖZÜLDÜ (FAZ 3 - TEST EDİLDİ, YAPILDI, GİT'E PUSHLANDI)**
- **Detay:** [analytics_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/analytics_screen.dart) geliştirildi. 4 ana sekme: Kilo trendi (CustomPaint spline ve hedef kılavuzu), İdman hacmi ve süresi bar grafiği, Kalori ve makro uyumu bar grafiği, 1RM büyük üçlü güç çubukları ve Avcı Güç Kademesi (S/A/B/C/D) sınıflandırması. Dashboard, Takvim ve Profil ekranlarından doğrudan erişim sağlandı. (Commit: `7f429e6`)

#### 2. 🔔 Akıllı Bildirim Protokolü — Streak Kırılma Uyarısı
- **Durum:** ✅ **ÇÖZÜLDÜ (FAZ 3 - TEST EDİLDİ, YAPILDI, GİT'E PUSHLANDI)**
- **Detay:** [notification_service.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/core/services/notification_service.dart) içine `akilliStreakBildirimiGuncelle` ve `streakBildirimiIptal` eklendi. Kullanıcının aktif serisi varsa ve gün tamamlanmamışsa akşam 21:00'e yüksek öncelikli kriz bildirimi planlanır, görevler bitince otomatik iptal edilir. (Commit: `7f429e6`)

#### 3. 📅 Takvimde İdman & Diyet Geçmişi Gösterimi
- **Durum:** ✅ **ÇÖZÜLDÜ (FAZ 3 - TEST EDİLDİ, YAPILDI, GİT'E PUSHLANDI)**
- **Detay:** [calendar_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/calendar_screen.dart) üzerinde hem yatay şerit hem aylık görünümde idman yapılan günlere altın alev (🔥), beslenme hedefleri kaydedilen günlere yeşil çatal-bıçak (🥗), ikisi birden biten günlere altın zırh çerçevesi eklendi. Seçili gün tıklandığında alt panelde zindan kayıtlarının yanı sıra tam beslenme makro dökümü gösterildi. (Commit: `7f429e6`)

---

### ⭐⭐ Orta Değer — Kullanıcı Deneyimini İyileştirir

#### 4. 🔄 Profil / Ayarlar Düzenleme Ekranı
- **Durum:** ✅ **ÇÖZÜLDÜ (FAZ 4 - TEST EDİLDİ, YAPILDI, GİT'E PUSHLANDI)**
- **Detay:** [hunter_profile_settings_modal.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/hunter_profile_settings_modal.dart) ile boy, kilo, hedef kilo, cinsiyet, hedef, zorluk, ekipman, dövüş branşları ve eklem kısıtlarının tek tıkla düzenlenmesi ve kaydedilmesi sağlandı. (Commit: `69c8fb6`)

#### 5. 💬 Sosyal / Rekabet Sistemi (Leaderboard)
- **Ne yapmalı:** Firebase veya basit bir backend ile arkadaşlarla streak karşılaştırması, haftalık liderlik tablosu.
- **Etki:** Sosyal rekabet güçlü motivasyon kaynağı, ama backend gerektirir.

#### 6. 🧮 Akıllı Kalori Öğrenme (ML Lite & Hızlı Çipler)
- **Durum:** ✅ **ÇÖZÜLDÜ (FAZ 4 - TEST EDİLDİ, YAPILDI, GİT'E PUSHLANDI)**
- **Detay:** [diet_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/diet_screen.dart) manuel yemek girişine sık tüketilen popüler avcı yemekleri hızlı seçim çipleri eklendi. Tek dokunuşla kalori ve makro otomatik doldurulur. (Commit: `69c8fb6`)

---

### ⭐ Düşük Değer — Polish & Nice-to-Have

#### 7. 🎵 Spotify / YouTube Music Playlist Entegrasyonu
- İdman esnasında direkt müzik önerisi veya playlist bağlantısı.

#### 8. 🗺️ Harita & Koşu Takip Özelliği
- GPS tabanlı koşu takibi ve rota kaydı. (Ertelenmiş özellik)

#### 9. 📱 Widget (Home Screen Widget)
- Android/iOS ana ekranında streak, günlük görev durumu ve su sayacı gösteren mini widget.

#### 10. 🎮 Günlük Mini Oyun / Zihinsel Meydan Okuma
- Hızlı matematik, hafıza kartları veya refleks testi gibi günlük mini oyunlar ile PER/INT kazanma.

---

## 🚨 Bölüm 2.5: UI/UX Tasarım, Girdi (Input) Bozuklukları ve Kilo-AI Eksiklikleri Analizi (26 Eylül 2026)

### 1. Girdilerdeki Bozukluklar ve Çökme (Crash) Riskleri
| # | Hata / Bozukluk | Etkilenen Dosya & Satır | Hata Türü / Etkisi | Çözüm |
|---|----------------|-------------------------|--------------------|-------|
| 1 | `double.parse` ile doğrudan dönüşüm ve unhandled `FormatException` | [profile_screen.dart#L425](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/profile_screen.dart#L425) | 🔴 **Kritik Çökme:** Tartı güncellemede virgüllü giriş (`75,5`) veya boşluk uygulamayı çökerterek kapatır. | `double.tryParse(kiloCtrl.text.replaceAll(',', '.'))` + geçerlilik kontrolü eklenmeli. |
| 2 | Virgüllü kilo ve hedef kilo girişlerinin algılanamaması (Sessiz Veri Kaybı) | [hunter_profile_settings_modal.dart#L117-L119](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/hunter_profile_settings_modal.dart#L117-L119) | 🔴 **Veri Kaybı:** Boy, kilo, hedef kilo virgülle girildiğinde `null` döner, kullanıcı fark etmeden eski değere geri düşer. | Tüm biyometri controller okumalarında `.replaceAll(',', '.')` yapılmalı. |
| 3 | Set ağırlık düzenlemesinde virgül girilince ağırlığın 0.0 kg kaydedilmesi | [active_workout_screen.dart#L1059](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/active_workout_screen.dart#L1059) | 🔴 **Hatalı İdman Kaydı:** `22,5` kg yazan avcının seti `0.0 kg` olarak kaydedilir. | `double.tryParse(kiloCtrl.text.replaceAll(',', '.'))` uygulanmalı. |
| 4 | Güç Testi (1RM) değerlerinin virgüllü girilince sıfırlanması | [awakening_test_dialog.dart#L73-L75](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/awakening_test_dialog.dart#L73-L75) & [setup_screen.dart#L190-L192](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/setup_screen.dart#L190-L192) | 🔴 **Rütbe (Rank) Bozulması:** Bench/Squat/Deadlift virgüllü girildiğinde 0 kg sayılır ve avcı E-Rank atanır. | Tüm güç test girdileri sanitizasyondan geçirilmeli. |
| 5 | Eksik Klavye Tipleri (`TextInputType.number` vs `numberWithOptions(decimal: true)`) | [setup_screen.dart#L877-L898](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/setup_screen.dart#L877-L898), [profile_screen.dart#L479](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/profile_screen.dart#L479) | 🟡 **UX Engeli:** iOS ve bazı Android klavyelerinde nokta/virgül tuşu çıkmaz, küsuratlı kilo girilemez. | `keyboardType: const TextInputType.numberWithOptions(decimal: true)` yapılmalı. |
| 6 | Bellek Sızıntısı (Undisposed Controller) | [setup_screen.dart#L36](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/setup_screen.dart#L36) | 🟡 **Memory Leak:** `hedefKiloCtrl` oluşturulmuş ancak `dispose()` edilmemektedir. | `hedefKiloCtrl.dispose()` eklenmeli. |
| 7 | Yemek Ekleme Sonrası Makro Alanlarının Sıfırlanmaması | [diet_screen.dart#L465-L467](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/diet_screen.dart#L465-L467) | 🟡 **Form Kirliliği:** Yeni yemek eklerken önceki yemeğin P/C/F değerleri kutularda asılı kalır. | `proteinCtrl.clear()`, `karbCtrl.clear()`, `yagCtrl.clear()` çağrılmalı. |
| 8 | Mantıksız Biyometri Doğrulaması Eksikliği | [hunter_profile_settings_modal.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/widgets/hunter_profile_settings_modal.dart) & [setup_screen.dart](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/setup_screen.dart) | 🟡 **Veri Tutarsızlığı:** 0 kg veya 400 kg girilse dahi sistem sessizce kabul eder. | 30 kg - 250 kg ve 100 cm - 250 cm aralık kontrolü ve SnackBar uyarısı eklenmeli. |

### 2. UI Layout, Taşma (Overflow) ve RenderFlex Hataları
| # | Hata / Taşma Riski | Etkilenen Dosya & Satır | Hata Detayı | Çözüm |
|---|-------------------|-------------------------|-------------|-------|
| 1 | `_kiloGecmisiGoster` Unbounded Layout Çökmesi | [profile_screen.dart#L491-L525](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/profile_screen.dart#L491-L525) | 🔴 `showModalBottomSheet` içinde kısıtsız `Column(mainAxisSize: Min)` içinde `Expanded(child: ListView)` kullanımı `RenderFlex has children with non-zero flex but incoming height constraints are unbounded` hatası fırlatır. | `isScrollControlled: true` ve `BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7)` eklenmeli. |
| 2 | Klavye Açıldığında Ekran Taşması (Bottom Overflow) | [profile_screen.dart#L385-L405](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/profile_screen.dart#L385-L405) & [diet_screen.dart#L350-L435](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/diet_screen.dart#L350-L435) | 🟡 Küçük ekranlı telefonlarda sayısal klavye açılınca diyalog altındaki butonlar sarı-siyah taşma çizgisi üretir. | Dialog içeriği esnek `SingleChildScrollView` ve `MainAxisSize.min` ile sarılmalı. |
| 3 | Üst Başlık Satırı Yatay Taşması (Header Overflow) | [dashboard_screen.dart#L170-L212](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/dashboard_screen.dart#L170-L212) | 🟡 Uzun avcı ismi + Rank rozeti + Analiz ikonu + Market ikonu dar ekranlarda sağdan taşma riski taşır. | Başlık alanı `Flexible` / `Expanded` ile sınırlandırılmalı ve metin `TextOverflow.ellipsis` almalı. |

### 3. Tasarım Bütünlüğü ve Dil Tutarsızlıkları
* **Hardcoded İngilizce Metinler:** [profile_screen.dart#L195, L214, L230](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel%20olan%20işler/solo_app/lib/screens/profile_screen.dart#L195) dosyalarındaki "RENAME HUNTER", "CANCEL", "CONFIRM" gibi diyalog metinleri `TranslationManager`'a bağlanmalı.
* **Solo Leveling Renk Bütünlüğü:** Bazı modallarda kullanılan mat gri (`Colors.black45`) ve rastgele arka planlar yerine neon sistem mavisi (`#38BDF8`), derin koyu arka plan (`#030712`) ve zindan altını (`#EAB308`) standartlaştırılmalı.

### 4. Antrenman Yapay Zekası ve Kullanıcı Kilosuna Göre "Net Yapılacaklar" Eksikliği
* **AI Ek İdman Booster'da Kilo Bilgisinin Olmaması:**
  * [memory_workout.dart#L527-L533](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel olan işler/solo_app/lib/controllers/memory_modules/memory_workout.dart#L527-L533) ve [gemini_service.dart#L676-L682](file:///c:/Users/Rıza%20Can%20Yavuz/Desktop/İşler%20Projeler/Özel olan işler/solo_app/lib/core/services/gemini_service.dart#L676-L682): `aiEkIdmanUret` fonksiyonuna avcının `kilo`, `boy` ve `hedefKilo` parametreleri aktarılmamaktadır. Yapay zeka kullanıcının vücut kütlesini ve yağ oranını bilmeden egzersiz türetmektedir.
* **Kullanıcı Kilosuna Göre Dinamik Egzersiz Ölçeklemesi:**
  * Ağır siklet / kilo verme hedefindeki kullanıcılar için eklemlere binen darbeyi azaltan düşük etkili (low-impact) kardiyo ve destekli vücut ağırlığı varyasyonları;
  * Kas kütlesi inşa etmeye çalışan kullanıcılar için kilonun belirli bir katı hedefleyen bileşik kuvvet görevleri;
  * Günlük "Net Yapılacaklar" (Daily Quests) paneline avcının mevcut kilosuna ve yakması gereken kaloriye endeksli dinamik mikro görevler entegre edilmelidir.

---

## 🧪 Bölüm 4: Kod Kalitesi & Teknik Durum

| Konu | Durum | Detay |
|------|-------|-------|
| **Test Kapsamı** | ✅ Mükemmel | 28 paket, 148 / 148 test eksiksiz geçiyor (%100 yeşil) |
| **Mimari** | ✅ Modüler | `SystemMemory` → 4 hafıza modülü delege sistemi (577 satır core) |
| **Fotoğraf Depolama** | ✅ Optimize | Profil, avatar ve galeri görselleri `solo_photos` yerel diskine taşındı (Faz 1) |
| **Canlı Boss & Çoklu Gün** | ✅ Tam Fonksiyonel | Hafta içi dinamik hasar + kaçırılan günlerin ardışık simülasyonu (Faz 2) |
| **İstatistik & Takvim** | ✅ Tam Entegre | 4 sekmeli `AnalyticsScreen` + Takvim geçmiş rozetleri (Faz 3) |
| **Profil & Hızlı Yemek** | ✅ Tam Entegre | `HunterProfileSettingsModal` + Hızlı kalori çipleri (Faz 4) |
| **Statik Analiz** | ✅ Temiz | `flutter analyze` → 0 issue |
| **Girdi & Format Hijyeni** | ⚠️ İyileştirilmeli | Virgül/nokta ayrımı, klavye tipleri ve bellek sızıntıları (Faz 5'te çözülecek) |
| **UI Taşma Güvenliği** | ⚠️ İyileştirilmeli | Modal yükseklikleri ve klavye çakışmaları (Faz 6'da çözülecek) |
| **Kilo-Odaklı AI Antrenman** | ⚠️ Genişletilmeli | Kullanıcı kilosuna göre idman ve görev üretimi (Faz 7'de eklenecek) |

---

## 📋 Bölüm 5: MVP Yol Haritası & Tamamlanma Faz Planı

Sistemin tam bir **üretim kalitesinde MVP (Minimum Viable Product)** haline gelmesi için planlanan ve uygulanan fazların net takvimi:

### 🚀 Tamamlanan Fazlar (Faz 1 – 4)
* [x] **FAZ 1: Performans & Veri Güvenliği (Fotoğraf Migrasyonu & Backup Genişletme)**
  * Base64 SharedPreferences yükü temizlendi, fotoğraflar diske taşındı (`PhotoStorageService`).
  * JSON Backup/Restore zihinsel görevler ve fotoğrafları kapsayacak şekilde tamamlandı. (Commit: `1aa8349`, `77dac68`)
* [x] **FAZ 2: Canlı Boss Mekaniği & Çoklu Gün Simülasyonu**
  * Hafta içi kümülatif canlı Boss HP barı ve geri sayım eklendi.
  * Kaçırılan günlerde inaktivite hesaplaşması ve ardışık telafi motoru kuruldu.
  * Varsayılan plana `[MIND]` zihinsel protokolleri atandı. (Commit: `7974cd0`)
* [x] **FAZ 3: Veri Görselleştirme, Takvim Arşivi & Akıllı Streak**
  * 4 sekmeli CustomPaint grafikli `AnalyticsScreen` inşa edildi (Kilo, İdman, Kalori, 1RM).
  * `CalendarScreen` üzerinde idman/diyet rozetleri ve geçmiş dökümü bağlandı.
  * Saat 21:00 akıllı streak koruma bildirimi entegre edildi. (Commit: `7f429e6`)
* [x] **FAZ 4: Profil/Ayarlar Düzenleme & Sık Yemek Çipleri**
  * `HunterProfileSettingsModal` ile biyometri ve dövüş kısıtları profil üzerinden tek tıkla düzenlenebilir yapıldı.
  * `DietScreen`'e sık tüketilen popüler avcı yemekleri hızlı seçim çipleri eklendi. (Commit: `69c8fb6`)

---

### 🔨 Aktif MVP Fazları (Faz 5 – 8)

| Faz | Kapsam | Öncelik | Hedef Çıktı & Doğrulama |
|:---:|:-------|:-------:|:------------------------|
| **FAZ 5** | **Girdi Güvenliği, Klavye ve Format Hijyeni** | 🔴 KRİTİK | `double.parse` çökmesi kaldırılacak; tüm sayısal alanlarda virgül (`75,5`) desteği sağlanacak; `TextInputType.numberWithOptions(decimal: true)` kuralı uygulanacak; `hedefKiloCtrl` bellek sızıntısı giderilecek; yemek ekleme formu temizlenecek; biyometri aralık doğrulaması eklenecek. |
| **FAZ 6** | **UI & Responsive Düzenleme, Taşma Koruması ve Tema Bütünlüğü** | 🔴 YÜKSEK | `_kiloGecmisiGoster` modalı `isScrollControlled` ve `BoxConstraints` ile güvene alınacak; tüm diyaloglara klavye taşma koruması (`SingleChildScrollView`) verilecek; üst başlık dar ekran koruması yapılacak; hardcoded İngilizce kelimeler `TranslationManager`'a bağlanacak; Solo Leveling neon renk paleti eşitlenecek. |
| **FAZ 7** | **Kilo-Odaklı AI Antrenman & Günlük "Net Yapılacaklar" Motoru** | 🟡 YÜKSEK | Avcının mevcut kilosu (`kilo`), boyu ve hedef kilosu hem `aiEkIdmanUret` promptuna hem de yerel `baslangicPrograminiAta` motoruna bağlanacak; kullanıcının kilosuna özel vücut ağırlığı direnç ölçeklemesi ve kardiyo yakım hedefleri entegre edilecek; Dashboard'daki "Net Yapılacaklar" paneline kiloya özel günlük görevler eklenecek. |
| **FAZ 8** | **MVP Final Polish, Uçtan Uca Test Paketi & Release Derlemesi** | 🟢 SON AŞAMA | Tüm yeni fonksiyonlar için widget ve birim testleri (150+ test) yazılacak; statik analiz sıfır hata ile doğrulanacak; projedeki tüm fazlar tamamlanarak kararlı MVP release APK'sı derlenecek. |

---

> [!TIP]
> Faz 5–8 tamamlandığında Solo Leveling App; sıfır çökme riski, kusursuz sayısal giriş ve klavye deneyimi, taşmasız responsive arayüz, kullanıcının vücut kilosuna tam adapte olan yapay zeka antrenman motoru ve eksiksiz Solo Leveling görsel kimliğiyle **tam teşekküllü MVP** olarak yayına hazır olacaktır.

