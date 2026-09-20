# AI Destekli Antrenman Uygulaması — Soru & Karar Motoru Geliştirme Prompt Seti

Bu dosya, mevcut "Dinamik Antrenman & Güncelleme Motoru" handover dokümanını baz alarak
diğer agent'a **sırayla** verilecek 5 promptu içerir. Her promptu tek tek çalıştır,
çıktısını bir sonraki promptu vermeden önce bağlama ekle.

---

## Ön Not (Agent'a bağlam olarak da verilebilir)

Onboarding'de "Ortak Temel Veriler" ve "Hedefe Özel Dinamik Veriler" ayrımı korunacak:
ortak sorular tek seferde ve herkese, hedefe özel sorular kullanıcının seçtiği **tek**
hedefe göre dallanacak — 3 ayrı form oluşturulmayacak. Aynı mantık feedback sorularında
da geçerli: RIR/RPE ve eklem konforu gibi sorular hedeften bağımsız her ağırlık
antrenmanında, konuşma testi her kardiyo seansında sorulur; hedef sadece AI'nin bu
cevaplara vereceği eşik/tepkiyi değiştirir.

---

## Prompt 1 — Onboarding Soru Seti (tam metin + dallanma)

```
Ekteki handover dokümanındaki "Kullanıcı Giriş Akışı" bölümünü baz alarak,
uygulamanın onboarding ekranlarında kullanıcıya gösterilecek TAM soru
metinlerini üret. Gereksinimler:

1. Her soru için: soru metni (TR), input tipi (single-select/multi-select/
   sayısal/slider), geçerli değer aralığı, ve hangi hedefte (Kas Kazanma /
   Yağ Yakma / Fiziği Koruma) gösterileceği (Ortak / Sadece X hedefi).
2. Ortak sorular tek bir akışta, hedefe özel sorular kullanıcının seçtiği
   TEK hedefe göre conditional olarak eklensin — 3 ayrı form OLUŞTURMA.
3. Vücut ağırlığı ve (opsiyonel) vücut ölçümü/fotoğraf soruları ekle —
   bu doküman eksik bırakmış, özellikle Yağ Yakma ve Kas Kazanma
   hedeflerinde ilerlemeyi doğrulamak için gerekli.
4. Hangi baseline verilerin PERİYODİK olarak yeniden sorulacağını belirt
   (örn. 1RM/çalışma ağırlığı retest'i kaç haftada bir, vücut ağırlığı
   ne sıklıkla).
5. Çıktıyı tablo halinde ver: Soru | Tip | Hedef Kapsamı | Tekrar Sıklığı.
```

---

## Prompt 2 — Seans İçi/Sonu (Micro) ve Haftalık (Macro) Geri Bildirim Soruları

```
Handover dokümanındaki "Dinamik Güncelleme & Adaptasyon Mantığı" bölümünü
genişleterek, kullanıcıya antrenman SIRASINDA/SONRASINDA ve HAFTALIK
sorulacak TAM soru metinlerini üret. Gereksinimler:

1. Ağırlık antrenmanı seansları için: hangi soru egzersiz bazında (her
   hareketten sonra), hangisi seans sonunda bir kez sorulacak — net ayır.
   Amaç: kullanıcıyı soru yorgunluğuna sokmamak (max 1-2 soru/egzersiz,
   2-3 soru/seans sonu).
2. Kardiyo seansları için ayrı bir soru seti kur (konuşma testi, tempo/
   mesafe tamamlama oranı, eklem etkisi) — mevcut dokümanda kardiyo
   feedback sığ kalmış, derinleştir.
3. RIR/RPE sorusunu kullanıcı dostu, teknik jargonsuz TR ifadeyle yaz
   (örn. "Bu seti bitirdiğinde kaç tekrar daha yapabilirdin?").
4. Haftalık check-in'e vücut ağırlığı girişini ve (opsiyonel) ölçü/foto
   hatırlatmasını ekle.
5. Çıktı: Seans Tipi | Soru Zamanlaması (egzersiz sonu/seans sonu/
   haftalık) | Soru Metni | Toplanan Veri Alanı (JSON key önerisi).
```

---

## Prompt 3 — Karar Motoru Kurallarının Genişletilmesi

```
Handover dokümanındaki "Karar Destek Kuralları" bölümü sadece ağırlık
ilerlemesi ve deload'u kapsıyor. Bunu şu eksiklerle genişlet:

1. KARDİYO İLERLEME KURALI ekle: konuşma testi + tempo/mesafe hedefi
   sürekli kolay geçiliyorsa (örn. üst üste 2 seans) tempo/mesafe/süre
   ne kadar artırılmalı — mevcut ağırlık kuralına simetrik bir eşik seti
   kur.
2. VÜCUT AĞIRLIĞI TRENDİ ile hedef arasındaki çapraz kontrolü ekle:
   Yağ Yakma hedefinde ağırlık düşmüyorsa ama performans/RIR verileri
   iyiyse AI ne yapmalı (kardiyo/adım kotasını mı artırmalı)? Kas
   Kazanma hedefinde ağırlık artmıyorsa hacim mi artırılmalı?
3. Eklem/tendon rahatsızlığı bildirildiğinde hangi egzersiz kaç
   varyasyona kadar denenir, hâlâ ağrı varsa ne olur (kas grubunu
   tamamen programdan mı çıkar) — karar ağacı olarak yaz.
4. Mevcut deload tetikleyicisine kardiyo sinyallerini de ekle.
5. Tüm kuralları aynı pseudo-code formatında (mevcut dokümandaki gibi)
   yaz ki rule-engine'e doğrudan aktarılabilsin.
```

---

## Prompt 4 — JSON Şemasının Genişletilmesi + Uçtan Uca Senaryo Testi

```
Handover dokümanındaki JSON şemasını, Prompt 1-3'te tanımlanan yeni
veri alanlarını (kardiyo seans verisi, vücut ağırlığı logu, haftalık
check-in genişletilmiş hali) kapsayacak şekilde güncelle.

Ardından 3 farklı örnek senaryo üret (biri her hedeften):
- Kullanıcının o hafta girdiği örnek cevaplar (JSON olarak)
- Karar motorunun bu cevaplara uygulayacağı kuralları adım adım göster
- Ortaya çıkan program güncellemesinin (ağırlık/hacim/tempo değişimi)
  özetini ver

Bu senaryolar, sistemi implementasyona geçirmeden önce kural mantığının
doğru çalıştığını doğrulamak için kullanılacak.
```

---

## Prompt 5 (Opsiyonel) — Güncelleme Motorunun LLM Sistem Promptu

Yalnızca kural motorunu bir rule-engine değil de bir LLM'e yaptıracaksan kullan.

```
Prompt 1-4'te oluşturulan soru seti, karar kuralları ve JSON şemasını
kullanarak, haftalık/seans sonu kullanıcı verisini alıp güncellenmiş
antrenman programını üretecek olan LLM için TAM bir sistem promptu yaz.
Prompt şunları içermeli: rol tanımı, girdi formatı, karar kurallarının
LLM'in UYMASI GEREKEN kesin talimatlar haline getirilmiş hali, çıktı
formatı (JSON), ve kuralların dışına çıkmaması için sınırlayıcı ifadeler.
```

---

## Kullanım Notu

Her prompt çıktısını buraya (Claude'a) geri yapıştırırsan, kural mantığındaki
tutarlılığı ve boşlukları birlikte kontrol edebiliriz.
