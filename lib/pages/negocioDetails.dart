import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:serviclick/main.dart';
import 'package:serviclick/services/controller.dart';

import 'package:serviclick/services/models.dart';
import 'package:serviclick/shared/colores.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class NegocioDetails extends StatefulWidget {
  NegociosModel? negocio;

  NegocioDetails({this.negocio});

  @override
  _NegocioDetailsState createState() => _NegocioDetailsState();
}

class _NegocioDetailsState extends State<NegocioDetails> {
  TextEditingController textEditingController = TextEditingController();
  Future<dynamic> comentarios(int? id, Controller controller) async {
    try {
      print("consulta comentarios");
      var url1 = Uri.parse(
        'https://serviclick.com.mx/api/comentarios_negocio',
      );
      final response = await http
          .post(
            url1,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, int?>{
              'negocio': id,
            }),
          )
          .timeout(Duration(seconds: 20));
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var finalResult = parsed['result']
            .map<ComentarioModel>((json) => ComentarioModel.fromJson(json))
            .toList();
        return finalResult;
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

  Future<dynamic> getFotos(int? id, Controller controller) async {
    try {
      print("consulta galería");
      var url1 = Uri.parse(
        'https://serviclick.com.mx/api/galeria_negocio',
      );
      final response = await http
          .post(
            url1,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, int?>{
              'negocio': id,
            }),
          )
          .timeout(Duration(seconds: 20));
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var finalResult = parsed['result']
            .map<GaleriaModel>((json) => GaleriaModel.fromJson(json))
            .toList();
        return finalResult;
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

  Future<dynamic> redes(int? id, Controller controller) async {
    try {
      print("consulta redes sociales");
      var url1 = Uri.parse(
        'https://serviclick.com.mx/api/redes_negocio',
      );
      final response = await http
          .post(
            url1,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, int?>{
              'negocio': id,
            }),
          )
          .timeout(Duration(seconds: 20));
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var finalResult = parsed['result']
            .map<RedesModel>((json) => RedesModel.fromJson(json))
            .toList();
        return finalResult;
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

  Future<dynamic> notificacionLocal(tipo) async {
    String? contenido;
    if (tipo == 1) {
      contenido =
          "Sigue disfrutando de la lista de servicios que tenemos para ti.";
    } else if (tipo == 2) {
      contenido =
          "Te has comunicado con un Negocio, por favor espera su respuesta!";
    }
    flutterLocalNotificationsPlugin.show(
      0,
      "Servicio ServiClick",
      contenido,
      NotificationDetails(
        android: AndroidNotificationDetails(
          chanel.id,
          chanel.name,
          //chanel.description,
          color: Colors.blue,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<dynamic> sedFirebaseApi(int? negocio) async {
    print("SedFirebaseApi $negocio");
    var url1 = Uri.parse(
      'https://serviclick.com.mx/api/send-firebase',
    );
    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int?>{
        'negocio': negocio,
        'notificacion': 8,
      }),
    );
    final respose1 = jsonDecode(response.body);
    //Enviar una notificacion local
    notificacionLocal(1);

    return respose1['result'];
  }

  Future<dynamic> saveFirebaseApi(int? negocio) async {
    print("Rememebar token $negocio");
    var url1 = Uri.parse(
      'https://serviclick.com.mx/api/enviar_notificacion',
    );
    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        //'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, int?>{
        'negocio': negocio,
        'tipo': 8,
      }),
    );
    final respose1 = jsonDecode(response.body);
    //print(respose1);
    //notificacionLocal();
    return respose1['result'];
  }

  RegExp exp = RegExp(r"<[^>]*>", caseSensitive: true, multiLine: true);
  String? thi;
  @override
  void initState() {
    super.initState();
    Controller controller = Provider.of<Controller>(context, listen: false);
    imgUrl = widget.negocio!.imagenUrl;
    redesF = redes(widget.negocio!.id, controller);
    galeriaF = getFotos(widget.negocio!.id, controller);
    comentariosF = comentarios(widget.negocio!.id, controller);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future? redesF, galeriaF, comentariosF;
  late List mapa;
  double? lat;
  double? long;
  String? imgUrl;
  late DateTime hola;
  int _messageCount = 0;

  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  String constructFCMPayload(String? token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  Widget build(BuildContext context) {
    mapa = widget.negocio!.mapa!.split(',');
    lat = double.parse(mapa[0]);
    long = double.parse(mapa[1]);
    Controller controller = Provider.of<Controller>(context);
    Completer<GoogleMapController> _controller = Completer();
    List<Marker> marcador = [
      Marker(
          markerId: MarkerId('negocioMarker'),
          draggable: false,
          onTap: () {
            // print(lat);
            controller.openMap(lat, long);
          },
          infoWindow: InfoWindow(title: '${widget.negocio!.nombre}'),
          position: LatLng(lat!, long!))
    ];
    thi = widget.negocio!.servicios!.replaceAll(exp, '');
    var largo = MediaQuery.of(context).size.height;
    var ancho = MediaQuery.of(context).size.width;

    return controller.internet
        ? DefaultTabController(
            length: 3,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text(widget.negocio!.nombre!),
                bottom: TabBar(
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 3,
                  tabs: <Widget>[
                    Tab(
                      text: 'Detalles',
                    ),
                    Tab(
                      text: 'Fotos',
                    ),
                    Tab(
                      text: 'Comentarios',
                    ),
                  ],
                ),
              ),
              body: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: <Widget>[
                          //Detalles
                          Container(
                            color: Colors.grey[350],
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Card(
                                    elevation: 5,
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: Alignment.bottomLeft,
                                          children: [
                                            Container(
                                                color: Colors.white,
                                                width: ancho,
                                                height: largo / 2.5,
                                                child: Hero(
                                                  tag: widget.negocio!.id!,
                                                  child: FadeInImage(
                                                    fit: BoxFit.contain,
                                                    image: NetworkImage(widget
                                                        .negocio!.imagenUrl!),
                                                    placeholder: AssetImage(
                                                        'assets/logo01.png'),
                                                  ),
                                                )),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        FutureBuilder(
                                          future: redesF,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (snapshot.data == "error") {
                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15,
                                                      horizontal: 100),
                                                  child: Column(
                                                    children: [
                                                      Text('Ocurrió un error'),
                                                      SizedBox(height: 10),
                                                      Icon(Icons.warning_amber,
                                                          color: Colors.grey
                                                              .withOpacity(0.6),
                                                          size: 25),
                                                    ],
                                                  ),
                                                );
                                              }
                                              final list = snapshot.data
                                                  as List<RedesModel>?;
                                              return Column(
                                                children: [
                                                  /*IconButton(
                                                    icon: Icon(
                                                      Icons.abc,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Application()));
                                                    },
                                                  ),*/
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10,
                                                        vertical: 0),
                                                    child: ListTile(
                                                      minVerticalPadding: 0,
                                                      leading: Icon(
                                                        Icons.call,
                                                        size: 18,
                                                        color: primaryDark,
                                                      ),
                                                      onTap: () async {
                                                        await canLaunch(
                                                                "tel://${widget.negocio!.telefono}")
                                                            ? await launch(
                                                                "tel://${widget.negocio!.telefono}")
                                                            : Fluttertoast
                                                                .showToast(
                                                                    msg:
                                                                        'No se ha podido lanzar el teléfono');
                                                        var ok =
                                                            await sedFirebaseApi(
                                                                widget.negocio!
                                                                    .id);
                                                        var ok1 =
                                                            await saveFirebaseApi(
                                                                widget.negocio!
                                                                    .id);
                                                        /*await mensajeWhatsapp(
                                                            widget.negocio!
                                                                .telefono!,
                                                            controller
                                                                .usuarioActual
                                                                .remembertoken);*/
                                                        /*if (ok != null) {
                                                          if (ok) {
                                                            if (controller
                                                                .sinIncheck) {
                                                              print(
                                                                  "Esta parte es felicidad");
                                                              var ok1 =
                                                                  await saveFirebaseApi(
                                                                      widget
                                                                          .negocio!
                                                                          .id);
                                                            }
                                                          }
                                                        } else {
                                                          print("No hay token");
                                                        }*/
                                                      },
                                                      minLeadingWidth: 10,
                                                      title: Text(widget
                                                          .negocio!.telefono!),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          widget.negocio!
                                                                      .puntuacion
                                                                      .toString() !=
                                                                  '0'
                                                              ? Text(
                                                                  widget
                                                                      .negocio!
                                                                      .puntuacion!
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black),
                                                                )
                                                              : Text(
                                                                  widget
                                                                      .negocio!
                                                                      .puntuacion!
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Icon(
                                                            Icons.star,
                                                            size: 25,
                                                            color: Colors
                                                                .amber[800],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(),
                                                  //Numero de whatsapp
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10,
                                                        vertical: 0),
                                                    child: ListTile(
                                                      minVerticalPadding: 0,
                                                      leading: Icon(
                                                        FontAwesomeIcons
                                                            .whatsappSquare,
                                                        size: 20,
                                                        color: Color.fromARGB(
                                                            255, 62, 173, 6),
                                                      ),
                                                      onTap: () async {
                                                        //var phone = 9613632725;
                                                        var text =
                                                            'Hola.\nMe contacto contigo a través de la aplicación Serviclick "Directorio de Negocios", para solicitar información.\nGracias';
                                                        var whatsapp =
                                                            "+52${widget.negocio!.telefono!}";
                                                        var whatsappURl_android =
                                                            "whatsapp://send?phone=" +
                                                                whatsapp +
                                                                "&text=$text";
                                                        var whatappURL_ios =
                                                            "https://wa.me/$whatsapp?text=${Uri.parse("$text")}";
                                                        if (Platform.isIOS) {
                                                          // for iOS phone only
                                                          notificacionLocal(2);
                                                          if (await canLaunch(
                                                              whatappURL_ios)) {
                                                            await launch(
                                                                whatappURL_ios,
                                                                forceSafariVC:
                                                                    false);
                                                          } else {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Whattsapp no instalado");
                                                          }
                                                        } else {
                                                          // android , web
                                                          if (await canLaunch(
                                                              whatsappURl_android)) {
                                                            await launch(
                                                                whatsappURl_android);
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(SnackBar(
                                                                    content:
                                                                        new Text(
                                                                            "whatsapp no installed")));
                                                          }
                                                        }
                                                      },
                                                      minLeadingWidth: 10,
                                                      title: Text(
                                                          "Enviar un mensaje..."),
                                                    ),
                                                  ),
                                                  widget.negocio!.web == ''
                                                      ? Container()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 0),
                                                          child: ListTile(
                                                            leading: Icon(
                                                              FontAwesomeIcons
                                                                  .globe,
                                                              size: 18,
                                                              color:
                                                                  primaryDark,
                                                            ),
                                                            minLeadingWidth: 10,
                                                            onTap: () async => widget
                                                                    .negocio!
                                                                    .web!
                                                                    .contains(
                                                                        'http')
                                                                ? await canLaunch(widget
                                                                        .negocio!
                                                                        .web!
                                                                        .trim())
                                                                    ? await launch(widget
                                                                        .negocio!
                                                                        .web!
                                                                        .trim())
                                                                    : Fluttertoast.showToast(
                                                                        msg:
                                                                            'No se ha podido abrir el navegador')
                                                                : await canLaunch('https://' +
                                                                        widget
                                                                            .negocio!
                                                                            .web!
                                                                            .trim())
                                                                    ? await launch(
                                                                        'https://' + widget.negocio!.web!.trim())
                                                                    : Fluttertoast.showToast(msg: 'No se ha podido abrir el navegador'),
                                                            title: Text(
                                                              widget.negocio!
                                                                  .web!,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        ),
                                                  list!.isEmpty
                                                      ? Container()
                                                      : Container(
                                                          height: 50.0 *
                                                              list.length,
                                                          child:
                                                              ListView.builder(
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            shrinkWrap: false,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              // print(
                                                              //     'IMPRIMIENDO AQUI');
                                                              // print(redes1);
                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        15,
                                                                    horizontal:
                                                                        15),
                                                                child:
                                                                    GestureDetector(
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        list[index].nombre!.toLowerCase() ==
                                                                                'facebook'
                                                                            ? FontAwesomeIcons.facebook
                                                                            : list[index].nombre!.toLowerCase() == 'twitter'
                                                                                ? FontAwesomeIcons.twitter
                                                                                : list[index].nombre!.toLowerCase() == 'instagram'
                                                                                    ? FontAwesomeIcons.instagram
                                                                                    : FontAwesomeIcons.icons,
                                                                        color:
                                                                            primaryDark,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(list[
                                                                              index]
                                                                          .nombre!),
                                                                    ],
                                                                  ),
                                                                  onTap: () async =>
                                                                      await launch(
                                                                          list[index]
                                                                              .url!),
                                                                ),
                                                              );
                                                            },
                                                            itemCount:
                                                                list.length,
                                                          ),
                                                        ),
                                                ],
                                              );
                                            } else {
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 100),
                                                child: Column(
                                                  children: [
                                                    Text('Cargando...'),
                                                    SizedBox(height: 10),
                                                    LinearProgressIndicator(),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'Conócenos: ',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Html(
                                              data:
                                                  widget.negocio!.descripcion),
                                          Divider(),
                                          Text(
                                            'Precios estimados:',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Text('Precio Mínimo: '),
                                                Text(
                                                    widget.negocio!.preciomin!),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Text('Precio Máximo: '),
                                                Text(
                                                    widget.negocio!.preciomax!),
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                          Text(
                                            'Servicios:',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(0),
                                            child: Row(
                                              children: [
                                                //Text('Ubicación: '),
                                                Expanded(
                                                    child: Html(
                                                        data: widget.negocio!
                                                            .servicios!)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Ubicación',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              IconButton(
                                                  icon: Icon(CupertinoIcons
                                                      .arrowshape_turn_up_right_circle_fill),
                                                  onPressed: () async {
                                                    await controller.openMap(
                                                        lat, long);
                                                  })
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              // SizedBox(width: 10,),
                                              Flexible(
                                                child: Text(
                                                    '${widget.negocio!.direccion} ${widget.negocio!.ubicacion}'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              alignment: Alignment.center,
                                              height: largo / 3,
                                              width: ancho / 1.2,
                                              child: GoogleMap(
                                                zoomGesturesEnabled: false,
                                                scrollGesturesEnabled: false,
                                                markers: Set.from(marcador),
                                                mapType: MapType.normal,
                                                initialCameraPosition:
                                                    CameraPosition(
                                                        target:
                                                            LatLng(lat!, long!),
                                                        zoom: 16),
                                                onMapCreated:
                                                    (GoogleMapController
                                                        controller) {
                                                  if (!_controller
                                                      .isCompleted) {
                                                    _controller
                                                        .complete(controller);
                                                  } else {}
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Galeria
                          SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FutureBuilder(
                                    future: galeriaF,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        if (snapshot.data == "error") {
                                          return Container(
                                              height: largo * .9,
                                              width: ancho,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.warning_amber,
                                                      color: Colors.grey
                                                          .withOpacity(0.6),
                                                      size: 40),
                                                  Text(
                                                      'Ocurrió un error al obtener la galería'),
                                                ],
                                              ));
                                        }
                                        final list = snapshot.data
                                            as List<GaleriaModel>?;
                                        if (list!.length != 0) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 20,
                                                    left: 10,
                                                    right: 10),
                                                child: (largo < 1000 &&
                                                        ancho < 450)
                                                    ? GridView.builder(
                                                        cacheExtent: 0,
                                                        shrinkWrap: true,
                                                        physics:
                                                            BouncingScrollPhysics(),
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2,
                                                          crossAxisSpacing: 10,
                                                          mainAxisSpacing: 10,
                                                          childAspectRatio:
                                                              (5 / 3),
                                                        ),
                                                        itemCount: list.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          GaleriaModel gal =
                                                              list[index];

                                                          return GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                  useSafeArea:
                                                                      true,
                                                                  barrierDismissible:
                                                                      false,

                                                                  //barrierColor: Colors.black26,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      insetPadding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              0),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white12,
                                                                      content:
                                                                          Container(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              color: Colors.black45,
                                                                              child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  // Padding(
                                                                                  //   padding: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                                                                                  //   child: Text(
                                                                                  //     '¿Qué hay de nuevo?',
                                                                                  //     style: TextStyle(color: Colors.white, fontSize: 20),
                                                                                  //   ),
                                                                                  // ),
                                                                                  Container(
                                                                                      margin: EdgeInsets.only(right: 10, top: 10, bottom: 5),
                                                                                      height: 30,
                                                                                      width: 30,
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(360),
                                                                                        border: Border.all(color: Colors.white),
                                                                                      ),
                                                                                      child: IconButton(
                                                                                        padding: EdgeInsets.all(0),
                                                                                        icon: Icon(
                                                                                          Icons.close_rounded,
                                                                                          color: Colors.white,
                                                                                          size: 20,
                                                                                        ),
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                      )),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: InteractiveViewer(
                                                                                child: Container(
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  //height: MediaQuery.of(context).size.height,
                                                                                  child: FadeInImage(
                                                                                    placeholder: AssetImage('assets/logo01.png'),
                                                                                    fit: BoxFit.contain,
                                                                                    image: NetworkImage(
                                                                                      gal.imagen!,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        height: MediaQuery.of(context)
                                                                            .size
                                                                            .height,
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                      ),
                                                                    );
                                                                  });
                                                            },
                                                            child: Container(
                                                              child: Stack(
                                                                alignment: Alignment
                                                                    .bottomLeft,
                                                                children: [
                                                                  Positioned(
                                                                    top: 0,
                                                                    left: 0,
                                                                    right: 0,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          largo /
                                                                              9,
                                                                      width:
                                                                          ancho,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: index % 2 ==
                                                                                0
                                                                            ? primaryLight
                                                                            : primaryDark,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    top: 15,
                                                                    left: 10,
                                                                    right: 10,
                                                                    child: Container(
                                                                        height: largo / 9.5,
                                                                        width: ancho,
                                                                        child: ClipRRect(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            child: CachedNetworkImage(
                                                                              imageUrl: gal.preview!,
                                                                              memCacheHeight: 200,
                                                                              memCacheWidth: 200,
                                                                              placeholder: (context, url) => Container(
                                                                                margin: EdgeInsets.symmetric(vertical: 20),
                                                                                height: largo * .2,
                                                                                width: largo * .2,
                                                                                child: Image.asset('assets/images/logo02.png'),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                                                              fit: BoxFit.cover,
                                                                            ))
                                                                        //     ClipRRect(
                                                                        //   borderRadius:
                                                                        //       BorderRadius.circular(
                                                                        //           10),
                                                                        //   child: Image
                                                                        //       .network(

                                                                        //     gal.imagen,
                                                                        //     fit: BoxFit
                                                                        //         .cover,

                                                                        //   ),
                                                                        // ),
                                                                        ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        })
                                                    : GridView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            BouncingScrollPhysics(),
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2,
                                                          crossAxisSpacing: 10,
                                                          mainAxisSpacing: 0,
                                                          childAspectRatio:
                                                              (6 / 3),
                                                        ),
                                                        itemCount: list.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          GaleriaModel gal =
                                                              list[index];

                                                          return GestureDetector(
                                                            onTap: () {
                                                              // print(largo);
                                                              // print(ancho);
                                                              setState(() {
                                                                imgUrl =
                                                                    gal.imagen;
                                                              });
                                                            },
                                                            child: Container(
                                                              child: Stack(
                                                                alignment: Alignment
                                                                    .bottomLeft,
                                                                children: [
                                                                  Positioned(
                                                                    top: 0,
                                                                    left: 0,
                                                                    right: 0,
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          largo /
                                                                              7.5,
                                                                      width:
                                                                          ancho,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: index % 2 ==
                                                                                0
                                                                            ? primaryLight
                                                                            : primaryDark,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    top: 15,
                                                                    left: 10,
                                                                    right: 10,
                                                                    child: Container(
                                                                        height: largo / 6.5,
                                                                        width: ancho,
                                                                        child: ClipRRect(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            child: CachedNetworkImage(
                                                                              imageUrl: gal.imagen!,
                                                                              memCacheHeight: 200,
                                                                              memCacheWidth: 200,
                                                                              placeholder: (context, url) => Container(
                                                                                margin: EdgeInsets.symmetric(vertical: 20),
                                                                                height: largo * .2,
                                                                                width: largo * .2,
                                                                                child: Image.asset('assets/images/logo02.png'),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                                                              fit: BoxFit.cover,
                                                                            ))),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                              )
                                            ],
                                          );
                                        } else {
                                          return Container(
                                              height: largo * .9,
                                              width: ancho,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    height: 100,
                                                    width: 100,
                                                    child: ClipRRect(
                                                      child: Image.asset(
                                                          'assets/logo01.png'),
                                                    ),
                                                  ),
                                                  Text(
                                                      'No hay nada para mostrar'),
                                                ],
                                              ));
                                        }
                                      } else {
                                        return Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height -
                                                200,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0),
                                            alignment: Alignment.center,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    alignment: Alignment.center,
                                                    height: 100,
                                                    width: 100,
                                                    child:
                                                        CircularProgressIndicator()),
                                                Text('Obteniendo imágenes...'),
                                              ],
                                            ));
                                      }
                                    }),
                              ],
                            ),
                          ),

                          //Comentarios
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Image.asset(
                                          'assets/Serviclic405.png',
                                          fit: BoxFit.cover),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.only(top: 30, bottom: 35),
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: SingleChildScrollView(
                                        physics: BouncingScrollPhysics(),
                                        child: Column(
                                          children: [
                                            FutureBuilder(
                                                future: comentariosF,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    if (snapshot.data ==
                                                        "error") {
                                                      return Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height -
                                                              200,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 0),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .warning_amber,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.6),
                                                                  size: 40),
                                                              Text(
                                                                  'Ocurrió un error al obtener los comentarios'),
                                                            ],
                                                          ));
                                                    }
                                                    final list = snapshot.data
                                                        as List<
                                                            ComentarioModel>?;
                                                    if (list!.length != 0) {
                                                      return Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                BouncingScrollPhysics(),
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              ComentarioModel
                                                                  com =
                                                                  list[index];
                                                              if (com.fecha !=
                                                                  '') {
                                                                hola = DateTime
                                                                    .parse(com
                                                                        .fecha!);
                                                              }

                                                              return Card(
                                                                color: Colors
                                                                    .transparent,
                                                                elevation: 0,
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    ListTile(
                                                                      leading: Container(
                                                                          padding: EdgeInsets.all(
                                                                              3),
                                                                          margin: EdgeInsets.all(
                                                                              4),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(
                                                                                  360),
                                                                              color:
                                                                                  primaryColor),
                                                                          child: Icon(
                                                                              Icons.person,
                                                                              size: 20,
                                                                              color: Colors.white)),
                                                                      title:
                                                                          Text(
                                                                        com.nombre!,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18),
                                                                      ),
                                                                      subtitle:
                                                                          Row(
                                                                        children: [
                                                                          RatingBar.builder(
                                                                              itemSize: 15,
                                                                              initialRating: com.puntuacion.toDouble(),
                                                                              allowHalfRating: true,
                                                                              itemCount: 5,
                                                                              ignoreGestures: true,
                                                                              itemPadding: EdgeInsets.symmetric(horizontal: 0),
                                                                              itemBuilder: (context, _) => Icon(
                                                                                    Icons.star,
                                                                                    color: Colors.amber[800],
                                                                                    size: 15,
                                                                                  ),
                                                                              onRatingUpdate: (rating) {
                                                                                // print(rating);
                                                                              }),
                                                                          SizedBox(
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          com.fecha!.isNotEmpty
                                                                              ? Text(
                                                                                  '${hola.hour}:${hola.minute}  ${hola.day}/${hola.month}/${hola.year}',
                                                                                  style: TextStyle(fontSize: 12),
                                                                                )
                                                                              : Container()
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              7,
                                                                          right:
                                                                              7,
                                                                          bottom:
                                                                              0),
                                                                      child: Text(
                                                                          com.contenido!),
                                                                    ),
                                                                    Divider(
                                                                      thickness:
                                                                          1,
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                            itemCount:
                                                                list.length,
                                                          ),
                                                        ],
                                                      );
                                                    } else {
                                                      return Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height -
                                                              200,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 0),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: 100,
                                                                width: 100,
                                                                child:
                                                                    ClipRRect(
                                                                  child: Image
                                                                      .asset(
                                                                          'assets/logo01.png'),
                                                                ),
                                                              ),
                                                              Text(
                                                                  'No hay nada para mostrar'),
                                                            ],
                                                          ));
                                                    }
                                                  } else {
                                                    return Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height -
                                                            200,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 0),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: 100,
                                                                width: 100,
                                                                child:
                                                                    CircularProgressIndicator()),
                                                            Text(
                                                                'Buscando comentarios...'),
                                                          ],
                                                        ));
                                                  }
                                                })
                                          ],
                                        ),
                                      ),
                                    ),
                                    /*controller.sinIncheck
                                        ? */
                                    Container(
                                        child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              color: Colors.white,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SafeArea(
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          top: 2),
                                                      padding: EdgeInsets.only(
                                                          top: 0,
                                                          bottom: 0,
                                                          left: 30,
                                                          right: 30),
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              onPrimary:
                                                                  Colors.white,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      0)),
                                                          onPressed: () =>
                                                              showDialog(
                                                                  barrierDismissible:
                                                                      false,
                                                                  useSafeArea:
                                                                      true,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return SimpleDialog(
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20)),
                                                                      title:
                                                                          Column(
                                                                        children: [
                                                                          Center(
                                                                            child:
                                                                                Text('Califica a éste negocio'),
                                                                          ),
                                                                          Divider(),
                                                                        ],
                                                                      ),
                                                                      children: [
                                                                        ComentarioCard(
                                                                            negocio:
                                                                                widget.negocio)
                                                                      ],
                                                                    );
                                                                  }),
                                                          child: Text(
                                                              'Dejar un comentario o valorar')),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )))
                                    /*: Container(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              padding: EdgeInsets.only(top: 0),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: primaryDark,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(' Para comentar',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white60)),
                                                  TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5)),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                '/registro');
                                                      },
                                                      child: Text('Regístrate',
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color: Colors
                                                                  .white))),
                                                  Text('ó',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white60)),
                                                  TextButton(
                                                      style: TextButton
                                                          .styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5)),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                '/logIn');
                                                      },
                                                      child: Text(
                                                          'Inicia sesión',
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color: Colors
                                                                  .white))),
                                                ],
                                              ),
                                            ),
                                          ),*/
                                  ],
                                ),
                              ),
                            ],
                          )
                        ]),
                  ),
                ],
              ),
              // floatingActionButton: FloatingActionButton.extended(onPressed: (){},icon: Icon(Icons.call),label: Text('Contactar'),),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.negocio!.nombre!),
            ),
            body: Center(
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
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Por favor, verifica tu conexión y vuelve a intentarlo.\n",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                    TextButton(
                        onPressed: () async {
                          if (await controller.internetcheck()) {
                            imgUrl = widget.negocio!.imagenUrl;
                            redesF = redes(widget.negocio!.id, controller);
                            galeriaF = getFotos(widget.negocio!.id, controller);
                            comentariosF =
                                comentarios(widget.negocio!.id, controller);
                            setState(() {});
                          } else {
                            return;
                          }
                        },
                        child:
                            Text("Reintentar", style: TextStyle(fontSize: 15)))
                  ],
                ),
              ),
            ),
          );
  }
}

