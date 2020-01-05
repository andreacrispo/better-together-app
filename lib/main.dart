
import 'package:better_together_app/screens/participant/participant_detail.dart';
import 'package:better_together_app/screens/participant/participant_form.dart';
import 'package:better_together_app/screens/participant/participant_list.dart';
import 'package:better_together_app/screens/service/service_detail.dart';
import 'package:better_together_app/screens/service/service_form.dart';
import 'package:better_together_app/screens/service/service_list.dart';
import 'package:better_together_app/screens/service/service_participant_form.dart';
import 'package:better_together_app/screens/service/service_preset.dart';
import 'package:better_together_app/service/service_participant_firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'model/ParticipantDocument.dart';
import 'model/ServiceDocument.dart';



Future<Null> main() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool darkThemeActive = sharedPreferences.getBool('darkThemeActive') ?? true;

  // TODO: Add option to signin with email
  final FirebaseAuth auth = FirebaseAuth.instance;
  await auth.signInAnonymously();
  var user = await auth.currentUser();
  print("USerID"); print(user.uid);
  final ServiceParticipantFirebase _repository = ServiceParticipantFirebase();
  _repository.uid = user.uid;

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
        '/': (context) => ServiceListWidget()
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
      case ServicePreset.routeName:
        return MaterialPageRoute(
            builder: (context) => ServicePreset(), settings: settings);
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

