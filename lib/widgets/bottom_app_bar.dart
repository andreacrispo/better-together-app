
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../main.dart';
import '../screens/participant/participant_list.dart';
import '../screens/service/service_list.dart';
import '../service/auth_service.dart';
import '../utils/custom_route_animation.dart';
import '../utils/utils.dart';



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
        /*
        IconButton(
            color: target == ServiceListWidget.routeName ? Theme.of(context).accentColor : Colors.white,
            iconSize: 36,
            icon: const Icon(Icons.featured_play_list_outlined, semanticLabel: 'Show service list'),
            onPressed: () => _changeRoute(context, ServiceListWidget.routeName, ServiceListWidget())
        ),

        IconButton(
            color: target == ParticipantListWidget.routeName ? Theme.of(context).accentColor : Colors.white,
            iconSize: 36,
            icon: const Icon(Icons.supervised_user_circle, semanticLabel: 'Show participants list'),
            onPressed: () => _changeRoute(context,ParticipantListWidget.routeName, ParticipantListWidget())
        ),
        */

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
            iconSize: 30,
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
        builder: (BuildContext bc) {
          return Wrap(
            children: <Widget>[
              ListTileVariableSort(title: "name", variableToSort: "name",),
              ListTileVariableSort(title: "price", variableToSort: "price",),
              ListTileVariableSort(title: "number_of_participants", variableToSort: "participantNumber",),
            ],
          );
        }
    );
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
              /*
              ListTile(
                leading: Icon(Icons.adb),
                title: Text("Currency"),
                onTap: () {
                  _currenciesBottomSheet(context);
                },
              ),
              */
              _logOut(bc, authUser?.isAnonymous)
            ],
          );
        }
    );
  }


  void _currenciesBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildCtx) {
          return ListView.builder(
            padding: EdgeInsets.all(2),
            shrinkWrap: true,
            itemCount: currenciesMap.length,
            itemBuilder: (BuildContext context, int index) {
              final String key = currenciesMap.keys.elementAt(index);
              return  Column(
                children: <Widget>[
                  ListTile(
                    title:  Text(getCurrencyDescription(key)),
                  ),
                  Divider(height: 2.0,),
                ],
              );
            },
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
  }

}

@immutable
class ListTileVariableSort extends StatelessWidget {

  const ListTileVariableSort({Key key, this.title, this.variableToSort}) : super(key: key);

  final String title;
  final String variableToSort;

  @override
  Widget build(BuildContext context) {
    final ServiceListNotifier serviceProvider = Provider.of<ServiceListNotifier>(context);
    return ListTile(
      title: Text( i18n(context, this.title)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon:  Icon(Icons.keyboard_arrow_up ),
            onPressed: () { serviceProvider.setSortByVariable(this.variableToSort, false); Navigator.pop(context); },
          ),
          IconButton(
            icon:   Icon(Icons.keyboard_arrow_down),
            onPressed: () { serviceProvider.setSortByVariable(this.variableToSort, true); Navigator.pop(context); },
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
          ..add(StringProperty('title', title))
          ..add(StringProperty('variableToSort', variableToSort));
  }

}
