


import 'package:better_together_app/participantForm.dart';
import 'package:better_together_app/service/ServiceParticipantFirebase.dart';
import 'package:better_together_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:swipedetector/swipedetector.dart';

import 'model/ParticipantDocument.dart';
import 'model/ServiceDocument.dart';



class ServiceDetailArgs {
  String serviceId;
  ServiceDocument service;
  int yearPaid;
  int monthPaid;

  ServiceDetailArgs(
      { this.serviceId, this.service, this.yearPaid, this.monthPaid});
}


class ServiceDetailWidget extends StatefulWidget {
  ServiceDetailWidget({Key key}) : super(key: key);
  static const routeName = '/serviceDetail';

  @override
  ServiceDetailWidgetState createState() => ServiceDetailWidgetState();
}

class ServiceDetailWidgetState extends State<ServiceDetailWidget> {
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
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Color(currentService.color),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/'))
        ),
      ),
      body:
      SwipeDetector(
         onSwipeLeft:  () => nextMonth(passArgs.monthPaid, passArgs.yearPaid),
         onSwipeRight: () => previousMonth(passArgs.monthPaid, passArgs.yearPaid),
          child: _buildBody(context, passArgs)
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addParticipantToService(context),
        child: Icon(Icons.add),
      ),
    );
  }


  Widget _buildBody(BuildContext context, ServiceDetailArgs args) {
    return StreamBuilder<QuerySnapshot>(
      stream: _repository.getServiceWithParticipants(
          args.serviceId, getTimestamp(args.yearPaid, args.monthPaid)),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();
        return _buildTable(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildTable(BuildContext context, List<DocumentSnapshot> snapshot) {
    final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
    List<ParticipantDocument> participants = [];
    snapshot.forEach((DocumentSnapshot docSnap) {
      participants.add(ParticipantDocument.fromSnapshot(docSnap));
    });
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () =>
                      previousMonth(passArgs.monthPaid, passArgs.yearPaid)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "${monthString[passArgs.monthPaid]} ${passArgs.yearPaid}",
                    style: TextStyle(fontSize: 32),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      showMonthPicker(
                        initialDate: DateTime(passArgs.yearPaid, passArgs.monthPaid),
                        context: context,
                      ).then((dateTime) {
                        changeMonthNavigator(dateTime.month, dateTime.year);
                      });
                    },
                  )
                ],
              ),
              IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () =>
                      nextMonth(passArgs.monthPaid, passArgs.yearPaid)
              ),
            ],
          ),

          Expanded(
              child: createTableParticipants(participants, context)
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Card(
                elevation: 10,
                child: Text(""),
              )
            ],
          )
        ]
    );
  }


  createTableParticipants(List<ParticipantDocument> participants, BuildContext context) {
    if (participants.length == 0) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: RaisedButton(
                child: Text("Copy participants from previous month"),
                onPressed: () => copyParticipantsFromPreviousMonth(context),
              ),
            ),
          ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: 30,
        sortAscending: sort,
        sortColumnIndex: 1,
        columns: [
          DataColumn(
            label: Text("Name"),
            numeric: false,
          ),
          DataColumn(
              label: Text("Has paid?"),
              numeric: false,
              onSort: (columnIndex, ascending) {
                setState(() {
                  sort = !sort;
                });
                onSortColumn(columnIndex, ascending, participants);
              }
          ),
          DataColumn(
            label: Text("Price Paid"),
            numeric: true,
          ),
          DataColumn(
            label: Text(""),
          ),
        ],
        rows: participants
            .map(
              (participant) =>
              DataRow(
                  cells: [
                    DataCell(Text(participant.name)),
                    DataCell(
                        HasPaidWidget(hasPaid: participant.hasPaid,
                            callback: (updatePaid) {
                              participant.hasPaid = updatePaid;
                              print("hasPaid");
                              print(this.currentService);
                              if (participant.hasPaid) {
                                participant.pricePaid =
                                participant.pricePaid != null
                                    ? participant.pricePaid
                                    : this.currentService.price /
                                    this.currentService.participantNumber;
                              } else {
                                participant.pricePaid = null;
                              }
                              updatePaidStatus(participant);
                            })
                    ),
                    DataCell(
                      Text(participant.pricePaid != null ? participant.pricePaid
                          .toString() : ''),
                    ),
                    DataCell(
                      PopupMenuButton<int>(
                        itemBuilder: (context) =>
                        [
                          PopupMenuItem(
                            value: 1,
                            child: Text("Edit"),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: Text("Delete"),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 1)
                            editParticipantFromService(participant);
                          else if (value == 2)
                            deleteParticipantFromService(participant);
                        },
                        icon: Icon(Icons.more_vert),
                      ),
                    )
                  ]),
        ).toList(),
      ),
    );
  }

  onSortColumn(int columnIndex, bool ascending,
      List<ParticipantDocument> users) {
    if (columnIndex == 1) {
      if (ascending) {
        users.sort((a, b) => a.hasPaid == b.hasPaid ? 1 : -1);
      } else {
        users.sort((a, b) => b.hasPaid == a.hasPaid ? 1 : -1);
      }
    }
  }

  addParticipantToService(BuildContext context) async {
    final ServiceDetailArgs passArgs = ModalRoute
        .of(context)
        .settings
        .arguments;
    ParticipantDocument newParticipant = await Navigator.pushNamed<ParticipantDocument>(
        context,
        ParticipantForm.routeName
    );

    if (newParticipant != null) {
      newParticipant.datePaid = getTimestamp(passArgs.yearPaid, passArgs.monthPaid);
      _repository.addParticipantIntoService(currentServiceId, newParticipant);
      setState(() {});
    }
  }

  editParticipantFromService(ParticipantDocument participant) async {
    ParticipantDocument editedParticipant = await Navigator.pushNamed(
        context,
        ParticipantForm.routeName,
        arguments: participant
    );

    if (editedParticipant != null) {
      await _repository.editParticipantFromService(
          currentServiceId, editedParticipant);
      setState(() {});
    }
  }

  deleteParticipantFromService(ParticipantDocument participant) async {
    await _repository.deleteParticipantFromService(
        currentServiceId, participant);
    setState(() {});
  }

  updatePaidStatus(ParticipantDocument participant) async {
    await _repository.editParticipantFromService(currentServiceId, participant);
    setState(() {});
  }

  copyParticipantsFromPreviousMonth(BuildContext context) async {
    final ServiceDetailArgs passArgs = ModalRoute
        .of(context)
        .settings
        .arguments;
    int month = passArgs.monthPaid;
    int year = passArgs.yearPaid;
    await _repository.copyParticipantsFromPreviousMonth(
        currentServiceId, year, month);
    setState(() {});
  }

  changeMonth(DragUpdateDetails details, passArgs) {
    //if details.primaryDelta is positive ,the drag is left to right. So previous month
    if (details.delta.dx > 0) {
      previousMonth(passArgs.monthPaid, passArgs.yearPaid);
    }
    //if details.primaryDelta is negative ,the drag is right to left. So next month
    else if (details.delta.dx <= 0) {
      nextMonth(passArgs.monthPaid, passArgs.yearPaid);
    }
  }

  previousMonth(month, year) {
    if (month - 1 <= 0) {
      month = 12;
      year -= 1;
    } else {
      month -= 1;
    }
    changeMonthNavigator(month, year);
  }

  nextMonth(int month, int year) {
    if (month + 1 >= 13) {
      month = 1;
      year += 1;
    } else {
      month += 1;
    }
    changeMonthNavigator(month, year);
  }

  changeMonthNavigator(month, year) {
    Navigator.pushReplacement(
      context,
      CustomChangeMonthRoute(
          builder: (context) => ServiceDetailWidget(),
          settings: RouteSettings(arguments: ServiceDetailArgs(
              serviceId: currentServiceId,
              service: currentService,
              monthPaid: month,
              yearPaid: year
          ))
      ),
    );
  }


}

class HasPaidWidget extends StatelessWidget {
  final bool hasPaid;
  final Function(bool) callback;
  HasPaidWidget({Key key, @required this.hasPaid, @required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: hasPaid ? Colors.green : Colors.red,
      textColor: Colors.white,
      padding: EdgeInsets.all(8.0),
      onPressed: () {
         callback(!hasPaid);
      },
      child: Text(
        hasPaid ? 'Paid' : 'NOT Paid',
        style: TextStyle(fontSize: 10.0),
      ),
    );
  }
}


class CustomChangeMonthRoute<T> extends MaterialPageRoute<T> {
  CustomChangeMonthRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child
  ) {
    if (settings.isInitialRoute) return child;
    return new FadeTransition(opacity: animation, child: child);
  }
}