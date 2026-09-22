# Solo Leveling App — Yeni Özellikler & Çok Yönlü Avcı Gelişimi Yol Haritası

Bu belge; Solo Leveling App sistemine tamamlanan fazları ve kullanıcının talebi doğrultusunda **yalnızca fiziksel sporla sınırlı kalmayan, zihinsel (INT), algısal (PER) ve profesyonel/akademik gelişimi de kapsayan** yeni nesil özelliklerin teknik ve mimari uygulama planını içermektedir.

---

## 📌 Durum Özeti & Tamamlanan Faz 1 (Doğrulandı - 115/115 Test Yeşil)

Aşağıdaki ilk 6 sistem özelliği eksiksiz geliştirilmiş, `SystemMemory` ve UI katmanına entegre edilmiş ve test edilmiştir:
- [x] **Modül 1: Push Bildirimler & Hatırlatmalar** (`flutter_local_notifications` ile Zindan Çağrısı ve Teftiş altyapısı)
- [x] **Modül 2: Uyku Takip Kartı** (Dashboard üzerinde dinamik hücresel onarım teşhisi ve hızlı seçim çipleri)
- [x] **Modül 3: Takvimde İdman Geçmişi** (Geçmiş idmanların parlak ateş aurası ile gösterimi ve zindan teftiş modalı)
- [x] **Modül 4: Sinematik Başarım Pop-up'ı** (Kademe yıldızları, altın parıltı ve otomatik tetikleyici)
- [x] **Modül 5: İlerleme Fotoğrafları Galerisi** (Zaman çizelgesi ve Öncesi/Sonrası split karşılaştırma)
- [x] **Modül 6: Dinamik Zorluk Ayarlama (DDA)** (7 günlük tamamlama ve yorgunluğa göre seviye uyarlama motoru)

---

## 🧠 FAZ 2: ÇOK YÖNLÜ AVCI GELİŞİMİ & ZİHİNSEL/MESLEKİ PROTOKOLLER

> *"Gerçek bir avcının gücü yalnızca kaslarında değil; zihninde, algısında ve uzmanlaştığı zanaattedir."*

Kişisel gelişim sadece spor salonuyla sınırlı değildir. Karakterin **Zeka (INT)** ve **Algı (PER)** statlarını gerçek hayata yansıtacak, kullanıcının mesleki veya akademik kariyerini bir RPG görevi haline getirecek yeni modüller:

---

### 📚 Modül 7: Zihinsel Gelişim & Kitap Okuma Zindanı (The Archive of Awakening)
- **Hedef:** Kitap okuma, araştırma yapma ve entelektüel derinliği doğrudan karakterin **INT** ve **PER** statlarına bağlamak.
- **Özellikler:**
  - **Okuma Takipçisi & Sayfa/Süre Sayacı:** Günlük okuma hedefi (örn: 30 sayfa veya 25 dakika odaklanmış okuma).
  - **Avcı Kütüphanesi (Grimoire Vault):** Okunmakta olan kitaplar, tamamlanan kitaplar listesi ve puanlama.
  - **Kitap Odaklı EXP & Stat:** Tamamlanan her 10 sayfa veya 15 dakikalık okuma için `+INT` ve `+MP` kazanımı.
  - **Streak & Alışkanlık Bağı:** Fiziksel antrenman gibi zihinsel görevlerin de günlük görevler listesinde yer alması ve streak'i beslemesi.

---

### 💻 Modül 8: Mesleki & Akademik Çalışma Planı Oluşturucu (Career & Skill Protocol)
- **Hedef:** Kullanıcının kendi uzmanlık alanında (Yazılım, Tıp, Hukuk, Mühendislik, Tasarım, Yabancı Dil, Sınav Hazırlığı vb.) planlı ve disiplinli bir gelişim rotası çizmesi.
- **Özellikler:**
  - **Alan ve Uzmanlık Seçimi:** Kullanıcı kendi uzmanlık hedefini belirler (örn: *"Flutter & AI Mühendisliği"*, *"YKS Sayısal Derece"*, *"B2 İngilizce İleri Düzey"*).
  - **Dinamik Çalışma Seansları & Deep Work:** Günlük/haftalık çalışma blokları (örn: 2 saat kodlama, 1 saat vaka incelemesi, 40 dk gramer pratiği).
  - **Zihinsel İlerleme Ağacı (Skill Tree):** Öğrenilen her yeni konu veya proje bitimi bir yetenek ağacı düğümü gibi açılır (Avcı Becerisi şeklinde görselleştirilir).

---

