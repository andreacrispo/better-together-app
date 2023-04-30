
import 'package:better_together_app/screens/service/service_detail.dart';
import 'package:better_together_app/screens/service/service_participant_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../main.dart';
import '../service/auth_service.dart';
import '../utils/utils.dart';



class BottomBarServiceDetail extends StatelessWidget {
  const BottomBarServiceDetail({
    this.target,
    this.serviceDetailArgs
  });

  final String target;
  final ServiceDetailArgs serviceDetailArgs;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 5,
      shape: const CircularNotchedRectangle(),
      child: Row(children: <Widget>[
        IconButton(
            color: target == ServiceDetailWidget.routeName ? Theme.of(context).accentColor : Colors.white,
            iconSize: 36,
            icon: const Icon(Icons.featured_play_list_outlined, semanticLabel: 'Show service list'),
            onPressed: () => _changeRoute(context, ServiceDetailWidget.routeName, ServiceDetailWidget())
        ),
        IconButton(
            color: target == ServiceParticipantListWidget.routeName ? Theme.of(context).accentColor : Colors.white,
            iconSize: 36,
            icon: const Icon(Icons.supervised_user_circle, semanticLabel: 'Show participants list'),
            onPressed: () => _changeRoute(context,ServiceParticipantListWidget.routeName, ServiceParticipantListWidget())
        ),
        const Expanded(child: SizedBox()),
        IconButton(
            iconSize: 36,
            icon: Icon(Icons.more_vert),
            onPressed: () => _showMoreMenu(context)
        ),
      ].where((w) => w != null).toList()),
    );
  }

  void _changeRoute(context, newRouteName, newWidget) {
    bool isNewRouteSameAsCurrent = false;

    Navigator.popUntil(context, (route) {
      if (route.settings.name == newRouteName) {
        isNewRouteSameAsCurrent = true;
      }
      return true;
    });

    if (!isNewRouteSameAsCurrent) {

      Navigator.pushReplacementNamed(
          context,
          newRouteName,
          arguments: this.serviceDetailArgs
      );

    }
  }



  void _showMoreMenu(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final bool isDarkThemeActive = prefs.getBool('darkThemeActive') ?? true;
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final authUser = await Provider.of<AuthService>(context, listen: false).getUser();
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.opacity),
                  title: Text(isDarkThemeActive ? i18n(bc, "enable_light_theme") : i18n(bc, "enable_dark_theme")),
                  onTap: ()  {
                    if(isDarkThemeActive) {
                      themeNotifier.setTheme(lightTheme);
                      prefs.setBool('darkThemeActive', false);
                    }else {
                      themeNotifier.setTheme(darkTheme);
                      prefs.setBool('darkThemeActive', true);
                    }
                    Navigator.pop(bc);
                  }
              ),
              _logOut(bc, authUser?.isAnonymous)
            ],
          );
        }
    );
  }

  Widget _logOut(context, isAnonymous) {
    // TODO: FIXME Uncomment before prod
    if(isAnonymous && kReleaseMode)
      return Container();

    return  ListTile(
        leading: Icon(Icons.lock_open),
        title: Text("Logout"),
        onTap: ()  async {
          await  Provider.of<AuthService>(context, listen: false).logout();
          await Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        }
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('target', target));
    properties.add(DiagnosticsProperty<ServiceDetailArgs>('serviceDetailArgs', serviceDetailArgs));
  }

}
