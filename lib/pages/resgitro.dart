import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';
import 'package:serviclick/pages/pages.dart';
import 'package:serviclick/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

enum Opciones { SI, NO }

class Registro extends StatefulWidget {
  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final key1 = GlobalKey<FormState>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool emppresa = false;
  bool loadingregistro = false;
  Map<String, dynamic> registroMap = {
    'empresa': null,
    'email': null,
    'password': null,
    'nombre': null,
    'tipo': null,
    'phone': null
  };

  bool checkregistro = true;

  Opciones? _opciones = Opciones.SI;

  bool showpass = false;
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    var largo = MediaQuery.of(context).size.height;
    var ancho = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => atras(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Regístrate'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: largo / 1.8,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        child: Image(
                            height: largo / 1.9,
                            fit: BoxFit.fill,
                            image: AssetImage('assets/Serviclic-05.png')),
                      ),
                    ),
                    loadingregistro
                        ? Positioned(
                            child: Center(
                            child: Container(
                                color: Colors.transparent,
                                height: largo / 5,
                                width: ancho / 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                        backgroundColor: Colors.white),
                                    SizedBox(
                                      height: largo * .05,
                                    ),
                                    Text('Creando usuario...',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white))
                                  ],
                                )),
                          ))
                        : Positioned(
                            top: 30,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              width: ancho,
                              height: largo,
                              child: Form(
                                  key: key1,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        validator: (String? texto) {
                                          var ok;
                                          if (texto!.isEmpty ||
                                              texto.trim() == '') {
                                            return 'Correo vacío';
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
                                            return 'Debe ser un formato de correo ';
                                          }
                                        },
                                        onSaved: (String? texto) {
                                          registroMap['email'] = texto!.trim();
                                        },
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          contentPadding:
                                              EdgeInsets.symmetric(vertical: 0),
                                          labelText: '* Correo',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          prefixIcon: Icon(Icons.email,
                                              color: Colors.white),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: largo * .02,
                                      ),
                                      TextFormField(
                                        style: TextStyle(color: Colors.white),
                                        validator: (String? texto) {
                                          if (texto!.isEmpty || texto == '') {
                                            return 'Nombre vacío';
                                          }
                                          return null;
                                        },
                                        onSaved: (String? texto) {
                                          registroMap['nombre'] = texto!.trim();
                                        },
                                        keyboardType: TextInputType.name,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          contentPadding:
                                              EdgeInsets.symmetric(vertical: 0),
                                          labelText: '*Nombre completo',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          prefixIcon: Icon(Icons.person_add_alt,
                                              color: Colors.white),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: largo * .02,
                                      ),
                                      TextFormField(
                                        style: TextStyle(color: Colors.white),
                                        //obscureText: !showpass,
                                        validator: (String? texto) {
                                          if (texto!.isEmpty || texto == '') {
                                            return 'Telefono vacío';
                                          } else if (texto.length < 10) {
                                            return 'La numero debe ser de 10 digitos.';
                                          }
                                          return null;
                                        },
                                        onSaved: (String? texto) {
                                          registroMap['phone'] = texto!.trim();
                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          contentPadding:
                                              EdgeInsets.symmetric(vertical: 0),
                                          labelText: '*Telefono',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          prefixIcon: Icon(Icons.phone,
                                              color: Colors.white),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: largo * .02,
                                      ),
                                      TextFormField(
                                        style: TextStyle(color: Colors.white),
                                        obscureText: !showpass,
                                        validator: (String? texto) {
                                          if (texto!.isEmpty || texto == '') {
                                            return 'Contraseña vacía';
                                          } else if (texto.length < 8) {
                                            return 'La contraseña debe tener al menos 8 carácteres';
                                          }
                                          return null;
                                        },
                                        onSaved: (String? texto) {
                                          registroMap['password'] =
                                              texto!.trim();
                                        },
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showpass = !showpass;
                                              });
                                            },
                                            child: Icon(
                                              showpass
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.white,
                                            ),
                                          ),
                                          contentPadding:
                                              EdgeInsets.symmetric(vertical: 0),
                                          labelText: '*Contraseña',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          prefixIcon: Icon(Icons.lock,
                                              color: Colors.white),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: largo * .02,
                                      ),
                                      TextFormField(
                                        expands: false,
                                        style: TextStyle(color: Colors.white),
                                        validator: (String? texto) {
                                          if (texto!.isEmpty || texto == '') {
                                            return 'Es requerido un nombre para el negocio';
                                          }
                                          return null;
                                        },
                                        // onChanged: ,
                                        onSaved: (String? texto) {
                                          registroMap['tipo'] = 'negocio';
                                          registroMap['empresa'] =
                                              texto!.trim();
                                        },
                                        keyboardType: TextInputType.name,
                                        decoration: InputDecoration(
                                          /*suffixIcon: IconButton(
                                            color: Colors.white,
                                            icon: Icon(Icons.help),
                                            onPressed: () {
                                              showDialog(
                                                  useSafeArea: false,
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                              'Si deseas ofrecer algún servicio y/o eres propietario de un negocio, debes  proporcionar a ServiClick un nombre el cual te identificará en el directorio cuando tus datos sean validados.'),
                                                          SizedBox(
                                                            height:
                                                                largo * 0.05,
                                                          ),
                                                          Text(
                                                            '¿Qué sucede si quiero registrarme y dejo éste campo vacío?',
                                                            style: TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                largo * 0.02,
                                                          ),
                                                          Text(
                                                            'La Aplicación móvil te registrará como un usuario que puede comentar y valorar pero no ofrece ningún servicio.',
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            },
                                          ),*/
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 5),
                                          labelText: '*Nombre del negocio',
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          prefixIcon: Icon(Icons.group,
                                              color: Colors.white),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  )),
                            ),
                          ),
                  ],
                ),
              ),
              // loadingregistro
              //     ? Container()
              //     : Center(
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Text('¿Regístrarse cómo negocio?'),
              //             IconButton(
              //                 icon: Icon(
              //                   Icons.help,
              //                   size: 15,
              //                 ),
              //                 onPressed: () {
              //                   return showDialog(
              //                       context: context,
              //                       builder: (context) {
              //                         return AlertDialog(
              //                           title: Column(
              //                             children: [
              //                               Text('Registrarse'),
              //                               Divider(),
              //                             ],
              //                           ),
              //                           content: Text(
              //                               'Existen dos opciones de registro.\nSi seleccionas NO, ServiClick te registrará como un usuario normal, si seleccionaste SI, Serviclick te registrará como un negocio o persona que ofrece algun tipo de servicio.'),
              //                           actions: [
              //                             ElevatedButton(
              //                                 onPressed: () {
              //                                   Navigator.of(context).pop();
              //                                 },
              //                                 child: Text('Ok'))
              //                           ],
              //                         );
              //                       });
              //                 })
              //           ],
              //         ),
              //       ),
              // loadingregistro
              //     ? Container()
              //     : Container(
              //         child: RadioButtonGroup(
              //           padding: EdgeInsets.symmetric(horizontal: ancho / 2.9),
              //           orientation: GroupedButtonsOrientation.HORIZONTAL,
              //           labels: <String>[
              //             'Si',
              //             'No',
              //           ],
              //           onSelected: (String opcion) {
              //             if (opcion == 'Si') {
              //               registroMap['tipo'] = 'negocio';
              //               setState(() {
              //                 emppresa = true;
              //               });
              //             } else {
              //               registroMap['tipo'] = 'cliente';
              //               registroMap['empresa'] = null;
              //               setState(() {
              //                 emppresa = false;
              //               });
              //             }
              //           },
              //           picked: null,
              //         ),
              //       ),
              // SizedBox(
              //   height: largo * .02,
              // ),

              loadingregistro
                  ? Container()
                  : Container(
                      child: Text(
                          'Todos los campos marcados con * son requeridos.')),

              SizedBox(
                height: largo * .05,
              ),

              loadingregistro
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                            value: checkregistro,
                            onChanged: (value) {
                              setState(() {
                                checkregistro = !checkregistro;
                              });
                            }),
                        Flexible(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.start,

                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Al registrarte aceptas nuestros',
                              ),
                              GestureDetector(
                                  child: Text('Términos y condiciones',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          decoration:
                                              TextDecoration.underline)),
                                  onTap: () async {
                                    await canLaunch(
                                            'https://serviclick.com.mx/terminos')
                                        ? await launch(
                                            'https://serviclick.com.mx/terminos')
                                        : Fluttertoast.showToast(
                                            msg:
                                                'No se ha podido lanzar el navegador.');
                                  }),
                              Text(' y '),
                              GestureDetector(
                                  child: Text('Política de privacidad',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          decoration:
                                              TextDecoration.underline)),
                                  onTap: () async {
                                    await canLaunch(
                                            'https://serviclick.com.mx/privacidad')
                                        ? await launch(
                                            'https://serviclick.com.mx/privacidad')
                                        : Fluttertoast.showToast(
                                            msg:
                                                'No se ha podido lanzar el navegador.');
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),

              SizedBox(
                height: largo * .05,
              ),
              loadingregistro
                  ? Container()
                  : ElevatedButton(
                      onPressed: checkregistro
                          ? () async {
                              if (!key1.currentState!.validate()) {
                              } else {
                                key1.currentState!.save();
                                if (await controller.internetcheck() == false) {
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
                                } else {
                                  setState(() {
                                    loadingregistro = true;
                                  });
                                  print(registroMap);
                                  //AQUI EL JSON PARA MANDAR A REGISTRAR LOS DATOS

                                  var registro = await controller
                                      .registrarUsuario(registroMap);

                                  if (registro.length == 0) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "No se pudo registrar el usuario, fallo en la conexión. Por favor intente mas tarde.");
                                  } else {
                                    print(registro['result']);
                                    if (registro['result'] == null) {
                                      print('entre aqui');

                                      setState(() {
                                        loadingregistro = false;
                                      });
                                      List<dynamic> hola = registro['message'];
                                      print(hola.first);
                                      return showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              title: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Html(
                                                    data: hola.first.toString(),
                                                    /*style: {
                                                      "body": Style(
                                                          fontSize:
                                                              FontSize(18))
                                                    },*/
                                                  ),
                                                ],
                                              ),
                                              content: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('ok'))
                                                ],
                                              ),
                                            );
                                          });
                                    } else {
                                      //print("else entre aqui");
                                      /*await controller.sigIn(
                                      registroMap['email'],
                                      registroMap['password'],
                                    );*/
                                      await controller.iniciarSesion(
                                        registroMap['email'],
                                        registroMap['phone'],
                                        registroMap['password'],
                                      );

                                      var checcar =
                                          await controller.iniciarSesion(
                                              registroMap['email'],
                                              registroMap['phone'],
                                              registroMap['password']);
                                      Map<String, dynamic> result =
                                          checcar['result'];
                                      result.addAll({
                                        'email': registroMap['email'],
                                        'password': registroMap['contrasena'],
                                      });

                                      UsuarioModel usuario =
                                          UsuarioModel.fromJson(result);
                                      controller.usuarioActual = usuario;
                                      controller.negocio = usuario.empresa;
                                      controller.notify();

                                      if (controller.negocio != 0 &&
                                          controller.sinIncheck) {
                                        await controller.obtenerNegocio(
                                            controller
                                                .usuarioActual.remembertoken,
                                            controller);
                                        setState(() {
                                          loadingregistro = false;
                                        });
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  NegocioPage(
                                                      token: controller
                                                          .rememberToken),
                                            ),
                                            (route) => false);
                                      } else if (controller.negocio == 0 &&
                                          controller.sinIncheck) {
                                        setState(() {
                                          loadingregistro = false;
                                        });
                                        controller.showDialog1(
                                            context, 'Iniciando sesión', true);
                                        controller.showDialog1(
                                            context, '', false);

                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                '/home',
                                                (Route<dynamic> route) =>
                                                    false);
                                      }

                                      // Navigator.of(context).pushAndRemoveUntil(
                                      //     MaterialPageRoute(
                                      //         builder: (context) => NewPageFisrt()),
                                      //     (Route<dynamic> route) => false);
                                    }
                                    //else de error 500
                                  }
                                }
                              }
                            }
                          : () => Fluttertoast.showToast(
                              msg:
                                  'Para registrarte en ServiClick debes aceptar las políticas y términos de uso'),
                      child: Text('Regístrate')),
            ],
          ),
        ),
      ),
    );
  }

  bool atras() {
    if (loadingregistro) {
      return false;
    } else {
      print(registroMap);
      registroMap.clear();
      print('hel');
      print(registroMap);
      return true;
      // Navigator.of(context).pop();

    }
  }
}
