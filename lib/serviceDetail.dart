


import 'package:better_together_app/participantForm.dart';
import 'package:better_together_app/service/ServiceParticipantService.dart';
import 'package:better_together_app/utils.dart';
import 'package:flutter/material.dart';
import 'model/ParticipantDto.dart';
import 'model/ServiceParticipantDto.dart';
import 'package:flutter/foundation.dart';


class ServiceDetailArgs {
  int serviceId;
  int yearPaid;
  int monthPaid;
  ServiceDetailArgs({this.serviceId, this.yearPaid, this.monthPaid});
}


class ServiceDetailWidget extends StatefulWidget {
  ServiceDetailWidget({Key key}) : super(key: key);
  static const routeName = '/serviceDetail';

  @override
  ServiceDetailWidgetState createState() => ServiceDetailWidgetState();
}

class ServiceDetailWidgetState extends State<ServiceDetailWidget> {
  String appBarTitle = 'Better Together';
  ServiceParticipantService _repository;
  bool sort;
  ServiceParticipantDto currentService;

  @override
  void initState() {
    _repository = ServiceParticipantService();
    sort = false;

    super.initState();
  }

  onSortColumn(int columnIndex, bool ascending, List<ParticipantDto> users) {
    if(columnIndex == 1) {
      if (ascending) {
        users.sort((a, b) => a.hasPaid == b.hasPaid ? 1 : -1);
      } else {
        users.sort((a, b) => b.hasPaid == a.hasPaid ? 1 : -1);
      }
    }
  }

  dataBody( List<ParticipantDto> participants) {
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
              (participant) => DataRow(
                cells: [
                  DataCell(Text(participant.name)),
                  DataCell(
                      HasPaidWidget(hasPaid: participant.hasPaid, callback: (updatePaid) {
                        participant.hasPaid = updatePaid;
                        if ( participant.hasPaid) {
                          participant.pricePaid = participant.pricePaid != null
                              ? participant.pricePaid
                              : this.currentService.monthlyPrice / this.currentService.participantNumber;
                        } else  {
                          participant.pricePaid = null;
                        }
                        updatePaidStatus(participant);
                      })
                  ),
                  DataCell(
                    Text(participant.pricePaid != null ? participant.pricePaid.toString(): ''),
                  ),
                  DataCell(
                       PopupMenuButton<int>(
                          itemBuilder: (context) => [
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
                            if(value == 1)
                              editParticipantFromService(participant);
                            else if(value == 2)
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

  addParticipantToService(BuildContext context) async {
    final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
    int serviceId = passArgs.serviceId;
    ParticipantDto newParticipant = await Navigator.pushNamed<ParticipantDto>(context, ParticipantForm.routeName);

    if (newParticipant != null) {
      newParticipant.monthPaid = passArgs.monthPaid;
      newParticipant.yearPaid = passArgs.yearPaid;
      await _repository.addParticipantToService(serviceId, newParticipant);
      setState(() {});
    }
  }

  editParticipantFromService(ParticipantDto participant) async {
    ParticipantDto editedParticipant = await Navigator.pushNamed<ParticipantDto>(
        context,
        ParticipantForm.routeName,
        arguments: participant
    );

    if (editedParticipant != null) {
      await _repository.editParticipantFromService(currentService.serviceId, editedParticipant);
      setState(() {});

    }
  }

  deleteParticipantFromService(ParticipantDto participant) async {
    await _repository.deleteParticipantFromService(currentService.serviceId, participant);
     setState(() {});
  }

  updatePaidStatus(ParticipantDto participant) async {
     await _repository.editParticipantFromService( currentService.serviceId, participant);
     setState(() {});
  }

  changeMonth(details, passArgs) {
      final int serviceId = passArgs.serviceId;
      //if details.primaryDelta is positive ,the drag is left to right. So previous month
      if(details.delta.dx > 0) {
        previousMonth(serviceId, passArgs.monthPaid, passArgs.yearPaid);
      }
      //if details.primaryDelta is negative ,the drag is right to left. So next month
      else if(details.delta.dx <= 0 ) {
        nextMonth(serviceId, passArgs.monthPaid, passArgs.yearPaid);
      }
  }

  previousMonth(serviceId, month, year) {
    if (month - 1 <= 0) {
      month = 12;
      year -= 1;
    } else {
      month -= 1;
    }
    Navigator.pushNamed(context,
        ServiceDetailWidget.routeName,
        arguments: ServiceDetailArgs(serviceId: serviceId, monthPaid: month, yearPaid: year)
    );
  }

  nextMonth(int serviceId, int month, int year) {
    if (month + 1 >= 13) {
      month = 1;
      year += 1;
    } else {
      month += 1;
    }
    Navigator.pushNamed(context,
        ServiceDetailWidget.routeName,
        arguments: ServiceDetailArgs(serviceId: serviceId, monthPaid: month, yearPaid: year)
    );
  }

  @override
  Widget build(BuildContext context) {
    final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/'))
        ),
      ),
      body:
      GestureDetector(
        onPanUpdate: (details) => changeMonth(details, passArgs),
        child: FutureBuilder<ServiceParticipantDto>(
          future:  _repository.getServiceWithParticipants(
             passArgs.serviceId,
             passArgs.monthPaid,
             passArgs.yearPaid
          ),
          builder: (BuildContext context, AsyncSnapshot<ServiceParticipantDto> snapshot) {
            if(!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            currentService = snapshot.data;
            return  Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                      Text(
                        "${monthString[passArgs.monthPaid]} ${passArgs.yearPaid}",
                        style: TextStyle(fontSize: 32),
                      ),
                  ],
                ),
                Expanded(
                  child: dataBody(currentService.participants),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Card(
                      elevation: 10,
                      child: Text("PROVA"),
                    )
                  ],
                )
              ]
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>  addParticipantToService(context),
        child: Icon(Icons.add),
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