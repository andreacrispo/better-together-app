
import 'package:better_together_app/model/ParticipantDocument.dart';
import 'package:better_together_app/screens/participant/participant_form.dart';
import 'package:better_together_app/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ServiceParticipantForm extends StatefulWidget {
  static const routeName = '/participantForm';

  @override
  _ServiceParticipantFormState createState() => _ServiceParticipantFormState();
}

class _ServiceParticipantFormState extends State<ServiceParticipantForm> {

  ParticipantDocument _participant = ParticipantDocument();
  final _formKey = GlobalKey<FormState>();
  bool _useCredit = false;
  String _participantId;


  getInputDecoration(labelText) {
    return InputDecoration(
      labelText: labelText,
      fillColor: Colors.white,
      border: new OutlineInputBorder(
        borderRadius: new BorderRadius.circular(8.0),
        borderSide: new BorderSide(
        ),
      ),
      //fillColor: Colors.green
    );
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = "Add Participant to Service";
    final ParticipantDocument passArgs = ModalRoute
        .of(context)
        .settings
        .arguments;
    if(passArgs != null) {
      _participant = passArgs;
      _participantId = passArgs.participantId;
      appBarTitle = "Edit Participant from Service";
    }


    Widget selectOrAddField() {
      return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
              Text("Select participant"),
             // Icon(Icons.add)
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _addParticipant(),
              )
            ],
      );
    }

    Widget participantSelector() {
      return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('participants').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator();
            }

            return Center(
              child: DropdownButton(
                hint: Text( "Participants"),
                isExpanded: true,
                value:  _participantId != null ? snapshot.data.documents.firstWhere((doc) => doc.documentID == _participantId) : null,
                onChanged: (DocumentSnapshot newValue) {
                  _participant = ParticipantDocument.fromSnapshot(newValue);
                  _participant.participantId = newValue.documentID;
                  _participantId =  _participant.participantId;
                  setState(() {});
                },
                items: snapshot.data.documents.map((DocumentSnapshot document) {
                  return new DropdownMenuItem(
                      value: document,
                      child: Text(document.data['name'] ?? ""),
                  );
                }).toList(),
              ),
            );
          }
      );

    }

    final hasPaidField = Container(
      margin: EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("Has paid"),
          Switch(
            value: _participant.hasPaid ?? false,
            onChanged: (value) {
              setState(() {
                _participant.hasPaid = value;
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      ),
    );

    final askToUseCreditField = Container(
      margin: EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("Credit: "),
          Text(_participant.credit != null ? _participant.credit.toString() : "0"),
          Text("Use money from credit?"),
          Switch(
            value: _useCredit,
            onChanged: (value) {
              setState(() {
                _useCredit = value;
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      ),
    );


    final pricePaidField = TextFormField(
        initialValue: _participant.pricePaid != null ?  _participant.pricePaid.toString() : "",
        decoration:  getInputDecoration('Price Paid'),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty) return "Mandatory field";
          if(!isNumeric(value)) return "Only numeric value";
          return null;
        },
        onSaved: (value) {
          _participant.pricePaid = double.parse(value);
        }
    );


    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                if(_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Navigator.pop(context, [_participant, _useCredit]);
                }
              },
            )
          ],
        ),

        body: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.only(top: 32),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              children: <Widget>[
                selectOrAddField(),
                participantSelector(),
                (_participant != null && _participant.name != null ) ?  hasPaidField : Container(),
                (_participant.hasPaid != null && _participant.hasPaid) ? askToUseCreditField : Container(),
                (_participant.hasPaid != null && _participant.hasPaid) ? pricePaidField : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }


  _addParticipant() async {
    ParticipantDocument newParticipant = await Navigator.pushNamed(
        context,
        ParticipantForm.routeName,
    );

    if (newParticipant != null) {
      DocumentReference doc = await Firestore.instance.collection('participants').add(newParticipant.toMap());
      setState(() {
        _participant = newParticipant;
        _participant.participantId = doc.documentID;
        _participantId = _participant.participantId;
      });
    }
  }

}
