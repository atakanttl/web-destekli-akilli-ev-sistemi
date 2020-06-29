import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // İkinci sayfada bulunan tüm değişkenler ve varsayılan ayarları
  bool lightSwitchValue = false;
  DatabaseReference _lightSwitchRef;
  StreamSubscription<Event> _lightSwitchSubscription;

  // Işığın varsayılan rengi beyaz olarak belirlendi.
  int lightColorValue = 4294967295;
  DatabaseReference _lightColorRef;
  StreamSubscription<Event> _lightColorSubscription;

  int lightBrightnessValue = 255;
  DatabaseReference _lightBrightnessRef;
  StreamSubscription<Event> _lightBrightnessSubscription;

  bool plugSwitchValue = false;
  DatabaseReference _plugSwitchRef;
  StreamSubscription<Event> _plugSwitchSubscription;

  bool doorSensorValue = false;
  DatabaseReference _doorSensorRef;
  StreamSubscription<Event> _doorSensorSubscription;

  DatabaseError _error;

  // Uygulamada görünen varsayılan renk, bu değer Firebase'den renk verisi alındığında güncelleniyor.
  Color currentColor = Colors.limeAccent;
  void changeColor(Color color) => setState(() => currentColor = color);

  int currentBrightness = 255;

  @override
  void initState() {
    super.initState();

    // Işık durumu başlangıç değerleri & abonelik
    // Firebase referans yoluyla ışık durumu referansını bağla
    _lightSwitchRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Automation/lightSwitch');
    // Işık durumu referansını Firebase referansıyla senkronize et
    _lightSwitchRef.keepSynced(true);
    // Referans değeri değiştiğinde durum (State) güncelle
    _lightSwitchSubscription = _lightSwitchRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        // Snapshot değeri null ise ışık durumu değerini sıfırla,
        // null değilse snapshot değerini ışık durumu değerine eşitle.
        lightSwitchValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      // Herhangi bir Firebase hatası durumunda error objesini güncelle.
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Işık rengi başlangıç değerleri & abonelik
    // Firebase referans yoluyla ışık renginin referansını bağla
    _lightColorRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Automation/lightColor');
    // Işık renginin referansını Firebase referansıyla senkronize et
    _lightColorRef.keepSynced(true);
    // Referans değeri değiştiğinde durum (State) güncelle
    _lightColorSubscription = _lightColorRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        // Snapshot değeri null ise ışık renginin değerini sıfırla,
        // null değilse snapshot değerini ışık renginin değerine eşitle.
        lightColorValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      // Herhangi bir Firebase hatası durumunda error objesini güncelle.
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Işık parlaklığı başlangıç değerleri & abonelik
    // Firebase referans yoluyla ışık parlaklığının referansını bağla
    _lightBrightnessRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Automation/lightBrightness');
    // Işık parlaklığının referansını Firebase referansıyla senkronize et
    _lightBrightnessRef.keepSynced(true);
    // Referans değeri değiştiğinde durum (State) güncelle
    _lightBrightnessSubscription =
        _lightBrightnessRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        // Snapshot değeri null ise ışık parlaklığının değerini sıfırla,
        // null değilse snapshot değerini ışık parlaklığının değerine eşitle.
        lightBrightnessValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      // Herhangi bir Firebase hatası durumunda error objesini güncelle.
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Akıllı priz başlangıç değerleri & abonelik
    // Firebase referans yoluyla akıllı priz referansını bağla
    _plugSwitchRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Automation/plugSwitch');
    // Akıllı priz referansını Firebase referansıyla senkronize et
    _plugSwitchRef.keepSynced(true);
    // Referans değeri değiştiğinde durum (State) güncelle
    _plugSwitchSubscription = _plugSwitchRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        // Snapshot değeri null ise akıllı priz değerini sıfırla,
        // null değilse snapshot değerini akıllı priz değerine eşitle.
        plugSwitchValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      // Herhangi bir Firebase hatası durumunda error objesini güncelle.
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Kapı sensörünün başlangıç değerleri & abonelik
    // Firebase referans yoluyla kapı sensörünün referansını bağla
    _doorSensorRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Automation/doorSensor');
    // Kapı sensörünün referansını Firebase referansıyla senkronize et
    _doorSensorRef.keepSynced(true);
    // Referans değeri değiştiğinde durum (State) güncelle
    _doorSensorSubscription = _doorSensorRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        // Snapshot değeri null ise kapı sensörünün değerini sıfırla,
        // null değilse snapshot değerini kapı sensörünün değerine eşitle.
        doorSensorValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      // Herhangi bir Firebase hatası durumunda error objesini güncelle.
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });
  }

  /*
  Switchleri tersine çevirmek için (true -> false, false -> true)
  ve verileri Firebase'e göndermek için oluşturulan fonksiyon.
  Switch değiştiğinde programın diğer işlevlerinin aksamaması için fonksiyon asenkron olarak oluşturuldu.
  */
  Future<void> _setInverse(DatabaseReference sensor) async {
    // mutableData'ya göre Transaction (işlem) yap
    final TransactionResult transactionResult =
        await sensor.runTransaction((MutableData mutableData) async {
      // mutableData değerini tersine çevir.
      mutableData.value = !(mutableData.value);
      // mutableData döndürerek Transaction'ı sonuçla, Firebase'e bu veriyi gönder
      return mutableData;
    });
  }

  /*
  Renk bilgisini Firebase'e iletmek için oluşturulan fonksiyon.
  */
  Future<void> _submitColor(DatabaseReference newColor) async {
    // mutableData'ya göre Transaction (işlem) yap
    final TransactionResult transactionResult =
        await newColor.runTransaction((MutableData mutableData) async {
      // mutableData değerini currentColor değerine göre belirle,
      // currentColor değeri changeColor fonksiyonuna göre belirleniyor.
      // Ayrıca currentColor.value, rengin integer değerini veriyor.
      mutableData.value = currentColor.value;
      // mutableData döndürerek Transaction'ı sonuçla, Firebase'e bu veriyi gönder
      return mutableData;
    });
  }

  /*
  Parlaklık bilgisini Firebase'e iletmek için oluşturulan fonksiyon.
  */
  Future<void> _submitBrightness(DatabaseReference brightnessRef) async {
    // mutableData'ya göre Transaction (işlem) yap
    final TransactionResult transactionResult =
        await brightnessRef.runTransaction((MutableData mutableData) async {
      // mutableData değerini currentBrightness değerine göre belirle,
      // currentBrightness değeri Slider'ın değerine göre değişiyor.
      mutableData.value = currentBrightness;
      // mutableData döndürerek Transaction'ı sonuçla, Firebase'e bu veriyi gönder
      return mutableData;
    });
  }

  // Oluşturulan abonelikler sayfa değiştiğinde atılır,
  // böylece hafıza sızıntısından korunulur.
  @override
  void dispose() {
    super.dispose();
    _lightSwitchSubscription.cancel();
    _lightColorSubscription.cancel();
    _lightBrightnessSubscription.cancel();
    _plugSwitchSubscription.cancel();
    _doorSensorSubscription.cancel();
  }

  /*
  Build metodu içerisinde 3 adet Card Widget'ı bulunuyor.
  Bu Cardların ilkinde ikon, durum yazısı, renk seçme butonu, ışık durum switch'i ve parlaklık slider'ı bulunuyor.
  İkincisinde ikon, durum yazısı ve akıllı priz durum switch'i bulunuyor.
  Üçüncüsünde ikon, durum yazısı ve durum ışığı bulunuyor.
  */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xfff5f5f5),
          body: Column(
            children: <Widget>[
              Card(
                color: Color(0xffb0bec5),
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xff000000),
                        size: 28,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            // Işık switch'i true ise açık, false ise kapalı bilgisi ver
                            lightSwitchValue == true
                                ? 'Işık açık'
                                : 'Işık kapalı',
                            style: TextStyle(
                              color: Color(0xff000000),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 30,
                            child: FloatingActionButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Color(0xfff5f5f5),
                                      content: SingleChildScrollView(
                                        child: SlidePicker(
                                          pickerColor: Color(lightColorValue),
                                          // Renk değiştiğinde changeColor fonksiyonunu çağır
                                          onColorChanged: changeColor,
                                          paletteType: PaletteType.rgb,
                                          enableAlpha: false,
                                          displayThumbColor: true,
                                          showLabel: false,
                                          showIndicator: true,
                                          sliderTextStyle: TextStyle(
                                              color: Color(0xff000000)),
                                          indicatorBorderRadius:
                                              const BorderRadius.vertical(
                                            top: const Radius.circular(25.0),
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        RaisedButton(
                                          child: Text('Gönder'),
                                          onPressed: () {
                                            // Gönder butonuna basıldığında Firebase'e ışık renk referansını gönder
                                            _submitColor(_lightColorRef);
                                            // Menüyü kapat
                                            Navigator.pop(context);
                                          },
                                          color: Colors.blueGrey,
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              backgroundColor: Color(lightColorValue),
                            ),
                          ),
                        ],
                      ),
                      trailing: Switch(
                        value: lightSwitchValue,
                        onChanged: (value) {
                          setState(() {
                            // Switch'e basıldığında durumu tersine çevirmek için setInverse fonksiyonunu çağır
                            _setInverse(_lightSwitchRef);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.brightness_6,
                        color: Color(0xff000000),
                        size: 28,
                      ),
                      title: Slider(
                        // Slider double değerler aldığı için önce ışık parlaklığını çeviriyoruz
                        value: lightBrightnessValue.toDouble(),
                        min: 0.0,
                        max: 255.0,
                        activeColor: Color(0xff37474f),
                        onChanged: (double newBrightness) {
                          setState(() {
                            // Mikrokontrolcü tarafında ışık parlaklığı integer olarak ayarlandığı için
                            // double olan değeri yuvarlıyoruz.
                            currentBrightness = newBrightness.round();
                            // Parlaklık değerini Firebase'e gönderiyoruz.
                            _submitBrightness(_lightBrightnessRef);
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Card(
                color: Color(0xffb0bec5),
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: ListTile(
                  leading:
                      Icon(Icons.power, color: Color(0xff000000), size: 28),
                  title: Text(
                    // Akıllı priz değeri true ise çalışıyor, false ise kapalı bilgisi yazdır.
                    plugSwitchValue == true
                        ? 'Akıllı Priz çalışıyor'
                        : 'Akıllı Priz kapalı',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Switch(
                    value: plugSwitchValue,
                    onChanged: (value) {
                      setState(() {
                        // Switch değerini tersine çevirmek için setInverse fonksiyonunu çağır.
                        _setInverse(_plugSwitchRef);
                      });
                    },
                  ),
                ),
              ),
              Card(
                color: Color(0xffb0bec5),
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: ListTile(
                  leading: Icon(
                    Icons.vpn_key,
                    color: Color(0xff000000),
                    size: 28,
                  ),
                  title: Text(
                    // Kapı değeri true ise açık, false ise kapalı bilgisini yazdır.
                    doorSensorValue == true ? 'Kapı açık' : 'Kapı kapalı',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Icon(Icons.brightness_1,
                      // İkonun rengini kapı açıksa yeşil, kapalıysa kırmızı olarak değiştir.
                      color: doorSensorValue == true
                          ? Color(0xdd2e7d32)
                          : Color(0xddc62828)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
