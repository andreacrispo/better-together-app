
import 'package:better_together_app/serviceDetail.dart';
import 'package:better_together_app/serviceForm.dart';
import 'package:better_together_app/utils.dart';
import 'package:flutter/material.dart';

import 'package:better_together_app/repository/ServiceRepository.dart';
import 'package:better_together_app/repository/DataRepository.dart';
import 'package:better_together_app/model/ServiceParticipantEntity.dart';

import 'model/ServiceEntity.dart';


class ServiceListWidget extends StatefulWidget {
  ServiceListWidget({Key key}) : super(key: key);
  static const routeName = '/serviceList';


  @override
  State<StatefulWidget> createState() => _ServiceListWidgetState();
}

class _ServiceListWidgetState extends State<ServiceListWidget> {

  DataRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = ServiceRepository();
  }

  @override
  void dispose() async {
    super.dispose();
 //   await _repository.closeDB();
  }

  void createNewService(BuildContext context) async {
    ServiceEntity newItem = await Navigator.pushNamed<ServiceEntity>(context, ServiceForm.routeName);

    if (newItem != null) {
      await _repository.create(newItem)
        .then((value) {
          setState(() {});
        })
        .catchError((error) => Scaffold.of(context).showSnackBar(createSnackBar(error.toString())));
    }
  }

  void deleteService(ServiceEntity item) async {
    if (item != null) {
      await _repository.delete(item.serviceId);
      setState(() {});
    }
  }

  Card createCardService( ServiceEntity service) {
    var now = new DateTime.now();
    Color backgroundColor = service.color != null ? Color(service.color) : Color.fromRGBO(64, 75, 96, .9);
    return Card(
      elevation: 4.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
        ),
        child:
          ListTile(
            onTap: () {
              Navigator.pushNamed(context,
                  ServiceDetailWidget.routeName,
                  arguments: ServiceDetailArgs(
                      serviceId: service.serviceId,
                      monthPaid: now.month,
                      yearPaid: now.year
                  )
              );
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            /*
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: new BoxDecoration(
                  border: new Border(
                      right: new BorderSide(width: 1.0, color: Colors.white24))),
              child: Icon(Icons.autorenew, color: Colors.white),
            ),
            */
            title: Text(
              "${service.name}",
               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
            ),
            subtitle: Text(
                "${service.monthlyPrice} € / monthly",
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.right
            ),
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      FutureBuilder<List<ServiceEntity>>(
        future: _repository.getAll(),
        builder: (BuildContext context, AsyncSnapshot<List<ServiceEntity>> snapshot) {
          return ListView.builder(
            padding: EdgeInsets.all(8),
            shrinkWrap: true,
            itemCount: snapshot.data == null ? 0 : snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(index.toString()),
                background: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.red),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  ServiceEntity item = snapshot.data[index];
                  snapshot.data.removeAt(index);
                  deleteService(item);
                },
                child: createCardService(snapshot.data[index])
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>  createNewService(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

