



import 'dart:convert';

import 'package:better_together_app/model/ServiceDocument.dart';
import 'package:better_together_app/screens/service/service_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ServicePreset extends StatefulWidget {
  static const String routeName = '/servicePresets';

  @override
  _ServicePresetState createState() => _ServicePresetState();
}

class _ServicePresetState extends State<ServicePreset> {
  final _PresetSearchDelegate _delegate = _PresetSearchDelegate();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Presets'),
        actions: <Widget>[
          /*
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final selected = await showSearch(
                context: context,
                delegate: _delegate,
              );
            },
          ),
          */
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addServicePreset(null),
          ),
        ],
      ),
      body: _buildBody(context)
    );
  }


  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<ServiceDocument>>(
      future: _loadPresetService(),
      builder: (context,  AsyncSnapshot<List<ServiceDocument>> snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();

        return _buildList(context, snapshot.data);
      },
    );
  }


  Widget _buildList(BuildContext context, List<ServiceDocument> serviceList) {
     return ListView.builder(
      padding: EdgeInsets.all(8),
      shrinkWrap: true,
      itemCount: serviceList == null ? 0 : serviceList.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildListItem(context, serviceList[index]);
      });
  }

  Widget _buildListItem(BuildContext context, ServiceDocument service) {

    Color backgroundColor = service.color != null
        ? Color(service.color)
        : Colors.white24;
    return Card(
      key: ValueKey(service.name),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child:
          ListTile(
            onTap: () => _addServicePreset(service),
           contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),

            leading: Container(
              padding: EdgeInsets.only(right: 16.0),
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(width: 1.0, color: Colors.white24),
                  )
              ),
              child: Tab(icon: Image.asset("assets/${service.icon}.png",color: backgroundColor,)),
            ),

            title: Text(
              "${service.name}",
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32),
            ),
          )
      ),
    );
  }


  Future<List<ServiceDocument>> _loadPresetService() async {
    String jsonString = await rootBundle.loadString('assets/data/service_preset.json');
    var parsedJson = jsonDecode(jsonString);
    print(parsedJson);
    assert(parsedJson is List);
    List<ServiceDocument> result = List(); //= parsedJson.map((item) =>  ServiceDocument.fromMap(item)).toList();
    for(var item in parsedJson) {
      result.add(ServiceDocument.fromMap(item));
    }
    return result;
  }


  _addServicePreset(service) async {
    ServiceDocument newItem = await Navigator.pushNamed<ServiceDocument>(
        context,
        ServiceForm.routeName,
        arguments: service
    );
    if (newItem != null) {
      newItem.color = newItem.color ?? Theme.of(context).primaryColor;
      var result = await Firestore.instance.collection('services').add(newItem.toMap());
      Navigator.pop(context);
    }
  }

}


class _PresetSearchDelegate extends SearchDelegate {

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
    if (query.isNotEmpty)
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
        query = '';
        showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Container();
  }

}

