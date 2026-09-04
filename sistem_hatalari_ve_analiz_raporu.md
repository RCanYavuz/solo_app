# Solo App - Sistem Analizi ve Hata Raporu

**Tarih:** 04.09.2026  
**Proje:** Solo Leveling Fitness & RPG Tracking App (`solo_app`)  
**Durum Özeti:** 36 Statik Analiz / Linter Uyarısı, 3 Kritik Yaşam Döngüsü/Navigasyon Hatası, 2 Yetim Ekran Entegrasyonu, 1 Çökme (FormatException) Riski ve 1 Windows/LSP CLI Çevre Hatası tespit edildi.

---

## 1. Kritik Navigasyon ve Yaşam Döngüsü Hataları

### 1.1. Kayıtlı Kullanıcıda Bile Sürekli `SetupScreen` Açılması(çözüldü test edilmedi)
* **Dosya:** [`lib/main.dart:47`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/main.dart#L47)
* **Kök Neden:** `SoloApp` widget'ı içerisinde `home` parametresi doğrudan `const SetupScreen()` olarak sabitlenmiştir.
* **Mevcut Durum:**
  ```dart
  // lib/main.dart
  home: const SetupScreen(),
  ```
* **Sorun:** `SystemMemory.baslat()` çalıştırıldığında cihazda daha önce kayıt varsa `SystemMemory.kayitBulundu = true;` bayrağı set edilmektedir. Fakat `main.dart` bu bayrağı kontrol etmediği için kullanıcı her uygulama açılışında kurulum/tara ekranına zorlanmaktadır.
* **Çözüm:**
  ```dart
  home: SystemMemory.kayitBulundu ? const AnaEkran() : const SetupScreen(),
  ```

### 1.2. `main.dart` Kullanılmayan Import (Unused Import)
* **Dosya:** [`lib/main.dart:7`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/main.dart#L7)
* **Hata:** `warning - main.dart:7:8 - Unused import: 'screens/instruction_screen.dart'`
* **Çözüm:** Kullanılmayan import satırı kaldırılmalıdır.

---

## 2. Yetim (Bağlantısı Kopuk) Ekranlar ve Modüller

### 2.1. Antrenman Kütüphanesi Ekranı Ulaşılamaz Durumda
* **Dosya:** [`lib/screens/workout_library_screen.dart`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/workout_library_screen.dart)
* **Kapsam:** 875 satırlık, YouTube bağlantı destekli, düzenlenebilir antrenman şablonları ekranı.
* **Sorun:** Proje genelinde hiçbir ekrandan (`workout_planner_screen.dart`, `dashboard_screen.dart`, `status_screen.dart`) bu ekrana yönlendirme (`Navigator.push`) yapılmamaktadır. Ekran kodlanmış ancak menülerde gizli kalmıştır.
* **Çözüm:** `WorkoutPlannerScreen` veya `DashboardScreen` üzerine "Workout Library / Antrenman Kütüphanesi" butonu eklenerek `WorkoutLibraryScreen` erişilebilir kılınmalıdır.

### 2.2. Görsel Makro Laboratuvarı Ekranı Ulaşılamaz Durumda
* **Dosya:** [`lib/screens/macro_dashboard_screen.dart`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/macro_dashboard_screen.dart)
* **Kapsam:** [`lib/core/diyet_motoru.dart`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/core/diyet_motoru.dart) ile çalışan, animasyonlu makro dağılımı ve öğün önerileri sunan 747 satırlık kapsamlı ekran.
* **Sorun:** [`lib/screens/diet_screen.dart`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/diet_screen.dart) içerisinden veya menülerden bu ekrana hiçbir geçiş rotası bulunmamaktadır.
* **Çözüm:** `diet_screen.dart` AppBar veya kart alanına "Macro Lab / Besin Analizi" butonu eklenmelidir.

---

## 3. Yapay Zeka (Gemini) Entegrasyon Eksiklikleri

### 3.1. Yapay Zeka Yemek Analizinin Çağrılmaması
* **Dosya:** [`lib/core/services/gemini_service.dart:150`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/core/services/gemini_service.dart#L150)
* **Kapsam:** `GeminiService.yemekAnalizEt(String yemekTarifi)` fonksiyonu doğal dille yazılan yiyeceği JSON formatında analiz edip kalori ve makro hesaplayacak şekilde hazırlanmıştır.
* **Sorun:** [`lib/screens/diet_screen.dart`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/diet_screen.dart) içinde kullanıcıya serbest metinle yemek analizi yaptıracak arayüz bulunmamakta, kullanıcı yalnızca adı ve kaloriyi manuel girmeye zorlanmaktadır.
* **Çözüm:** Yemek ekleme diyaloğuna "AI ile Çözümle" seçeneği entegre edilmelidir.

### 3.2. Profil Ekranında Gemini API Anahtarı Yönetimi Yok
* **Dosya:** [`lib/screens/profile_screen.dart`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/profile_screen.dart)
* **Sorun:** Gemini API anahtarı yalnızca ilk kurulumdaki `SetupScreen` ekranından girilebilmektedir. Kullanıcı API anahtarını sonradan değiştirmek, girmek veya bağlantısını test etmek istediğinde `ProfileScreen` üzerinde hiçbir alan yoktur.
* **Çözüm:** Profil ekranına "System Core / Gemini API Key" ayar ve test alanı eklenmelidir.

### 3.3. Aktif Model Kalıcılığı Sağlanmıyor
* **Dosya:** [`lib/core/services/gemini_service.dart:11`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/core/services/gemini_service.dart#L11)
* **Sorun:** `testBaglantisi()` sırasında çalışan model tespit edilip `_activeModelName` değişkenine atansa da `SharedPreferences` üzerine kaydedilmediği için uygulama yeniden başlatıldığında varsayılan `gemini-1.5-flash` değerine dönmektedir.

---

## 4. Mantıksal ve Çalışma Zamanı (Runtime) Hataları

### 4.1. Yemek Eklerken Çökme Riski (`FormatException`)
* **Dosya:** [`lib/screens/diet_screen.dart:65`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/diet_screen.dart#L65)
* **Hatalı Kod:**
  ```dart
  int kalori = int.parse(_kaloriCtrl.text);
  ```
* **Sorun:** Kullanıcı boşluk, virgüllü sayı veya sayı dışı bir karakter girdiğinde `int.parse` unhandled `FormatException` fırlatır ve uygulama çöker.
* **Çözüm:**
  ```dart
  int kalori = int.tryParse(_kaloriCtrl.text.trim()) ?? 0;
  ```

### 4.2. Gün Sonu Hesaplamasında Tüm Haftanın Sıfırlanması
* **Dosya:** [`lib/controllers/system_memory.dart:657-661`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/controllers/system_memory.dart#L657-L661)
* **Hatalı Kod:**
  ```dart
  for (int i = 1; i <= 7; i++) {
    for (var g in haftalikPlan[i]!) {
      g.yapildiMi = false;
    }
  }
  ```
* **Sorun:** Gün değişimi tespit edildiğinde sadece değerlendirilen günün görevleri değil, haftanın 7 günündeki tüm görevler sıfırlanmaktadır. Bu durum haftalık ilerleme takviminde geçmiş günlerin kayıt durumunun bozulmasına sebep olur.

---

## 5. Statik Kod Analizi ve Linter Uyarıları (36 Adet)

### 5.1. Kullanılmayan Alan (Unused Field)
* [`lib/screens/shop_screen.dart:20`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/shop_screen.dart#L20):
  * `warning - The value of the field 'cardBg' isn't used.`

### 5.2. İsimlendirme Kuralı (Non-CamelCase Identifier)
* [`lib/screens/status_screen.dart:551`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/status_screen.dart#L551):
  * `info - The variable name '_StatRow' isn't a lowerCamelCase identifier.`
  * Çözüm: `_statRow` olarak yeniden adlandırılmalıdır.

### 5.3. Kullanımdan Kalkan API'ler (Flutter Deprecations)
* [`lib/screens/setup_screen.dart:111`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/setup_screen.dart#L111):
  * `dialogBackgroundColor` deprecated. Yerine `DialogThemeData.backgroundColor` kullanılmalıdır.
* [`lib/screens/setup_screen.dart:201, 231, 239`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/setup_screen.dart#L201):
  * `DropdownButtonFormField` içindeki `value:` kullanımı deprecated. `initialValue:` kullanılmalıdır.
* [`lib/screens/setup_screen.dart`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/setup_screen.dart) (11 adet satır: 160, 162, 163, 181, 208, 240, 256, 259, 286, 311, 327):
  * `.withOpacity(x)` kullanımı deprecated. Hassasiyet kaybını önlemek için `.withValues(alpha: x)` kullanılmalıdır.

### 5.4. Bloksuz Akış Kontrolleri (Curly Braces Rule)
* [`lib/controllers/system_memory.dart`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/controllers/system_memory.dart): Satır 343, 348, 401, 408, 411, 567, 592, 671, 674.
* [`lib/screens/setup_screen.dart`](file:///c:/Users/R%C4%B1za/Desktop/%C4%B0%C5%9Fler%20Projeler/solo_app/lib/screens/setup_screen.dart): Satır 149, 150.
* Tek satırlık `if (...) statement;` ifadelerinin süslü parantez `{ ... }` içine alınması gerekmektedir.

---

## 6. Geliştirme Ortamı Hatası (Windows UTF-8 CLI LSP Crash)

* **Komut:** `flutter analyze`
* **Hata:** `FormatException: Unexpected end of input (at character 372)`
* **Kök Neden:** Proje dizini olan `c:\Users\Rıza\Desktop\İşler Projeler\solo_app` yolundaki `İ` ve `ş` Türkçe karakterleri, Flutter CLI'nin Language Server Protocol (LSP) istemcisinde JSON-RPC `Content-Length` bayt/karakter uzunluğu hesaplamasında tutarsızlığa yol açmaktadır.
* **Geçici Çözüm / Not:** Bu bir proje kaynak kodu hatası değildir. Analiz için `dart analyze lib` komutu doğrudan ve hatasız çalışmaktadır. Proje klasör yolu ASCII karakterlerle adlandırıldığında `flutter analyze` da normal çalışacaktır.
