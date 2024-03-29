
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';

@immutable
class HasPaidWidget extends StatelessWidget {

  const HasPaidWidget({@required this.hasPaid, @required this.callback, Key key}) : super(key: key);

  final bool hasPaid;
  final Function(bool) callback;

  @override
  Widget build(BuildContext context) {
    return  TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: hasPaid ? Colors.green : Colors.red,
        textStyle: TextStyle(color: Colors.white),
        padding: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      onPressed: () {
        callback(!hasPaid);
      },
      child: Text(
        hasPaid ? i18n(context, 'paid') : i18n(context, 'not_paid'),
        style: TextStyle(fontSize: 10.0),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
          ..add(DiagnosticsProperty<bool>('hasPaid', hasPaid))
          ..add(DiagnosticsProperty<Function(bool)>('callback', callback));
  }
}