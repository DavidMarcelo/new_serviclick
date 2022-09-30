import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serviclick/pages/pages.dart';
import 'package:serviclick/services/services.dart';
import 'package:serviclick/shared/colores.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mydrawer extends StatefulWidget {
  /*int? totalNotificacione;
  int? totalPagos;
  Mydrawer({this.totalNotificacione, this.totalPagos});*/
  @override
  _MydrawerState createState() => _MydrawerState();
}

class _MydrawerState extends State<Mydrawer> {
  int? totalNotificacione = 0;
  int? totalPagos = 0;
  @override
  void dispose() {
    super.dispose();
  }

  Future obtenerNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    totalNotificacione = prefs.getInt('totalNotificaciones');
    totalPagos = prefs.getInt('totalPagos');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    obtenerNotificaciones();
  }

  @override
  Widget build(BuildContext context) {
    //print("My drawe: ");
    //print(totalNotificacione);
    Controller controller = Provider.of<Controller>(context);
    return Drawer(
      child: Stack(
        children: [
          Container(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 80,
                width: 80,
                child: Image.asset(
                  'assets/logo01.png',
                  fit: BoxFit.cover,
                ),
              )),
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                controller.negocio != 0
                    ? DrawerHeader(
                        curve: Curves.easeInBack,
                        margin: EdgeInsets.all(0),
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(color: primaryDark),
                        child: Container(
                          height: 80,
                          padding: EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            //borderRadius: BorderRadius.circular(360),
                            child: FadeInImage(
                              fit: BoxFit.cover,
                              image: (controller.negocioActual!.imagenUrl != ''
                                  ? NetworkImage(
                                      '${controller.negocioActual!.imagenUrl}')
                                  : AssetImage(
                                      'assets/logo01.png')) as ImageProvider<
                                  Object>,
                              placeholder: AssetImage('assets/logo01.png'),
                            ),
                          ),
                        ))
                    : DrawerHeader(
                        margin: EdgeInsets.all(0),
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: primaryDark,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          color: Colors.white,
                          height: 80,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                              child: Image.asset('assets/servilogo.png')),
                        )),
                controller.negocio != 0
                    ? ListTile(
                        leading: Icon(Icons.image),
                        title: Text('Mis imágenes'),
                        onTap: () async {
                          Navigator.of(context).pushNamed('/subirLogo');
                        },
                      )
                    : controller.sinIncheck
                        ? Container(
                            color: Colors.transparent,
                            height: 0,
                            width: 0,
                          )
                        : ListTile(
                            leading: Icon(Icons.login),
                            title: Text('Iniciar sesión'),
                            onTap: () {
                              Navigator.of(context).pushNamed('/logIn');
                            },
                          ),
                controller.negocio != 0 ? Divider() : Container(),
                controller.negocio != 0
                    ? ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Editar información'),
                        onTap: () async {
                          // Navigator.of(context).pushReplacementNamed('/editInfo');
                          Navigator.of(context).pushNamed('/editInfo');
                        },
                      )
                    : controller.nombre == ''
                        ? Container()
                        : ListTile(
                            leading: Icon(Icons.person_sharp),
                            title: Text(controller.nombre!),
                            subtitle: Text('cerrar sesión'),
                            onTap: () async {
                              await controller.singOut();
                              // controller.singOut();
                              print(controller.nombre);
                              controller.nombre = '';

                              controller.sinIncheck = false;
                              controller.negocio = 0;

                              controller.notify();
                              Navigator.of(context).pushAndRemoveUntil(
                                  CupertinoPageRoute(
                                      builder: (context) => NewPageFisrt()),
                                  (Route<dynamic> route) => false);
                            },
                          ),
                controller.negocio != 0 ? Divider() : Container(),
                controller.negocio != 0
                    ? ListTile(
                        leading: Icon(Icons.money),
                        title: Text('Pagos'),
                        trailing: totalPagos != 0
                            ? Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Center(
                                  child: Text(
                                    totalPagos.toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : Container(
                                child: Text(""),
                              ),
                        onTap: () {
                          Navigator.of(context).pushNamed('/pagos');
                        },
                      )
                    : Container(),
                controller.negocio != 0 ? Divider() : Container(),
                controller.negocio != 0
                    ? ListTile(
                        leading: Icon(Icons.remove_red_eye_outlined),
                        title: Text('Notificaciones'),
                        subtitle: Text('Registro de actividad'),
                        trailing: totalNotificacione != 0
                            ? Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Center(
                                  child: Text(
                                    totalNotificacione.toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : Container(
                                child: Text(""),
                              ),
                        onTap: () {
                          Navigator.of(context).pushNamed('/actividad');
                        },
                      )
                    : Container(),
                controller.negocio != 0 ? Divider() : Container(),
                controller.negocio != 0
                    ? ListTile(
                        leading: Icon(Icons.person_sharp),
                        title: Text(controller.nombre!),
                        subtitle: Text('cerrar sesión'),
                        onTap: () {
                          controller.singOut();
                          // controller.singOut();
                          print(controller.nombre);
                          controller.nombre = '';

                          controller.sinIncheck = false;
                          controller.negocio = 0;

                          controller.notify();
                          Navigator.of(context).pushAndRemoveUntil(
                              CupertinoPageRoute(
                                  builder: (context) => NewPageFisrt()),
                              (Route<dynamic> route) => false);
                        },
                      )
                    : Container(),
                Divider(),
                controller.sinIncheck
                    ? Container()
                    : ListTile(
                        leading: Icon(Icons.person_outlined),
                        title: Text('Regístrate'),
                        onTap: () {
                          Navigator.of(context).pushNamed('/registro');
                        },
                      ),
                controller.sinIncheck ? Container() : Divider(),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Acerca de.'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/acercade');
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.help),
                  title: Text('Ayuda y soporte técnico'),
                  onTap: () {
                    Navigator.of(context).pushNamed('/soporte');
                  },
                ),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
