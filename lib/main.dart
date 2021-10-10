
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'model/participant_document.dart';
import 'model/service_document.dart';
import 'screens/login-signup/login_signup.dart';
import 'screens/participant/participant_detail.dart';
import 'screens/participant/participant_form.dart';
import 'screens/participant/participant_list.dart';
import 'screens/service/service_detail.dart';
import 'screens/service/service_form.dart';
import 'screens/service/service_list.dart';
import 'screens/service/service_participant_form.dart';
import 'screens/service/service_preset.dart';
import 'service/auth_service.dart';
import 'service/service_participant_firebase.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final bool darkThemeActive = sharedPreferences.getBool('darkThemeActive') ?? true;

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier(darkThemeActive ? darkTheme : lightTheme)),
          ChangeNotifierProvider<ServiceListNotifier>(create: (_) => ServiceListNotifier()),
          ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
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
    final ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: _title,
      theme:  themeNotifier.getTheme(),
      localizationsDelegates: [
        FlutterI18nDelegate(),
   //     GlobalMaterialLocalizations.delegate,
    //    GlobalWidgetsLocalizations.delegate
      ],
      onGenerateRoute: Router.generate,
      home: FutureBuilder<User>(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.error != null) {
              return Text(snapshot.error.toString());
            }
            if(snapshot.hasData) {
              final ServiceParticipantFirebase _repository = ServiceParticipantFirebase();
              _repository.uid = snapshot.data.uid;


               return ServiceListWidget();
            }else {
              return LoginSignUpWidget();
            }
          } else {
            return LinearProgressIndicator();
          }
        },
      ),
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

  ThemeNotifier(this._themeData);

  ThemeData _themeData;

  ThemeData getTheme() => _themeData;

  Future<void> setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }
}

