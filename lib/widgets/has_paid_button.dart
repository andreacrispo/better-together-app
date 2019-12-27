
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
        hasPaid ? 'Paid' : 'NOT Paid',
        style: TextStyle(fontSize: 10.0),
      ),
    );
  }
}