// ignore: must_be_immutable
class ComentarioCard extends StatefulWidget {
  NegociosModel? negocio;
  ComentarioCard({this.negocio});

  @override
  _ComentarioCardState createState() => _ComentarioCardState();
}

class _ComentarioCardState extends State<ComentarioCard> {
  TextEditingController textEditingController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  Future<dynamic> getCatCalif() async {
    var url1 = Uri.parse(
      'https://serviclick.com.mx/api/obtener-criterios',
    );
    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
      },
    );
    // print('DESPUES VIENE EL BODY');
    // print(response.body);
    if (response.statusCode == 200) {
      final response1 = await jsonDecode(response.body);
      //print(response1['result']);

      return parseJson(response.body);
    } else {
      return criterios;
    }

//print(response.statusCode);
  }

  List<Criterios>? parseJson(String response) {
    final parsed = jsonDecode(response);

    criterios = parsed['result']
        .map<Criterios>((json) => Criterios.fromJson(json))
        .toList();

    return criterios;
  }

  List<Criterios>? criterios;

  Map<String, dynamic> calificar = {
    'negocio': null,
    'comentario': null,
  };

  Future<dynamic> enviarComentario(
      Map<String, dynamic> calificar1, correo, nombre) async {
    print("APi envair comentario");
    print(calificar1['negocio']);
    var url1 = Uri.parse(
      'https://serviclick.com.mx/api/comentar-negocio',
    );
    //print(registro);
    // print('dentro del metodo registrar usuario');
    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        //'Authorization': 'Bearer $token',
      },
      //body: jsonEncode(calificar1),
      body: jsonEncode(<String, dynamic>{
        'negocio': calificar1['negocio'],
        'comentario': calificar1['comentario'],
        'S1': calificar1['S1'],
        'S2': calificar1['S2'],
        'S3': calificar1['S3'],
        'nombre': nombre,
        'correo': correo
      }),
    );
    print(response.body);
    // print('AQUI SE IMPRIME EL STATUS CODE');
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,+
      final response1 = await jsonDecode(response.body);
      // then parse the JSON.

      return response1;
      // UsuarioModel.fromJson(jsonDecode(response.body));
    } else {
      final response2 = await jsonDecode(response.body);
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      return response2;
    }
  }

  bool validator = false;
  bool cargando = false;
  bool complete = false;
  bool starsValidatos = false;
  bool cerrar = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return cerrar;
      },
      child: FutureBuilder(
          future: getCatCalif(),
          builder: (context, snapshots) {
            if (snapshots.hasError) print(snapshots.error);

            return snapshots.hasData
                ? SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Card(
                              color: Colors.white,
                              elevation: 0,
                              child: Container(
                                height: criterios!.length * 52.0,
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: false,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: ListTile(
                                        leading: Text(criterios![index].nombre!,
                                            style: TextStyle(
                                              fontSize: 15,
                                            )),
                                        trailing: RatingBar.builder(
                                            itemSize: 20,
                                            initialRating: 0,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            ignoreGestures: false,
                                            itemPadding: EdgeInsets.symmetric(
                                                horizontal: 0),
                                            itemBuilder: (context, _) => Icon(
                                                  Icons.star,
                                                  color: Colors.amber[800],
                                                  size: 15,
                                                ),
                                            onRatingUpdate: (rating) {
                                              calificar['S${index + 1}'] =
                                                  rating;
                                              // print(rating);
                                            }),
                                      ),
                                    );
                                  },
                                  itemCount: criterios!.length,
                                ),
                              ),
                            ),
                            starsValidatos
                                ? Text(
                                    'Debes de marcar todos los criterios a evaluar',
                                    style: TextStyle(
                                        color: Colors.red[800], fontSize: 12),
                                  )
                                : Container(),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: emailController,
                                style: TextStyle(color: Colors.black),
                                validator: (String? texto) {
                                  var ok;
                                  if (texto!.isEmpty || texto == '') {
                                    return 'El correo no puede quedar vacío';
                                  } else {
                                    String p =
                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                                    RegExp regExp = new RegExp(p);

                                    ok = regExp.hasMatch(texto.trim());
                                    print(ok);
                                  }
                                  if (ok) {
                                    return null;
                                  } else {
                                    return 'Formato de correo inválido';
                                  }
                                },
                                onSaved: (String? texto) {
                                  emailController.text = texto!;
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 0),
                                  labelText: 'Correo electronico',
                                  labelStyle: TextStyle(color: Colors.black),
                                  prefixIcon:
                                      Icon(Icons.email, color: Colors.black),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: nameController,
                                style: TextStyle(color: Colors.black),
                                validator: (String? texto) {
                                  if (texto!.isEmpty || texto == '') {
                                    nameController.text = "Usuario anonimo";
                                    return null;
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (String? texto) {
                                  nameController.text = texto!;
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 0),
                                  labelText: 'Nombre',
                                  labelStyle: TextStyle(color: Colors.black),
                                  prefixIcon:
                                      Icon(Icons.person, color: Colors.black),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 2,
                                  controller: textEditingController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    labelText: 'Escribe algo..',
                                    errorText: validator
                                        ? 'No puedes dejar el campo vacío'
                                        : null,
                                  )),
                            ),
                            cargando
                                ? CircularProgressIndicator()
                                : Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ButtonBar(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancelar')),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10))),
                                            child: Text('Enviar'),
                                            onPressed: () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                print("Valido");
                                                if (calificar.length - 2 ==
                                                    criterios!.length) {
                                                  //  print('Llenó los 4');
                                                } else {
                                                  // print('nooo te falta bro');
                                                  setState(() {
                                                    starsValidatos = true;
                                                  });
                                                  return;
                                                }
                                                // print(calificar.length);

                                                // print(criterios!.length);
                                                if (textEditingController.text
                                                    .trim()
                                                    .isEmpty) {
                                                  print("Si comentario");
                                                  setState(() {
                                                    validator = true;
                                                  });
                                                } else {
                                                  print("Else comentario");
                                                  setState(() {
                                                    cerrar = false;
                                                    cargando = true;
                                                  });
                                                  print("Continua");
                                                  calificar['comentario'] =
                                                      textEditingController.text
                                                          .trim();
                                                  calificar['negocio'] =
                                                      widget.negocio!.id;
                                                  print(
                                                      calificar['comentario']);
                                                  print(calificar['negocio']);
                                                  print("Continuax2");

                                                  // print(textEditingController.text
                                                  //     .trim());
                                                  print(calificar);

                                                  var response =
                                                      await enviarComentario(
                                                          calificar,
                                                          emailController.text,
                                                          nameController.text);
                                                  print("Continuax3");
                                                  setState(() {
                                                    cerrar = true;
                                                    complete = true;
                                                    cargando = false;
                                                    validator = false;
                                                    starsValidatos = false;
                                                  });
                                                  Navigator.of(context).pop();
                                                  if (response['result'] ==
                                                      true) {
                                                    return showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            title: Column(
                                                              children: [
                                                                Text(
                                                                    'TODO SALIÓ BIEN'),
                                                                Divider()
                                                              ],
                                                            ),
                                                            content: Text(
                                                                'El comentario se ha enviado correctamente, podrás visualizarlo después de pasar por revisión'),
                                                            actions: [
                                                              Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              360),
                                                                      color:
                                                                          primaryDark),
                                                                  child: IconButton(
                                                                      icon: Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            30,
                                                                      ),
                                                                      onPressed: () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }))
                                                            ],
                                                          );
                                                        });
                                                  }
                                                }
                                                // print(response['result']);
                                                /*
                                              }*/
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: "Campos vacios");
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(15),
                    child: LinearProgressIndicator(
                      semanticsLabel: 'Cargando...',
                    ),
                  );
          }),
    );
  }
}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });
  String? title;
  String? body;
}
