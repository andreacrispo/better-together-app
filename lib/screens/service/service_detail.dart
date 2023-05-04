import 'package:better_together_app/screens/service/service_list.dart';
import 'package:better_together_app/widgets/bottom_app_bar.dart';
import 'package:better_together_app/widgets/bottom_bar_service_detail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:swipedetector/swipedetector.dart';

import '../../model/participant_document.dart';
import '../../model/service_document.dart';
import '../../service/service_participant_firebase.dart';
import '../../utils/custom_route_animation.dart';
import '../../utils/utils.dart';
import '../../widgets/has_paid_button.dart';
import '../../widgets/month_navigator.dart';
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

  ServiceDetailArgs serviceDetailArgs;

  @override
  void initState() {
    _repository = ServiceParticipantFirebase();
    sort = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
    this.serviceDetailArgs = passArgs;
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar:  BottomBarServiceDetail(target: ServiceDetailWidget.routeName, serviceDetailArgs: passArgs)
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

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
            MonthNavigatorWidget(
                currentMonth: passArgs.monthPaid,
                currentYear: passArgs.yearPaid,
                changeMonthCallback: changeMonthNavigator,
                previousMonthCallback: previousMonth,
                nextMonthCallback: nextMonth,
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
        ]
    );
  }

  Widget createTableParticipants(List<ParticipantDocument> participants, BuildContext context) {
    if (participants.isEmpty) {
      final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 90),
          Text(
            i18n(context, 'no_participant_added'),
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height:40),
          Text(
            i18n(context, 'copy_participants_from'),
            style: TextStyle(fontSize: 22),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => copyParticipantsFromPreviousMonth(context),
            child: Text(i18n(context, 'copy_participants_previous_month')),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                i18n(context, 'copy_participants_from_select_date'),
                style: TextStyle(fontSize: 22),
              ),
              IconButton(
                color: Theme.of(context).textTheme.button.color,
                icon: Icon(Icons.calendar_today),
                onPressed: () {
                  showMonthPicker(
                    initialDate: DateTime(passArgs.yearPaid, passArgs.monthPaid),
                    context: context,
                  ).then((dateTime) async {
                    await _repository.copyParticipantsFromAnotherDate(
                        serviceId: currentServiceId,
                        currentToTimestamp: getDatePaid(passArgs.yearPaid, passArgs.monthPaid),
                        fromAnotherTimestamp: getDatePaid(dateTime.year, dateTime.month));
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
                        final pricePaid = (participant.pricePaid != null && participant.pricePaid != 0 ) ? participant.pricePaid : (this.currentService.price / this.currentService.participantNumber);
                        participant.datePaid = getTimestamp(this.serviceDetailArgs.yearPaid, this.serviceDetailArgs.monthPaid);
                        participant.pricePaid = pricePaid;
                      } else {
                        participant.pricePaid = null;
                      }
                      updatePaidStatus(participant);
                    })),
                DataCell(
                  Text(participant.pricePaid != null ? participant.pricePaid.toStringAsFixed(3): ''),
                ),
                DataCell(
                  PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Text(i18n(context, 'edit')),
                      ),
                      /*
                      PopupMenuItem(
                        value: 2,
                        child: Text(i18n(context, 'delete')),
                      ),
                      */

                    ],
                    onSelected: (value) {
                      if (value == 1) {
                        editParticipantFromService(participant);
                      } else if (value == 2) {
                        deleteParticipantFromService(participant);
                      }
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

  Future<void> addParticipantToService(BuildContext context) async {
    final result = await Navigator.pushNamed<dynamic>(
      context,
      ServiceParticipantForm.routeName,
    );
    if (result == null) {
      return;
    }

    final ParticipantDocument newParticipant = result[0];
    final bool useCredit = result[1];

    if (newParticipant != null) {
      final ServiceDetailArgs passArgs = ModalRoute.of(context).settings.arguments;
      newParticipant.datePaid = getTimestamp(passArgs.yearPaid, passArgs.monthPaid);
      await _repository.addParticipantIntoService(
        serviceId: currentServiceId,
        participant: newParticipant,
        useCredit: useCredit,
      );
      setState(() {});
    }
  }

  editParticipantFromService(ParticipantDocument participant) async {
    final result = await Navigator.pushNamed<dynamic>(context, ServiceParticipantForm.routeName, arguments: participant);
    if (result == null) {
      return;
    }

    final ParticipantDocument editedParticipant = result[0];
    final bool useCredit = result[1];
    editedParticipant.datePaid = getTimestamp(this.serviceDetailArgs.yearPaid, this.serviceDetailArgs.monthPaid);
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
        currentToTimestamp: getDatePaid(passArgs.yearPaid, passArgs.monthPaid)
    );
    setState(() {});
  }

  void previousMonth(int month, int year) {
    int prevMonth = month; int prevYear = year;
    if (month - 1 <= 0) {
      prevMonth = 12;
      prevYear -= 1;
    } else {
      prevMonth -= 1;
    }
    changeMonthNavigator(prevMonth, prevYear);
  }

  void nextMonth(int month, int year) {
    int nextMonth = month; int nextYear = year;
    if (month + 1 >= 13) {
      nextMonth = 1;
      nextYear += 1;
    } else {
      nextMonth += 1;
    }
    changeMonthNavigator(nextMonth, nextYear);
  }


  void changeMonthNavigator(int month, int year) {
    Navigator.pushReplacement(
      context,
      CustomRouteFadeAnimation(
          builder: (context) => ServiceDetailWidget(),
          settings: RouteSettings(arguments: ServiceDetailArgs(
              serviceId: currentServiceId, service: currentService,
              monthPaid: month, yearPaid: year
          ))
      ),
    );
  }

  _editService(ServiceDocument service) async {
    final ServiceDocument editedService = await Navigator.pushNamed<ServiceDocument>(context, ServiceForm.routeName, arguments: service);
    if (editedService != null) {
      await _repository.editService(service.reference.id, editedService);
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


