import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'sensors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Lokal bildirimler için obje oluşturuldu
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // Ana sayfada yer alan tüm değişkenler
  Sensors temperature = Sensors(0);
  Sensors gas = Sensors(0);
  Sensors flame = Sensors(4096);
  Sensors humidity = Sensors(0);

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

    // Sensör aboneliklerinin başlatılması
    temperature.initSensor('/SensorValues/Stream/tempValue');
    temperature.subscription = temperature.ref.onValue.listen((event) {
      setState(() {
        temperature.linkValue(event);
      });
    }, onError: (Object o) {
      setState(() {
        temperature.error = o;
      });
    });
    gas.initSensor('/SensorValues/Stream/gasValue');
    gas.subscription = gas.ref.onValue.listen((event) {
      setState(() {
        gas.linkValue(event);
        if (gas.value > 1600) showNotification('Gaz', 0);
      });
    }, onError: (Object o) {
      setState(() {
        gas.error = o;
      });
    });

    flame.initSensor('/SensorValues/Stream/flameValue');
    flame.subscription = flame.ref.onValue.listen((event) {
      setState(() {
        flame.linkValue(event);
        if (flame.value < 1000) showNotification('Alev', 1);
      });
    }, onError: (Object o) {
      setState(() {
        flame.error = o;
      });
    });

    humidity.initSensor('/SensorValues/Stream/humidityValue');
    humidity.subscription = humidity.ref.onValue.listen((event) {
      setState(() {
        humidity.linkValue(event);
      });
    }, onError: (Object o) {
      setState(() {
        humidity.error = o;
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
    temperature.subscription.cancel();
    gas.subscription.cancel();
    flame.subscription.cancel();
    humidity.subscription.cancel();
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
                        temperature.value.toString() + '\u2103',
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
                        gas.value < 1600 ? 'Normal' : 'Gaz kaçağı olabilir',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        gas.value.toString() + ' ppm',
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
                        flame.value < 1000 ? 'ALEV ALGILANDI' : 'Normal',
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
                        humidity.value.toString() + '%',
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
