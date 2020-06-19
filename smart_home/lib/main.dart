import 'package:flutter/material.dart';
import 'tasks.dart';
import 'home.dart';

void main() => runApp(SmartHomeApp());

class SmartHomeApp extends StatefulWidget {
  const SmartHomeApp({Key key}) : super(key: key);
  @override
  _SmartHomeAppState createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends State<SmartHomeApp>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  final _kTabPages = [
    HomePage(),
    TasksPage(),
  ];
  static const _kTabs = <Tab>[
    Tab(
      icon: Icon(Icons.data_usage),
      child: Text(
        'Sensörler',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    Tab(
      icon: Icon(Icons.dashboard),
      child: Text(
        'Görevler',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _kTabPages.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            title: Text(
              'Akıllı Evim',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.grey[850],
            elevation: 0,
          ),
          body: TabBarView(
            children: _kTabPages,
            controller: _tabController,
          ),
          bottomNavigationBar: Material(
            color: Color(0xdd263238),
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
