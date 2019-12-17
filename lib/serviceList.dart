
import 'package:better_together_app/serviceDetail.dart';
import 'package:better_together_app/serviceForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'BTBottomAppBarWidget.dart';
import 'model/ServiceDocument.dart';


class ServiceListNotifier with ChangeNotifier {

  final whiteListVariable = ["name", "price", "participantNumber"];

  String _sortByVariable = "name";
  bool _isSortByDesc = false;

  get sortByVariable => _sortByVariable;

  get isSortByDesc => _isSortByDesc;

  setSortByVariable(String variable, isDesc) async {
    if(!whiteListVariable.contains(variable)) {
      return;
    }

    _sortByVariable = variable;
    _isSortByDesc = _isSortByDesc;
    notifyListeners();
  }

}

class ServiceListWidget extends StatefulWidget {
  ServiceListWidget({Key key}) : super(key: key);
  static const routeName = '/serviceList';


  @override
  State<StatefulWidget> createState() => _ServiceListWidgetState();
}

class _ServiceListWidgetState extends State<ServiceListWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topAppBar = AppBar(
        elevation: 0.2,
        title: Text('Better Together')
    );

    return Scaffold(
      appBar: topAppBar,
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _createNewService(),
          child: Icon(Icons.add)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:  BTBottomAppBarWidget(target: ServiceListWidget.routeName)
    );
  }


  Widget _buildBody(BuildContext context) {

    final serviceProvider = Provider.of<ServiceListNotifier>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('services').orderBy(serviceProvider.sortByVariable, descending: serviceProvider.isSortByDesc).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      shrinkWrap: true,
      itemCount: snapshot == null ? 0 : snapshot.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
            key: UniqueKey(),
            background: DecoratedBox(
              decoration: BoxDecoration(color: Colors.redAccent),
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              DocumentSnapshot item = snapshot[index];
              snapshot.removeAt(index);
              _deleteService(item);
            },
            child: _buildListItem(context, snapshot[index])
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final service = ServiceDocument.fromSnapshot(data);

    var now = new DateTime.now();
    Color backgroundColor = service.color != null
        ? Color(service.color)
        : Theme.of(context).primaryColor;
    return Card(
      key: ValueKey(service.name),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child:
          ListTile(
            onTap: () {
              Navigator.pushNamed(context,
                  ServiceDetailWidget.routeName,
                  arguments: ServiceDetailArgs(
                      serviceId: data.documentID,
                      service: service,
                      monthPaid: now.month,
                      yearPaid: now.year
                  )
              );
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            /*
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      right: new BorderSide(width: 1.0, color: Colors.white24))),
              child: Icon(Icons.autorenew, color: Colors.white),
            ),
            */
            title: Text(
              "${service.name}",
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32),
            ),
            trailing: Text(
                "${service.price} € / monthly",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.right
            ),
          )
      ),
    );
  }

  void _createNewService() async {
    ServiceDocument newItem = await Navigator.pushNamed<ServiceDocument>(context, ServiceForm.routeName);
    if (newItem != null) {
      newItem.color = newItem.color ?? Theme.of(context).primaryColor;
      Firestore.instance.collection('services').add(newItem.toMap());
    }
  }

  void _deleteService(DocumentSnapshot service) async {
    Firestore.instance.collection('services')
        .document(service.documentID)
        .delete();
  }

}

