
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../model/participant_document.dart';
import '../../service/service_participant_firebase.dart';
import '../../utils/utils.dart';
import 'participant_form.dart';


class ParticipantDetailWidget extends StatefulWidget {
  ParticipantDetailWidget({Key key}) : super(key: key);
  static const routeName = '/participantDetail';


  @override
  State<StatefulWidget> createState() => _ParticipantDetailWidgetState();
}

class _ParticipantDetailWidgetState extends State<ParticipantDetailWidget> {

  String appBarTitle = 'Better Together';
  ServiceParticipantFirebase _repository;
  ParticipantDocument currentParticipant;
  String currentServiceId;

  bool isHistoryExpanded = true;

  @override
  void initState() {
    _repository = ServiceParticipantFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final passArgs = ModalRoute.of(context).settings.arguments;
    this.currentParticipant = passArgs;
    this.appBarTitle = this.currentParticipant.name;
    return Scaffold(
      body: _buildBody(context)
    );
  }


  Widget _buildBody(BuildContext context) {
    return StreamBuilder<ParticipantDocument>(
      stream: _repository.getParticipantDetail(currentParticipant.reference.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[ Container()],
                ),

                Container(
                    margin: EdgeInsets.only(top: 50, left: 10, right: 10),
                    child: _buildSummaryCard(context)
                ),

                Container(
                  margin: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 20),
                  child: _buildCreditHistorySection(),
                )
              ]
          ),
        );
      },
    );
  }

  Card _buildSummaryCard(BuildContext context) {
    final String currencySymbol = getCurrencySymbol(currentParticipant.currencyCode);
    return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
      //    color: Theme.of(context).primaryColor,
          elevation: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context)
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.white,
                    onPressed: _editParticipant
                  ),
                ],
              ),
              Center(
                child: ListTile(
                  title: Text(
                     currentParticipant.name,
                     textAlign: TextAlign.center,
                     style: TextStyle(
                         color: Colors.white,
                         fontWeight: FontWeight.bold,
                         fontSize: 40
                     )
                  ),
                  subtitle: Text(
                    "${i18n(context,'credit')}:  ${formatCredit(currentParticipant.credit)} $currencySymbol",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
  }


  Widget _buildCreditHistorySection() {
    final sortedHistory =  currentParticipant.creditHistory.keys.toList()..sort((a,b) => b.compareTo(a));
    final String currencySymbol = getCurrencySymbol(currentParticipant.currencyCode);
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          this.isHistoryExpanded = !this.isHistoryExpanded;
        });
      },
      children: [
         ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return  ListTile(
                title: Text(i18n(context,'credit_history')),
              );
          },
          body: Container(
            height: 450,
            child: ListView.builder(
              padding: EdgeInsets.all(2),
              shrinkWrap: true,
              itemCount: sortedHistory.length,
              itemBuilder: (BuildContext context, int index) {
                final String key = sortedHistory.elementAt(index);
                final String dateFormatted = _dateFormatted(key);
                final num credit = currentParticipant.creditHistory[key];
                return  Column(
                  children: <Widget>[
                    ListTile(
                      title:  Text("$dateFormatted"),
                      trailing: Text("${formatCredit(credit)} $currencySymbol"),
                    ),
                    Divider(height: 2.0,),
                  ],
                );
               },
            ),
          ),
          isExpanded: this.isHistoryExpanded,
          canTapOnHeader: true
        )
      ]
    );
  }

  Future<void> _editParticipant() async {
    final ParticipantDocument edited = await Navigator.pushNamed<ParticipantDocument>(
        context,
        ParticipantForm.routeName,
        arguments: currentParticipant
    );
    if (edited != null)
      await _repository.editParticipant(currentParticipant.reference.id, edited);

  }


  String _dateFormatted(dateAsString) {
    String dateFormatted = dateAsString;
      try {
        dateFormatted = DateFormat('yyyy-MM-dd').format(DateTime.parse(dateAsString));
      } on Exception {
        initializeDateFormatting();
        dateFormatted = DateFormat('yyyy-MM-dd').format(DateTime.parse(dateAsString));
      }
      return dateFormatted;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(StringProperty('appBarTitle', appBarTitle))
              ..add(DiagnosticsProperty<ParticipantDocument>('currentParticipant', currentParticipant))
              ..add(StringProperty('currentServiceId', currentServiceId))
              ..add(DiagnosticsProperty<bool>('isHistoryExpanded', isHistoryExpanded));
  }



}

