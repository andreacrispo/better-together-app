
import 'package:better_together_app/utils.dart';
import 'package:flutter/material.dart';

import 'model/ParticipantDocument.dart';

class NewParticipantForm extends StatefulWidget {
  static const routeName = '/newParticipantForm';

  @override
  _NewParticipantFormState createState() => _NewParticipantFormState();
}

class _NewParticipantFormState extends State<NewParticipantForm> {
  final ParticipantDocument _item = ParticipantDocument();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final nameField = TextFormField(
      decoration: getInputDecoration('Name'),
      validator: (value) {
        if (value.isEmpty) return "Mandatory field";
        return null;
      },
      onSaved: (value) => _item.name = value,
    );

    final emailField = TextFormField(
      decoration: getInputDecoration('Email'),
      onSaved: (value) => _item.email = value
    );

    final creditField = TextFormField(
      decoration: getInputDecoration('Credit'),
      validator: (value) {
        if (value.isEmpty) return "Mandatory field";
        if(!isNumeric(value)) return "Only numeric value";
        return null;
      },
      onSaved: (value) => _item.credit = int.parse(value),
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Participant"),

          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),

          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if(_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Navigator.pop(context, _item);
                }
              },
            )
          ],
        ),

        body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.only(top: 32),

            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              children: <Widget>[
                  nameField,
                  emailField,
                  creditField
                ],
            ),
          ),
        ),
      ),
    );
  }


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

}



