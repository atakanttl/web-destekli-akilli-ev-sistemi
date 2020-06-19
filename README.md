# Web Destekli Akıllı Ev Sistemi

Bu projenin genel kapsamı şu şekildedir; veri tabanına sensörlerden aldığı veriyi aktaran birden fazla mikrodenetleyici ve veri tabanından veri alan ve veri tabanına veri gönderen bir mobil uygulama arayüzü. Mikrodenetleyiciler, üzerlerinde bulunan sensörler aracılığı ile ortam verilerini toplayarak veri tabanına aktarmakta, aynı zamanda mobil uygulamadan veri tabanına gönderilen bilgiler doğrultusunda otomasyon işlemi de yapmaktadır. Veri tabanına aktarılan veriler kullanıcıya mobil uygulama arayüzü ile sunulmaktadır. Bu verilerden herhangi birinin sahip olduğu değer, normal aralıkların dışındaysa kullanıcı bu durum hakkında mobil uygulama bildirimleri aracılığıyla bilgilendirilir.

Gerçekleştirilen projeyi yeniden elde etmek için gereken 4 adım şu şekildedir:

# 1. Birinci ESP32 (Sensörler)

![Birinci ESP32 Şematiği](https://i.imgur.com/y1jjjYX.png)

# 2. İkinci ESP32 (Otomasyon)

![İkinci ESP32 Şematiği](https://i.imgur.com/DhstRXS.png)

# 3. Firebase

Proje Firebase Realtime Database ile oluşturulmuştur. Veri ağacı şu şekildedir:

![Firebase veri ağacı](https://i.imgur.com/Nkz5cSt.png)

# 4. Flutter (smart-home)

Flutter projesini düzgün bir biçimde build edebilmek için kendi oluşturduğunuz Firebase projesine mobil uygulama ekleyip "google-services.json" dosyasını Flutter projesinin /android/app klasörüne koymanız gerekmekte ve "pubspec.yaml" dosyasındaki dependency'leri doğrulamanız gerekmektedir.

![Uygulama ekran görüntüsü](https://i.imgur.com/3G8cy5T.png)
