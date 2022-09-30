import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:serviclick/main.dart';
import 'package:serviclick/pages/filtroPage.dart';
import 'package:serviclick/pages/pages.dart';
import 'package:serviclick/services/services.dart';
import 'package:serviclick/shared/colores.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Gifi extends StatefulWidget {
  @override
  _GifiState createState() => _GifiState();
}

class _GifiState extends State<Gifi> {
  //
  @override
  void initState() {
    super.initState();
    Controller controlador = Provider.of<Controller>(context, listen: false);
    checkLocation1 = checklocation(controlador);
    //checkVersion();
  }

  Future getIDS(
      SharedPreferences pref, Controller controller, Map latLong) async {
    var listIDS = await getUbicacionIDS(controller, latLong);
    if (listIDS == "error") {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: AlertDialog(
                title: Text('Error'),
                content: Text(
                    'Ocurrió un error inesperado, por favor intenta de nuevo más tarde'),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        exit(0);
                      },
                      child: Text('Salir')),
                ],
              ),
            );
          });
    } else {
      print("guardo IDS obtenidos");
      controller.ubicacion1 = listIDS[0];
      controller.ubicacion2 = listIDS[1];
      pref.setInt("ubicacion1", controller.ubicacion1);
      pref.setInt("ubicacion2", controller.ubicacion2);
    }
  }

  Future checarTotalUbic(SharedPreferences pref, Controller controller) async {
    var cantiUbi = await cantidadUbicaciones(controller);
    if (cantiUbi == "error") {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: AlertDialog(
                title: Text('Error'),
                content: Text(
                    'Ocurrió un error inesperado, por favor intenta de nuevo más tarde'),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        exit(0);
                      },
                      child: Text('Salir')),
                ],
              ),
            );
          });
    } else if (cantiUbi == true) {
      return true;
    } else if (cantiUbi == false) {
      return false;
    }
  }

  bool primera = false;
  int page = 0;
  Future<bool?> checklocation(Controller controller) async {
    await controller.internetcheck().then((value) async {
      if (value) {
        var ubicacion = await controller.checkLocationPermission(context);
        if (ubicacion == "reintentar") {
          checkLocation1 = checklocation(controller);
          setState(() {});
          return;
        } else {
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          if (ubicacion == true) {
            //////------ revision por ciudad
            var miCiudad = await controller.getAdress();
            if (miCiudad == "sinDato") {
              controller.ciudad = "";
              //datos predeterminados del centro de mexico
              var latLong = {"latitud": 19.42847, "longitud": -99.12766};
              await getIDS(_prefs, controller, latLong);
            } else {
              if (miCiudad != _prefs.getString("miCiudad")) {
                print("diferente ciudad");
                _prefs.setString("miCiudad", miCiudad);
                var latLong = {
                  "latitud": controller.currentPosition!.latitude,
                  "longitud": controller.currentPosition!.longitude
                };
                await getIDS(_prefs, controller, latLong);
              } else {
                print("misma ciudad");
                //////------ revision por cantidad ubicaciones
                var cantidadUbicaciones =
                    await checarTotalUbic(_prefs, controller);
                if (cantidadUbicaciones == true) {
                  print("misma cantidad ubicaciones");
                  controller.ubicacion1 = _prefs.getInt("ubicacion1")!;
                  controller.ubicacion2 = _prefs.getInt("ubicacion2")!;
                }
                if (cantidadUbicaciones == false) {
                  print("diferente cantidad ubicaciones");
                  var latLong = {
                    "latitud": controller.currentPosition!.latitude,
                    "longitud": controller.currentPosition!.longitude
                  };
                  await getIDS(_prefs, controller, latLong);
                }
              }
              controller.ciudad = miCiudad;
            }
          } else if (ubicacion == false) {
            controller.ciudad = "";
            //datos predeterminados del centro de mexico
            var latLong = {"latitud": 19.42847, "longitud": -99.12766};
            await getIDS(_prefs, controller, latLong);
          }
          print("--- " + controller.ciudad.toString());
          //////------ revision preview (final)
          var preview = _prefs.getBool('primera');
          if (preview == true) {
            //navegar a home
            Timer(
                Duration(seconds: 0),
                () => Navigator.pushReplacement(context,
                    CupertinoPageRoute(builder: (context) => NewPageFisrt())));
            primera = false;
            return primera;
          } else {
            // navegar a preview
            Timer(
                Duration(seconds: 0),
                () => Navigator.pushReplacement(context,
                    CupertinoPageRoute(builder: (context) => Intro())));

            primera = true;
            return primera;
          }
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
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => Gifi()),
                              (route) => false);
                        },
                        child: Text('Reintentar'))
                  ],
                ),
              );
            });
      }
    });
    return null;
  }

  Future<dynamic> cantidadUbicaciones(Controller controller) async {
    print("consulta cantidad ubicaciones");
    try {
      var url = Uri.parse("https://serviclick.com.mx/api/ubicaciones");
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(Duration(seconds: 20));
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        var convertir = jsonDecode(response.body);
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        if (convertir["count"] == _prefs.getInt("cantidadUbicaciones")) {
          return true;
        } else {
          _prefs.setInt("cantidadUbicaciones", convertir["count"]);
          return false;
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
      if (controller.internet) {
        print("ERROR --- " + e.toString());
        return "error";
      } else {
        return "internet";
      }
    }
  }

  Future<dynamic> getUbicacionIDS(Controller controller, Map latlong) async {
    print("consulta ubicacion IDS");
    try {
      print(latlong);
      var url = Uri.parse("https://serviclick.com.mx/api/ubicacion_cercana");
      final response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(latlong),
          )
          .timeout(Duration(seconds: 20));
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        var convertir = jsonDecode(response.body);
        return [convertir["result"][0], convertir["result"][1]];
      } else {
        print("error " +
            response.statusCode.toString() +
            " --- " +
            response.body.toString());
        return "error";
      }
    } catch (e) {
      await controller.internetcheck();
      if (controller.internet) {
        print("ERROR --- " + e.toString());
        return "error";
      } else {
        return "internet";
      }
    }
  }

  Future? checkLocation1;
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);

    return Scaffold(
      body: FutureBuilder(
          future: checkLocation1,
          builder: (context, snapshot) {
            return Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Image.asset(
                      'assets/servi.gif',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Text(
                          'FROM',
                          style: TextStyle(color: primaryColor, fontSize: 12),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(bottom: 20),
                          height: 100,
                          width: 100,
                          child: Image.asset('assets/logoMetros.png',
                              fit: BoxFit.fill)),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  PageController _pageController = PageController(initialPage: 0);

  bool primera = false;

  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          PageView(
            physics: BouncingScrollPhysics(),
            onPageChanged: (int value) {
              setState(() {
                page = value;
              });
            },
            controller: _pageController,
            children: [pag1(context), pag2(context)], //pag3(context)
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: TextButton(
                onPressed: () async {
                  SharedPreferences _prefs =
                      await SharedPreferences.getInstance();
                  _prefs.setBool('primera', true);
                  Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(builder: (context) => NewPageFisrt()),
                      (route) => false);
                },
                child: Text(
                  page != 1 ? 'OMITIR' : 'CERRAR',
                  style: TextStyle(
                      fontSize: 17, decoration: TextDecoration.underline),
                )),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                page != 0
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                        ),
                        onPressed: () {
                          _pageController.previousPage(
                              duration: Duration(seconds: 1),
                              curve: Curves.easeInOutCubic);
                        })
                    : Container(),
                page == 0
                    ? IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded),
                        onPressed: () {
                          _pageController.nextPage(
                              duration: Duration(seconds: 1),
                              curve: Curves.easeInOutCubic);
                        })
                    : Container()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget pag1(BuildContext context) {
    return SafeArea(
      child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Image.asset('assets/11.png')),
    );
  }

  Widget pag3(BuildContext context) {
    return SafeArea(
      child: Container(
          color: Colors.transparent,
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              Center(child: Image.asset('assets/22.png')),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () async {
                            SharedPreferences _prefs =
                                await SharedPreferences.getInstance();
                            _prefs.setBool('primera', true);
                            Navigator.of(context).pushAndRemoveUntil(
                                CupertinoPageRoute(
                                    builder: (context) => NewPageFisrt()),
                                (route) => false);
                          },
                          child: Text(
                            'Busca algún servicio',
                            style: TextStyle(color: Colors.black),
                          ),
                          style:
                              ElevatedButton.styleFrom(primary: Colors.yellow),
                        )),
                      ],
                    ),
                    Text('Ó'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences _prefs =
                                      await SharedPreferences.getInstance();
                                  _prefs.setBool('primera', true);
                                  await Navigator.pushNamed(context, '/logIn');
                                },
                                child: Text('Inicia Sesión'))),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences _prefs =
                                      await SharedPreferences.getInstance();
                                  _prefs.setBool('primera', true);
                                  await Navigator.pushNamed(
                                      context, '/registro');
                                },
                                child: Text('Regístrate')))
                      ],
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }

  Widget pag2(BuildContext context) {
    return SafeArea(
      child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Image.asset('assets/33.png')),
    );
  }
}

