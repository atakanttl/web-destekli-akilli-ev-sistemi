import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Lokal bildirimler için obje oluşturuldu
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // Ana sayfada yer alan tüm değişkenler
  int temperatureValue = 0;
  DatabaseReference _temperatureRef;
  StreamSubscription<Event> _temperatureSubscription;
  int gasValue = 0;
  DatabaseReference _gasRef;
  StreamSubscription<Event> _gasSubscription;
  int flameValue = 4096;
  DatabaseReference _flameRef;
  StreamSubscription<Event> _flameSubscription;
  int humidityValue = 0;
  DatabaseReference _humidityRef;
  StreamSubscription<Event> _humiditySubscription;
  DatabaseError _error;

  @override
  void initState() {
    super.initState();
    // Lokal bildirimlerin başlatılması
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // Android ve iOS yapılandırılması (iOS kullanılmıyor fakat initialization içinde bulunması zorunlu)
    var android = AndroidInitializationSettings('app_icon');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings);

    // Sıcaklık başlangıç değerleri & abonelik
    // Firebase referans yoluyla sıcaklık referansını bağla
    _temperatureRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Stream/tempValue');
    // Sıcaklık referansını Firebase referansıyla senkronize et
    _temperatureRef.keepSynced(true);
    // Referans değeri değiştiğinde durum (State) güncelle
    _temperatureSubscription = _temperatureRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        // Snapshot değeri null ise sıcaklık değerini sıfırla,
        // null değilse snapshot değerini sıcaklık değerine eşitle.
        temperatureValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      // Herhangi bir Firebase hatası durumunda error objesini güncelle.
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Gaz başlangıç değerleri & abonelik
    // Firebase referans yoluyla gaz referansını bağla
    _gasRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Stream/gasValue');
    // Gaz referansını Firebase referansıyla senkronize et
    _gasRef.keepSynced(true);
    // Referans değeri değiştiğinde durum (State) güncelle
    _gasSubscription = _gasRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        // Snapshot değeri null ise gaz değerini sıfırla,
        // null değilse snapshot değerini gaz değerine eşitle.
        gasValue = event.snapshot.value ?? 0;
        // Gaz değeri 1600'ün üzerindeyse bildirim gönder
        if (gasValue > 1600) showNotification('Gaz', 0);
      });
    }, onError: (Object o) {
      // Herhangi bir Firebase hatası durumunda error objesini güncelle.
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Alev başlangıç değerleri & abonelik
    // Firebase referans yoluyla alev referansını bağla
    _flameRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Stream/flameValue');
    // Alev referansını Firebase referansıyla senkronize et
    _flameRef.keepSynced(true);
    // Referans değeri değiştiğinde durum (State) güncelle
    _flameSubscription = _flameRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        // Snapshot değeri null ise alev değerini sıfırla,
        // null değilse snapshot değerini alev değerine eşitle.
        flameValue = event.snapshot.value ?? 0;
        // Alev değeri 1000'in altındaysa bildirim gönder
        if (flameValue < 1000)
          showNotification('Alev', 1); // Sends notification
      });
    }, onError: (Object o) {
      // Herhangi bir Firebase hatası durumunda error objesini güncelle.
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Nem başlangıç değerleri & abonelik
    // Firebase referans yoluyla nem referansını bağla
    _humidityRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Stream/humidityValue');
    // Nem referansını Firebase referansıyla senkronize et
    _humidityRef.keepSynced(true);
    // Referans değeri değiştiğinde durum (State) güncelle
    _humiditySubscription = _humidityRef.onValue.listen((Event event) {
      setState(() {
        _error = _error;
        // Snapshot değeri null ise gaz değerini sıfırla,
        // null değilse snapshot değerini gaz değerine eşitle.
        humidityValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      // Herhangi bir Firebase hatası durumunda error objesini güncelle.
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });
  }

  // Belirlenen sensöre göre bildirim ayarla
  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Notification'),
        content: Text('$payload'),
      ),
    );
  }

  /*
  Belirlenen sensöre göre ('Gaz') veya ('Alev') uyarı oluştur,
  ID'leri birbirinden farklı olursa hepsi aynı anda görülebilir.
  Asenkron fonksiyon olduğu için program akışına müdahale etmez.
  */
  showNotification(String warningSensor, int id) async {
    var android = AndroidNotificationDetails(
        'channel id', 'Sensor notifications', 'CHANNEL DESCRIPTION',
        priority: Priority.High,
        importance: Importance.Max,
        onlyAlertOnce: true);
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        id, 'UYARI', '$warningSensor değeri normal değil', platform,
        payload: '');
  }

  // Oluşturulan abonelikler sayfa değiştiğinde atılır,
  // böylece hafıza sızıntısından korunulur.
  @override
  void dispose() {
    super.dispose();
    _temperatureSubscription.cancel();
    _gasSubscription.cancel();
    _flameSubscription.cancel();
    _humiditySubscription.cancel();
  }

  /*
  Build metodu içinde 4 adet Grid oluşturuldu,
  İkonlar, sensör değerleri ve basit mantık işlemleri yapıldı.
  */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: SafeArea(
        child: Scaffold(
            backgroundColor: Color(0xfff5f5f5),
            body: GridView.count(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              crossAxisCount: 2,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xddba68c8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          BoxedIcon(
                            WeatherIcons.hot,
                            color: Colors.white,
                            size: 28,
                          ),
                          Text(
                            'Sıcaklık',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Text(
                        '$temperatureValue \u2103',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(0xdd4dd0e1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          BoxedIcon(
                            WeatherIcons.barometer,
                            color: Colors.white,
                            size: 28,
                          ),
                          Text(
                            'Gaz',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Text(
                        // Gaz değeri 1600'ün altındaysa normal olduğunu belirt,
                        // değilse anormal durumu belirt.
                        gasValue < 1600 ? 'Normal' : 'Gaz kaçağı olabilir',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$gasValue ppm',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(0xddef5350)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          BoxedIcon(
                            WeatherIcons.fire,
                            color: Colors.white,
                            size: 28,
                          ),
                          Text(
                            'Alev',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Text(
                        // Alev değeri 1000'in altındaysa anormal durumu belirt,
                        // değilse normal durumu belirt.
                        flameValue < 1000 ? 'ALEV ALGILANDI' : 'Normal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(0xdd009688)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          BoxedIcon(
                            WeatherIcons.humidity,
                            color: Colors.white,
                            size: 28,
                          ),
                          Text(
                            'Nem',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Text(
                        '$humidityValue%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
