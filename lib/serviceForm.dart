
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:better_together_app/model/ServiceParticipantEntity.dart';
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

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: new InputDecoration(
                      labelText: 'Name',
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(
                        ),
                      ),
                      //fillColor: Colors.green
                    ),
                    validator: (value) {
                      if (value.isEmpty) return "Campo obbligatorio";
                      return null;
                    },
                    onSaved: (value) => _item.name = value,
                  ),

                  TextFormField(
                    decoration: new InputDecoration(
                      labelText: 'Monthly Price',
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        borderSide: new BorderSide(
                        ),
                      ),
                      //fillColor: Colors.green
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value.isEmpty) return "Campo obbligatorio";
                      return null;
                    },
                    onSaved: (value) => _item.monthlyPrice = double.parse(value)
                  ),

                  TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Number of pariticipant',
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:  BorderSide(
                          ),
                        ),
                        //fillColor: Colors.green
                      ),
                      keyboardType: TextInputType.numberWithOptions(),
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      validator: (value) {
                        if (value.isEmpty) return "Campo obbligatorio";
                        return null;
                      },
                      onSaved: (value) => _item.participantNumber = int.parse(value)
                  ),

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



