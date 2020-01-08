
import 'package:better_together_app/app_theme.dart';
import 'package:better_together_app/main.dart';
import 'package:better_together_app/screens/participant/participant_list.dart';
import 'package:better_together_app/screens/service/service_list.dart';
import 'package:better_together_app/service/auth_service.dart';
import 'package:better_together_app/utils/custom_route_animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BTBottomAppBarWidget extends StatelessWidget {
  const BTBottomAppBarWidget({
    this.target
  });

  final String target;


  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 5,
      shape: const CircularNotchedRectangle(),
      child: Row(children: <Widget>[
        IconButton(
            iconSize: 36,
            icon: const Icon(Icons.home, semanticLabel: 'Show service list'),
            onPressed: () => _changeRoute(context, ServiceListWidget.routeName, ServiceListWidget())
        ),
        IconButton(
            iconSize: 36,
            icon: const Icon(Icons.supervised_user_circle, semanticLabel: 'Show participants list'),
            onPressed: () => _changeRoute(context,ParticipantListWidget.routeName, ParticipantListWidget())
        ),
        const Expanded(child: SizedBox()),
        /*
        IconButton(
          icon: Icon(Icons.filter_list),
        ),
        */
        this.target == ServiceListWidget.routeName
          ?  IconButton(
              icon: Icon(Icons.sort),
              onPressed: () => _showSortByBottomSheet(context)
            )
          : null,

        IconButton(
            iconSize: 36,
            icon: Icon(Icons.more_vert),
            onPressed: () => _showMoreMenu(context)
        ),
      ].where((w) => w != null).toList()),
    );
  }

  _changeRoute(context, newRouteName, newWidget) {
    bool isNewRouteSameAsCurrent = false;

    Navigator.popUntil(context, (route) {
      if (route.settings.name == newRouteName) {
        isNewRouteSameAsCurrent = true;
      }
      return true;
    });

    if (!isNewRouteSameAsCurrent) {

      Navigator.pushReplacement(
        context,
        CustomRouteFadeAnimation(
            builder: (context) => newWidget
        ),
      );
    }
  }

  void _showSortByBottomSheet(context) {
    final serviceProvider = Provider.of<ServiceListNotifier>(context);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    title: Text('Name'),
                    onTap: () { serviceProvider.setSortByVariable("name", false); Navigator.pop(context); }
                ),
                ListTile(
                  title: Text('Price'),
                  onTap: () { serviceProvider.setSortByVariable("price", false); Navigator.pop(context); }
                ),
                ListTile(
                  title: Text('Number of participants'),
                  onTap: () { serviceProvider.setSortByVariable("participantNumber", false); Navigator.pop(context); }
                )
              ],
            ),
          );
        }
    );
  }

  _showMoreMenu(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    bool isDarkThemeActive = prefs.getBool('darkThemeActive') ?? true;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final authUser = await Provider.of<AuthService>(context).getUser();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.opacity),
                    title: Text(isDarkThemeActive ? 'Enable light mode' : 'Enable dark mode'),
                    onTap: ()  {
                      if(isDarkThemeActive) {
                        themeNotifier.setTheme(lightTheme);
                        prefs.setBool('darkThemeActive', false);
                      }else {
                        themeNotifier.setTheme(darkTheme);
                        prefs.setBool('darkThemeActive', true);
                      }
                      Navigator.pop(context);
                    }
                ),
                _logOut(context, authUser?.isAnonymous)
              ],
            ),
          );
        }
    );
  }

  _logOut(context, isAnonymous){
    if(isAnonymous) return Container();

    return  ListTile(
        leading: Icon(Icons.lock_open),
        title: Text("Logout"),
        onTap: ()  {
          Provider.of<AuthService>(context).logout();
          Navigator.pop(context);
        }
    );
  }

}

