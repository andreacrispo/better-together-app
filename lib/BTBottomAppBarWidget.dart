
import 'package:better_together_app/AppTheme.dart';
import 'package:better_together_app/main.dart';
import 'package:better_together_app/participantList.dart';
import 'package:better_together_app/serviceList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BTBottomAppBarWidget extends StatelessWidget {
  const BTBottomAppBarWidget({
    this.fabLocation,
  });

  final FloatingActionButtonLocation fabLocation;


  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      //color: Theme.of(context).primaryColor,
      elevation: 5,
      shape: const CircularNotchedRectangle(),
      child: Row(children: <Widget>[
        IconButton(
            color: Theme.of(context).accentColor,
            iconSize: 36,
            icon: const Icon(Icons.home, semanticLabel: 'Show service list'),
            onPressed: () => _changeRoute(context, ServiceListWidget.routeName)
        ),
        IconButton(
            color: Theme.of(context).accentColor,
            iconSize: 36,
            icon: const Icon(Icons.supervised_user_circle, semanticLabel: 'Show participants list'),
            onPressed: () => _changeRoute(context,ParticipantListWidget.routeName)
        ),
        const Expanded(child: SizedBox()),
        /*
        IconButton(
          icon: Icon(Icons.filter_list),
        ),
        IconButton(
          icon: Icon(Icons.sort),
          onPressed: () => _showSortByBottomSheet(context)
        ),
        */
        IconButton(
            iconSize: 36,
            icon: Icon(Icons.more_vert),
            onPressed: () => _showMoreMenu(context)
        ),
      ]),
    );
  }

  _changeRoute(context, newRouteName) {
    bool isNewRouteSameAsCurrent = false;

    Navigator.popUntil(context, (route) {
      if (route.settings.name == newRouteName) {
        isNewRouteSameAsCurrent = true;
      }
      return true;
    });

    if (!isNewRouteSameAsCurrent) {
      Navigator.pushReplacementNamed(context, newRouteName);
    }
  }

  void _showSortByBottomSheet(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    title: Text('Name'),
                    onTap: () => {}
                ),
                ListTile(
                  title: Text('Price'),
                  onTap: () => {},
                ),
                ListTile(
                  title: Text('Number of participants'),
                  onTap: () => {},
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
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
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

              ],
            ),
          );
        }
    );
  }

}

