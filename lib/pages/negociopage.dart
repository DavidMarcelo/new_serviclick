import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:serviclick/pages/pages.dart';
import 'package:serviclick/services/services.dart';
import 'package:serviclick/shared/colores.dart';
import 'package:serviclick/shared/shared.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class NegocioPage extends StatefulWidget {
  String? token;
  NegocioPage({this.token});
  @override
  _NegocioPageState createState() => _NegocioPageState();
}

class _NegocioPageState extends State<NegocioPage> {
  var sub;
  late StreamController _notificacionController;

  Future<dynamic> pagos(Controller controller) async {
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
          'Authorization': 'Bearer ${controller.usuarioActual.remembertoken}',
        },
      );
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        //print(parsed);
        return parsed['count'];
      } else {
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

  Future<dynamic> getregistro(Controller controller) async {
    try {
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
      //print(result12);
      int totalNotificaciones = 0;
      for (int i = 0; i < result12['result'].length; i++) {
        //print(result12['result'][i]);
        if (result12['result'][i]['nuevo'] == 0 &&
            result12['result'][i]['leido'] == 0) {
          print(result12['result'][i]);
          totalNotificaciones++;
        }
      }
      //print("Total de notificaciones2 $totalNotificaciones");
      return totalNotificaciones;
    } catch (e) {
      await controller.internetcheck();
      controller.notify();
      if (controller.internet) {
        print("ERROR --- " + e.toString());
        return 0;
      }
    }
  }

  @override
  void initState() {
    //_notificacionController = StreamController();
    //loadNotifications();
    Controller controller = Provider.of<Controller>(context, listen: false);
    getTotoalN(controller);
    super.initState();
  }

  getTotoalN(controller) async {
    print("Consultar otra vez");
    totalNot = await recibeNotifications(widget.token.toString());
    //totalNot = await getregistro(controller);
    totalPagos = await pagos(controller);
    final prefs = await SharedPreferences.getInstance();
    int? temp = prefs.getInt('totalPagos');
    int? comparePago = prefs.getInt('comparePago');
    bool? pagoRevisado = prefs.getBool('pagoRevisado');
    print(totalPagos);
    print(comparePago);
    print(pagoRevisado);
    if (temp == null && totalPagos == 0 || temp == 0 && totalPagos == 0) {
      //No hay notificaciones y debe ser 0
      await prefs.setInt('totalPagos', 0);
    } else {
      //Sabemos que temp es 0 o algun numero
      if (comparePago == null && pagoRevisado == null) {
        //Accede por primera vez y se agrega el valor
        await prefs.setInt('totalPagos', totalPagos);
      } else {
        //ya existe algun registro
        if (comparePago == totalPagos) {
          if (pagoRevisado == true) {
            //Ya fue revisado
            await prefs.setInt('totalPagos', 0);
          } else {
            //Aun no ha sido revisado
            await prefs.setInt('totalPagos', totalPagos);
          }
        }
        //En caso de que exista una nueva notificacion
        if (totalPagos > comparePago!) {
          await prefs.setInt('totalPagos', totalPagos);
          await prefs.setBool("pagoRevisado", false);
          //Cambiamos el estado de revisado a no revisado.
        }
      }
    }
    /*if (temp == null && totalPagos == null ||
        temp == 0 && totalPagos == 0 ||
        temp == null && totalPagos == 0) {
      await prefs.setInt('totalPagos', 0);
    } else if (temp! > totalPagos) {
      await prefs.setInt('totalPagos', temp);
    } else if (totalPagos > temp) {
      int? comparePago = prefs.getInt('comparePago'); //pagoRevisado
      bool? pagoRevisado = prefs.getBool('pagoRevisado');
      print("ComparePago : $comparePago");
      if (comparePago == null || comparePago == 0) {
        await prefs.setInt('totalPagos', totalPagos);
      } else {
        if (comparePago == totalPagos && pagoRevisado == true) {
          await prefs.setInt('totalPagos', 0);
        } else {
          await prefs.setBool("pagoRevisado", false);
          await prefs.setInt('totalPagos', totalPagos);
        }
      }
    }*/
    setState(() {});
  }

  int totalPagos = 0;
  int totalNot = 0;
  Timer? _timer;
  int _start = 5;

  startTimer(Controller controller) async {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    } else {
      _timer = new Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => setState(
          () {
            if (_start < 1) {
              timer.cancel();
              controller.showDialog1(context, 'Abriendo el navegador', true);
              autoLogIn(controller.usuarioActual.remembertoken!);
              controller.showDialog1(context, 'Abriendo el navegador', false);
              _start = 5;

              return;
            } else {
              _start = _start - 1;
              startTimer(controller);
            }
          },
        ),
      );
    }
  }

  Future recibeNotifications(String token) async {
    //print('DESPUES VIENE EL BODY de las notificaciones xdxd');
    //print(token);

    var url1 = Uri.parse(
      'https://serviclick.com.mx/api/obtener_notificaciones',
    );
    //print(token);

    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      //print("Es diferente todo");
      if (response.body == null) {
      } else {
        final result = await jsonDecode(response.body);
        int totalNotificaciones = result['count'];
        final prefs = await SharedPreferences.getInstance();
        int? temp = prefs.getInt('totalNotificaciones');
        if (temp == null && totalNotificaciones == null ||
            temp == 0 && totalNotificaciones == 0 ||
            temp == null && totalNotificaciones == 0) {
          await prefs.setInt('totalNotificaciones', 0);
        } else if (temp! > totalNotificaciones) {
          await prefs.setInt('totalNotificaciones', temp);
        } else if (totalNotificaciones > temp) {
          await prefs.setInt('totalNotificaciones', totalNotificaciones);
        }

        return totalNotificaciones;
      }
    } else {
      print("Error ${response.statusCode} --- ${response.body}");
      return 'error';
      //throw Exception('something went wrong');
    }
  }

  List<NotificacionModel>? parseJson(String response) {
    final parsed = jsonDecode(response);
    // final parsed2= jsonDecode(parsed['result']);

    return parsed['result']
        .map<NotificacionModel>((json) => NotificacionModel.fromJson(json))
        .toList();
  }

  PageController _pageController = PageController(initialPage: 0);

  String message1 = '';

  NegociosModel? negocioActual;

  @override
  void dispose() {
    super.dispose();
    //_timer.cancel();
    // _notificacionController.close();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int page = 0;
  @override
  Widget build(BuildContext context) {
    //Controller controller = Provider.of<Controller>(context, listen: false);
    //notificacionesF = getregistro(controller);
    Controller controller = Provider.of<Controller>(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: controller.negocioActual!.status == 1
          ? Stack(
              children: [
                Mydrawer(),
              ],
            )
          : null,
      appBar: AppBar(
        title: Row(
          children: [
            Text('ServiClick'),
          ],
        ),
        actions: <Widget>[
          //Scaffold.of(context).openDrawer(),
          // IconButton(
          //     icon: Icon(Icons.one_k),
          //     onPressed: () {
          //       print(controller.negocio);
          //       print('Status ${controller.negocioActual.status}');
          //       print('tramite ${controller.negocioActual.tramites}')  ;            }),

          TextButton.icon(
              onPressed: () async {
                await controller.singOut();
                // controller.singOut();
                print(controller.nombre);
                controller.nombre = '';

                controller.sinIncheck = false;
                controller.negocio = 0;

                controller.notify();
                Navigator.of(context).pushAndRemoveUntil(
                    CupertinoPageRoute(builder: (context) => NewPageFisrt()),
                    (Route<dynamic> route) => false);
              },
              icon: Icon(
                controller.nombre == ''
                    ? Icons.person
                    : FontAwesomeIcons.running,
                size: 25,
                color: Colors.white,
              ),
              label: Text(
                controller.nombre == '' ? 'Iniciar sesión' : 'Cerrar sesión',
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
      //
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,

      floatingActionButton: Container(
        padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Gifi()));
          },
          child: Icon(Icons.home),
          backgroundColor: primaryDark,
          hoverColor: buttonColor,
          splashColor: secundaryColor,
          focusColor: buttonColor,
          tooltip: 'Ir al inicio',
        ),
      ),
      body: controller.negocioActual!.status == 1
          ? Stack(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset('assets/Serviclic304.png'),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset('assets/Serviclic305.png'),
                ),
                SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: primaryDark, width: 2),
                                borderRadius: BorderRadius.circular(360)),
                            height: 200,
                            width: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(360),
                              child: FadeInImage(
                                fit: BoxFit.cover,
                                image: controller
                                        .negocioActual!.imagenUrl!.isNotEmpty
                                    ? NetworkImage(controller.negocioActual!
                                        .imagenUrl!) as ImageProvider
                                    : AssetImage('assets/logo01.png'),
                                placeholder: AssetImage('assets/logo01.png'),
                              ),
                            )),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Bienvenido: ${controller.negocioActual!.nombre}',
                          style: TextStyle(fontSize: 25),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        controller.negocioActual!.status == 1
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                        'Éste es el panel de control para empresas, desde aquí puedes modificar tu información y checar tus pagos, además de ver el registro de actividad.'),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        'Para continuar con el proceso dirijete a la página e inicia sesión'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(FontAwesomeIcons.globe),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'https://serviclick.com.mx/',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                      onTap: () =>
                                          launch('https://serviclick.com.mx/'),
                                    ),
                                  )
                                ],
                              ),
                        controller.negocioActual!.status == 1
                            ? Expanded(
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.only(bottom: 100),
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.grey[50]),
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                              'Presiona el botón para ver más opciones.'),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(5),
                                        padding: EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(360),
                                            color: Colors.grey[50]),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.menu,
                                            color: Colors.black,
                                          ),
                                          onPressed: () => _scaffoldKey
                                              .currentState!
                                              .openDrawer(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : FutureBuilder(
              future: waitin(controller),
              //initialData: InitialData,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            'assets/5.png',
                          ),
                          fit: BoxFit.cover)),
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                            'En unos segundos serás redirigdo a ServiClick web.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                              height: 75,
                              width: 75,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(360)),
                              child: Text('$_start',
                                  style: TextStyle(
                                      fontSize: 50, color: Colors.white))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10, top: 5),
                        width: double.infinity,
                        color: Colors.black38,
                        child: Column(
                          children: [
                            Text(
                                'O puedes ingresar a través del siguiente botón ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            ElevatedButton(
                                onPressed: () async {
                                  //  startTimer(controller);
                                  controller.showDialog1(
                                      context, 'Abriendo el navegador', true);
                                  await autoLogIn(
                                      controller.usuarioActual.remembertoken!);
                                  controller.showDialog1(
                                      context, 'obteniendo el link', false);
                                },
                                child: Text('Ingresa aquí'))
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future waitin(Controller controller) async {
    startTimer(controller);

    // await autoLogIn(controller.usuarioActual.remembertoken);
  }

  String autlogin = '';
  int count = 10;
  Future autoLogIn(String token) async {
    print('Ando por aqui');
    var url = Uri.parse('https://serviclick.com.mx/api/link-acceso');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body == null) {
        return Fluttertoast.showToast(
            msg: 'Algo ha salido mal ingrese nuevamente');
      } else {
        var response1 = jsonDecode(response.body);
        autlogin = response1['result'];
        // await Future.delayed(Duration(seconds: 5));
        //Navigator.pop(context);
        await canLaunch(autlogin)
            ? launch(autlogin)
            : Fluttertoast.showToast(
                msg: 'No tienes ningun navegador instalado');
        await Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => NewPageFisrt()),
            (route) => false);

        return autlogin;
      }
    } else {
      return Fluttertoast.showToast(
          msg: 'Algo ha salido mal intente nuevamente');
    }
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}
