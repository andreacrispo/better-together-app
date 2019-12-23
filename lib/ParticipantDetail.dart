







import 'package:better_together_app/ParticipantForm.dart';
import 'package:better_together_app/model/ParticipantDocument.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ParticipantDetailWidget extends StatefulWidget {
  ParticipantDetailWidget({Key key}) : super(key: key);
  static const routeName = '/participantDetail';


  @override
  State<StatefulWidget> createState() => _ParticipantDetailWidgetState();
}

class _ParticipantDetailWidgetState extends State<ParticipantDetailWidget> {

  String appBarTitle = 'Better Together';
 // ServiceParticipantFirebase _repository;
  ParticipantDocument currentParticipant;

  String currentServiceId;

  @override
  void initState() {
  //  _repository = ServiceParticipantFirebase();
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
      stream: Firestore.instance.collection('participants').document(currentParticipant.participantId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return LinearProgressIndicator();

        return _buildSummaryCard(context);
      },
    );
  }

  Card _buildSummaryCard(BuildContext context) {
    return Card(
          margin: EdgeInsets.only(top: 50, left: 10, right: 10),
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


  _buildCreditHistorySection(){
    // TODO:
  }

  _editParticipant() async {
    ParticipantDocument edited = await Navigator.pushNamed<ParticipantDocument>(
        context,
        ParticipantForm.routeName,
        arguments: currentParticipant
    );
    if (edited != null) {
      Firestore.instance.collection('participants')
          .document(currentParticipant.reference.documentID)
          .setData(edited.toMap());
    }
  }

}