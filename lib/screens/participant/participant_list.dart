
import 'package:better_together_app/model/ParticipantDocument.dart';
import 'package:better_together_app/screens/participant/participant_detail.dart';
import 'package:better_together_app/screens/participant/participant_form.dart';
import 'package:better_together_app/service/service_participant_firebase.dart';
import 'package:better_together_app/utils/utils.dart';
import 'package:better_together_app/widgets/bottom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ParticipantListWidget extends StatefulWidget {
  ParticipantListWidget({Key key}) : super(key: key);
  static const routeName = '/participantList';


  @override
  State<StatefulWidget> createState() => _ParticipantListWidgetState();
}

class _ParticipantListWidgetState extends State<ParticipantListWidget> {

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
        title: Text('Better Together')
    );
    return Scaffold(
      appBar: topAppBar,
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _createNewParticipant(),
          child: Icon(Icons.add)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:  BTBottomAppBarWidget(target: ParticipantListWidget.routeName)
    );
  }


  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _repository.getParticipants(),
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError)
          return LinearProgressIndicator();

        if( snapshot.data.documents.length == 0)
          return _buildEmptyParticipantList();

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
              _deleteParticipant(item);
            },
            child: _buildListItem(context, snapshot[index])
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final ParticipantDocument participant = ParticipantDocument.fromSnapshot(data);

    String currencySymbol = participant.currencyCode != null
        ? currenciesMap[participant.currencyCode][0]
        : "€";
    return Card(
      key: ValueKey(participant.name),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
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
                "${i18n(context,'credit')}: ${participant.credit ?? 0} $currencySymbol",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.right
            ),
          )
      ),
    );
  }

  void _createNewParticipant() async {
    ParticipantDocument newItem = await Navigator.pushNamed<ParticipantDocument>(
        context, ParticipantForm.routeName);
    if (newItem != null)
      _repository.createParticipant(newItem);
  }

  void _deleteParticipant(DocumentSnapshot service) async {
    _repository.deleteParticipant(service.documentID);
  }

  _openParticipantDetail(ParticipantDocument participant) {
    Navigator.pushNamed(
        context,
        ParticipantDetailWidget.routeName,
        arguments: participant
    );
  }

  Widget _buildEmptyParticipantList() {
    return Column(
        children: [
          Center(
            child:
            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 100,
              child: Image.asset('assets/images/icon-users.png', color: Theme.of(context).accentColor ),
            ),
          ),
          SizedBox(height: 50,),
          Center(
              child: Text(
                i18n(context, 'no_participant_added'),
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