### 🤖 Modül 9: Gemini AI Destekli Akıllı Çalışma Planlayıcısı & Mentor
- **Hedef:** Mevcut `GeminiService` altyapısını kullanarak kişiye özel akademik/kariyer çalışma protokolleri üretmek.
- **Özellikler:**
  - **AI Çalışma Protokolü Üretimi:**
    - Girdi: Uzmanlık Alanı + Mevcut Seviye + Günlük Ayırabileceği Süre + Hedef Tarih.
    - Çıktı: Gün gün ayrılmış, gerçekçi, mola ve tekrar fazları içeren modüler haftalık çalışma planı.
  - **AI Kitap Özeti & Insight Çıkarıcı:**
    - Kullanıcı okuduğu kitaptan veya çalıştığı konudan kısa bir not veya fotoğraf girdiğinde, Gemini AI bu bilgiyi analiz ederek 3 kritik avcı dersi / kilit çıkarım üretir.
  - **AI Görev Uyarlama:**
    - Eğer avcı o gün zihinsel olarak çok yorgunsa (yüksek yorgunluk/bitkinlik), AI çalışma bloklarını hafifletip hafif okuma veya sesli dinleme görevine çevirebilir.

---

### ⏳ Modül 10: Odaklanma Seansı & Deep Work Zindanı (Pomodoro & Focus Dungeon)
- **Hedef:** Çalışma ve okuma esnasında dikkat dağınıklığını önleyen tematik bir odaklanma aracı.
- **Özellikler:**
  - Tıpkı `BoxingTimerScreen` ve `ActiveWorkoutScreen` gibi çalışan, geri sayımlı ve arka plan korumalı **"Zihinsel Odaklanma Seansı"** (25/5 Pomodoro veya 50/10 Deep Work blokları).
  - Seans başarıyla tamamlandığında `[ DEEP WORK CLEARED ]` zafer raporu, odaklanma süresine göre EXP, MP ve Altın ödülü.
  - Seans ortasında çıkılırsa *"Zindan Terk Edildi"* uyarısı ile disiplin teşviki.

---

### 🎨 Modül 11: UI / UX Tasarım Rötuşları & Görsel Hiyerarşi
- **Welcome & Instruction Ekranı Standardizasyonu:**
  - `welcome_screen.dart` ve `instruction_screen.dart` ekranlarındaki eski yuvarlak kenarlar ve camgöbeği (`cyanAccent`) renkler; uygulamanın genelindeki 4px keskin kenarlı ve Buz Mavisi (`0xFF38BDF8`) `HologramCard` çizgisine güncellenecektir.
- **Dashboard Görsel Gruplama (Sekmeli / Hiyerarşik Tasarım):**
  - Genişleyen içerik nedeniyle Dashboard 2 ana bölüme veya filtre çipine ayrılabilir:
    1. **Fiziksel Zindan (Physical Quests):** Antrenman, Adım, Kalori, Su, Boks.
    2. **Zihinsel Zindan (Mind & Skill Quests):** Kitap Okuma, Çalışma Blokları, Odaklanma.
- **Rest Day (Dinlenme & İyileşme) Kartı:**
  - Antrenman olmayan günlerde boş liste yerine *"AKTİF TOPARLANMA & ZİHİNSEL GELİŞİM PROTOKOLÜ"* (Esneme, Mobilite, Kitap Okuma, Meditasyon) tematik kartı gösterilecektir.

---

## 🏗️ Veri Modeli ve Mimari Tasarım Taslağı

### 1. `MentalTask` / `StudyTask` Modeli
```dart
class MentalTask {
  final String id;
  final String title;            // Örn: "Yapay Zeka Mimarisi Okuması"
  final String category;         // "Book", "Coding", "Language", "Exam", "Skill"
  final int targetMinutes;       // 45 dk
  final int completedMinutes;
  final int rewardExp;
  final int rewardInt;           // Zeka artışı
  final int rewardPer;           // Algı artışı
  final bool isCompleted;
  final String? bookTitle;
  final int? targetPages;
}
```

### 2. `SystemMemory` Entegrasyonu
- `List<MentalTask> gunlukZihinselGorevler`: Günlük hesaplaşmaya ve streak'e etki eder.
- `int toplamOkunanSayfaSayisi`, `int toplamOdaklanmaDakikasi`: İstatistik ve başarılara bağlanır.
- Yeni Başarımlar:
  - `Bilge Avcı (The Grand Scholar)`: 10/25/50 kitap bitirme.
  - `Derin Odaklanma (Absolute Concentration)`: 100/500/1000 saat Deep Work tamamlama.

---

## 📋 Geliştirme Sıralaması (Yol Haritası)

1. **Adım 1:** UI Tasarım Bütünlüğü (`welcome_screen.dart` ve `instruction_screen.dart` dosyalarının modern 4px HologramCard çizgisine kavuşturulması).
2. **Adım 2:** Zihinsel Görev & Kitap Okuma Veri Modellerinin (`MentalTask`) sisteme eklenmesi.
3. **Adım 3:** Gemini AI ile Çalışma Planı & Zihinsel Protokol Oluşturma servisinin yazılması.
4. **Adım 4:** Deep Work / Odaklanma Zindanı sayacının (Pomodoro / Focus HUD) kodlanması.
5. **Adım 5:** Dashboard üzerinde Fiziksel ve Zihinsel görevlerin estetik olarak gruplanması ve Dinlenme Günü modülünün tamamlanması.
6. **Adım 6:** Tüm yeni özellikler için birim/widget testlerinin yazılması ve sıfır regresyon doğrulaması.
