import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

import '../../model/service_document.dart';
import '../../utils/utils.dart';

class ServiceForm extends StatefulWidget {
  static const routeName = '/serviceForm';

  @override
  _ServiceFormState createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  ServiceDocument _service = ServiceDocument();
  final _formKey = GlobalKey<FormState>();

  InputDecoration getInputDecoration(String labelText){
    return InputDecoration(
      labelText: labelText,
      fillColor: Colors.white,
    );
  }
  
  @override
  Widget build(BuildContext context) {

    String appBarTitle = "${i18n(context, "add")} ${i18n(context, "service")}";
    final ServiceDocument passArgs = ModalRoute.of(context).settings.arguments;
    if(passArgs != null) {
      _service = passArgs;
      appBarTitle = "${i18n(context, "edit")} ${i18n(context, "service")}";
    }

    final iconField =  CircleAvatar(
        backgroundColor: (_service.color != null || _service.color != "") ? HexColor(_service.color) : Colors.grey,
        radius: 50,
        child: Image.asset('assets/${_service.icon ?? DEFAULT_ICON}.png'),
    );

    final nameField = TextFormField(
      initialValue: _service.name,
      decoration: getInputDecoration(i18n(context, "name")),
      validator: (value) {
        if (value.isEmpty)
          return i18n(context, "mandatory_field");
        return null;
      },
      onSaved: (value) => _service.name = value,
    );

    final priceField = Container(
        margin: EdgeInsets.only(top: 10),
        child: TextFormField(
          initialValue: _service.price != null ? _service.price.toString() : "",
          decoration: getInputDecoration(i18n(context, "price")),
          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
          inputFormatters: <TextInputFormatter>[
            //   WhitelistingTextInputFormatter.digitsOnly
          ],
          validator: (value) {
            if (value.isEmpty)
              return i18n(context, "mandatory_field");
            if(!isNumeric(value))
              return i18n(context,"only_numeric_value");
            return null;
          },
          onSaved: (value) => _service.price = double.parse(value)
      )
    );


    final currenciesField = DropdownButton(
      itemHeight: 80,
      hint: Text( i18n(context, 'currency')  ),
      isExpanded: true,
      value:_service.currencyCode,
      onChanged: (currencySelected) {
        setState(() {
          _service.currencyCode = currencySelected;
        });
      },
      items: currenciesMap.keys.map((currencyCode) {
        final String currencyName = getCurrencyDescription(currencyCode);
        return DropdownMenuItem(
          value: currencyCode,
          child: Text(currencyName),
        );
      }).toList(),
    );


    final priceCurrencyField = Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: priceField,
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

    final participantNumberField = Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: TextFormField(
            initialValue: _service.participantNumber != null ?_service.participantNumber.toString() : "",
            decoration: getInputDecoration(i18n(context, 'number_of_participants')),
            keyboardType: TextInputType.numberWithOptions(),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value.isEmpty)
                return i18n(context, "mandatory_field");
              if(!isNumeric(value))
                return i18n(context,"only_numeric_value");
              return null;
            },
            onSaved: (value) => _service.participantNumber = int.parse(value)
        )
    );

    final colorPickerField = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(height: 10.0),
        Text(i18n(context, 'color')),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              onPressed: _openColorPicker,
              child: Text(i18n(context, "choose_color")),
            ),
        //    const SizedBox(height: 16.0),
            CircleAvatar(
              backgroundColor: _service.color != null ? HexColor(_service.color) : Colors.grey,
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
                  const SizedBox(height: 30.0),
                  nameField,
                  const SizedBox(height: 10.0),
                  priceCurrencyField,
                  const SizedBox(height: 10.0),
                  participantNumberField,
                  colorPickerField,
                ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openColorPicker() async {
    _openDialog(
      i18n(context, "choose_color"),
      MaterialColorPicker(
        allowShades: false,
        onMainColorChange: (Color color) =>
            setState(() => _service.color = HexColor.from(color)),
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
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(i18n(context, 'cancel')),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(i18n(context, 'select')),
            ),
          ],
        );
      },
    );
  }


}



