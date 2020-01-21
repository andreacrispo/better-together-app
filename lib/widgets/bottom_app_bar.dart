
import 'package:better_together_app/app_theme.dart';
import 'package:better_together_app/main.dart';
import 'package:better_together_app/screens/participant/participant_list.dart';
import 'package:better_together_app/screens/service/service_list.dart';
import 'package:better_together_app/service/auth_service.dart';
import 'package:better_together_app/utils/custom_route_animation.dart';
import 'package:better_together_app/utils/utils.dart';
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
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                _listTileSort(context: context, title: "name", variableToSort: "name"),
                _listTileSort(context: context, title: "price", variableToSort: "price"),
                _listTileSort(context: context, title: "number_of_participants", variableToSort: "participantNumber"),
              ],
            ),
          );
        }
    );
  }

  ListTile _listTileSort({BuildContext context, String title, String variableToSort}) {
    final ServiceListNotifier serviceProvider = Provider.of<ServiceListNotifier>(context);

    return ListTile(
      title: Text( i18n(context, title)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon:  Icon(Icons.keyboard_arrow_up ),
            onPressed: () { serviceProvider.setSortByVariable(variableToSort, false); Navigator.pop(context); },
          ),
          IconButton(
            icon:   Icon(Icons.keyboard_arrow_down),
            onPressed: () { serviceProvider.setSortByVariable(variableToSort, true); Navigator.pop(context); },
          ),
        ],
      ),
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
                    title: Text(isDarkThemeActive ? i18n(context, "enable_light_theme") : i18n(context, "enable_dark_theme")),
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
                /*
                ListTile(
                  leading: Icon(Icons.adb),
                  title: Text("Currency"),
                  onTap: () {
                    _currenciesBottomSheet(context);
                  },
                ),
                */
                _logOut(context, authUser?.isAnonymous)
              ],
            ),
          );
        }
    );
  }


  _currenciesBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildCtx) {
          return ListView.builder(
            padding: EdgeInsets.all(2),
            shrinkWrap: true,
            itemCount: currenciesMap.length,
            itemBuilder: (BuildContext context, int index) {
               String key = currenciesMap.keys.elementAt(index);
               String currencyName = currenciesMap[key][1];
              return  Column(
                children: <Widget>[
                  ListTile(
                    title:  Text(currencyName),
                  ),
                  Divider(height: 2.0,),
                ],
              );
            },
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

