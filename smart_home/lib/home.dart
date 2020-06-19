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
  FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin; // Notification plugin definition

  // Sensor Page definitions
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
    // Local Notification initialization
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('app_icon');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings);

    // Temperature initial values & subscription
    _temperatureRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Stream/tempValue');
    _temperatureRef.keepSynced(true);
    _temperatureSubscription = _temperatureRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        temperatureValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Gas initial values & subscription
    _gasRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Stream/gasValue');
    _gasRef.keepSynced(true);
    _gasSubscription = _gasRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        gasValue = event.snapshot.value ?? 0;
        if (gasValue > 1600) showNotification('Gaz', 0); // Sends notification
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Flame initial values & subscription
    _flameRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Stream/flameValue');
    _flameRef.keepSynced(true);
    _flameSubscription = _flameRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        flameValue = event.snapshot.value ?? 0;
        if (flameValue < 1000)
          showNotification('Alev', 1); // Sends notification
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Humidity initial values & subscription
    _humidityRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Stream/humidityValue');
    _humidityRef.keepSynced(true);
    _humiditySubscription = _humidityRef.onValue.listen((Event event) {
      setState(() {
        _error = _error;
        humidityValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });
  }

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

  @override
  void dispose() {
    super.dispose();
    _temperatureSubscription.cancel();
    _gasSubscription.cancel();
    _flameSubscription.cancel();
    _humiditySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: SafeArea(
        child: Scaffold(
            backgroundColor: Color(0xff212121),
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
                                letterSpacing: 2,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Text(
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
                                letterSpacing: 2,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Text(
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
