import 'dart:async';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serviclick/services/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geo;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class Controller extends ChangeNotifier {
  notify() {
    notifyListeners();
  }

  static const Duration DEFAULT_TIMEOUT = Duration(seconds: 10);
  bool isloading = false;
  bool sinIncheck = false;
  String? nombre = '';
  int? negocio = 0;
  String? rememberToken;
  sigIn(String usuario, String password, {String? remeberToken}) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('usuario', usuario);
    await prefs.setString('password', password);
    if (rememberToken != '') {
      await prefs.setString('token', remeberToken!);
      rememberToken = remeberToken;
      return;
    } else {
      return;
    }
  }

  List<FrasesModel> frasesList = [];
  List<TypewriterAnimatedText> textos4 = [];
  bool complete = false;
  bool banner = false;

  late UsuarioModel usuarioActual;
  Future<void> openMap(double? latitude, double? longitude) async {
    String googleUrl =
        "https://www.google.com.mx/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'could not open maps';
    }
  }

  agregarUsuario(UsuarioModel usuario) {
    usuarioActual = usuario;
  }

  NegociosModel? negocioActual;
  Future<bool> sinInCheck(BuildContext context) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    isloading = true;
    if (prefs.getString('usuario') == null &&
        prefs.getString('phone') == null) {
      //no tengo usuario
      isloading = false;
      return false;
    } else {
      //tengo usuario
      print("Acedes acac o no?");
      var checcar = await iniciarSesion(
          prefs.getString('usuario').toString(),
          prefs.getString('phone').toString(),
          prefs.getString('password').toString());
      if (checcar['result'] == null) {
        //no pude iniciar sesión
        singOut();
        return false;
      } else {
        //inicié sesión
        Map<String, dynamic> result = await checcar['result'];
        if (prefs.getString('usuario') != null) {
          result.addAll({
            'email': prefs.getString('usuario'),
            'password': prefs.getString('password'),
          });
          usuarioActual = UsuarioModel.fromJson(result);
          nombre = usuarioActual.name;
          rememberToken = usuarioActual.remembertoken;
          negocio = usuarioActual.empresa;
          return true;
        } else {
          //Inicari con numero
          result.addAll({
            'phone': prefs.getString('phone'),
            'password': prefs.getString('password'),
          });
          usuarioActual = UsuarioModel.fromJson(result);
          nombre = usuarioActual.name;
          rememberToken = usuarioActual.remembertoken;
          negocio = usuarioActual.empresa;
          return true;
        }
      }
    }
  }

  // UsuarioFromFirebase usuarioFromFirebase;

  Future checkGaleryPermission(bool camera) async {
    if (camera) {
      if (await Permission.camera.request().isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      if (Platform.isIOS) {
        if (await Permission.photos.request().isGranted) {
          return true;
        } else {
          return false;
        }
      } else {
        if (await Permission.storage.request().isGranted) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Future getImageCamera(BuildContext context) async {
    var permission = await checkGaleryPermission(true);
    if (permission) {
      ImagePicker image = ImagePicker();
      var image1 = await image.pickImage(
          source: ImageSource.camera,
          maxHeight: 750,
          maxWidth: 750,
          imageQuality: 80);
      if (image1 == null) {
        Fluttertoast.showToast(msg: 'No se seleccionó la imagen');
        return;
      } else {
        return image1;
      }
    } else {
      Fluttertoast.showToast(msg: 'ServiClick no pudo acceder a tu cámara');
      return;
    }
  }

  Future getImage(BuildContext context) async {
    var permission = await checkGaleryPermission(false);
    if (permission) {
      ImagePicker image = ImagePicker();
      var image1 = await image.pickImage(
          source: ImageSource.gallery,
          maxHeight: 750,
          maxWidth: 750,
          imageQuality: 80);
      if (image1 == null) {
        Fluttertoast.showToast(msg: 'No se seleccionó la imagen');
        return;
      } else {
        return image1;
      }
    } else {
      Fluttertoast.showToast(msg: 'ServiClick no pudo acceder a tus imágenes');
      return;
    }
  }

  Future getMultiImage(BuildContext context) async {
    var permission = await checkGaleryPermission(false);
    if (permission) {
      ImagePicker image = ImagePicker();
      var image1 = await image.pickMultiImage(
          maxHeight: 750, maxWidth: 750, imageQuality: 80);
      if (image1 == null) {
        Fluttertoast.showToast(msg: 'No se seleccionaron imágenes');
        return;
      } else {
        return image1;
      }
    } else {
      Fluttertoast.showToast(msg: 'ServiClick no pudo acceder a tus imágenes');
      return;
    }
  }

  // ignore: missing_return

  Future<dynamic> registrarUsuario(Map<String, dynamic> registro) async {
    print(registro);
    print('dentro del metodo registrar usuario');
    var url1 = Uri.parse('https://serviclick.com.mx/api/register');
    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String?>{
        'tipo': registro['tipo'],
        'empresa': registro['empresa'],
        'nombre': registro['nombre'],
        'email': registro['email'],
        'password': registro['password'],
        'phone': registro['phone']
      }),
    );
    print(response.body);
    print('AQUI SE IMPRIME EL STATUS CODE');
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,+
      final response1 = await jsonDecode(response.body);
      // then parse the JSON.
      nombre = registro['nombre'];

      sinIncheck = true;
      return response1;
      // UsuarioModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 422) {
      final response2 = await jsonDecode(response.body);
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      return response2;
    } else {
      final nada = {};
      return nada;
    }
  }

  Future<dynamic> obtenerNegocio(String? token, Controller controller) async {
    var url1 = Uri.parse('https://serviclick.com.mx/api/mostrar');
    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,+
      final response1 = await jsonDecode(response.body);
      final response2 = jsonEncode(response1['result']);
      final response3 = jsonDecode(response2);

      //print(response3);
      // then parse the JSON.
      negocioActual = NegociosModel.fromJson(response3[0]);
      controller.negocioActual = negocioActual;
      notify();
      return response1['result'];
      // UsuarioModel.fromJson(jsonDecode(response.body));
    } else {
      final response2 = await jsonDecode(response.body);
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      return response2;
    }
  }

  late LocationData ubicacion;
  late LatLng latlng;

  //-------------------- MÉTODO PARA CHECAR PERMISOS DE UBICACIÓN Y ESTADO DEL GPS
  Future checkLocationPermission(BuildContext context) async {
    var permiso = await Permission.locationWhenInUse.request();
    if (permiso.isGranted || permiso.isLimited) {
      bool permiso = await Location().serviceEnabled();
      if (permiso) {
        //gps activado
        try {
          ubicacion = await Location().getLocation();
          latlng = LatLng(
              ubicacion.latitude!.toDouble(), ubicacion.longitude!.toDouble());
          return true;
        } catch (e) {
          return false;
        }
      } else {
        //gps desactivado
        await Location().requestService();
        return "reintentar";
      }
    } else {
      var reintentar = await showDialog(
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: Text("Permiso denegado"),
                content: Text(
                    "Acceder a tu ubicación es necesario para que serviclick funcione correctamente. Por favor, activa los permisos desde la configuración del teléfono."),
                actions: [
                  ElevatedButton(
                      onPressed: () async {
                        await openAppSettings();
                      },
                      child: Text("Abrir configuración")),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context, "reintentar");
                      },
                      child: Text("Reintentar")),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context, false);
                      },
                      child: Text("Ignorar")),
                ],
              ),
            );
          });
      return reintentar;
    }
  }

  //-------------------- MÉTODO PARA OBTENER LA UBICACIÓN

  LocationData? currentPosition;
  UbicacionModel? miubicacion;
  String ciudad = '';

  int ubicacion1 = 0;
  int ubicacion2 = 0;

  Future<String> getAdress() async {
    bool gps = await Location().serviceEnabled();
    if (gps) {
      try {
        currentPosition = await Location().getLocation();
        print("correcto acceso al gps");
        List<geo.Placemark> data = await geo.placemarkFromCoordinates(
            currentPosition!.latitude!, currentPosition!.longitude!);
        internet = false;
        var direccion = data.first;
        return ciudad =
            '${direccion.locality}, ${direccion.administrativeArea}';
      } catch (e) {
        print("error gps");
        currentPosition = null;
        return ciudad = "sinDato";
      }
    } else {
      print("gps no activado");
      currentPosition = null;
      return ciudad = "sinDato";
    }
  }

  Future<dynamic> showDialog2(
      BuildContext context, String message, bool isShowwing) async {
    if (isShowwing) {
      return showDialog(
          barrierDismissible: false,
          barrierColor: Colors.black26,
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: SimpleDialog(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                backgroundColor: Colors.white,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.only(left: 10, bottom: 5, top: 5),
                          height: 80,
                          width: 80,
                          child: CircularProgressIndicator()

                          // CircularProgressIndicator(
                          //   strokeWidth: 2,
                          //   backgroundColor: Colors.greenAccent,
                          // ),
                          ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text(message,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).timeout(Duration(seconds: 10), onTimeout: () async {
        Fluttertoast.showToast(msg: 'Algo no salió bien, intente nuevamente.');
        Navigator.pop(context);
      });
    } else {
      complete = true;
      Navigator.pop(context);
    }
  }

  // Future<bool> showDialog1(
  //     BuildContext context, String message, bool isShowwing) async {
  //   ProgressDialog progressDialog;
  //   progressDialog = ProgressDialog(context,
  //       isDismissible: false, type: ProgressDialogType.Normal);
  //   progressDialog.style(
  //     message: message,
  //   );
  //   var dialog;
  //   if (isShowwing) {
  //     dialog = progressDialog.show();
  //   } else {
  //     dialog = progressDialog.hide();
  //   }
  //   return dialog;
  // }

  String? tokenMessagin = '';

  Future<void> showDialog1(
      BuildContext context, String message, bool isShowwing) async {
    isShowwing
        ? showDialog(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AbsorbPointer(
                    child: Container(
                      height: 45,
                      width: 45,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).indicatorColor),
                        strokeWidth: 3,
                        backgroundColor: null,
                      ),
                    ),
                  ),
                ],
              );
            })
        : Navigator.of(context).pop();
  }

  Future<dynamic> iniciarSesion(
      String? usuario, String? phone, String? contrasena) async {
    tokenMessagin = await FirebaseMessaging.instance.getToken();
    //token = await FirebaseMessaging.instance.getToken();
    //print("toekn:  $tokenMessagin");
    print("U: $usuario, P: $phone, C: $contrasena");
    var url1 = Uri.parse('https://serviclick.com.mx/api/login');
    var boddy;
    if (usuario == null) {
      boddy = jsonEncode(<String, dynamic>{
        'phone': int.parse(phone!),
        'password': contrasena,
        'token_notificacion': tokenMessagin
      });
    } else {
      boddy = jsonEncode(<String, String?>{
        'email': usuario,
        'password': contrasena,
        'token_notificacion': tokenMessagin
      });
    }
    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: boddy,
    );

    /*var responde = jsonEncode(<String, String?>{
      'email': usuario,
      'password': contrasena,
    });*/

    print(jsonDecode(response.body));

    if (response.statusCode == 200) {
      final response1 = await jsonDecode(response.body);
      print(response1);
      // then parse the JSON.
      sinIncheck = true;
      return response1;
    } else {
      print("Mal todo");
      await singOut();
      final response2 = await jsonDecode(response.body);
      return response2;
    }
  }

  singOut() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    print('CERRANDO SESIÓN');
    await prefs.remove('usuario');
    await prefs.remove('password');
    await prefs.remove('token');
    //await prefs.clear();
    // if (usuarioActual.empresa != 0) {
    //   await Workmanager.cancelAll();
    // }
