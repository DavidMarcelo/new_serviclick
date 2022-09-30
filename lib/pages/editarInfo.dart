import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:serviclick/pages/mapa.dart';
import 'package:http/http.dart' as http;
import 'package:serviclick/services/services.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class EditarInfo extends StatefulWidget {
  EditarInfo({this.negocioActual});
  NegociosModel? negocioActual;

  @override
  _EditarInfoState createState() => _EditarInfoState();
}

class _EditarInfoState extends State<EditarInfo> {
  NegociosModel? negocioActual1;

  final key2 = GlobalKey<FormState>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool emppresa = false;

  bool loadingregistro = false;
  bool registrando = false;

  TramitesModel? tramites;
  void initState() {
    super.initState();
  }

  Future<List<CategoriaModel>?> categorias(Controller controller) async {
    try {
      var response;
      var response1;
      var response2;
      var url1 = Uri.parse('https://serviclick.com.mx/api/categorias');
      response = await http.post(url1);

      response1 = jsonDecode(response.body);
      response2 = jsonEncode(response1['result']);

      return parseJson(response2, controller);
    } catch (e) {
      await controller.internetcheck();
      controller.notify();
    }
    return null;
  }

  List<CategoriaModel>? parseJson(String response, Controller controller) {
    final parsed = jsonDecode(response);

    categoriasList = parsed['categorias']
        .map<CategoriaModel>((json) => CategoriaModel.fromJson(json))
        .toList();

    if (categoriasList!.length == categoria!.length) {
    } else {
      categoria!.clear();
      categoria = categoriasList;
    }
    categoria!.forEach((element) {
      if (controller.negocioActual!.categoria.toString() == element.nombre) {
        if (selectedCategoria == null) {
          selectedCategoria = element;
        }
      }
    });

    return categoriasList;
  }

  Future<List<UbicacionModel>?> ubicaciones(Controller controller) async {
    try {
      var response;
      var response1;
      var response2;
      var url1 = Uri.parse('https://serviclick.com.mx/api/ubicaciones');
      response = await http.post(url1);

      response1 = jsonDecode(response.body);
      response2 = jsonEncode(response1['result']);

      return parseJsonUbicacion(response2, controller);
    } catch (e) {
      await controller.internetcheck();
      controller.notify();
    }
    return null;
  }

  bool ubicarionR = false;
  bool cargando = false;
  List<UbicacionModel>? parseJsonUbicacion(
      String response, Controller controller) {
    final parsed = jsonDecode(response);

    ubicacionList = parsed['ubicaciones']
        .map<UbicacionModel>((json) => UbicacionModel.fromJson(json))
        .toList();
    if (ubicacionList!.length == ubicacion!.length) {
    } else {
      ubicacion!.clear();
      ubicacion = ubicacionList;
    }
    //print(controller.negocioActual!.categoria);
    //print(controller.negocioActual!.ubicacion.toString());
    ubicacion!.forEach((element) {
      if (controller.negocioActual!.ubicacion.toString() == element.nombre) {
        if (selectedUbicacion == null) {
          selectedUbicacion = element;
          //print('ESTA NULO');
        }
      }
    });

    return ubicacionList;
  }

  Map<String, dynamic> actualizar = {
    'nombre': null,
    'direccion': null,
    'telefono': null,
    'descripcion': null,
    'servicios': null,
    'precio_min': null,
    'precio_max': null,
    'categoria': null,
    'ubicacion': null,
    'mapa': null,
    'web': null
  };

  List<CategoriaModel>? categoriasList = [];

  List<UbicacionModel>? ubicacionList = [];

  List<CategoriaModel>? categoria = [];

  CategoriaModel? selectedCategoria;

  List<UbicacionModel>? ubicacion = [];

  UbicacionModel? selectedUbicacion;
  Future<dynamic> actualizarInfo(
      Map<String, dynamic> datos, String? token) async {
    var url1 =
        Uri.parse('https://serviclick.com.mx/api/actualizar_informacion');
    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(datos),
    );

