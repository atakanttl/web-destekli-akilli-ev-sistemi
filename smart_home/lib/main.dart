import 'package:flutter/material.dart';
import 'tasks.dart';
import 'home.dart';

void main() => runApp(SmartHomeApp());

class SmartHomeApp extends StatefulWidget {
  // Başlatıcı boilerplate kodları
  const SmartHomeApp({Key key}) : super(key: key);
  @override
  _SmartHomeAppState createState() => _SmartHomeAppState();
}

// Sekme kontrolcüsü TickerProvider gerektirdiği için SingleTickerProviderStateMixin kullanıldı
class _SmartHomeAppState extends State<SmartHomeApp>
    with SingleTickerProviderStateMixin {
  // Sekme kontrolü için oluşturulan obje
  TabController _tabController;
  // İki sayfanın yönlendirilmesi
  final _kTabPages = [
    HomePage(),
    TasksPage(),
  ];
  // Oluşturulan sekmelerin ikon, renk ve isimleri
  static const _kTabs = <Tab>[
    Tab(
      icon: Icon(
        Icons.data_usage,
        color: Color(0xff000000),
      ),
      child: Text(
        'Sensörler',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xff000000),
        ),
      ),
    ),
    Tab(
      icon: Icon(
        Icons.dashboard,
        color: Color(0xff000000),
      ),
      child: Text(
        'Görevler',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xff000000),
        ),
      ),
    ),
  ];

  @override
  void initState() {
    // Metot override edilirken mutlaka super.metot() yazılmalı
    super.initState();
    // Sayfa sayısına göre sekme eklenip TickerProvider içeren classımız vsynce eklendi
    _tabController = TabController(length: _kTabPages.length, vsync: this);
  }

  // Hafıza sızıntısı oluşmaması için dispose metodu yeniden yazılıp sekme kontrolcüsü eklendi
  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  /*
  Build metodu içinde AppBar, Gövde (TabBarView) ve Sekmeler (bottomNavigationBar) bulunuyor.
  Gövdenin içinde sayfaların yönlendirildiği obje (_kTabPages) ve bunu yöneten kontrolcü bulunuyor.
  */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xfff5f5f5),
          appBar: AppBar(
            title: Text(
              'Akıllı Evim',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff000000),
              ),
            ),
            centerTitle: true,
            backgroundColor: Color(0xfff5f5f5),
            elevation: 0,
          ),
          body: TabBarView(
            children: _kTabPages,
            controller: _tabController,
          ),
          bottomNavigationBar: Material(
            color: Color(0xffb0bec5),
            child: TabBar(
              tabs: _kTabs,
              controller: _tabController,
            ),
          ),
        ),
      ),
    );
  }
}
