import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:serviclick/pages/negociopage.dart';
import 'package:serviclick/services/services.dart';
import 'package:http/http.dart' as http;
import 'package:serviclick/shared/colores.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PagosNegocios extends StatefulWidget {
  @override
  _PagosNegociosState createState() => _PagosNegociosState();
}

class _PagosNegociosState extends State<PagosNegocios> {
  Future? pagos1;

  @override
  void initState() {
    super.initState();
    Controller controller = Provider.of<Controller>(context, listen: false);
    pagos1 = pagos(controller.usuarioActual.remembertoken, controller);
    quitarNotificaciones();
  }

  Future quitarNotificaciones() async {
    print("Quitar y revisar");
    final prefs = await SharedPreferences.getInstance();
    int? totalPagos = prefs.getInt('totalPagos');
    int? comparePago = prefs.getInt('comparePago');
    bool? pagoRevisado = prefs.getBool('pagoRevisado');
    /**
     * Lo que tenemos que hacer aqui es poner el total de pagos a 0 en caso de ser la primera vez en entrar,
     * en caso de que ya halla entrado comprar si el pago ya fue revisado anterior mente y saber si no hay alguna
     * notificacion nueva para pago.
     * 
     */
    print(totalPagos);
    print(comparePago);
    print(pagoRevisado);
    if (comparePago == null && pagoRevisado == null) {
      await prefs.setInt('totalPagos', 0);
      await prefs.setInt(
          'comparePago', totalPagos!); //Agregar el valor del pago
      await prefs.setBool("pagoRevisado", true); //Revisado
    } else {
      if (pagoRevisado == false) {
        //False por si aun no ha sido revisado
        await prefs.setInt('totalPagos', 0);
        await prefs.setInt(
            'comparePago', totalPagos!); //Agregar el valor del pago
        await prefs.setBool("pagoRevisado", true); //Revisado
      } else {
        //True por si ya fue revisado
        await prefs.setInt('totalPagos', 0);
      }
    }
    /*if (pagoRevisado == null) {
      await prefs.setBool("pagoRevisado", true);
      await prefs.setInt('comparePago', comparePago!);
    } else {
      if (pagoRevisado == false) {
        await prefs.setBool("pagoRevisado", true);
        await prefs.setInt('comparePago', comparePago!);
      }
    }

    await prefs.setInt('totalPagos', 0);*/
  }