    /*print(response.body);
    print(response.statusCode);

    print('aqui se imprime el inicio de sesión');*/
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,+
      final response1 = await jsonDecode(response.body);
      //print(response1['message']);
      // then parse the JSON.

      return response1;
      // UsuarioModel.fromJson(jsonDecode(response.body));
    } else {
      final response2 = await jsonDecode(response.body);
      //print(response2);
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      return response2;
    }
  }

  Future<TramitesModel?> tramite(String? token) async {
    var url1 = Uri.parse('https://serviclick.com.mx/api/tramite_informacion');
    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    /*print('DESPUES VIENE EL BODY');
    print(response.body);*/
    if (response.statusCode == 200) {
      final response1 = await jsonDecode(response.body);
      final response2 = jsonEncode(response1['result']);
      final response3 = jsonDecode(response2);
      tramites = TramitesModel.fromJson(response3);
      //print(tramites!.status);
      return tramites;
    } else {
      return tramites;
    }
//print(response.statusCode);
  }

  late List mapa;
  double? lat;
  double? long;
  late LocationData _currentPosition;
  @override
  Widget build(BuildContext context) {
    final Location location = Location();
    Controller controller = Provider.of<Controller>(context);
    mapa = controller.negocioActual!.mapa!.split(',');
    lat = double.parse(mapa[0]);
    long = double.parse(mapa[1]);

    return Scaffold(
        appBar: AppBar(
          title: Text('Editar Información'),
          actions: [
            IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              Text('Más información'),
                              Divider(),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  'Si necesitas agregar imágenes a tu galería o redes sociales, te invitamos a visitar e ingresar como usuario:'),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () =>
                                    launch('https://serviclick.com.mx/'),
                                child: Text(
                                  'ServiClick web',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                })
          ],
        ),
        body: controller.internet
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height,
                            alignment: Alignment.bottomCenter,
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset('assets/Serviclic404.png'),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / 1.1,
                            child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Form(
                                  key: key2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                            child: Card(
                                                color: Colors.green[300],
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        leading: Icon(
                                                          Icons.check,
                                                          color: Colors.black,
                                                        ),
                                                        title: Text(
                                                          'Tu información ha sido aprobada.\n',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        subtitle: Text(
                                                          'Si necesitas actualizar algún apartado hazlo aqui, los cambios se reflejaran automáticamente en el directorio.',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ))),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          //maxLength: 200,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              labelText: 'Nombre',
                                              prefixIcon: Icon(
                                                  FontAwesomeIcons.idCard)),
                                          validator: (String? texto) {
                                            if (texto!.trim() == '') {
                                              return 'No puedes dejar campos vacíos';
                                            }

                                            return null;
                                          },
                                          onChanged: (String texto) {},
                                          enabled: true,
                                          initialValue:
                                              controller.negocioActual!.nombre,
                                          onSaved: (String? texto) {
                                            actualizar['nombre'] =
                                                texto!.trim();
                                            return;
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              labelText: 'Dirección',
                                              prefixIcon: Icon(FontAwesomeIcons
                                                  .mapMarkedAlt)),
                                          validator: (String? texto) {
                                            if (texto!.trim() == '') {
                                              return 'No puedes dejar campos vacíos';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onChanged: (String texto) {},
                                          enabled: true,
                                          initialValue: controller
                                              .negocioActual!.direccion,
                                          onSaved: (String? texto) {
                                            actualizar['direccion'] =
                                                texto!.trim();
                                            return;
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              labelText: 'Teléfono',
                                              prefixIcon: Icon(Icons.phone)),
                                          validator: (String? texto) {
                                            if (texto!.trim() == '') {
                                              return 'No puedes dejar campos vacíos';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onChanged: (String texto) {},
                                          enabled: true,
                                          initialValue: controller
                                              .negocioActual!.telefono,
                                          onSaved: (String? texto) {
                                            actualizar['telefono'] =
                                                texto!.trim();
                                            return;
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          minLines: 1,
                                          maxLines: 6,
                                          maxLength: 1000,
                                          // expands: true,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              labelText: 'Describe tu empresa',
                                              prefixIcon: Icon(
                                                  FontAwesomeIcons.commentAlt)),
                                          validator: (String? texto) {
                                            if (texto!.trim() == '') {
                                              return 'No puedes dejar campos vacíos';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onChanged: (String texto) {},
                                          enabled: true,
                                          initialValue: controller
                                              .negocioActual!.descripcion,
                                          onSaved: (String? texto) {
                                            actualizar['descripcion'] =
                                                texto!.trim();
                                            return;
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          minLines: 1,
                                          maxLines: 6,
                                          maxLength: 1000,
                                          // expands: true,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              labelText: 'Servicios que ofrece',
                                              prefixIcon: Icon(FontAwesomeIcons
                                                  .conciergeBell)),
                                          validator: (String? texto) {
                                            if (texto!.trim() == '') {
                                              return 'No puedes dejar campos vacíos';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onChanged: (String texto) {},
                                          enabled: true,
                                          initialValue: controller
                                              .negocioActual!.servicios,
                                          onSaved: (String? texto) {
                                            actualizar['servicios'] =
                                                texto!.trim();
                                            return;
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        FutureBuilder(
                                          builder: (context, snapshots) {
                                            //if (snapshots.hasError)
                                              //print(snapshots.error);
                                            // ubicacion = snapshots.data;

                                            return Column(
                                              children: [
                                                Container(
                                                  child:
                                                      DropdownButtonFormField(
                                                          isExpanded: true,
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          10)),
                                                              labelText:
                                                                  'Ubicación',
                                                              prefixIcon: Icon(
                                                                  FontAwesomeIcons
                                                                      .mapMarkerAlt)),
                                                          validator:
                                                              (UbicacionModel?
                                                                  ubicacion) {
                                                            if (ubicacion ==
                                                                null) {
                                                              return 'Necesitas elegir una ubicación';
                                                            }
                                                            return null;
                                                          },
                                                          onSaved:
                                                              (UbicacionModel?
                                                                  ubicacion) {
                                                            actualizar[
                                                                    'ubicacion'] =
                                                                ubicacion!.id
                                                                    .toString();
                                                            return;
                                                          },
                                                          value:
                                                              selectedUbicacion,
                                                          items: ubicacion!.map(
                                                              (ubicacion1) {
                                                            return DropdownMenuItem(
                                                              value: ubicacion1,
                                                              child: Text(
                                                                  ubicacion1
                                                                      .nombre!),
                                                            );
                                                          }).toList(),
                                                          hint: Text(
                                                              "Selecciona la ubicación"),
                                                          onChanged:
                                                              (UbicacionModel?
                                                                  newVal) {
                                                            setState(() {
                                                              selectedUbicacion =
                                                                  newVal;
                                                            });

                                                            //print(selectedUbicacion);
                                                          }),
                                                ),
                                              ],
                                            );
                                          },
                                          future: ubicaciones(controller),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        FutureBuilder(
                                          builder: (context, snapshots) {
                                            //if (snapshots.hasError)
                                              //print(snapshots.error);
                                            // ubicacion = snapshots.data;

                                            return Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: DropdownButtonFormField(
                                                  decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      labelText: 'Categoría',
                                                      prefixIcon: Icon(
                                                          FontAwesomeIcons
                                                              .userTie)),
                                                  onSaved: (CategoriaModel?
                                                      categoria) {
                                                    actualizar['categoria'] =
                                                        categoria!.id
                                                            .toString();
                                                  },
                                                  validator: (CategoriaModel?
                                                      categoria) {
                                                    if (categoria == null) {
                                                      return 'Necesitas elegir una categoría';
                                                    }
                                                    return null;
                                                  },
                                                  value: selectedCategoria,
                                                  items: categoria!
                                                      .map((categoria1) {
                                                    return DropdownMenuItem(
                                                      value: categoria1,
                                                      child: Text(
                                                          categoria1.nombre!),
                                                    );
                                                  }).toList(),
                                                  hint: Text(
                                                      "Selecciona la categoría"),
                                                  onChanged:
                                                      (CategoriaModel? newVal) {
                                                    setState(() {
                                                      selectedCategoria =
                                                          newVal;
                                                    });

                                                    //print(selectedCategoria);
                                                  }),
                                            );
                                          },
                                          future: categorias(controller),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              labelText: 'Página web',
                                              prefixIcon:
                                                  Icon(Icons.open_in_browser)),
                                          validator: (String? texto) {
                                            return;
                                          },
                                          onChanged: (String texto) {},
                                          enabled: true,
                                          initialValue:
                                              controller.negocioActual!.web,
                                          onSaved: (String? texto) {
                                            actualizar['web'] = texto!.trim();
                                            return;
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              labelText: 'Precio mínimo',
                                              prefixIcon:
                                                  Icon(Icons.attach_money)),
                                          validator: (String? texto) {
                                            if (texto!.trim() == '') {
                                              return 'No puedes dejar campos vacíos';
                                            }
                                            return null;
                                          },
                                          onChanged: (String texto) {},
                                          enabled: true,
                                          initialValue: controller
                                              .negocioActual!.preciomin,
                                          onSaved: (String? texto) {
                                            actualizar['precio_min'] =
                                                texto!.trim();
                                            return;
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              labelText: 'Precio máximo',
                                              prefixIcon:
                                                  Icon(Icons.attach_money)),
                                          validator: (String? texto) {
                                            if (texto!.trim() == '') {
                                              return 'No puedes dejar campos vacíos';
                                            }
                                            return null;
                                          },
                                          onChanged: (String texto) {},
                                          enabled: true,
                                          initialValue: controller
                                              .negocioActual!.preciomax,
                                          onSaved: (String? texto) {
                                            actualizar['precio_max'] =
                                                texto!.trim();
                                            return;
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        cargando
                                            ? CircularProgressIndicator()
                                            : ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 10,
                                                ),
                                                onPressed: () async {
                                                  setState(() {
                                                    cargando = true;
                                                  });

                                                  _currentPosition =
                                                      await location
                                                          .getLocation();

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Mapa(
                                                                controller:
                                                                    controller,
                                                                latitud: lat,
                                                                longitud: long,
                                                              )));

                                                  print(_currentPosition
                                                      .longitude);
                                                  print(_currentPosition
                                                      .latitude);
                                                  setState(() {
                                                    cargando = false;
                                                    ubicarionR = true;
                                                  });
                                                },
                                                label: Text(ubicarionR
                                                    ? 'Ubicación recibida'
                                                    : 'Obtener ubicación'),
                                                icon: Icon(ubicarionR
                                                    ? Icons.check
                                                    : FontAwesomeIcons
                                                        .mapMarkerAlt),
                                              ),
                                        registrando
                                            ? CircularProgressIndicator()
                                            : ButtonBar(
                                                children: [
                                                  ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 10,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Cancelar')),
                                                  ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 10,
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          registrando = true;
                                                        });
                                                        if (!key2.currentState!
                                                            .validate()) {
                                                          setState(() {
                                                            registrando = false;
                                                          });
                                                          return;
                                                        }
                                                        if (controller
                                                                    .latFinal ==
                                                                null &&
                                                            controller
                                                                    .longFinal ==
                                                                null) {
                                                          String latLng =
                                                              '${lat.toString()}' +
                                                                  ',' +
                                                                  '${long.toString()}';
                                                          print(latLng);
                                                          actualizar['mapa'] =
                                                              latLng;
                                                        } else {
                                                          String lat =
                                                              controller
                                                                  .latFinal
                                                                  .toString();
                                                          String long =
                                                              controller
                                                                  .longFinal
                                                                  .toString();
                                                          String latLng =
                                                              '$lat' +
                                                                  ',' +
                                                                  '$long';
                                                          print(latLng);
                                                          actualizar['mapa'] =
                                                              latLng;
                                                        }
                                                        key2.currentState!
                                                            .validate();
                                                        key2.currentState!
                                                            .save();
                                                        var mensaje =
                                                            await actualizarInfo(
                                                                actualizar,
                                                                controller
                                                                    .usuarioActual
                                                                    .remembertoken);
                                                        /*print(actualizar);
                                                        print(controller
                                                            .latFinal);
                                                        print(controller
                                                            .longFinal);*/
                                                        await controller
                                                            .obtenerNegocio(
                                                                controller
                                                                    .usuarioActual
                                                                    .remembertoken,
                                                                controller);
                                                        setState(() {
                                                          registrando = false;
                                                        });

                                                        //print(mensaje['message']);

                                                        return showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                actions: [],
                                                                title: Text(
                                                                    'Todo salió bien'),
                                                                content: Text(mensaje[
                                                                        'message']
                                                                    .toString()),
                                                              );
                                                            });
                                                      },
                                                      child: Text('Enviar')),
                                                ],
                                              ),
                                        SizedBox(
                                          height: 15,
                                        )
                                      ],
                                    ),
                                  ),
                                )

                                // FutureBuilder(
                                //     future:
                                //         tramite(controller.usuarioActual.remembertoken),
                                //     builder: (context, snapshots) {
                                //       if (snapshots.hasError) print(snapshots.error);

                                //       print(snapshots.data);

                                //       return snapshots.hasData && snapshots.data != null
                                //           ?
                                //           : snapshots.data == null &&
                                //                   snapshots.connectionState !=
                                //                       ConnectionState.waiting
                                //               ? Container(
                                //                   height:
                                //                       MediaQuery.of(context).size.height,
                                //                   width:
                                //                       MediaQuery.of(context).size.width,
                                //                   child: Center(
                                //                       child: Column(
                                //                     crossAxisAlignment:
                                //                         CrossAxisAlignment.center,
                                //                     mainAxisSize: MainAxisSize.max,
                                //                     mainAxisAlignment:
                                //                         MainAxisAlignment.center,
                                //                     children: [
                                //                       Text(
                                //                           'Ha ocurridó un error intente nuevamente'),
                                //                       SizedBox(
                                //                         height: 10,
                                //                       ),
                                //                       ElevatedButton.icon(
                                //                           onPressed: () {
                                //                             setState(() {});
                                //                           },
                                //                           icon: Icon(CupertinoIcons
                                //                               .arrow_clockwise),
                                //                           label: Text('Recargar'))
                                //                     ],
                                //                   )),
                                //                 )
                                //               : Container(
                                //                   height:
                                //                       MediaQuery.of(context).size.height,
                                //                   width:
                                //                       MediaQuery.of(context).size.width,
                                //                   child: Center(
                                //                       child: Column(
                                //                     crossAxisAlignment:
                                //                         CrossAxisAlignment.center,
                                //                     mainAxisSize: MainAxisSize.max,
                                //                     mainAxisAlignment:
                                //                         MainAxisAlignment.center,
                                //                     children: [
                                //                       CircularProgressIndicator(),
                                //                       SizedBox(
                                //                         height: 10,
                                //                       ),
                                //                       Text('Obteniendo datos...'),
                                //                     ],
                                //                   )),
                                //                 );
                                //     }),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Por favor, verifica tu conexión y vuelve a intentarlo.\n",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                      TextButton(
                          onPressed: () async {
                            if (await controller.internetcheck()) {
                              setState(() {});
                            }
                          },
                          child: Text("Reintentar",
                              style: TextStyle(fontSize: 15)))
                    ],
                  ),
                ),
              ));
  }
}
