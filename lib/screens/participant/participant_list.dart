
import 'package:better_together_app/model/ParticipantDocument.dart';
import 'package:better_together_app/screens/participant/participant_detail.dart';
import 'package:better_together_app/screens/participant/participant_form.dart';
import 'package:better_together_app/service/service_participant_firebase.dart';
import 'package:better_together_app/widgets/bottom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


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
    final participant = ParticipantDocument.fromSnapshot(data);

    return Card(
      key: ValueKey(participant.name),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child:
          ListTile(
            onTap: () => _openParticipantDetail(participant),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(
              "${participant.name}",
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32),
            ),
            trailing: Text(
                "Credit: ${participant.credit ?? 0} €",
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


}




