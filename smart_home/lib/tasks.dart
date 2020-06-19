import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // Tasks Page definitions
  bool lightSwitchValue = false;
  DatabaseReference _lightSwitchRef;
  StreamSubscription<Event> _lightSwitchSubscription;

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

  Color currentColor = Colors.limeAccent;
  void changeColor(Color color) => setState(() => currentColor = color);

  int currentBrightness = 255;

  @override
  void initState() {
    super.initState();

    // Light Switch initial values & subscription
    _lightSwitchRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Automation/lightSwitch');
    _lightSwitchRef.keepSynced(true);
    _lightSwitchSubscription = _lightSwitchRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        lightSwitchValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Light Color initial values & subscription
    _lightColorRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Automation/lightColor');
    _lightColorRef.keepSynced(true);
    _lightColorSubscription = _lightColorRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        lightColorValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Light Brightness initial values & subscription
    _lightBrightnessRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Automation/lightBrightness');
    _lightBrightnessRef.keepSynced(true);
    _lightBrightnessSubscription =
        _lightBrightnessRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        lightBrightnessValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Smart Plug initial values & subscription
    _plugSwitchRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Automation/plugSwitch');
    _plugSwitchRef.keepSynced(true);
    _plugSwitchSubscription = _plugSwitchRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        plugSwitchValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });

    // Door Sensor initial values & subscription
    _doorSensorRef = FirebaseDatabase.instance
        .reference()
        .child('/SensorValues/Automation/doorSensor');
    _doorSensorRef.keepSynced(true);
    _doorSensorSubscription = _doorSensorRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        doorSensorValue = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });
  }

  Future<void> _setInverse(DatabaseReference sensor) async {
    final TransactionResult transactionResult =
        await sensor.runTransaction((MutableData mutableData) async {
      mutableData.value = !(mutableData.value);
      return mutableData;
    });
  }

  Future<void> _submitColor(DatabaseReference newColor) async {
    final TransactionResult transactionResult =
        await newColor.runTransaction((MutableData mutableData) async {
      mutableData.value = currentColor.value;
      return mutableData;
    });
  }

  Future<void> _submitBrightness(DatabaseReference brightnessRef) async {
    final TransactionResult transactionResult =
        await brightnessRef.runTransaction((MutableData mutableData) async {
      mutableData.value = currentBrightness;
      return mutableData;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _lightSwitchSubscription.cancel();
    _lightColorSubscription.cancel();
    _lightBrightnessSubscription.cancel();
    _plugSwitchSubscription.cancel();
    _doorSensorSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xff212121),
          body: Column(
            children: <Widget>[
              Card(
                color: Color(0xdd37474f),
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            lightSwitchValue == true
                                ? 'Işık açık'
                                : 'Işık kapalı',
                            style: TextStyle(
                              color: Colors.white,
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
                                      backgroundColor: Color(0xff212121),
                                      content: SingleChildScrollView(
                                        child: SlidePicker(
                                          pickerColor: Color(lightColorValue),
                                          onColorChanged: changeColor,
                                          paletteType: PaletteType.rgb,
                                          enableAlpha: false,
                                          displayThumbColor: true,
                                          showLabel: false,
                                          showIndicator: true,
                                          sliderTextStyle:
                                              TextStyle(color: Colors.white),
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
                                            _submitColor(_lightColorRef);
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
                            _setInverse(_lightSwitchRef);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.brightness_6,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: Slider(
                        value: lightBrightnessValue.toDouble(),
                        min: 0.0,
                        max: 255.0,
                        activeColor: Colors.blueGrey,
                        //inactiveColor: Colors.black54,
                        //label: 'Change brightness',
                        onChanged: (double newBrightness) {
                          setState(() {
                            currentBrightness = newBrightness.round();
                            _submitBrightness(_lightBrightnessRef);
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              Card(
                color: Color(0xdd37474f),
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: ListTile(
                  leading: Icon(Icons.power, color: Colors.white, size: 28),
                  title: Text(
                    plugSwitchValue == true
                        ? 'Akıllı Priz çalışıyor'
                        : 'Akıllı Priz kapalı',
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 2,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Switch(
                    value: plugSwitchValue,
                    onChanged: (value) {
                      setState(() {
                        _setInverse(_plugSwitchRef);
                      });
                    },
                  ),
                ),
              ),
              Card(
                color: Color(0xdd37474f),
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                child: ListTile(
                  leading: Icon(
                    Icons.vpn_key,
                    color: Colors.white,
                    size: 28,
                  ),
                  title: Text(
                    doorSensorValue == true ? 'Kapı açık' : 'Kapı kapalı',
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 2,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Icon(Icons.brightness_1,
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
