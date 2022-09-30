import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:serviclick/pages/negociopage.dart';
import 'package:serviclick/services/services.dart';
import 'package:serviclick/shared/colores.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrodeActividad extends StatefulWidget {
  @override
  State<RegistrodeActividad> createState() => _RegistrodeActividadState();
}

class _RegistrodeActividadState extends State<RegistrodeActividad> {
  Future<dynamic> getregistro(Controller controller) async {
    try {
      /*print("Obtener notificaciones ");
      var url =
          Uri.parse('https://serviclick.com.mx/api/obtener_notificaciones');
      final resp = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json',
          'Authorization': 'Bearer ${controller.usuarioActual.remembertoken}',
        },
      );
      final result1 = await jsonDecode(resp.body);
      print("Resultado 1:");
      print(result1);*/
      print('consulta notificaciones Listar');
      var url1 = Uri.parse(
        'https://serviclick.com.mx/api/listar_notificaciones',
      );
      final response = await http.post(
        url1,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json',
          'Authorization': 'Bearer ${controller.usuarioActual.remembertoken}',
        },
      );
      final result12 = await jsonDecode(response.body);
      //print("Resultado 2:");
      //print(result12);
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed["result"].toString() == "null" ||
            parsed["result"].toString() == "[]") {
          return;
        } else {
          return parsed['result']
              .map<NotificacionModel>(
                  (json) => NotificacionModel.fromJson(json))
              .toList();
        }
      } else {
        print("error " +
            response.statusCode.toString() +
            " --- " +
            response.body.toString());
        return "error";
      }
    } catch (e) {
      await controller.internetcheck();
      controller.notify();
      if (controller.internet) {
        print("ERROR --- " + e.toString());
        return "error";
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Controller controller = Provider.of<Controller>(context, listen: false);
    notificacionesF = getregistro(controller);
    quitarNotificaciones();
  }

  Future quitarNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalNotificaciones', 0);
  }

  Future? notificacionesF;

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            //Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NegocioPage(token: controller.rememberToken),
              ),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text('Registro'),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            controller.internet
                ? FutureBuilder(
                    future: notificacionesF,
                    builder: (context, snapshots) {
                      if (snapshots.hasData) {
                        print("Accedo en has Data");
                        //print(snapshots.data);
                        if (snapshots.data == "error") {
                          return Container(
                              height: MediaQuery.of(context).size.height,
                              child: Center(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(Icons.warning_amber,
                                      color: Colors.grey.withOpacity(0.6),
                                      size: 40),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Ocurrió un error al cargar datos')
                                ],
                              )));
                        }
                        if (snapshots.data == null) {
                          print("Etras aqui perro?");
                          return Container(
                              height: MediaQuery.of(context).size.height,
                              // padding: EdgeInsets.symmetric(vertical: 50),
                              alignment: Alignment.center,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 50,
                                      child: Image(
                                          image: AssetImage(
                                              'assets/images/logo02.png')),
                                    ),
                                    Text('No hay nada para mostrar',
                                        style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                              ));
                        } else {
                          print("Mostrar notificaciones");
                          //if (snapshots.data != null) {
                          final noti =
                              snapshots.data as List<NotificacionModel>;
                          print(noti[0].notificacion);
                          print(noti[0].leido);
                          return NotificationList(
                            notificacion: noti,
                          );
                        }
                      } else {
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            child: Center(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Cargando...')
                              ],
                            )));
                      }
                    })
                : Center(
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Icon(Icons.wifi_off_rounded, size: 40),
                          Text(
                            "No tienes acceso a internet",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Por favor, verifica tu conexión y vuelve a intentarlo.\n",
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
                          ),
                          TextButton(
                              onPressed: () async {
                                if (await controller.internetcheck()) {
                                  notificacionesF = getregistro(controller);
                                  setState(() {});
                                } else {
                                  return;
                                }
                              },
                              child: Text("Reintentar",
                                  style: TextStyle(fontSize: 15)))
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class NotificationList extends StatefulWidget {
  List<NotificacionModel>? notificacion;
  NotificationList({this.notificacion});

  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<NotificacionModel>? notificacionactual;

  Widget build(BuildContext context) {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.notificacion!.length,
        itemBuilder: (context, index) {
          /*if (widget.notificacion![index].leido == 1) {
            return Container();
          } else {*/
          return widget.notificacion!.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    NotificacionCard(
                      notificacion: widget.notificacion![index],
                    ),
                  ],
                )
              : CircularProgressIndicator();
          //}
        });
  }
}

// ignore: must_be_immutable
class NotificacionCard extends StatelessWidget {
  NotificacionModel? notificacion;
  NotificacionCard({this.notificacion});
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return GestureDetector(
      onTap: () async {
        print("Borrar la notificacion leída");
        print(notificacion!.id);
        leerNotificacion(controller, this.notificacion!.id);
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              elevation: 5,
              child: Column(
                children: [
                  ListTile(
                    leading: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 7),
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(360),
                              color: Colors.grey[400]),
                          height: MediaQuery.of(context).size.height * .2,
                          width: MediaQuery.of(context).size.width * .15,
                          child: Icon(
                            FontAwesomeIcons.userAlt,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          FontAwesomeIcons.solidBell,
                          color: Colors.amber[800],
                        )
                      ],
                    ),
                    title: Text(
                      notificacion!.fecha! + " " + notificacion!.hora!,
                      style: TextStyle(color: primaryColor),
                    ),
                    subtitle: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(notificacion!.notificacion!)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future leerNotificacion(Controller controller, int? id) async {
    print("Leer notificaciones ");
    var url = Uri.parse('https://serviclick.com.mx/api/leer_notificacion');
    final resp = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer ${controller.usuarioActual.remembertoken}',
      },
      body: jsonEncode(<String, String?>{"notificacion": id.toString()}),
    );
    final result1 = await jsonDecode(resp.body);
    //print("Resultado 1:");
    //print(result1);
  }
}
