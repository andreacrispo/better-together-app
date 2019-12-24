
import 'package:better_together_app/ParticipantDetail.dart';
import 'package:better_together_app/ServiceParticipantForm.dart';
import 'package:better_together_app/participantList.dart';
import 'package:better_together_app/serviceDetail.dart';
import 'package:better_together_app/serviceForm.dart';
import 'package:better_together_app/serviceList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppTheme.dart';
import 'ParticipantForm.dart';
import 'model/ParticipantDocument.dart';
import 'model/ServiceDocument.dart';



Future<Null> main() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool darkThemeActive = sharedPreferences.getBool('darkThemeActive') ?? true;
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier(darkThemeActive ? darkTheme : lightTheme)),
          ChangeNotifierProvider<ServiceListNotifier>(create: (_) => ServiceListNotifier()),
        ],
        child: BetterTogetherApp()
      )
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
      case ServiceParticipantForm.routeName:
        return MaterialPageRoute<dynamic>(
            builder: (context) => ServiceParticipantForm(), settings: settings);
      case ParticipantListWidget.routeName:
        return MaterialPageRoute(builder: (context) => ParticipantListWidget(), settings: settings);
      case ParticipantDetailWidget.routeName:
        return MaterialPageRoute(builder: (context) => ParticipantDetailWidget(), settings: settings);
      case ParticipantForm.routeName:
        return MaterialPageRoute<ParticipantDocument>(
            builder: (context) => ParticipantForm(), settings: settings);
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

