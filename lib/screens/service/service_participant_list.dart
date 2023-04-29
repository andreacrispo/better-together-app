import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../model/participant_document.dart';
import '../../model/service_document.dart';
import '../../service/service_participant_firebase.dart';
import '../../utils/utils.dart';
import '../../widgets/bottom_bar_service_detail.dart';
import '../participant/participant_detail.dart';
import 'service_detail.dart';


class ServiceParticipantListWidget extends StatefulWidget {
  const ServiceParticipantListWidget({Key key}) : super(key: key);
  static const routeName = '/serviceParticipantList';

  @override
  ServiceDetailWidgetState createState() => ServiceDetailWidgetState();
}

class ServiceDetailWidgetState extends State<ServiceParticipantListWidget> {
  String appBarTitle = 'Better Together';
  ServiceParticipantFirebase _repository;
  bool sort;
  ServiceDocument currentService;

  String currentServiceId;

  @override
  void initState() {
    _repository = ServiceParticipantFirebase();
    sort = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
    this.currentServiceId = passArgs.serviceId;
    this.currentService = passArgs.service;
    this.appBarTitle = this.currentService.name;
    return Scaffold(
        body: _buildBody(context, passArgs),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar:  BottomBarServiceDetail(target: ServiceParticipantListWidget.routeName, serviceDetailArgs: passArgs)
    );
  }

  Widget _buildBody(BuildContext context, ServiceDetailArgs args) {
    return StreamBuilder<List<ParticipantDocument>>(
      stream: _repository.getServiceWithParticipants(args.serviceId, getDatePaid(args.yearPaid, args.monthPaid)),
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError)
          return LinearProgressIndicator();

        final String currencySymbol = getCurrencySymbol(currentService.currencyCode);
        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 130.0,
              elevation: 4,
              forceElevated: true,
              centerTitle: true,
              backgroundColor: HexColor(currentService.color),
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                        child: Text(
                          currentService.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        )),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("${currentService.price} $currencySymbol", textAlign: TextAlign.left, style: TextStyle(fontSize: 14.0)),
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(Icons.supervised_user_circle, size: 14),
                                ),
                                TextSpan(
                                  text: "  ${currentService.participantNumber}",
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        ])
                  ],
                ),
                centerTitle: true,
              ),
              actions: <Widget>[
                //IconButton(icon: Icon(Icons.edit), tooltip: i18n(context, 'edit'), onPressed: () => _editService(currentService)),
              ],
            ),
            // If the main content is a list, use SliverList instead.
            SliverFillRemaining(child: _buildList(context, snapshot.data)),
          ],
        );
      },
    );
  }


  Widget _buildList(BuildContext context, List<ParticipantDocument> snapshot) {
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
              final item = snapshot[index];
              snapshot.removeAt(index);
             // _deleteParticipant(item);
            },
            child: _buildListItem(context, snapshot[index])
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, ParticipantDocument participant) {
    final String currencySymbol = getCurrencySymbol(participant.currencyCode);
    return Card(
      key: ValueKey(participant.name),
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child:
          ListTile(
          onTap: () => _openParticipantDetail(participant),
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            title: Text(
              "${participant.name}",
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
            trailing: Text(
                "${i18n(context,'credit')}: ${formatCredit(participant.credit)} $currencySymbol",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.right
            ),
          )
      ),
    );
  }


  void _openParticipantDetail(ParticipantDocument participant) {
    Navigator.pushNamed(
        context,
        ParticipantDetailWidget.routeName,
        arguments: participant
    );
  }


  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('appBarTitle', appBarTitle))
      ..add(DiagnosticsProperty<bool>('sort', sort))
      ..add(DiagnosticsProperty<ServiceDocument>('currentService', currentService))
      ..add(StringProperty('currentServiceId', currentServiceId));
  }
}


