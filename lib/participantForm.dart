
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:better_together_app/model/ServiceParticipantEntity.dart';

import 'model/ParticipantDto.dart';
import 'model/ParticipantEntity.dart';

class ParticipantForm extends StatefulWidget {
  static const routeName = '/participantForm';

  @override
  _ParticipantFormState createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  final ParticipantDto _item = ParticipantDto();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[

                TextFormField(
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value.isEmpty) return "Campo obbligatorio";
                    return null;
                  },
                  onSaved: (value) => _item.name = value,
                ),

                Container(
                  child: Row(
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
                ),

                TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      labelText: 'Price Paid',
                    ),
                    validator: (value) {
                      if (value.isEmpty) return "Campo obbligatorio";
                      return null;
                    },
                    onSaved: (value) => _item.pricePaid = double.parse(value)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



