import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:provider/provider.dart';
import 'package:serviclick/main.dart';
import 'package:serviclick/services/services.dart';
import 'package:http/http.dart' as http;
import 'package:serviclick/shared/shared.dart';

class FiltroPage extends StatefulWidget {
  final int? categoriaid;
  final dynamic ubicacionid;
  final String? servicio;
  final double? latitud;
  final double? longitud;
  final bool? chingona;

  const FiltroPage(
      {Key? key,
      this.categoriaid,
      this.ubicacionid,
      this.servicio,
      this.latitud,
      this.longitud,
      this.chingona})
      : super(key: key);

  @override
  _FiltroPageState createState() => _FiltroPageState();
}

class _FiltroPageState extends State<FiltroPage> {
  Future<dynamic> listaFiltrada(
      bool? chingona,
      String? busqueda,
      int? categoria,
      dynamic ubicacion,
      double? latitud,
      double? longitud,
      int pagina) async {
    try {
      var url;
      var response;
      var parsed;
      if (busqueda!.isNotEmpty) {
        url = Uri.parse('https://serviclick.com.mx/api/negocios');
        print("consulta negocios");
        response = await http.post(url).timeout(Duration(seconds: 20));
        controller.internet = true;
        controller.notify();
        if (response.statusCode == 200) {
          parsed = jsonDecode(response.body);
          listaFinal = parseJson(parsed['result']["negocios"])!;
          return listaFinal;
        } else {
          print("error " +
              response.statusCode +
              " --- " +
              response.body.toString());
          return "error";
        }
      } else {
        if (chingona == true) {
          url = Uri.parse(
            'https://serviclick.com.mx/api/buscar_cercanos',
          );
          print("consulta buscar cercanos");
          response = await http
              .post(url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, dynamic>{
                    'pagina': pagina,
                    'latitud': latitud,
                    'longitud': longitud,
                    'ubicacion': ubicacion,
                    'categoria': categoria
                  }))
              .timeout(Duration(seconds: 20));
        } else {
          url = Uri.parse(
            'https://serviclick.com.mx/api/buscar_temp',
          );
          print("consulta busqueda simple");
          response = await http
              .post(url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, dynamic>{
                    'pagina': pagina,
                    'ubicacion': ubicacion,
                    'categoria': categoria
                  }))
              .timeout(Duration(seconds: 20));
        }
        controller.internet = true;
        controller.notify();
        if (response.statusCode == 200) {
          parsed = jsonDecode(response.body);
          totalPaginas = parsed['result']["total"];
          print(parsed);
          print("primera consulta");
          print("pagina actual: " + pagina.toString());
          print("total paginas " + totalPaginas.toString());
          if (pagina == totalPaginas) {
            setState(() {
              _hasNextPage = false;
            });
          }
          listaFinal = parseJson(parsed['result']["negocios"])!;
          return listaFinal;
        } else {
          print("error " +
              response.statusCode +
              " --- " +
              response.body.toString());
          return "error";
        }
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

  List<NegociosModel>? parseJson(parsed) {
    List<NegociosModel> lista = [];
    String palabra = HtmlCharacterEntities.encode(
      widget.servicio!.toLowerCase(),
      characters: 'ó á ú í é ñ ü',
    );
    List<NegociosModel> lista1 = parsed
        .map<NegociosModel>((json) => NegociosModel.fromJson(json))
        .toList();
    List<NegociosModel> lista2 = lista1
        .where((element) => element.nombre!
            .replaceAll(exp, '')
            .toLowerCase()
            .contains(widget.servicio!.toLowerCase()))
        .toList();
    for (NegociosModel item in lista2) {
      lista.add(item);
    }
    List<NegociosModel> lista3 = lista1
        .where((element) => element.servicios!
            .replaceAll(exp, '')
            .toLowerCase()
            .contains(palabra))
        .toList();
    for (NegociosModel item in lista3) {
      lista.add(item);
    }
    List<NegociosModel> lista4 = lista1
        .where((element) => element.descripcion!
            .replaceAll(exp, '')
            .toLowerCase()
            .contains(palabra))
        .toList();
    for (NegociosModel item in lista4) {
      lista.add(item);
    }
    lista = lista.toSet().toList();
    return lista;
  }

  RegExp exp = RegExp(
    r"<[^>]*>",
    caseSensitive: true,
    multiLine: true,
  );

  void _loadMore() async {
    if (widget.servicio!.isNotEmpty) {
      return;
    } else {
      if (_hasNextPage == true &&
          _isFirstLoadRunning == false &&
          _isLoadMoreRunning == false) {
        setState(() {
          _isLoadMoreRunning =
              true; // Display a progress indicator at the bottom
        });
        pagina++; // Increase _page by 1
        try {
          var response;
          if (widget.chingona == true) {
            var url = Uri.parse(
              'https://serviclick.com.mx/api/buscar_cercanos',
            );
            response = await http
                .post(url,
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, dynamic>{
                      'pagina': pagina,
                      'latitud': widget.latitud,
                      'longitud': widget.longitud,
                      'ubicacion': widget.ubicacionid,
                      'categoria': widget.categoriaid
                    }))
                .timeout(Duration(seconds: 20));
          } else {
            var url = Uri.parse(
              'https://serviclick.com.mx/api/buscar_temp',
            );
            response = await http
                .post(url,
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, dynamic>{
                      'pagina': pagina,
                      'ubicacion': widget.ubicacionid,
                      'categoria': widget.categoriaid
                    }))
                .timeout(Duration(seconds: 20));
          }
          controller.internet = true;
          controller.notify();
          if (response.statusCode == 200) {
            var convertir = jsonDecode(response.body);
            totalPaginas = convertir['result']["total"];
            print("nueva consulta");
            print("pagina actual: " + pagina.toString());
            print("total paginas " + totalPaginas.toString());
            if (pagina <= totalPaginas) {
              var listTemp = parseJson(convertir['result']["negocios"]);
              listaFinal.addAll(listTemp!);
              if (pagina == totalPaginas) {
                _hasNextPage = false;
                print("terminó la lista");
              }
              setState(() {});
            } else {
              print("nunca debías entrar aquí D:");
            }
          } else {
            print("error " +
                response.statusCode.toString() +
                " --- " +
                response.body.toString());
            setState(() {
              _hasNextPage = false;
            });
          }
        } catch (e) {
          await controller.internetcheck();
          controller.notify();
          if (controller.internet) {
            print("ERROR --- " + e.toString());
            setState(() {
              _hasNextPage = false;
            });
          }
          {
            pagina = 1;
            totalPaginas = 0;
            setState(() {});
          }
        }
        setState(() {
          _isLoadMoreRunning = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    listaFiltradaF = listaFiltrada(
      widget.chingona,
      widget.servicio,
      widget.categoriaid,
      widget.ubicacionid,
      widget.latitud,
      widget.longitud,
      pagina,
    );
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  ScrollController _controller = new ScrollController();
  int pagina = 1;
  int totalPaginas = 0;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;
  Future? listaFiltradaF;
  List<NegociosModel> listaFinal = [];
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Resultados de búsqueda'),
        ),
        body: controller.internet
            ? FutureBuilder(
                future: listaFiltradaF,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data == "error") {
                      return Center(
                          child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                    final list = snapshot.data as List<NegociosModel>?;
                    if (list!.length != 0) {
                      return SingleChildScrollView(
                        controller: _controller,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 10),
                              child: ListView.builder(
                                  physics: BouncingScrollPhysics(
                                      parent: NeverScrollableScrollPhysics()),
                                  shrinkWrap: true,
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    return list.isNotEmpty
                                        ? Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              NegociosCard(
                                                index: index,
                                                negocio: list[index],
                                              ),
                                            ],
                                          )
                                        : CircularProgressIndicator();
                                  }),
                            ),
                            // when the _loadMore function is running
                            if (_isLoadMoreRunning == true)
                              Center(
                                child: LinearProgressIndicator(
                                  color: Colors.blue,
                                ),
                              ),

                            // When nothing else to load
                            if (_hasNextPage == false)
                              Container(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Divider(
                                    color: Colors.grey,
                                  )),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                height: 100,
                                width: 100,
                                child: ClipRRect(
                                  child: Image.asset('assets/logo01.png'),
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            Text('No se han encontrado resultados.'),
                          ],
                        ),
                      );
                    }
                  } else {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Obteniendo datos...'),
                        ],
                      ),
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
                          onPressed: () async {
                            if (await controller.internetcheck()) {
                              listaFiltradaF = listaFiltrada(
                                widget.chingona,
                                widget.servicio,
                                widget.categoriaid,
                                widget.ubicacionid,
                                widget.latitud,
                                widget.longitud,
                                pagina,
                              );
                              setState(() {});
                            } else {
                              return;
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
