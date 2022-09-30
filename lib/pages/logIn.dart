import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serviclick/pages/pages.dart';
import 'package:serviclick/services/controller.dart';
import 'package:serviclick/services/models.dart';
import 'package:serviclick/shared/colores.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool isSwitched = true;

  final key = GlobalKey<FormState>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool errorbase = false;
  bool loading = false;
  bool showpass = false;
  Map<String, dynamic> logInmap = {
    'usuario': null,
    'contrasena': null,
    'telefono': null
  };

  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);

    var largo = MediaQuery.of(context).size.height;
    var ancho = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: largo / 1.4,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      child: Image(
                          height: largo / 1.5,
                          fit: BoxFit.fill,
                          image: AssetImage('assets/Serviclic-05.png')),
                    ),
                  ),
                  loading
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
                                    backgroundColor: Colors.white,
                                  ),
                                  SizedBox(
                                    height: largo * .05,
                                  ),
                                  Text('Iniciando sesión...',
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
                              key: key,
                              child: Column(
                                children: [
                                  Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Ahora puedes iniciar sesión con tu correo o telefono.",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Correo electronico.",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Switch(
                                              value: isSwitched,
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value) {
                                                    logInmap['usuario'] = null;
                                                  } else {
                                                    logInmap['phone'] = null;
                                                  }
                                                  isSwitched = value;
                                                  print(isSwitched);
                                                });
                                              },
                                              activeTrackColor:
                                                  Colors.lightBlue.shade900,
                                              activeColor: Colors.white,
                                              inactiveTrackColor: Colors.white,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextFormField(
                                    enabled: isSwitched ? true : false,
                                    style: TextStyle(color: Colors.white),
                                    validator: (String? texto) {
                                      if (isSwitched == true) {
                                        var ok;
                                        if (texto!.isEmpty ||
                                            texto == '' ||
                                            errorbase) {
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
                                      }
                                      return null;
                                    },
                                    onSaved: (String? texto) {
                                      logInmap['usuario'] = texto!.trim();
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 0),
                                      labelText: 'Correo',
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
                                    enabled: isSwitched ? false : true,
                                    style: TextStyle(color: Colors.white),
                                    validator: (String? texto) {
                                      if (isSwitched == false) {
                                        if (texto!.isEmpty ||
                                            texto == '' ||
                                            errorbase) {
                                          return 'Telefono Incorrecto';
                                        } else if (texto.trim().length < 10) {
                                          return 'El numéro debe tener 10 digitos';
                                        }
                                        return null;
                                      }
                                      return null;
                                    },
                                    onSaved: (String? texto) {
                                      logInmap['telefono'] = texto!.trim();
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 0),
                                      labelText: 'Telefono',
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
                                      if (texto!.isEmpty ||
                                          texto == '' ||
                                          errorbase) {
                                        return 'Contraseña Incorrecta';
                                      } else if (texto.trim().length < 8) {
                                        return 'La contraseña debe tener al menos 8 carácteres';
                                      }
                                      return null;
                                    },
                                    onSaved: (String? texto) {
                                      logInmap['contrasena'] = texto!.trim();
                                    },
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 0),
                                      labelText: 'Contraseña',
                                      labelStyle:
                                          TextStyle(color: Colors.white),
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
                                      prefixIcon:
                                          Icon(Icons.lock, color: Colors.white),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: largo * .02,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).push(
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        RecuperarContrasena()));
                                          },
                                          child: Text(
                                              '¿Olvidaste tu contraseña?',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  decoration: TextDecoration
                                                      .underline))),
                                    ],
                                  ),
                                  ButtonBar(
                                    children: [
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.grey[400],
                                              onPrimary: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          onPressed: () {
                                            Navigator.popAndPushNamed(
                                                context, '/registro');
                                          },
                                          child: Text('Regístrate')),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.grey[400],
                                              onPrimary: Colors.black,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          onPressed: () async {
                                            errorbase = false;
                                            print(
                                                !key.currentState!.validate());
                                            if (!key.currentState!.validate()) {
                                              print("Nada");
                                              return;
                                            } else {
                                              print("Bueno a empezar");
                                              key.currentState!.save();
                                              if (await controller
                                                      .internetcheck() ==
                                                  false) {
                                                return showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return WillPopScope(
                                                        onWillPop: () async {
                                                          return false;
                                                        },
                                                        child: AlertDialog(
                                                          title: Text(
                                                              'Sin conexión'),
                                                          content: Text(
                                                              'Verifica tu conexión a internet y vuelve a intentarlo'),
                                                          actions: [
                                                            ElevatedButton(
                                                                onPressed: () {
                                                                  exit(0);
                                                                },
                                                                child: Text(
                                                                    'Salir')),
                                                            ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                    'Reintentar'))
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              } else {
                                                setState(() {
                                                  loading = true;
                                                });
                                                print("map login: " +
                                                    logInmap.toString());

                                                var checcar = await controller
                                                    .iniciarSesion(
                                                        logInmap['usuario'],
                                                        logInmap['telefono'],
                                                        logInmap['contrasena']);

                                                print(checcar['result']);

                                                print(logInmap);
                                                print('entre aqui');

                                                if (checcar['result'] == null) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  return showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          title: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'Datos Incorrectos',
                                                                style: TextStyle(
                                                                    color:
                                                                        primaryColor),
                                                              ),
                                                              Text(
                                                                  'Intenta nuevamente')
                                                            ],
                                                          ),
                                                          content: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                      'ok'))
                                                            ],
                                                          ),
                                                        );
                                                      });
                                                } else {
                                                  print(
                                                      'DESPUES DE INICIAR SESIÓN');
                                                  Map<String, dynamic> result =
                                                      checcar['result'];
                                                  result.addAll({
                                                    'email':
                                                        logInmap['usuario'],
                                                    'phone':
                                                        logInmap['telefono'],
                                                    'password':
                                                        logInmap['contrasena'],
                                                  });

                                                  UsuarioModel usuario =
                                                      UsuarioModel.fromJson(
                                                          result);
                                                  print(usuario.email);
                                                  print(usuario.name);
                                                  print(usuario.empresa);
                                                  print(usuario.remembertoken);
                                                  controller.usuarioActual =
                                                      usuario;
                                                  controller.nombre =
                                                      usuario.name;
                                                  controller.negocio =
                                                      usuario.empresa;
                                                  controller.rememberToken =
                                                      usuario.remembertoken;
                                                  await controller.sigIn(
                                                    controller
                                                        .usuarioActual.email!,
                                                    controller.usuarioActual
                                                        .password!,
                                                    remeberToken: controller
                                                        .usuarioActual
                                                        .remembertoken,
                                                  );
                                                  // controller.notify();

                                                  // controller.agregarUsuario(usuarioact);
                                                  //  print(usuarioact.email);

                                                  if (controller.negocio != 0 &&
                                                      controller.sinIncheck) {
                                                    await controller
                                                        .obtenerNegocio(
                                                            controller
                                                                .usuarioActual
                                                                .remembertoken,
                                                            controller);

                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  NegocioPage(
                                                                      token: controller
                                                                          .rememberToken),
                                                            ),
                                                            (route) => false);
                                                  } else if (controller
                                                              .negocio ==
                                                          0 &&
                                                      controller.sinIncheck) {
                                                    controller.showDialog1(
                                                        context,
                                                        'Iniciando sesión',
                                                        true);
                                                    controller.showDialog1(
                                                        context, '', false);

                                                    Navigator.of(context)
                                                        .pushNamedAndRemoveUntil(
                                                            '/home',
                                                            (Route<dynamic>
                                                                    route) =>
                                                                false);
                                                  }
                                                }
                                              }

                                              setState(() {
                                                loading = false;
                                              });

                                              //aqui se manda el pam al json que me pasaran
                                            }
                                          },
                                          child: Text('Ingresar'))
                                    ],
                                  ),
                                  SizedBox(
                                    height: largo * .03,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              width: ancho,
              child: Image(
                  height: ancho * .25,
                  width: ancho * .25,
                  image: AssetImage('assets/images/logo8.png')),
            ),
            SizedBox(
              height: largo * .01,
            ),
          ],
        ),
      ),
    );
  }
}
