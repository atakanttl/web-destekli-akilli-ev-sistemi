import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'sensors.dart';

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // İkinci sayfada bulunan tüm değişkenler ve varsayılan ayarları
  static const int whiteColor = 0xffffffff;
  static const int maxBrightness = 0xff;
  Sensors lightSwitch = Sensors(false);
  Sensors lightColor = Sensors(whiteColor);
  Sensors lightBrightness = Sensors(maxBrightness);
  Sensors plugSwitch = Sensors(false);
  Sensors door = Sensors(false);

  // Uygulamada görünen varsayılan renk, bu değer Firebase'den renk verisi alındığında güncelleniyor.
  Color currentColor = Color(whiteColor);
  void changeColor(Color color) => setState(() => currentColor = color);

  int currentBrightness = maxBrightness;

  @override
  void initState() {
    super.initState();

    // Sensör aboneliklerinin başlatılması
    lightSwitch.initSensor('/SensorValues/Automation/lightSwitch');
    lightSwitch.subscription = lightSwitch.ref.onValue.listen((event) {
      setState(() {
        lightSwitch.linkValue(event);
      });
    }, onError: (Object o) {
      setState(() {
        lightSwitch.error = o;
      });
    });
    lightColor.initSensor('/SensorValues/Automation/lightColor');
    lightColor.subscription = lightColor.ref.onValue.listen((event) {
      setState(() {
        lightColor.linkValue(event);
      });
    }, onError: (Object o) {
      setState(() {
        lightColor.error = o;
      });
    });
    lightBrightness.initSensor('/SensorValues/Automation/lightBrightness');
    lightBrightness.subscription = lightBrightness.ref.onValue.listen((event) {
      setState(() {
        lightBrightness.linkValue(event);
      });
    }, onError: (Object o) {
      lightBrightness.error = o;
    });
    plugSwitch.initSensor('/SensorValues/Automation/plugSwitch');
    plugSwitch.subscription = plugSwitch.ref.onValue.listen((event) {
      setState(() {
        plugSwitch.linkValue(event);
      });
    }, onError: (Object o) {
      plugSwitch.error = o;
    });
    door.initSensor('/SensorValues/Automation/doorSensor');
    door.subscription = door.ref.onValue.listen((event) {
      setState(() {
        door.linkValue(event);
      });
    }, onError: (Object o) {
      door.error = o;
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
    lightSwitch.subscription.cancel();
    lightColor.subscription.cancel();
    lightBrightness.subscription.cancel();
    plugSwitch.subscription.cancel();
    door.subscription.cancel();
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
                            lightSwitch.value == true
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
                                          pickerColor: Color(lightColor.value),
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
                                            _submitColor(lightColor.ref);
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
                              backgroundColor: Color(lightColor.value),
                            ),
                          ),
                        ],
                      ),
                      trailing: Switch(
                        value: lightSwitch.value,
                        onChanged: (value) {
                          setState(() {
                            // Switch'e basıldığında durumu tersine çevirmek için setInverse fonksiyonunu çağır
                            _setInverse(lightSwitch.ref);
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
                        value: lightBrightness.value.toDouble(),
                        min: 0.0,
                        max: 255.0,
                        activeColor: Color(0xff37474f),
                        onChanged: (double newBrightness) {
                          setState(() {
                            // Mikrokontrolcü tarafında ışık parlaklığı integer olarak ayarlandığı için
                            // double olan değeri yuvarlıyoruz.
                            currentBrightness = newBrightness.round();
                            // Parlaklık değerini Firebase'e gönderiyoruz.
                            _submitBrightness(lightBrightness.ref);
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
                    plugSwitch.value == true
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
                    value: plugSwitch.value,
                    onChanged: (value) {
                      setState(() {
                        // Switch değerini tersine çevirmek için setInverse fonksiyonunu çağır.
                        _setInverse(plugSwitch.ref);
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
                    door.value == true ? 'Kapı açık' : 'Kapı kapalı',
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Icon(Icons.brightness_1,
                      // İkonun rengini kapı açıksa yeşil, kapalıysa kırmızı olarak değiştir.
                      color: door.value == true
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
