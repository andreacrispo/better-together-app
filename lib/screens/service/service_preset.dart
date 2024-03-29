import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_theme.dart';
import '../../model/service_document.dart';
import '../../service/service_participant_firebase.dart';
import '../../utils/utils.dart';
import 'service_form.dart';


class ServicePreset extends StatefulWidget {
  static const String routeName = '/servicePresets';

  @override
  _ServicePresetState createState() => _ServicePresetState();
}

class _ServicePresetState extends State<ServicePreset> {
 // final _PresetSearchDelegate _delegate = _PresetSearchDelegate();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ServiceParticipantFirebase _repository;

  List<ServiceDocument> _servicePresetList;


  @override
  void initState() {
    super.initState();
    _repository = ServiceParticipantFirebase();
  }


  @override
  Widget build(BuildContext context) {

    final fab = FloatingActionButton.extended(
      label: Text(i18n(context,'add_custom_service')),
      icon: Icon(Icons.add),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onPressed: () => _addServicePreset(null),
    );

    final appBar = AppBar(
      title: Text(i18n(context,'service')),
      actions: <Widget>[
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search),
          onPressed: () async {
            final selected = await showSearch(
                context: context,
                delegate: _PresetSearchDelegate(_servicePresetList) // _delegate,
            );
            if(selected != null) {
              _addServicePreset(selected);
            }
          },
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: appBar,
      body: _buildBody(context)
    );
  }


  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<ServiceDocument>>(
      future: _loadPresetService(),
      builder: (context,  AsyncSnapshot<List<ServiceDocument>> snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();

        _servicePresetList = snapshot.data;
        return _buildList(context, snapshot.data);
      },
    );
  }


  Widget _buildList(BuildContext context, List<ServiceDocument> serviceList) {
     return ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 16, 8, 70), //.all(8),
      shrinkWrap: true,
      itemCount: serviceList == null ? 0 : serviceList.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildListItem(context, serviceList[index]);
      });
  }

  Widget _buildListItem(BuildContext context, ServiceDocument service) {

    final Color borderColor = service.color != null ? HexColor(service.color) : Colors.white24;
    final Color iconColor = service.color != "" ? borderColor : null;
    return Card(
      key: ValueKey(service.name),
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2,),
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
              child: Tab(icon: Image.asset("assets/${service.icon}.png",color: iconColor,)),
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
    final String jsonString = await rootBundle.loadString('assets/data/service_preset.json');
    final parsedJson = jsonDecode(jsonString);
    assert(parsedJson is List, "Must be a list");
    final List<ServiceDocument> result = [];
    for(final item in parsedJson) {
      result.add(ServiceDocument.fromMap(item));
    }
    result.sort((a,b) => a.name.compareTo(b.name));
    return result;
  }


  _addServicePreset(service) async {
    final ServiceDocument newItem = await Navigator.pushNamed<ServiceDocument>(
        context,
        ServiceForm.routeName,
        arguments: service
    );
    if (newItem != null) {
      await _repository.createService(newItem);
      Navigator.pop(context);
    }
  }

}


class _PresetSearchDelegate extends SearchDelegate {

  _PresetSearchDelegate(this.serviceList);

  List<ServiceDocument> serviceList;

  @override
  String get searchFieldLabel => super.searchFieldLabel;



  @override
  ThemeData appBarTheme(BuildContext context) {
    return darkTheme;
  }

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
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<ServiceDocument> suggestionList = query.isEmpty
        ? []
        : serviceList.where((ServiceDocument p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) =>
          ListTile(
            trailing: Icon(Icons.arrow_forward),
            onTap: () => this.close(context, suggestionList[index]), // showResults(context),
            title: RichText(
                text:
                  TextSpan(
                    text: suggestionList[index].name.substring(0, query.length),
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,fontSize: 32),
                    children: [
                      TextSpan(
                        text: suggestionList[index].name.substring(query.length),
                        style: TextStyle(color: Colors.white)
                      )
                    ]
                  )
            ),
          ),
    );
  }

}

