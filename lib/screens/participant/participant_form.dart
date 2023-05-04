import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/participant_document.dart';
import '../../utils/utils.dart';


class ParticipantForm extends StatefulWidget {
  static const routeName = '/newParticipantForm';

  @override
  _ParticipantFormState createState() => _ParticipantFormState();
}

class _ParticipantFormState extends State<ParticipantForm> {
  ParticipantDocument _participant = ParticipantDocument();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    String appBarTitle = "${i18n(context, 'add')} ${i18n(context, 'participant')}";
    final ParticipantDocument passArgs = ModalRoute.of(context).settings.arguments;
    if(passArgs != null) {
      _participant = passArgs;
      appBarTitle = "${i18n(context, 'edit')} ${i18n(context, 'participant')}";
    }

    final nameField = TextFormField(
      initialValue: _participant.name ?? "",
      decoration: getInputDecoration(i18n(context, 'name')),
      validator: (value) {
        if (value.isEmpty)
          return i18n(context, "mandatory_field");
        return null;
      },
      onSaved: (value) => _participant.name = value,
    );

    final emailField = TextFormField(
      initialValue: _participant.email ?? "",
      decoration: getInputDecoration('Email'),
      onSaved: (value) => _participant.email = value
    );

    final creditField = TextFormField(
      initialValue: _participant.credit != null ? formatCredit(_participant.credit) : "",
      decoration: getInputDecoration(i18n(context, 'credit')),
      validator: (value) {
        if (value.isEmpty)
          return i18n(context, "mandatory_field");
        if(!isNumeric(value))
          return i18n(context,"only_numeric_value");
        return null;
      },
      onSaved: (value) {
        if(double.parse(value) != _participant.credit) {
          _participant.credit = double.parse(value);
          final String dateKey = Timestamp.now().toDate().toIso8601String();
         _participant.creditHistory.putIfAbsent(dateKey, () => _participant.credit);
        }
      }
    );

    final currenciesField = DropdownButton(
      hint: Text( i18n(context, 'currency')  ),
      isExpanded: true,
      value: _participant.currencyCode,
      onChanged: (currencySelected) {
        setState(() {
          _participant.currencyCode = currencySelected;
        });
      },
      items: currenciesMap.keys.map((currencyCode) {
        return DropdownMenuItem(
          value: currencyCode,
          child: Text(getCurrencyDescription(currencyCode)),
        );
      }).toList(),
    );

    final creditCurrencyField = Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: creditField,
              ),
              Container(margin: EdgeInsets.only(right: 20)),
              Expanded(
                flex: 6,
                child: currenciesField,
              ),
            ],
          ),
        ),
      ],
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
            padding: const EdgeInsets.only(top: 32),

            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              children: <Widget>[
                  const SizedBox(height: 20.0),
                  nameField,
                  const SizedBox(height: 30.0),
                  emailField,
                  const SizedBox(height: 30.0),
                  creditCurrencyField
                ],
            ),
          ),
        ),
      ),
    );
  }


  InputDecoration getInputDecoration(String labelText){
    return InputDecoration(
      labelText: labelText,
      fillColor: Colors.white,
      //fillColor: Colors.green
    );
  }

}



