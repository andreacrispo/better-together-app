
import 'package:better_together_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model/ParticipantDocument.dart';

class ParticipantForm extends StatefulWidget {
  static const routeName = '/participantForm';

  @override
  _ParticipantFormState createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  ParticipantDocument _participant = ParticipantDocument();
  final _formKey = GlobalKey<FormState>();


  getInputDecoration(labelText){
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
    String appBarTitle = "Add Participant";
    final ParticipantDocument passArgs = ModalRoute
        .of(context)
        .settings
        .arguments;
    if(passArgs != null) {
      _participant = passArgs;
      appBarTitle = "Edit Participant";
    }


    final nameField = TextFormField(
      initialValue: _participant.name,
      decoration: getInputDecoration('Name'),
      validator: (value) {
        if (value.isEmpty) return "Mandatory field";
        return null;
      },
      onSaved: (value) => _participant.name = value,
    );

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

    final pricePaidField = TextFormField(
        initialValue: _participant.pricePaid != null ?  _participant.pricePaid.toString() : "",
        decoration:  getInputDecoration('Price Paid'),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty) return "Mandatory field";
          if(!isNumeric(value)) return "Only numeric value";
          return null;
        },
        onSaved: (value) => _participant.pricePaid = double.parse(value)
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
                  Navigator.pop(context, _participant);
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
                nameField,
                hasPaidField,
                (_participant.hasPaid != null && _participant.hasPaid)  ? pricePaidField : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
