
import 'package:better_together_app/model/ServiceDocument.dart';
import 'package:better_together_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class ServiceForm extends StatefulWidget {
  static const routeName = '/serviceForm';

  @override
  _ServiceFormState createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  ServiceDocument _service = ServiceDocument();
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

    String appBarTitle = "Add Service";
    final ServiceDocument passArgs = ModalRoute.of(context).settings.arguments;
    if(passArgs != null) {
      _service = passArgs;
      appBarTitle = "Edit Service";
    }

    final iconField =  CircleAvatar(
        backgroundColor: _service.icon != null ? Color(_service.color) : Colors.white60,
        radius: 50,
        child: Image.asset(_service.icon != null ? 'assets/${_service.icon}.png' :  'assets/$DEFAULT_ICON.png'),
    );

    final nameField = TextFormField(
      initialValue: _service.name,
      decoration: getInputDecoration('Name'),
      validator: (value) {
        if (value.isEmpty) return "Mandatory field";
        return null;
      },
      onSaved: (value) => _service.name = value,
    );

    final monthlyPriceField = Container(
        margin: EdgeInsets.only(top: 10),
        child: TextFormField(
          initialValue: _service.price != null ? _service.price.toString() : "",
          decoration: getInputDecoration( 'Price'),
          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
          inputFormatters: <TextInputFormatter>[
            //   WhitelistingTextInputFormatter.digitsOnly
          ],
          validator: (value) {
            if (value.isEmpty) return "Mandatory field";
            if(!isNumeric(value)) return "Only numeric value";
            return null;
          },
          onSaved: (value) => _service.price = double.parse(value)
      )
    );



    final participantNumberField = Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        initialValue: _service.participantNumber != null ?_service.participantNumber.toString() : "",
        decoration: getInputDecoration('Number of participants'),
        keyboardType: TextInputType.numberWithOptions(),
        inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
        ],
        validator: (value) {
          if (value.isEmpty) return "Mandatory field";
          if(!isNumeric(value)) return "Only numeric value";
          return null;
        },
        onSaved: (value) => _service.participantNumber = int.parse(value)
      )
    );


    final colorPickerField = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(height: 10.0),
        Text(
          "Service Color",
         ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlineButton(
              onPressed: _openColorPicker,
              child: const Text('Choose color'),
            ),
        //    const SizedBox(height: 16.0),
            CircleAvatar(
              backgroundColor: Color(_service.color ?? Theme.of(context).primaryColor.value),
              radius: 22.0
            ),
          ],
        ),
      ]
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
                  Navigator.pop(context, _service);
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
                  iconField,
                  nameField,
                  monthlyPriceField,
                  participantNumberField,
                  colorPickerField,
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
        onMainColorChange: (color) =>
            setState(() => _service.color = color.value),
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
              onPressed: () => Navigator.of(context).pop()
            ),
          ],
        );
      },
    );
  }


}



