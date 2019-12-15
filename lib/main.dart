
import 'package:better_together_app/participantForm.dart';
import 'package:better_together_app/participantList.dart';
import 'package:better_together_app/serviceDetail.dart';
import 'package:better_together_app/serviceForm.dart';
import 'package:better_together_app/serviceList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppTheme.dart';
import 'model/ParticipantDocument.dart';
import 'model/ServiceDocument.dart';
import 'newParticipantForm.dart';



Future<Null> main() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool darkThemeActive = sharedPreferences.getBool('darkThemeActive') ?? true;
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (context) => ThemeNotifier(darkThemeActive ? darkTheme : lightTheme),
      child: BetterTogetherApp(),
    ),
  );

}




/// This Widget is the main application widget.
class BetterTogetherApp extends StatelessWidget {
  static const String _title = 'Better Together App';

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: _title,
      theme:  themeNotifier.getTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => ServiceListWidget(),
       },
      onGenerateRoute: (settings) => Router.generate(settings),
    );
  }
}


abstract class Router {
  static Route<dynamic> generate(RouteSettings settings) {
    switch(settings.name) {
      case ServiceListWidget.routeName:
        return MaterialPageRoute(builder: (context) => ServiceListWidget(), settings: settings);
      case ServiceDetailWidget.routeName:
        return MaterialPageRoute(builder: (context) => ServiceDetailWidget(), settings: settings);
      case ServiceForm.routeName:
        return MaterialPageRoute<ServiceDocument>(
            builder: (context) => ServiceForm(), settings: settings);
      case ParticipantForm.routeName:
        return MaterialPageRoute<ParticipantDocument>(
            builder: (context) => ParticipantForm(), settings: settings);
      case ParticipantListWidget.routeName:
        return MaterialPageRoute(builder: (context) => ParticipantListWidget(), settings: settings);
      case NewParticipantForm.routeName:
        return MaterialPageRoute<ParticipantDocument>(
            builder: (context) => NewParticipantForm(), settings: settings);
    }
    return null;
  }
}


class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }
}


class MainWidget extends StatefulWidget {
  MainWidget({Key key}) : super(key: key);

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[
    ServiceListWidget(),

    ParticipantListWidget(),

    Text(
      'Settings',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final topAppBar = AppBar(
      elevation: 0.2,
      title: Text('Better Together')
    );

    return Scaffold(
      appBar: topAppBar,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }
}


