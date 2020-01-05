
import 'package:better_together_app/model/ParticipantDocument.dart';
import 'package:better_together_app/screens/participant/participant_form.dart';
import 'package:better_together_app/service/service_participant_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

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
    return StreamBuilder<DocumentSnapshot>(
      stream: _repository.getParticipantDetail(currentParticipant.participantId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();

        return Column(
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
                margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                child:
                   _buildCreditHistorySection(),
              )
            ]
        );
      },
    );
  }

   _buildSummaryCard(BuildContext context) {
    return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Theme.of(context).primaryColor,
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
                    onPressed: () => _editParticipant()
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
                    "Credit:  ${currentParticipant.credit.toString()}",
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


  _buildCreditHistorySection() {
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
                title: Text("Credit History"),
              );
          },
          body: ListView.builder(
            padding: EdgeInsets.all(2),
            shrinkWrap: true,
            itemCount: currentParticipant.creditHistory.length,
            itemBuilder: (BuildContext context, int index) {
              String key = currentParticipant.creditHistory.keys.elementAt(index);
              String dateFormatted = DateFormat('yyyy-MM-dd').format(DateTime.parse(key));
              return  Column(
                children: <Widget>[
                  ListTile(
                    title:  Text("$dateFormatted"),
                    trailing: Text("${currentParticipant.creditHistory[key]}"),
                  ),
                  Divider(height: 2.0,),
                ],
              );
             },
          ),
          isExpanded: this.isHistoryExpanded
        )
      ]
    );
  }

  _editParticipant() async {
    ParticipantDocument edited = await Navigator.pushNamed<ParticipantDocument>(
        context,
        ParticipantForm.routeName,
        arguments: currentParticipant
    );
    if (edited != null)
      _repository.editParticipant(currentParticipant.reference.documentID, edited);

  }



}