class NewPageFisrt extends StatefulWidget {
  @override
  _NewPageFisrtState createState() => _NewPageFisrtState();
}

class _NewPageFisrtState extends State<NewPageFisrt> {
  Future<dynamic> categorias(Controller controller) async {
    try {
      print("consulta categorias");
      var url1 = Uri.parse('https://serviclick.com.mx/api/categorias');
      var response = await http.post(url1);
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var finalResult = parsed['result']['categorias']
            .map<CategoriaModel>((json) => CategoriaModel.fromJson(json))
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

  Future<dynamic> frases(Controller controller) async {
    try {
      print("consulta frases");
      var url1 = Uri.parse('https://serviclick.com.mx/api/frases');
      final response = await http.post(url1);
      if (response.statusCode == 200) {
        controller.internet = true;
        controller.notify();
        final parsed = jsonDecode(response.body);
        var finalResult = parsed['result']
            .map<FrasesModel>((json) => FrasesModel.fromJson(json))
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

  Future getImg(BuildContext context, Controller controller) async {
    try {
      print("consulta imagen");
      var url = Uri.parse('https://serviclick.com.mx/api/anuncio');
      final response = await http.post(url);
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed['result'] != '[]') {
          String url = parsed['result'].first['imagen'];
          return await noticias(context, url);
        } else {
          return;
        }
      } else {
        print("error " +
            response.statusCode.toString() +
            " --- " +
            response.body.toString());
        return;
      }
    } catch (e) {
      controller.internetcheck();
      controller.notify();
      if (controller.internet) {
        print("ERROR --- " + e.toString());
        return;
      }
    }
  }

  List<TypewriterAnimatedText> textos = [];

  Future inicioSesion(Controller controller) async {
    print("metodo inicio sesion auto");
    // await controller.checkLocationPermission(context);
    if (controller.sinIncheck &&
        controller.usuarioActual.remembertoken!.isNotEmpty) {
    } else {
      await controller.sinInCheck(context).then((value) async {
        if (value) {
          print("Usuario ya ha inciado sesion");
          //tengo usuario
          controller.sinIncheck = true;
          controller.nombre = controller.usuarioActual.name;
          Fluttertoast.showToast(
              msg: 'Bienvenido ${controller.usuarioActual.name}');
          controller.negocio = controller.usuarioActual.empresa;
        }
        controller.complete = true;
        if (controller.banner == false) {
          print("Esto que es?");
          //obtengo el banner
          await getImg(context, controller);
          controller.banner = true;
          controller.notify();
        }
      });
    }
    print("Sabe si un usuario ha iniciado sesion o no?");
  }

  Future noticias(BuildContext context, String url) async {
    showDialog(
        useSafeArea: true,
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(0),
            contentPadding: EdgeInsets.all(0),
            backgroundColor: Colors.white12,
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.black45,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, top: 10, bottom: 5),
                          child: Text(
                            '¿Qué hay de nuevo?',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        Container(
                            margin:
                                EdgeInsets.only(right: 10, top: 10, bottom: 5),
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
                        child: FadeInImage(
                          placeholder: AssetImage('assets/logo01.png'),
                          fit: BoxFit.contain,
                          image: NetworkImage(
                            url,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    Controller controller = Provider.of<Controller>(context, listen: false);
    inicioSesion1 = inicioSesion(controller);
    categoriasF = categorias(controller);
    frasesF = frases(controller);
    checkVersion();
  }

  Future<dynamic> notificacionLocal(tipo) async {
    flutterLocalNotificationsPlugin.show(
      0,
      "Servicio ServiClick",
      "¡Nueva Actualización!",
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

  checkVersion() async {
    /*print("Checa la version en la que esta el usuario");

    final nuevaVersion = NewVersion(
        androidId: "javier.com.serviclick", iOSId: "javier.com.servilcik");
    try {
      final statusVersion = await nuevaVersion.getVersionStatus();
      print(statusVersion!.releaseNotes);
      print(statusVersion.appStoreLink);
      print(statusVersion.localVersion);
      print(statusVersion.storeVersion);
      print(statusVersion.canUpdate.toString());
      if (statusVersion.canUpdate == true) {
        notificacionLocal(1);
        nuevaVersion.showUpdateDialog(
          context: context,
          versionStatus: statusVersion,
          dialogTitle: "Nueva versión!",
          dialogText:
              "Se encuentra disponible una nueva actualización de ServiClick (" +
                  statusVersion.storeVersion +
                  "), le recomendamos actualizar ahora.",
          updateButtonText: "Actualizar ahora",
          dismissButtonText: "Cerrar",
          dismissAction: () {
            //Cierra la aplicacion, fuerza que el usuario actualize la nueva version...
            //SystemNavigator.pop();
            //Solo salir del dialogo
            Navigator.pop(context);
          },
        );
      }
    } catch (e) {
      print("Error de version no se puede solicitar $e");
    }*/
  }

  Future? inicioSesion1;
  Future? categoriasF;
  Future? frasesF;
  Future? imagenF;

  List<UbicacionModel>? ubicacionList = [];
  List<UbicacionModel>? ubicacion = [];
  CategoriaModel? selectedCategoria;
  bool validator = false;
  bool loading = false;
  bool complete2 = false;
  TextEditingController textEditingController = TextEditingController();
  UbicacionModel? ubi;
  PageController pagecontroller = PageController(viewportFraction: 1);

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);

    return Stack(alignment: Alignment.bottomCenter, children: [
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/degradado.png',
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(primaryDark, BlendMode.color)),
        ),
      ),
      Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: FutureBuilder(
            future: inicioSesion1,
            builder: (context, snapshot) {
              return PageView(
                physics: BouncingScrollPhysics(),
                controller: pagecontroller,
                scrollDirection: Axis.vertical,
                children: [
                  page1(context),
                  page2(context),
                ],
              );
            }),
      )
    ]);
  }

  Widget page1(context) {
    Controller controller = Provider.of<Controller>(context);
    var largo = MediaQuery.of(context).size.height;
    var ancho = MediaQuery.of(context).size.width;
    return Container(
      height: largo * .95,
      width: ancho,
      child: Column(
        children: [
          SizedBox(
            height: largo * .05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.only(left: 10),
                alignment: Alignment.topRight,
                child: Image(
                  color: Colors.white54,
                  height: ancho * .1,
                  width: ancho * .1,
                  image: AssetImage(
                    'assets/logoblanco.png',
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: controller.complete
                    ? () {
                        Navigator.of(context).pushNamed('/home');
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Conoce el directorio completo',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    Icon(
                      Icons.double_arrow_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: largo * .07,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            alignment: Alignment.topCenter,
            child: SizedBox(
                height: largo * .2,
                child: FutureBuilder(
                    future: frasesF,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == "error") {
                          return DefaultTextStyle(
                            style: GoogleFonts.exo2(fontSize: 25),
                            child: AnimatedTextKit(
                              repeatForever: true,
                              isRepeatingAnimation: true,
                              animatedTexts: [
                                TypewriterAnimatedText(
                                    'Bienvenido a ServiClick')
                              ],
                              onTap: () {},
                            ),
                          );
                        } else {
                          final list = snapshot.data as List<FrasesModel>;
                          if (list.length != 0) {
                            list.forEach((element) {
                              textos.add(TypewriterAnimatedText(element.frase!,
                                  speed: Duration(milliseconds: 60)));
                            });
                            return DefaultTextStyle(
                              style: (largo > 300 && largo < 700)
                                  ? GoogleFonts.kanit(fontSize: 22)
                                  : GoogleFonts.kanit(fontSize: 27),
                              child: AnimatedTextKit(
                                pause: Duration(milliseconds: 400),
                                displayFullTextOnTap: true,
                                stopPauseOnTap: true,
                                repeatForever: true,
                                isRepeatingAnimation: true,
                                animatedTexts: textos,
                                onTap: () {},
                              ),
                            );
                          } else {
                            return DefaultTextStyle(
                              style: GoogleFonts.exo2(fontSize: 25),
                              child: AnimatedTextKit(
                                repeatForever: true,
                                isRepeatingAnimation: true,
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                      'Bienvenido a ServiClick')
                                ],
                                onTap: () {},
                              ),
                            );
                          }
                        }
                      } else {
                        return DefaultTextStyle(
                          style: GoogleFonts.exo2(fontSize: 25),
                          child: AnimatedTextKit(
                            repeatForever: true,
                            isRepeatingAnimation: true,
                            animatedTexts: [
                              TypewriterAnimatedText('Cargando...')
                            ],
                            onTap: () {},
                          ),
                        );
                      }
                    })),
          ),
          SizedBox(
            height: largo * .01,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        autofocus: false,
                        controller: textEditingController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            labelText: 'Buscar servicio',
                            hintText: 'Ejm: Construcción')),
                  ),
                  Container(
                      width: ancho,
                      height: largo * .08,
                      child: FutureBuilder(
                        future: categoriasF,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data == "error") {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      width: ancho,
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Error al cargar'),
                                          Icon(Icons.warning_amber)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              final list =
                                  snapshot.data as List<CategoriaModel>;
                              if (list.length == 0) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        width: ancho,
                                        color: Colors.white,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                'Ninguna categoría registrada'),
                                            Icon(Icons.arrow_drop_down)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButton(
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            elevation: 0,
                                            value: selectedCategoria,
                                            items: list.map((categoria1) {
                                              return DropdownMenuItem(
                                                value: categoria1,
                                                child: Text(categoria1.nombre!),
                                              );
                                            }).toList(),
                                            hint: Text(
                                              "Selecciona la categoría",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            onChanged:
                                                (CategoriaModel? newVal) {
                                              selectedCategoria = newVal;
                                              setState(() {});
                                            }),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          } else {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    width: ancho,
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Cargando categorías'),
                                        Icon(Icons.arrow_drop_down)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      )),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(bottom: Radius.circular(5)),
                          color: Colors.yellow),
                      width: MediaQuery.of(context).size.width,
                      child: loading
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator()),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Buscando...')
                                ],
                              ),
                            )
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                  elevation: 0,
                                  primary: Colors.transparent),
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            FiltroPage(
                                                chingona: true,
                                                categoriaid:
                                                    selectedCategoria != null
                                                        ? selectedCategoria!.id
                                                        : null,
                                                ubicacionid: {
                                                  "0": controller.ubicacion1,
                                                  "1": controller.ubicacion2
                                                },
                                                //  "latitud": 19.42847, "longitud": -99.12766;
                                                latitud: controller
                                                            .currentPosition !=
                                                        null
                                                    ? controller
                                                        .currentPosition!
                                                        .latitude!
                                                    : 19.42847,
                                                longitud: controller
                                                            .currentPosition !=
                                                        null
                                                    ? controller
                                                        .currentPosition!
                                                        .longitude!
                                                    : -99.12766,
                                                servicio: textEditingController
                                                    .text
                                                    .trim())));
                              },
                              icon: Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              label: Text(
                                'Buscar',
                                style: TextStyle(color: Colors.black),
                              )))
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              controller.ciudad.isEmpty
                  ? Container(color: Colors.red)
                  : Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.white),
              SizedBox(
                width: 10,
              ),
              Text(
                controller.ciudad,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          Expanded(
            child: Container(
              width: ancho,
              padding: EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Text(
                      'Desliza para ver categorías',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: ancho,
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 10),
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                controller.sinIncheck
                    ? TextButton(onPressed: () => null, child: Text(''))
                    : !controller.sinIncheck && controller.complete
                        ? TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: controller.complete
                                ? () {
                                    Navigator.of(context)
                                        .pushNamed('/registro');
                                  }
                                : null,
                            child: Text(
                              'Regístrate',
                              style: TextStyle(color: Colors.white),
                            ))
                        : TextButton(onPressed: () => null, child: Text('')),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        pagecontroller.nextPage(
                            duration: Duration(seconds: 1),
                            curve: Curves.easeInOutBack);
                      },
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          size: 30, color: Colors.grey[300]),
                    ),
                  ],
                ),
                controller.complete
                    ? TextButton(
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          if (controller.negocio != 0 &&
                              controller.sinIncheck) {
                            controller.showDialog1(
                                context, 'Iniciando sesión', true);
                            await controller.obtenerNegocio(
                                controller.usuarioActual.remembertoken,
                                controller);

                            controller.showDialog1(
                                context, 'Iniciando sesión', false);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      NegocioPage(
                                          token: controller.rememberToken),
                                ));
                          } else if (controller.negocio == 0 &&
                              controller.sinIncheck) {
                            controller.showDialog1(
                                context, 'Iniciando sesión', true);

                            controller.showDialog1(context, '', false);
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home', (Route<dynamic> route) => false);
                          } else {
                            controller.sinIncheck = false;

                            Navigator.of(context).pushNamed('/logIn');
                          }
                        },
                        child: Text(
                          !controller.sinIncheck ? 'Inicia sesión' : 'Entrar',
                          style: TextStyle(color: Colors.white),
                        ))
                    : TextButton(onPressed: () => null, child: Text('holi'))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget page2(context) {
    Controller controller = Provider.of<Controller>(context);
    var largo = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(top: 30),
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // controller.listaCat.isEmpty
          //     ?
          Container(
            height: largo * .90,
            child: FutureBuilder(
                future: categoriasF,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == "error") {
                      return Container(
                        height: largo * .9,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber, color: Colors.white),
                            SizedBox(
                              height: 15,
                            ),
                            Text('Ocurrió un error',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      );
                    } else {
                      final list = snapshot.data as List<CategoriaModel>;
                      //print(list[0].id);
                      if (list.length != 0) {
                        return GridView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: list.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 3 / 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 8),
                            itemBuilder: (BuildContext context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  selectedCategoria = list[index];
                                  // controller.showDialog1(
                                  //     context, 'Buscando...', true);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          FiltroPage(
                                        chingona: true,
                                        categoriaid: selectedCategoria!.id,
                                        ubicacionid: {
                                          "0": controller.ubicacion1,
                                          "1": controller.ubicacion2
                                        },
                                        //  "latitud": 19.42847, "longitud": -99.12766;
                                        latitud:
                                            controller.currentPosition != null
                                                ? controller
                                                    .currentPosition!.latitude!
                                                : 19.42847,
                                        longitud:
                                            controller.currentPosition != null
                                                ? controller
                                                    .currentPosition!.longitude!
                                                : -99.12766,
                                        servicio: "",
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    Container(
                                      width: 1000,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: list[index].imagen!,
                                        placeholder: (context, url) =>
                                            Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 30),
                                          height: largo * .1,
                                          width: largo * .1,
                                          child: Image.asset(
                                              'assets/images/logo02.png'),
                                        ),
                                        memCacheHeight: 400,
                                        memCacheWidth: 400,
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.black26,
                                            child: Text(
                                              list[index].nombre!,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            });
                      } else {
                        return Container(
                          height: largo * .9,
                          child: Center(
                            child: Text('Ninguna categoría registrada',
                                style: TextStyle(color: Colors.white)),
                          ),
                        );
                      }
                    }
                  } else {
                    return Container(
                      height: largo * .9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text('Cargando categorias',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  }
                }),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                pagecontroller.previousPage(
                    duration: Duration(seconds: 1),
                    curve: Curves.easeInOutBack);
              },
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Text(
                  'Volver al inicio',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                color: Colors.yellow,
              ),
            ),
          )
        ],
      ),
    );
  }
}
