// @dart=2.9
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:serviclick/pages/acercade.dart';

import 'package:serviclick/pages/pages.dart';
import 'package:serviclick/pages/soporte.dart';

import 'package:serviclick/services/controller.dart';
import 'package:serviclick/services/notifaciones.dart';
import 'package:serviclick/shared/colores.dart';

var sub;
Controller controller = Controller();
FirebaseMessaging messaging = FirebaseMessaging.instance;

const AndroidNotificationChannel chanel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.high,
  playSound: true,
);

/*IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails(
  badgeNumber: 1,
  presentAlert: true,
  presentSound: true,
  presentBadge: true,
);*/

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessassingBackground(RemoteMessage message) async {
  //print("Inicializacion del mensaje");
  await Firebase.initializeApp();
  //print("A bg message just showed ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacionService.initializedApp();
  //inicializa Firebase
  await Firebase.initializeApp();
  /*await Firebase.initializeApp().whenComplete(() {
    print('Inicialización de Firebase');
  });*/
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(chanel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  //IOSNotificationDetails();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  String mensaje;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NotificacionService.messageStream.listen((message) {
      mensaje = message;
      //print("My app: $message");
      //Navegar a otra pantalla
      if (mensaje == "Solicitud de servicio") {
        if (controller.sinIncheck) {
          //Navegar en el apartado de notifcaciones
          navigatorKey.currentState
              ?.pushNamed('/actividad', arguments: message);
        } else {
          //Si el usuario no ha iniciado sesion primero debe hacerlo
          navigatorKey.currentState?.pushNamed('/logIn', arguments: message);
        }
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => controller,
      lazy: false,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Serviclick',
        theme: ThemeData(
            primaryColorDark: primaryDark,
            disabledColor: primaryDark,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  primary: primaryDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
              primary: primaryDark,
            )),
            primaryColorLight: primaryLight,
            highlightColor: secundaryColor,
            indicatorColor: secundaryColor,
            focusColor: secundaryColor,
            hintColor: secundaryColor,

            // cardColor: primaryColor,
            //botones
            buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
                disabledColor: secundaryColor,
                buttonColor: primaryDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            //navbar
            bottomAppBarTheme: BottomAppBarTheme(color: primaryLight),
            iconTheme: IconThemeData(color: Colors.black),
            primaryIconTheme: IconThemeData(color: Colors.black),
            //texto

            textTheme: TextTheme(
              bodyText1: GoogleFonts.exo2(fontSize: 18),
              button: GoogleFonts.exo2(),
              subtitle1: GoogleFonts.exo2(),
              bodyText2: GoogleFonts.exo2(fontSize: 15),
              headline6: GoogleFonts.exo2(fontSize: 18),
            ),
            //boton flotante
            floatingActionButtonTheme:
                FloatingActionButtonThemeData(backgroundColor: secundaryColor),
            //appbar

            appBarTheme: AppBarTheme(
              elevation: 0,
              iconTheme: IconThemeData(size: 30, color: Colors.white),
              actionsIconTheme: IconThemeData(color: Colors.white, size: 30),
              color: primaryDark,
              //backgroundColor: secundaryColor
            ),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
                .copyWith(secondary: primaryDark)),
        debugShowCheckedModeBanner: false,

        //home: Diseno(),
        home: Gifi(),

        //initialRoute: '/firstPage',
        routes: {
          '/logIn': (BuildContext context) => LogIn(),
          '/home': (BuildContext context) => Home(),
          '/registro': (BuildContext context) => Registro(),
          '/negocioPage': (BuildContext context) => NegocioPage(),
          '/firstPage': (BuildContext context) => NewPageFisrt(),
          '/editInfo': (BuildContext context) => EditarInfo(),
          '/pagos': (BuildContext context) => PagosNegocios(),
          '/actividad': (BuildContext context) => RegistrodeActividad(),
          '/subirLogo': (BuildContext context) => SubirLogo(),
          '/Gifi': (BuildContext context) => Gifi(),
          '/acercade': (BuildContext context) => AcercaDe(),
          '/soporte': (BuildContext context) => Soporte(),
        },
      ),
    );
  }
}
