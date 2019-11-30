
import 'package:better_together_app/participantForm.dart';
import 'package:better_together_app/serviceDetail.dart';
import 'package:better_together_app/serviceForm.dart';
import 'package:better_together_app/serviceList.dart';
import 'package:flutter/material.dart';

import 'model/ParticipantDocument.dart';
import 'model/ServiceDocument.dart';


void main() => runApp(BetterTogetherApp());

/// This Widget is the main application widget.
class BetterTogetherApp extends StatelessWidget {
  static const String _title = 'Better Together App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Color.fromRGBO(58, 66, 86, 1.0),
        accentColor: Colors.blue[700],

      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainWidget(),
       },
      onGenerateRoute: (settings) => Router.generate(settings),
    );
  }
}


abstract class Router {
  static Route<dynamic> generate(RouteSettings settings) {
    switch(settings.name) {
      case ServiceDetailWidget.routeName:
        return MaterialPageRoute(builder: (context) => ServiceDetailWidget(), settings: settings);
        break;
      case ServiceForm.routeName:
        return MaterialPageRoute<ServiceDocument>(
            builder: (context) => ServiceForm(), settings: settings);
        break;
      case ParticipantForm.routeName:
        return MaterialPageRoute<ParticipantDocument>(
            builder: (context) => ParticipantForm(), settings: settings);
        break;
    }
    return null;
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

    Text(
      'Participants',
      style: optionStyle,
    ),

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
      elevation: 0.1,
      title: Text('Better Together')
    );

    return Scaffold(
      appBar: topAppBar,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Services'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            title: Text('Participants'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:  Theme.of(context).accentColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
