
import 'package:better_together_app/model/ServiceDocument.dart';
import 'package:better_together_app/screens/service/service_detail.dart';
import 'package:better_together_app/screens/service/service_preset.dart';
import 'package:better_together_app/service/service_participant_firebase.dart';
import 'package:better_together_app/widgets/bottom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



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

  ServiceParticipantFirebase _repository;

  @override
  void initState() {
    super.initState();
    _repository = ServiceParticipantFirebase();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topAppBar = AppBar(
        elevation: 0.2,
        title:  Text('Better Together')
    );

    return Scaffold(
      appBar: topAppBar,
      body: _buildBody(context),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, ServicePreset.routeName),  // _createNewService(),
            child: Icon(Icons.add)
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:  BTBottomAppBarWidget(target: ServiceListWidget.routeName)
    );
  }




  Widget _buildBody(BuildContext context) {
    final serviceProvider = Provider.of<ServiceListNotifier>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: _repository.getServices(serviceProvider.sortByVariable, serviceProvider.isSortByDesc),
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError)
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

    Color backgroundColor = service.color != null
        ? Color(service.color)
        : Theme.of(context).primaryColor;
    return Card(
      key: ValueKey(service.name),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: backgroundColor, width: 2,),
            color: Theme.of(context).primaryColor, //backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            onTap: () {
              Navigator.pushNamed(context,
                  ServiceDetailWidget.routeName,
                  arguments: ServiceDetailArgs(
                      serviceId: data.documentID,
                      service: service,
                      monthPaid: DateTime.now().month,
                      yearPaid: DateTime.now().year
                  )
              );
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),

            leading: _iconLeading(service, backgroundColor),

            title: Text(
              "${service.name}",
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
            trailing: Text(
                "${service.price} €",
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.right
            ),
          )
      ),
    );
  }

  _iconLeading(ServiceDocument service, Color backgroundColor) {
    if(service.icon == null)
      return null;

    return Container(
      padding: EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: 1.0, color: Colors.white24),
          )
      ),
      child: Tab(icon: Image.asset("assets/${service.icon}.png",color: backgroundColor,)),
    );
  }


  void _deleteService(DocumentSnapshot service) async {
    Firestore.instance.collection('services')
        .document(service.documentID)
        .delete();
  }



}