//     if(usuarioActual.empresa !=0){
//  await usuarioFromFirebase.reference.update({
//       'tokens': FieldValue.arrayRemove([tokenMessagin])
//     });
//     }

    nombre = '';
    negocio = 0;
    sinIncheck = false;
    complete = false;
  }

  bool internet = true;
  Future<bool> internetcheck() async {
    try {
      var url = Uri.parse("https://jsonplaceholder.typicode.com/todos/1");
      await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(Duration(seconds: 20));
      internet = true;
      print("si hay internet");
      return true;
    } catch (e) {
      internet = false;
      print("no hay internet");
      return false;
    }
  }

  double? latFinal;
  double? longFinal;

  // Future showNotificationWithDefaultSound(String newData) async {
  //   FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
  //   var android = AndroidInitializationSettings('icon');
  //   var iOS = IOSInitializationSettings();
  //   var settings = InitializationSettings(android: android, iOS: iOS);
  //   flip.initialize(settings);
  //   // Show a notification after every 15 minute with the first
  //   // appearance happening a minute after invoking the method
  //   var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
  //       'your channel id', 'your channel name', 'your channel description',
  //       importance: Importance.max, priority: Priority.high);
  //   var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

  //   // initialise channel platform for both Android and iOS device.
  //   var platformChannelSpecifics = new NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: iOSPlatformChannelSpecifics);
  //   await flip.show(0, 'Holaa', newData, platformChannelSpecifics,
  //       payload: 'Default_Sound');
  // }

}
