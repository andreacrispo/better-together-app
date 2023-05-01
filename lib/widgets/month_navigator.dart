
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../utils/utils.dart';

class MonthNavigatorWidget extends StatelessWidget {

  const MonthNavigatorWidget({
    @required this.currentMonth,
    @required this.currentYear,
    @required this.changeMonthCallback,
    @required this.previousMonthCallback,
    @required this.nextMonthCallback,
    Key key
  }) : super(key: key);

  final int currentMonth;
  final int currentYear;
  final Function(int,int) changeMonthCallback;
  final Function(int,int) previousMonthCallback;
  final Function(int,int) nextMonthCallback;


  @override
  Widget build(BuildContext context) {
    final Locale locale = FlutterI18n.currentLocale(context);
    final String currentMonthFormatted = localeMonthString[locale.languageCode][currentMonth];

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.arrow_back),
              color: Theme.of(context).textTheme.labelLarge.color,
              onPressed: () =>  previousMonthCallback(currentMonth, currentYear)
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "$currentMonthFormatted $currentYear",
                style: TextStyle(fontSize: 32),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                color: Theme.of(context).textTheme.labelLarge.color,
                onPressed: () {
                  showMonthPicker(
                    initialDate: DateTime(currentYear, currentMonth),
                    context: context,
                  ).then((dateTime) {
                    changeMonthCallback(dateTime.month, dateTime.year);
                  });
                },
              )
            ],
          ),
          IconButton(
              icon: Icon(Icons.arrow_forward),
              color: Theme.of(context).textTheme.labelLarge.color,
              onPressed: () => nextMonthCallback(currentMonth, currentYear)),
        ]
    );
  }


  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('currentYear', currentYear));
    properties.add(IntProperty('currentMonth', currentMonth));
    properties.add(DiagnosticsProperty<Function(int p1, int p2)>('changeMonthCallback', changeMonthCallback));
    properties.add(DiagnosticsProperty<Function(int p1, int p2)>('previousMonthCallback', previousMonthCallback));
    properties.add(DiagnosticsProperty<Function(int p1, int p2)>('nextMonthCallback', nextMonthCallback));
  }


}
