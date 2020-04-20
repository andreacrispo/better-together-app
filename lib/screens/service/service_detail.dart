import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:swipedetector/swipedetector.dart';

import '../../model/participant_document.dart';
import '../../model/service_document.dart';
import '../../service/service_participant_firebase.dart';
import '../../utils/custom_route_animation.dart';
import '../../utils/utils.dart';
import '../../widgets/has_paid_button.dart';
import 'service_form.dart';
import 'service_participant_form.dart';

class ServiceDetailArgs {
  String serviceId;
  ServiceDocument service;
  int yearPaid;
  int monthPaid;

  ServiceDetailArgs({this.serviceId, this.service, this.yearPaid, this.monthPaid});
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
      body: SwipeDetector(
          onSwipeLeft: () => nextMonth(passArgs.monthPaid, passArgs.yearPaid),
          onSwipeRight: () => previousMonth(passArgs.monthPaid, passArgs.yearPaid),
          child: _buildBody(context, passArgs)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addParticipantToService(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ServiceDetailArgs args) {
    return StreamBuilder<List<ParticipantDocument>>(
      stream: _repository.getServiceWithParticipants(args.serviceId, getTimestamp(args.yearPaid, args.monthPaid)),
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) return LinearProgressIndicator();

        final String currencySymbol = currentService.currencyCode != null ? currenciesMap[currentService.currencyCode][0] : "€";
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
                    Center(child: Text("${currentService.price} $currencySymbol", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0))),
                  ],
                ),
                centerTitle: true,
              ),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.edit), tooltip: i18n(context, 'edit'), onPressed: () => _editService(currentService)),
              ],
            ),
            // If the main content is a list, use SliverList instead.
            SliverFillRemaining(child: _buildTable(context, snapshot.data)),
          ],
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, List<ParticipantDocument> participants) {
    final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
    final Locale locale = FlutterI18n.currentLocale(context);
    final String currentMonth = localeMonthString[locale.languageCode][passArgs.monthPaid];

    return Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, verticalDirection: VerticalDirection.down, children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.arrow_back),
              color: Theme.of(context).textTheme.button.color,
              onPressed: () => previousMonth(passArgs.monthPaid, passArgs.yearPaid)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "$currentMonth ${passArgs.yearPaid}",
                style: TextStyle(fontSize: 32),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                color: Theme.of(context).textTheme.button.color,
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
              color: Theme.of(context).textTheme.button.color,
              onPressed: () => nextMonth(passArgs.monthPaid, passArgs.yearPaid)),
        ],
      ),
      Expanded(child: createTableParticipants(participants, context)),
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
    ]);
  }

  Widget createTableParticipants(List<ParticipantDocument> participants, BuildContext context) {
    if (participants.isEmpty) {
      final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 150,
          ),
          RaisedButton(
            onPressed: () => copyParticipantsFromPreviousMonth(context),
            child: Text(i18n(context, 'copy_participants_previous_month')),
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                i18n(context, 'copy_participants_from'),
                style: TextStyle(fontSize: 22),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () {
                  showMonthPicker(
                    initialDate: DateTime(passArgs.yearPaid, passArgs.monthPaid),
                    context: context,
                  ).then((dateTime) async {
                    await _repository.copyParticipantsFromAnotherDate(
                        serviceId: currentServiceId,
                        currentToTimestamp: getTimestamp(passArgs.yearPaid, passArgs.monthPaid),
                        fromAnotherTimestamp: getTimestamp(dateTime.year, dateTime.month));
                    setState(() {});
                  });
                },
              )
            ],
          ),
        ],
      );
    }

    // TODO: FIXME: Remove when sort order works in firebase
    participants.sort((a, b) {
      return a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase());
    });

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: 10,
        sortAscending: sort,
        // sortColumnIndex: 1,
        columns: [
          DataColumn(
            label: Text(i18n(context, 'name')),
            numeric: false,
          ),
          DataColumn(
              label: Text(i18n(context, 'has_paid')),
              numeric: false,
              onSort: (columnIndex, ascending) {
                onSortColumn(columnIndex, ascending, participants);
                setState(() {
                  sort = !sort;
                });
              }),
          DataColumn(
            label: Text(i18n(context, 'price_paid')),
            numeric: true,
          ),
          DataColumn(
            label: const Text(""),
          ),
        ],
        rows: participants
            .map(
              (participant) => DataRow(cells: [
                DataCell(Text(participant.name)),
                DataCell(HasPaidWidget(
                    hasPaid: participant.hasPaid,
                    callback: (updatePaid) {
                      participant.hasPaid = updatePaid;
                      if (participant.hasPaid) {
                        participant.pricePaid = participant.pricePaid ?? (this.currentService.price / this.currentService.participantNumber);
                      } else {
                        participant.pricePaid = null;
                      }
                      updatePaidStatus(participant);
                    })),
                DataCell(
                  Text(participant.pricePaid != null ? participant.pricePaid.toString() : ''),
                ),
                DataCell(
                  PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Text(i18n(context, 'edit')),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Text(i18n(context, 'delete')),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 1)
                        editParticipantFromService(participant);
                      else if (value == 2) deleteParticipantFromService(participant);
                    },
                    icon: Icon(Icons.more_vert),
                  ),
                )
              ]),
            )
            .toList(),
      ),
    );
  }

  void onSortColumn(int columnIndex, bool ascending, List<ParticipantDocument> users) {
    if (columnIndex == 1) {
      if (ascending) {
        users.sort((a, b) => a.hasPaid == b.hasPaid ? 1 : -1);
      } else {
        users.sort((a, b) => a.hasPaid == b.hasPaid ? -1 : 1);
      }
    }
  }

  addParticipantToService(BuildContext context) async {
    final result = await Navigator.pushNamed<dynamic>(
      context,
      ServiceParticipantForm.routeName,
    );
    if (result == null) return;

    final ParticipantDocument newParticipant = result[0];
    final bool useCredit = result[1];

    if (newParticipant != null) {
      final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
      newParticipant.datePaid = getTimestamp(passArgs.yearPaid, passArgs.monthPaid);
      _repository.addParticipantIntoService(
        serviceId: currentServiceId,
        participant: newParticipant,
        useCredit: useCredit,
      );
      setState(() {});
    }
  }

  editParticipantFromService(ParticipantDocument participant) async {
    final result = await Navigator.pushNamed<dynamic>(context, ServiceParticipantForm.routeName, arguments: participant);
    if (result == null) return;

    final ParticipantDocument editedParticipant = result[0];
    final bool useCredit = result[1];

    if (editedParticipant != null) {
      await _repository.editParticipantFromService(
          serviceId: currentServiceId,
          participant :editedParticipant,
          useCredit: useCredit
      );
      setState(() {});
    }
  }

  deleteParticipantFromService(ParticipantDocument participant) async {
    await _repository.deleteParticipantFromService(currentServiceId, participant);
    setState(() {});
  }

  updatePaidStatus(ParticipantDocument participant) async {
    await _repository.editParticipantFromService(
        serviceId: currentServiceId,
        participant: participant,
        useCredit: true
    );
    setState(() {});
  }

  copyParticipantsFromPreviousMonth(BuildContext context) async {
    final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
    final int month = passArgs.monthPaid;
    final int year = passArgs.yearPaid;
    await _repository.copyParticipantsFromPreviousMonth(currentServiceId, year, month);
    setState(() {});
  }

  copyParticipantsFromAnotherDate() async {
    final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;

    await _repository.copyParticipantsFromAnotherDate(
        serviceId: currentServiceId,
        fromAnotherTimestamp: null, // TIMESTAMP
        currentToTimestamp: getTimestamp(passArgs.yearPaid, passArgs.monthPaid));
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

  void previousMonth(int month, int year) {
    if (month - 1 <= 0) {
      month = 12;
      year -= 1;
    } else {
      month -= 1;
    }
    changeMonthNavigator(month, year);
  }

  void nextMonth(int month, int year) {
    if (month + 1 >= 13) {
      month = 1;
      year += 1;
    } else {
      month += 1;
    }
    changeMonthNavigator(month, year);
  }

  void changeMonthNavigator(int month, int year) {
    Navigator.pushReplacement(
      context,
      CustomRouteFadeAnimation(
          builder: (context) => ServiceDetailWidget(),
          settings: RouteSettings(arguments: ServiceDetailArgs(serviceId: currentServiceId, service: currentService, monthPaid: month, yearPaid: year))),
    );
  }

  _editService(ServiceDocument service) async {
    final ServiceDocument editedService = await Navigator.pushNamed<ServiceDocument>(context, ServiceForm.routeName, arguments: service);
    if (editedService != null) {
      await _repository.editService(service.reference.documentID, editedService);
    }
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
