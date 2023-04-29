
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/participant_document.dart';
import '../../service/service_participant_firebase.dart';
import '../../utils/utils.dart';
import '../participant/participant_form.dart';


class ServiceParticipantForm extends StatefulWidget {
  static const routeName = '/participantForm';

  @override
  _ServiceParticipantFormState createState() => _ServiceParticipantFormState();
}

class _ServiceParticipantFormState extends State<ServiceParticipantForm> {
  ServiceParticipantFirebase _repository;

  ParticipantDocument _participant = ParticipantDocument();
  final _formKey = GlobalKey<FormState>();
  bool _useCredit = true;
  String _participantId;


  @override
  void initState() {
    _repository = ServiceParticipantFirebase();
    super.initState();
  }

  InputDecoration getInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(),
      ),
      //fillColor: Colors.green
    );
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = i18n(context,'add_participant_to_service');
    final ParticipantDocument passArgs = ModalRoute.of(context).settings.arguments;
    if(passArgs != null) {
      _participant = passArgs;
      _participantId = passArgs.participantId;
      appBarTitle = i18n(context,'edit_participant_from_service');
    }


    Widget selectOrAddField() {
      return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text( i18n(context, 'select_participant')  ),
             // Icon(Icons.add)
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _addParticipant,
              )
            ],
      );
    }

    Widget participantSelector() {
      return StreamBuilder<List<ParticipantDocument>>(
          stream: _repository.getParticipants(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator();
            }
            return Center(
              child: DropdownButton(
                hint: Text( i18n(context, 'participant')  ),
                isExpanded: true,
                value:  _participantId != null ? snapshot.data.firstWhere((p) => p.reference.id == _participantId) : null,
                onChanged: (ParticipantDocument newParticipant) {
                  _participant = newParticipant;
                  // ignore: cascade_invocations
                  _participant.participantId = newParticipant.reference.id;
                  _participantId =  _participant.participantId;
                  setState(() {});
                },
                items: snapshot.data.map((ParticipantDocument participant) {
                  return DropdownMenuItem(
                      value: participant,
                      child: Text(participant.name ?? ""),
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
          Text(i18n(context, "has_paid")),
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
          Text("${i18n(context,"credit")}: ", style: TextStyle(fontSize: 18),),
          Text(_participant.credit != null ? formatCredit(_participant.credit).toString() : "0",style: TextStyle(fontSize: 18),),
          Text(i18n(context,'money_from_credit'),),
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
        decoration:  getInputDecoration(i18n(context, 'price_paid')),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty)
            return i18n(context, "mandatory_field");
          if(!isNumeric(value)) 
            return i18n(context,"only_numeric_value");
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
    final ParticipantDocument newParticipant = await Navigator.pushNamed(
        context,
        ParticipantForm.routeName,
    );

    if (newParticipant != null) {
      final DocumentReference doc = await _repository.createParticipant(newParticipant);
      setState(() {
        _participant = newParticipant;
        _participant.participantId = doc.id;
        _participantId = _participant.participantId;
      });
    }
  }

}
