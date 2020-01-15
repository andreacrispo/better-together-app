
import 'package:better_together_app/utils/utils.dart';
import 'package:flutter/material.dart';

class HasPaidWidget extends StatelessWidget {
  final bool hasPaid;
  final Function(bool) callback;
  HasPaidWidget({Key key, @required this.hasPaid, @required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: hasPaid ? Colors.green : Colors.red,
      textColor: Colors.white,
      padding: EdgeInsets.all(8.0),
      onPressed: () {
        callback(!hasPaid);
      },
      child: Text(
        hasPaid ? i18n(context, 'paid') : i18n(context, 'not_paid'),
        style: TextStyle(fontSize: 10.0),
      ),
    );
  }
}