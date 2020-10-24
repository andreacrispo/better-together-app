
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../model/service_document.dart';
import '../../service/service_participant_firebase.dart';
import '../../utils/utils.dart';
import '../../widgets/bottom_app_bar.dart';
import 'service_detail.dart';
import 'service_preset.dart';




class ServiceListNotifier with ChangeNotifier {

  final List<String> whiteListVariable = ["name", "price", "participantNumber"];

  String _sortByVariable = "name";
  bool _isSortByDesc = false;

  String get sortByVariable => _sortByVariable;

  bool get isSortByDesc => _isSortByDesc;

  Future<void> setSortByVariable(String variable, bool isDesc) async {
    if(!whiteListVariable.contains(variable)) {
      return;
    }

    _sortByVariable = variable;
    _isSortByDesc = isDesc;
    notifyListeners();
  }

}

class ServiceListWidget extends StatefulWidget {
  ServiceListWidget({Key key}) : super(key: key);
  static const String routeName = '/serviceList';


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
    final AppBar topAppBar = AppBar(
        elevation: 0.2,
        title:  Text('Better Together')
    );

    return Scaffold(
      appBar: topAppBar,
      body: _buildBody(context),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, ServicePreset.routeName),
            child: Icon(Icons.add)
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:  BTBottomAppBarWidget(target: ServiceListWidget.routeName)
    );
  }




  Widget _buildBody(BuildContext context) {
    final serviceProvider = Provider.of<ServiceListNotifier>(context);
    return StreamBuilder<List<ServiceDocument>>(
      stream: _repository.getServices(serviceProvider.sortByVariable, isSortByDesc: serviceProvider.isSortByDesc),
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError)
          return LinearProgressIndicator();

        if(snapshot.data.isEmpty)
          return _buildEmptyServiceList();

        return _buildList(context, snapshot.data);
      },
    );
  }

  Widget _buildList(BuildContext context, List<ServiceDocument> snapshot) {
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
            onDismissed: (direction) async {
              final item = snapshot[index];
              snapshot.removeAt(index);
              await _repository.deleteService(item.reference.documentID);
            },
            child: _buildListItem(context, snapshot[index])
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context,  ServiceDocument service) {
    final Color backgroundColor = service.color != null ? HexColor(service.color) : Theme.of(context).primaryColor;
    final String currencySymbol = getCurrencySymbol( service.currencyCode);
    return Card(
      key: ValueKey(service.name),
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
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
                      serviceId: service.reference.documentID,
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
            trailing:Wrap(
              spacing: 12,
              children: [
                Column(
                  children: [
                    Text(
                        "${service.price} $currencySymbol",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.right
                    ),
                    SizedBox(height: 8,),
                    RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.supervised_user_circle, size: 20),
                          ),
                          TextSpan(
                            text: "  ${service.participantNumber}",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }

  Widget _iconLeading(ServiceDocument service, Color backgroundColor) {
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


  Widget _buildEmptyServiceList() {
    return Column(
        children: <Widget>[
          Center(
            child:
            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 140,
              child: Image.asset(
                  'assets/images/icon-service.png',
              ),
            ),
          ),
          SizedBox(height: 50,),
          Center(
              child: Text(
                  i18n(context, 'no_service_added'),
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )
              )
          )
        ]
    );
  }



}

