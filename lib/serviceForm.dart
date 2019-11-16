
import 'package:better_together_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

import 'model/ServiceEntity.dart';

class ServiceForm extends StatefulWidget {
  static const routeName = '/serviceForm';

  @override
  _ServiceFormState createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final ServiceEntity _item = ServiceEntity();
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
        if (value.isEmpty) return "Mandatory field";
        return null;
      },
      onSaved: (value) => _item.name = value,
    );

    final monthlyPriceField = Container(
        margin: EdgeInsets.only(top: 10),
        child: TextFormField(
        decoration: getInputDecoration( 'Monthly Price'),
        keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
        inputFormatters: <TextInputFormatter>[
          //   WhitelistingTextInputFormatter.digitsOnly
        ],
        validator: (value) {
          if (value.isEmpty) return "Mandatory field";
          if(!isNumeric(value)) return "Only numeric value";
          return null;
        },
        onSaved: (value) => _item.monthlyPrice = double.parse(value)
      )
    );

    final participantNumberField = Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        decoration: getInputDecoration('Number of pariticipant'),
        keyboardType: TextInputType.numberWithOptions(),
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        validator: (value) {
          if (value.isEmpty) return "Mandatory field";
          if(!isNumeric(value)) return "Only numeric value";
          return null;
        },
        onSaved: (value) => _item.participantNumber = int.parse(value)
      )
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("New Service"),

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
                  monthlyPriceField,
                  participantNumberField,
                  SizedBox(
                    width: double.infinity,
                    child: OutlineButton(
                      onPressed: _openColorPicker,
                      child: const Text('Choose color'),
                    ),
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }

  void _openColorPicker() async {
    _openDialog(
      "Choose one color",
      MaterialColorPicker(
        allowShades: false,
        onMainColorChange: (color) => setState(() => _item.color = color.value),
      ),
    );
  }

  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            FlatButton(
              child: Text('Cancel'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
                //setState(() => _mainColor = _tempMainColor);
              },
            ),
          ],
        );
      },
    );
  }


}



