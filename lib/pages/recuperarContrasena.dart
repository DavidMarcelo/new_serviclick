import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:serviclick/services/services.dart';

class RecuperarContrasena extends StatefulWidget {
  const RecuperarContrasena({Key? key}) : super(key: key);

  @override
  _RecuperarContrasenaState createState() => _RecuperarContrasenaState();
}

Future enviarCorreo(String email) async {
  print('DESPUES VIENE EL BODY de las notificaciones');
  print(email);
  var url = Uri.parse(
    'https://serviclick.com.mx/api/recuperacion',
  );
  final response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        //'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"email": email}));
  var response1 = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print(response1);
    if (response1['message'] ==
        'No existe ninguna cuenta vinculada a la dirección de correo proporcionada') {
      mensaje = response1['message'];
      return false;
    } else {
      mensaje = response1['message'];
      return true;
    }
  } else {
    print('error ${response.body}');
    mensaje = response1['message'];
    return false;
  }
}

Future recuperarContrasena(Map recuperar) async {
  print('DESPUES VIENE EL BODY de las notificaciones');
  //print(email);
  var url = Uri.parse(
    'https://serviclick.com.mx/api/recuperar',
  );
  final response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        //'Authorization': 'Bearer $token',
      },
      body: jsonEncode(recuperar));
  var response1 = jsonDecode(response.body);
  if (response.statusCode == 200) {
    print(response1);
    if (response1['message'] == 'El código proporcionado no existe') {
      mensaje = response1['message'];
      return false;
    } else {
      mensaje = response1['message'];
      return true;
    }
  } else {
    print('error ${response.body}');
    mensaje = response1['message'][0];
    return false;
  }
}

final GlobalKey<FormState> formkey = GlobalKey<FormState>();

String mensaje = '';
bool showpass = false;
bool showpass1 = false;
String contrasena = '';

class _RecuperarContrasenaState extends State<RecuperarContrasena> {
  TextEditingController textEditingController = TextEditingController();
  String error = '';
  bool correoEnviado = false;
  Map<String, dynamic> recuperar = {};
  bool comparado = false;
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    var largo = MediaQuery.of(context).size.height;
    var ancho = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar Contraseña.'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: largo,
          width: ancho,
          child: Column(
            children: [
              !correoEnviado
                  ? Expanded(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Por favor Ingrese el correo electrónico.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 20),
                          child: TextField(
                            controller: textEditingController,
                            style: TextStyle(color: Colors.black),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              errorText: error.isEmpty ? null : error,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 0),
                              labelText: 'Correo',
                              labelStyle: TextStyle(color: Colors.black),
                              prefixIcon:
                                  Icon(Icons.email, color: Colors.black),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              var ok;
                              if (textEditingController.text.isEmpty ||
                                  textEditingController.text == '') {
                                setState(() {
                                  error = 'El correo no puede quedar vacío';
                                });
                                return;
                              } else {
                                controller.showDialog1(
                                    context, 'Enviando correo', true);
                                String p =
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                                RegExp regExp = new RegExp(p);

                                ok = regExp.hasMatch(
                                    textEditingController.text.trim());
                                print(ok);
                                if (ok) {
                                  setState(() {
                                    error = '';
                                  });
                                } else {
                                  setState(() {
                                    error = 'Formato de correo inválido';
                                  });
                                  return;
                                }

                                await enviarCorreo(
                                        textEditingController.text.trim())
                                    .then((value) {
                                  if (value) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('$mensaje.'),
                                      backgroundColor: Colors.green,
                                    ));
                                    setState(() {
                                      correoEnviado = true;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('$mensaje.'),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                });

                                controller.showDialog1(context, 'aaqa', false);
                                //controller.notify();
                              }
                            },
                            child: Text('Enviar correo.'))
                      ],
                    ))
                  : Expanded(
                      child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Por favor ingresa los datos que se te piden.',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: largo * .02,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 20),
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              validator: (String? texto) {
                                if (texto!.isEmpty || texto == '') {
                                  return 'Clave vacía';
                                }
                                return null;
                              },
                              onSaved: (String? texto) {
                                recuperar['clave'] = texto!.trim();
                              },
                              decoration: InputDecoration(
                                helperText:
                                    'La clave que te ha enviado a tu correo.',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 0),
                                labelText: 'Clave',
                                labelStyle: TextStyle(color: Colors.black),
                                prefixIcon:
                                    Icon(Icons.vpn_key, color: Colors.black),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 20),
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              obscureText: !showpass,
                              validator: (String? texto) {
                                if (texto!.isEmpty || texto == '') {
                                  return 'Contraseña vacía';
                                } else if (texto.trim().length < 8) {
                                  return 'La contraseña debe tener al menos 8 carácteres';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                contrasena = value;
                              },
                              onSaved: (String? texto) {
                                recuperar['password'] = texto!.trim();
                              },
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 0),
                                labelText: 'Contraseña',
                                labelStyle: TextStyle(color: Colors.black),
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
                                    color: Colors.black,
                                  ),
                                ),
                                prefixIcon:
                                    Icon(Icons.lock, color: Colors.black),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 20),
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              obscureText: !showpass1,
                              validator: (String? texto) {
                                if (texto!.isEmpty || texto == '') {
                                  return 'Contraseña vacía';
                                } else if (texto.trim().length < 8) {
                                  return 'La contraseña debe tener al menos 8 carácteres';
                                }
                                int valor = contrasena.compareTo(texto);
                                print(valor);
                                if (valor != 0) {
                                  print('aqui');
                                  return 'Las contaseñas no coinciden.';
                                } else {
                                  setState(() {
                                    comparado = true;
                                  });
                                }
                                return null;
                              },
                              onSaved: (String? texto) {
                                //logInmap['contrasena'] = texto.trim();
                              },
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 0),
                                labelText: 'Confirma tu contraseña',
                                labelStyle: TextStyle(color: Colors.black),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showpass1 = !showpass1;
                                    });
                                  },
                                  child: Icon(
                                    showpass1
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                ),
                                prefixIcon:
                                    Icon(Icons.lock, color: Colors.black),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                if (!formkey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Por favor completa lo faltante.')));
                                  return;
                                }
                                controller.showDialog1(
                                    context, 'Restaurando contraseña.', true);
                                formkey.currentState!.save();
                                await recuperarContrasena(recuperar)
                                    .then((value) {
                                  if (value) {
                                    controller.showDialog1(context,
                                        'Restaurando contraseña.', false);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'La contraseña ha sido restaurada.'),
                                      backgroundColor: Colors.green,
                                    ));
                                    Navigator.of(context).pop();
                                  } else {
                                    controller.showDialog1(context,
                                        'Restaurando contraseña.', false);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('$mensaje'),
                                      backgroundColor: Colors.red,
                                    ));
                                    return;
                                  }
                                });
                              },
                              child: Text('Recuperar mi contraseña')),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
