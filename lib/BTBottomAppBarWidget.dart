
import 'package:better_together_app/AppTheme.dart';
import 'package:better_together_app/main.dart';
import 'package:better_together_app/participantList.dart';
import 'package:better_together_app/serviceList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BTBottomAppBarWidget extends StatelessWidget {
  const BTBottomAppBarWidget({
 //   this.fabLocation,
    this.target
  });

  //final FloatingActionButtonLocation fabLocation;
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
            onPressed: () => _changeRoute(context, ServiceListWidget.routeName)
        ),
        IconButton(
            iconSize: 36,
            icon: const Icon(Icons.supervised_user_circle, semanticLabel: 'Show participants list'),
            onPressed: () => _changeRoute(context,ParticipantListWidget.routeName)
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

