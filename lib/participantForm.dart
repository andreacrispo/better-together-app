
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model/ParticipantDto.dart';

class ParticipantForm extends StatefulWidget {
  static const routeName = '/participantForm';

  @override
  _ParticipantFormState createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  final ParticipantDto _item = ParticipantDto();
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

    final nameField = TextFormField(
      decoration: getInputDecoration('Name'),
      validator: (value) {
        if (value.isEmpty) return "Campo obbligatorio";
        return null;
      },
      onSaved: (value) => _item.name = value,
    );

    final hasPaidField = Container(
      margin: EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("Has paid"),
          Switch(
            value: _item.hasPaid == null ? false : _item.hasPaid,
            onChanged: (value) {
              setState(() {
                _item.hasPaid = value;
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        ],
      ),
    );

    final pricePaidField = TextFormField(
        decoration:  getInputDecoration('Price Paid'),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        validator: (value) {
          if (value.isEmpty) return "Campo obbligatorio";
          return null;
        },
        onSaved: (value) => _item.pricePaid = double.parse(value)
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
            padding: EdgeInsets.only(top: 32),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              children: <Widget>[
                nameField,
                hasPaidField,
                (_item.hasPaid != null && _item.hasPaid)  ? pricePaidField : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
