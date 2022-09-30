import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:serviclick/pages/filtroPage.dart';
import 'package:serviclick/services/services.dart';
import 'package:http/http.dart' as http;
import 'package:serviclick/shared/shared.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<dynamic> getNegocios(Controller controller) async {
    try {
      print("consulta negocios");
      var url1 = Uri.parse('https://serviclick.com.mx/api/negocios');
      var response = await http.post(url1).timeout(Duration(seconds: 20));
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        String response2 = jsonEncode(parsed['result']);
        var finalResult = await compute(parseJson, response2);
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

  static List<NegociosModel> parseJson(String response) {
    final parsed = jsonDecode(response);
    List<NegociosModel> negocios = parsed['negocios']
        .map<NegociosModel>((json) => NegociosModel.fromJson(json))
        .toList();
    return negocios;
  }

  //bool internet = true;

  @override
  void initState() {
    super.initState();
    Controller controlador = Provider.of<Controller>(context, listen: false);
    negociosF = getNegocios(controlador);
  }

  Future? negociosF;
  bool sinIncheck = false;
  bool sinInloading = false;
  // ignore: missing_return

  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return Scaffold(
        drawer: controller.sinIncheck
            ? controller.usuarioActual.empresa != 0
                ? null
                : Mydrawer()
            : Mydrawer(),
        appBar: AppBar(
          title: Text('Negocios cerca de ti'),
          actions: <Widget>[
            controller.internet
                ? IconButton(
                    icon: Icon(Icons.search),
                    tooltip: 'Buscar',
                    onPressed: () {
                      showSearch(
                          context: context, delegate: CustomSearchDelegate());
                    })
                : Container(),
            controller.internet
                ? TextButton(
                    onPressed: () {
                      showDialog(
                        useSafeArea: true,
                        context: context,
                        builder: (BuildContext context) => SimpleDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          insetPadding: EdgeInsets.all(12),
                          title: Center(child: Text('Selecciona tus filtros')),
                          children: [Divider(), Filtros()],
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Filtrar',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Icon(
                          FontAwesomeIcons.sortAmountDownAlt,
                          color: Colors.white,
                          size: 23,
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            !controller.sinIncheck
                ? TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back_ios_rounded, size: 18),
                    label: Text('Volver'))
                : Container(),
            Expanded(
              child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: controller.internet
                      ? FutureBuilder(
                          future: negociosF,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data == "error") {
                                return Center(
                                    child: Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Icon(
                                        Icons.warning_amber,
                                        size: 40,
                                        color: Colors.grey.withOpacity(0.6),
                                      ),
                                      Text(
                                        "\nOcurrió un error, intenta de nuevo más tarde.",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                              }
                              final list =
                                  snapshot.data as List<NegociosModel>?;
                              if (list!.length != 0) {
                                return NegocioList(negocio: list);
                              } else {
                                return Container(
                                  height: MediaQuery.of(context).size.height,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                            height: 100,
                                            width: 100,
                                            child: ClipRRect(
                                              child: Image.asset(
                                                  'assets/logo01.png'),
                                            )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('No hay negocios para mostrar.',
                                            style: TextStyle(fontSize: 20)),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            } else {
                              return Container(
                                height: MediaQuery.of(context).size.height,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text('Obteniendo datos...'),
                                    ],
                                  ),
                                ),
                              );
                            }
                            //}
                          })
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Por favor, verifica tu conexión y vuelve a intentarlo.\n",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey[700]),
                                ),
                                TextButton(
                                    onPressed: () {
                                      negociosF = getNegocios(controller);
                                      setState(() {});
                                    },
                                    child: Text("Reintentar",
                                        style: TextStyle(fontSize: 15)))
                              ],
                            ),
                          ),
                        )),
            )
          ],
        ));
  }
}

class Filtros extends StatefulWidget {
  @override
  _FiltrosState createState() => _FiltrosState();
}

class _FiltrosState extends State<Filtros> {
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

  Future<dynamic> ubicaciones(Controller controller) async {
    try {
      print("consulta ubicaciones");
      var url1 = Uri.parse('https://serviclick.com.mx/api/ubicaciones');
      var response = await http.post(url1);
      controller.internet = true;
      controller.notify();
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var finalResult = parsed["result"]['ubicaciones']
            .map<UbicacionModel>((json) => UbicacionModel.fromJson(json))
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

  @override
  void initState() {
    super.initState();
    Controller controller = Provider.of<Controller>(context, listen: false);
    categoriasF = categorias(controller);
    ubicacionesF = ubicaciones(controller);
  }

  Future? categoriasF;
  Future? ubicacionesF;
  CategoriaModel? selectedCategoria;
  UbicacionModel? selectedUbicacion;
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    var largo = MediaQuery.of(context).size.height;
    var ancho = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        controller.internet
            ? FutureBuilder(
                future: ubicacionesF,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == "error") {
                      return Text("  Error al cargar ubicaciones",
                          style: TextStyle(color: Colors.red));
                    } else {
                      final list = snapshot.data as List<UbicacionModel>;
                      if (list.length == 0) {
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
                                    Text('Ninguna ubicación registrada'),
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
                                    value: selectedUbicacion,
                                    items: list.map((ubicacion1) {
                                      return DropdownMenuItem(
                                        value: ubicacion1,
                                        child: Text(ubicacion1.nombre!),
                                      );
                                    }).toList(),
                                    hint: Text(
                                      "Selecciona la ubicación",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onChanged: (UbicacionModel? newVal) {
                                      selectedUbicacion = newVal;
                                      setState(() {});
                                    }),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  } else {
                    return Container();
                  }
                })
            : Container(),
        SizedBox(
          height: 5,
        ),
        controller.internet
            ? FutureBuilder(
                future: categoriasF,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == "error") {
                      return Text("  Error al cargar categorías",
                          style: TextStyle(color: Colors.red));
                    } else {
                      final list = snapshot.data as List<CategoriaModel>;
                      if (list.length == 0) {
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
                                    Text('Ninguna categoría registrada'),
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
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onChanged: (CategoriaModel? newVal) {
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
                    return Center(
                      child: Container(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator()),
                    );
                  }
                })
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
                          onPressed: () {
                            categoriasF = categorias(controller);
                            ubicacionesF = ubicaciones(controller);
                            setState(() {});
                          },
                          child: Text("Reintentar",
                              style: TextStyle(fontSize: 15)))
                    ],
                  ),
                ),
              ),
        controller.internet
            ? ButtonBar(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('cancelar')),
                  ElevatedButton(
                      onPressed: () {
                        if (selectedCategoria == null &&
                            selectedUbicacion == null) {
                          return;
                        } else {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => FiltroPage(
                                        categoriaid: selectedCategoria != null
                                            ? selectedCategoria!.id
                                            : null,
                                        chingona: false,
                                        ubicacionid: selectedUbicacion != null
                                            ? selectedUbicacion!.id
                                            : null,
                                        servicio: '',
                                      )));
                        }
                      },
                      child: Text('Buscar')),
                ],
              )
            : Container()
      ],
    );
  }
}

// ignore: must_be_immutable
class NegocioList extends StatefulWidget {
  final List<NegociosModel>? negocio;
  NegocioList({this.negocio});

  @override
  _NegocioListState createState() => _NegocioListState();
}

class _NegocioListState extends State<NegocioList> {
  late List<NegociosModel> negocioactual;

  Widget build(BuildContext context) {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.negocio!.length,
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              NegociosCard(
                index: index,
                negocio: widget.negocio![index],
              ),
            ],
          );
        });
  }
}