  Future<dynamic> pagos(String? token, Controller controller) async {
    try {
      //print("consulta pagos");
      var url1 = Uri.parse(
        'https://serviclick.com.mx/api/historial_pagos',
      );
      final response = await http.post(
        url1,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        //print(parsed);
        return parsed['result']
            .map<PAgosModel>((json) => PAgosModel.fromJson(json))
            .toList();
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

  Future<dynamic> fichas(Controller controller) async {
    try {
      print("consulta ficha");
      var url1 = Uri.parse(
        'https://serviclick.com.mx/api/ficha',
      );
      final response = await http.post(
        url1,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json',
          'Authorization': 'Bearer ${controller.usuarioActual.remembertoken}',
        },
      );
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed["result"].toString() != "null") {
          var res = parsed['result']
              .map<PAgosModel>((json) => PAgosModel.fromJson(json))
              .toList();
          //print(res);
          return parsed['result']
              .map<PAgosModel>((json) => PAgosModel.fromJson(json))
              .toList();
        } else {
          return;
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

  //List<PAgosModel> pagosList = [];
  bool cargando = false;
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
          title: Text('Pagos'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      alignment: Alignment.bottomRight,
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset(
                        'assets/Serviclic0404.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: controller.internet
                          ? FutureBuilder(
                              future: pagos1,
                              builder: (context, snapshots) {
                                if (snapshots.hasData) {
                                  if (snapshots.data == "error") {
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.warning_amber,
                                            color: Colors.grey.withOpacity(0.6),
                                            size: 40,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                              'Ocurrió un error al obtener los pagos'),
                                        ],
                                      ),
                                    );
                                  }

                                  if (snapshots.data.toString() == "[]" ||
                                      snapshots.data == null) {
                                    return Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 50),
                                        alignment: Alignment.center,
                                        child: Center(
                                          child: Text(
                                              'No hay nada para mostrar',
                                              style: TextStyle(fontSize: 20)),
                                        ));
                                  } else {
                                    final list =
                                        snapshots.data as List<PAgosModel>;
                                    return ListPagos(
                                      pagos: list,
                                    );
                                  }
                                } else {
                                  return Container(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('Obteniendo pagos...'),
                                      ],
                                    ),
                                  );
                                }
                              },
                            )
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Por favor, verifica tu conexión y vuelve a intentarlo.\n",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[700]),
                                    ),
                                    TextButton(
                                        onPressed: () async {
                                          if (await controller
                                              .internetcheck()) {
                                            pagos1 = pagos(
                                                controller.usuarioActual
                                                    .remembertoken,
                                                controller);
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: controller.internet
            ? FloatingActionButton.extended(
                label:
                    cargando ? Text('Buscando...') : Text('Ver ficha del mes'),
                onPressed: () async {
                  controller.showDialog1(context, 'Buscando...', true);
                  var ficha = await fichas(controller);
                  print("Valor de la ficha ");
                  print(ficha);
                  controller.showDialog1(context, 'Buscando', false);
                  if (controller.internet == true) {
                    late FichaModel fichamodel;
                    if (ficha == "error") {
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('ok'))
                              ],
                              title: Text('Algo salió mal'),
                              content:
                                  Text('Por favor, intenta de nuevo más tarde'),
                            );
                          });
                    }
                    if (ficha == null) {
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('ok'))
                              ],
                              title: Text('Nada para mostrar'),
                              content:
                                  Text('Sin ficha disponible por el momento'),
                            );
                          });
                    } else {
                      fichamodel = FichaModel.fromJson(ficha);
                      return showDialog(
                          useSafeArea: false,
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: SimpleDialog(
                                titlePadding:
                                    EdgeInsets.only(left: 15, right: 15),
                                title: Container(
                                    margin:
                                        EdgeInsets.only(left: 15, right: 15),
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    color: Colors.black,
                                    child: Center(
                                        child: Text(
                                      'FICHA DIGITAL, NO ES NECESARIO IMPRIMIR.',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ))),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                children: [
                                  ficha3(context, fichamodel)
                                  // Html(data: ficha)
                                ],
                                insetPadding: EdgeInsets.only(
                                    top: 50, bottom: 0, left: 10, right: 10),
                                contentPadding: EdgeInsets.all(0),
                              ),
                            );
                          });
                    }
                  } else {
                    return showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return WillPopScope(
                            onWillPop: () async {
                              return false;
                            },
                            child: AlertDialog(
                              title: Text('Sin conexión'),
                              content: Text(
                                  'Verifica tu conexión a internet y vuelve a intentarlo'),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      exit(0);
                                    },
                                    child: Text('Salir')),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Reintentar'))
                              ],
                            ),
                          );
                        });
                  }
                })
            : Container());
  }

  Widget ficha3(BuildContext context, FichaModel ficha) {
    var ancho = MediaQuery.of(context).size.width;
    var largo = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.only(top: 20),
                    width: ancho * .4,
                    child: Image.asset('assets/oxxopay.png'),
                  ),
                  SizedBox(
                    width: ancho * .05,
                  ),
                  Container(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    width: ancho * .4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'MONTO A PAGAR',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 40,
                            ),
                            Text(
                              ficha.monto.toString(),
                              style: TextStyle(fontSize: 40),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Align(
                              child: Text(ficha.moneda!),
                              alignment: Alignment.topRight,
                            )
                          ],
                        ),
                        Text(
                          'OXXO cobrará una comisión adicional al momento de realizar el pago.',
                          style: TextStyle(fontSize: 11),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: largo * .05,
              ),
              Column(
                children: [
                  Text(
                    'REFERENCIA',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: largo * .01),
                  Container(
                    padding:
                        EdgeInsets.only(top: 5, left: 30, right: 30, bottom: 5),
                    child: Text(
                      ficha.referencia!,
                      style: TextStyle(fontSize: 30),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[200],
                        border: Border.all()),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: largo * .03,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: .1, color: Colors.grey[700]!),
            color: Colors.grey[100],
          ),
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          width: ancho,
          child: Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(left: 15, right: 15, top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'INSTRUCCIONES',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Text('1.'),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('Acude a la tienda OXXO más cercana.'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 17, bottom: 5),
                  child: GestureDetector(
                    child: Text(
                      'Encuéntrala aquí.',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () =>
                        launch('https://www.google.com.mx/maps/search/oxxo/'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2.'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 5),
                        child: Text(
                            'Indica en caja que quieres realizar un pago de OXXOPay.'),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('3.'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 5),
                        child: Text(
                            'Dicta al cajero el número de referencia en esta ficha para que tecleé directamete en la pantalla de venta.'),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('4.'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 5),
                        child: Text(
                            'Realiza el pago correspondiente con dinero en efectivo.'),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('5.'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 10),
                        child: Text(
                            'Al confirmar tu pago, el cajero te entregará un comprobante impreso. En el podrás verificar que se haya realizado correctamente. Conserva este comprobante de pago.'),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.green[700]!),
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          'Al completar estos pasos recibirás un correo de ServiClick confirmando tu pago.',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ancho * .07,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class ListPagos extends StatelessWidget {
  List<PAgosModel>? pagos;
  ListPagos({this.pagos});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.grey[300],
                child: ListTile(
                  leading: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.dollarSign,
                          color: Colors.yellow[700]),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        pagos![index].total!,
                        style: TextStyle(color: primaryColor),
                      ),
                    ],
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pagos![index].periodo!,
                        style: TextStyle(fontSize: 20, color: primaryColor),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(pagos![index].pagado!,
                          style: TextStyle(fontSize: 15, color: primaryColor)),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.handshake,
                        color: primaryColor,
                      ),
                      Text(
                        pagos![index].status!,
                        style: TextStyle(color: primaryColor),
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: pagos!.length),
      ],
    );
  }
}
