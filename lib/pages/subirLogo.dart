import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:serviclick/services/controller.dart';
import 'package:serviclick/services/models.dart';
import 'package:serviclick/shared/colores.dart';
import 'package:http/http.dart' as http;

class SubirLogo extends StatefulWidget {
  @override
  _SubirLogoState createState() => _SubirLogoState();
}

class _SubirLogoState extends State<SubirLogo> {
  Future<dynamic> subirFoto(String foto64, String? token) async {
    var url1 = Uri.parse(
      'https://serviclick.com.mx/api/actualizar_logo',
    );
    final response = await http.post(url1,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{'logo': foto64}));
    if (response.statusCode == 200) {
      return true;
    } else {
      print("--error: " + response.statusCode.toString());
      return false;
    }
  }

  Future<List<GaleriaModel>> getFotos(Controller controlador) async {
    var url1 = Uri.parse(
      'https://serviclick.com.mx/api/listar_galeria',
    );
    final response = await http.post(
      url1,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'accept': 'application/json',
        'Authorization': 'Bearer ${controlador.usuarioActual.remembertoken}',
      },
    ).timeout(Duration(seconds: 20));

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var finalResult = parsed['result']
          .map<GaleriaModel>((json) => GaleriaModel.fromJson(json))
          .toList();
      return finalResult;
    } else {
      print("--error " + response.statusCode.toString());
      List<GaleriaModel> vacio = [];
      return vacio;
    }
  }

  @override
  void initState() {
    super.initState();
    Controller controlador = Provider.of<Controller>(context, listen: false);
    galeriaX = getFotos(controlador);
  }

  Future? galeriaX;
  XFile? _image;
  List<File> listaFiles = [];
  late File imageFile;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis imágenes'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              // color: Colors.green,
              height: 230,
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(30))),
                      width: MediaQuery.of(context).size.width,
                      height: 230,
                      child: Image.asset(
                        'assets/subirlogo.png',
                        fit: BoxFit.fill,
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Sube el logotipo de tu negocio",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: primaryDark, width: 2),
                                borderRadius: BorderRadius.circular(360)),
                            height: 150,
                            width: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(360),
                              child: FadeInImage(
                                fit: BoxFit.cover,
                                placeholder: AssetImage('assets/logo01.png'),
                                image: (_image == null
                                        ? NetworkImage(controller
                                            .negocioActual!.imagenUrl!)
                                        : FileImage(imageFile))
                                    as ImageProvider<Object>,
                              ),
                            ),
                          ),
                          loading
                              ? Container(
                                  child: CircularProgressIndicator(),
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 40))
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'Selecciona una imágen',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    loading
                                        ? Container()
                                        : Align(
                                            alignment: Alignment.topCenter,
                                            child: ButtonBar(
                                              alignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[400],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        FontAwesomeIcons.camera,
                                                      ),
                                                      onPressed: () async {
                                                        _image =
                                                            await controller
                                                                .getImageCamera(
                                                                    context);
                                                        if (_image != null) {
                                                          imageFile = File(
                                                              _image!.path);
                                                          setState(() {});
                                                        } else {
                                                          return;
                                                        }
                                                      },
                                                    )),
                                                Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[400],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: IconButton(
                                                      icon: Icon(
                                                          FontAwesomeIcons
                                                              .image),
                                                      onPressed: () async {
                                                        _image =
                                                            await (controller
                                                                .getImage(
                                                                    context));
                                                        if (_image != null) {
                                                          imageFile = File(
                                                              _image!.path);
                                                          setState(() {});
                                                        } else {
                                                          return;
                                                        }
                                                      },
                                                    ))
                                              ],
                                            ),
                                          ),
                                    Container(
                                      alignment: Alignment.topCenter,
                                      child: ElevatedButton.icon(
                                          onPressed: () async {
                                            if (_image != null) {
                                              setState(() {
                                                loading = true;
                                              });

                                              final bytes = File(_image!.path)
                                                  .readAsBytesSync();
                                              String img64 =
                                                  base64Encode(bytes);
                                              var checar = await subirFoto(
                                                  img64,
                                                  controller.usuarioActual
                                                      .remembertoken);
                                              setState(() {
                                                loading = false;
                                              });
                                              if (checar) {
                                                controller.obtenerNegocio(
                                                    controller.usuarioActual
                                                        .remembertoken,
                                                    controller);
                                                setState(() {});
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Tu logo se ha actualizado");
                                              }
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Algo salió mal, intenta de nuevo más tarde");
                                              return;
                                            }
                                          },
                                          icon: Icon(
                                              FontAwesomeIcons.cloudUploadAlt),
                                          label: Text(
                                            ' Subir',
                                            style: TextStyle(fontSize: 18),
                                          )),
                                    )
                                  ],
                                )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            Text(
              "Edita tu galería de fotos",
              style: TextStyle(
                  fontSize: 20,
                  color: buttonColor,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            FutureBuilder(
                future: galeriaX,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print("error-- " + snapshot.error.toString());
                    return Container();
                  } else {
                    if (snapshot.hasData) {
                      final list = snapshot.data as List<GaleriaModel>?;
                      if (list!.length != 0) {
                        return GridView.builder(
                          padding: EdgeInsets.all(10),
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            if (index != list.length) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          useSafeArea: true,
                                          barrierDismissible: false,

                                          //barrierColor: Colors.black26,
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              insetPadding: EdgeInsets.all(0),
                                              contentPadding: EdgeInsets.all(0),
                                              backgroundColor: Colors.white12,
                                              content: Container(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      color: Colors.black45,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          // Padding(
                                                          //   padding: const EdgeInsets.only(left: 10, top: 10, bottom: 5),
                                                          //   child: Text(
                                                          //     '¿Qué hay de nuevo?',
                                                          //     style: TextStyle(color: Colors.white, fontSize: 20),
                                                          //   ),
                                                          // ),
                                                          Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right: 10,
                                                                      top: 10,
                                                                      bottom:
                                                                          5),
                                                              height: 30,
                                                              width: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            360),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              child: IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(0),
                                                                icon: Icon(
                                                                  Icons
                                                                      .close_rounded,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 20,
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: InteractiveViewer(
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          //height: MediaQuery.of(context).size.height,
                                                          child: FadeInImage(
                                                            placeholder: AssetImage(
                                                                'assets/logo01.png'),
                                                            fit: BoxFit.contain,
                                                            image: NetworkImage(
                                                              list[index]
                                                                  .imagen!,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                              ),
                                            );
                                          });
                                    },
                                    child: Container(
                                      height: 130,
                                      width: 120,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: FadeInImage(
                                            fit: BoxFit.cover,
                                            placeholder:
                                                AssetImage('assets/logo01.png'),
                                            image: NetworkImage(list[index]
                                                .preview
                                                .toString())),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    right: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(360),
                                          color: Colors.black38),
                                      child: GestureDetector(
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                          onTap: () async {
                                            var borrarX = await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return WillPopScope(
                                                      onWillPop: () async {
                                                        return false;
                                                      },
                                                      child: BorrarDialog(
                                                          id: int.parse(
                                                        list[index]
                                                            .id
                                                            .toString(),
                                                      )));
                                                });
                                            if (borrarX) {
                                              Fluttertoast.showToast(
                                                  msg: "Imagen eliminada");
                                              galeriaX = getFotos(controller);
                                              setState(() {});
                                            }
                                          }),
                                    ),
                                  )
                                ],
                              );
                            } else {
                              return Container(
                                height: 130,
                                width: 120,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.black26),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 30,
                                    ),
                                    onTap: () async {
                                      var listaImg = await (controller
                                          .getMultiImage(context));
                                      if (listaImg != null &&
                                          listaImg.length != 0) {
                                        listaFiles = [];
                                        for (var imagen in listaImg) {
                                          listaFiles.add(File(imagen.path));
                                        }
                                        var subir = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return GaleriaDialog(
                                                imageFiles: listaFiles,
                                              );
                                            });
                                        if (subir) {
                                          galeriaX = getFotos(controller);
                                          setState(() {});
                                        } else {
                                          return;
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          itemCount: list.length + 1,
                        );
                      } else {
                        return Column(
                          children: [
                            Text("No hay fotos en tu galería"),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 130,
                              width: 120,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.black26),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: GestureDetector(
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 30,
                                  ),
                                  onTap: () async {
                                    var listaImg = await (controller
                                        .getMultiImage(context));
                                    if (listaImg != null &&
                                        listaImg.length != 0) {
                                      listaFiles = [];
                                      for (var imagen in listaImg) {
                                        listaFiles.add(File(imagen.path));
                                      }
                                      var subir = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return GaleriaDialog(
                                              imageFiles: listaFiles,
                                            );
                                          });
                                      if (subir) {
                                        galeriaX = getFotos(controller);
                                        setState(() {});
                                      } else {
                                        return;
                                      }
                                    }
                                  },
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    } else {
                      return Container(
                          child: CircularProgressIndicator(),
                          height: 40,
                          width: 40);
                    }
                  }
                }),
          ],
        ),
      ),
    );
  }
}

class BorrarDialog extends StatefulWidget {
  int id;
  BorrarDialog({required this.id});

  @override
  State<BorrarDialog> createState() => _BorrarDialogState();
}

class _BorrarDialogState extends State<BorrarDialog> {
  Future<bool> borrarFoto(int id, String? token) async {
    var url1 = Uri.parse(
      'https://serviclick.com.mx/api/borrar_foto_galeria',
    );
    final response = await http
        .post(url1,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({"foto": id}))
        .timeout(Duration(seconds: 20));
    if (response.statusCode == 200) {
      return true;
    } else {
      print("error-- " + response.statusCode.toString());
      return false;
    }
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return AlertDialog(
        title: Text("¿Estás seguro que deseas borrar esta imagen?"),
        actions: !loading
            ? [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text("Cancelar")),
                TextButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      var borrar = await borrarFoto(
                          widget.id, controller.usuarioActual.remembertoken);
                      if (borrar) {
                        Navigator.pop(context, true);
                      } else {
                        Fluttertoast.showToast(
                            msg: "Algo salió mal, intenta de nuevo más tarde");
                        Navigator.pop(context, false);
                      }
                    },
                    child: Text(
                      "Sí, borrar",
                      style: TextStyle(color: Colors.red),
                    ))
              ]
            : [
                Container(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(),
                )
              ]);
  }
}

class GaleriaDialog extends StatefulWidget {
  List<File>? imageFiles;
  GaleriaDialog({this.imageFiles});
  @override
  State<GaleriaDialog> createState() => _GaleriaDialogState();
}

class _GaleriaDialogState extends State<GaleriaDialog> {
  Future<bool> subirGaleria(Map galeriaFinal, String? token) async {
    var url1 = Uri.parse(
      'https://serviclick.com.mx/api/subir_galeria',
    );
    final response = await http
        .post(url1,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({"foto": galeriaFinal}))
        .timeout(Duration(seconds: 20));
    if (response.statusCode == 200) {
      return true;
    } else {
      print("error-- " + response.statusCode.toString());
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    imagenes = widget.imageFiles;
  }

  bool loading = false;
  List<File>? imagenes = [];
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          title: Center(child: Text("Imagenes seleccionadas")),
          content: Container(
              width: double.maxFinite,
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 130,
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: FadeInImage(
                              fit: BoxFit.cover,
                              placeholder: AssetImage('assets/logo01.png'),
                              image: FileImage(imagenes![index])),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 2,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(360),
                              color: Colors.black38),
                          child: GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              onTap: () async {
                                if (loading) {
                                  return;
                                } else {
                                  imagenes!.removeWhere(
                                      (element) => element == imagenes![index]);
                                  if (imagenes!.length == 0) {
                                    Navigator.pop(context, false);
                                  } else {
                                    setState(() {});
                                  }
                                }
                              }),
                        ),
                      )
                    ],
                  );
                },
                itemCount: widget.imageFiles!.length,
              )),
          actions: !loading
              ? [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text("Cancelar")),
                  ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        var listTo64 = [];
                        for (var item in imagenes!) {
                          final bytes = File(item.path).readAsBytesSync();
                          String img64 = base64Encode(bytes);
                          listTo64.add(img64);
                        }
                        Map<String, String> mapFotos = {};
                        int index = 0;
                        for (var item in listTo64) {
                          mapFotos[index.toString()] = item;
                          index++;
                        }
                        var subida = await subirGaleria(
                            mapFotos, controller.usuarioActual.remembertoken);
                        if (subida) {
                          Navigator.pop(context, true);
                          Fluttertoast.showToast(
                              msg: "Galería actualizada correctamente");
                        } else {
                          Navigator.pop(context, false);
                          Fluttertoast.showToast(
                              msg:
                                  "Error al subir, intente de nuevo más tarde");
                        }
                      },
                      icon: Icon(FontAwesomeIcons.cloudUploadAlt),
                      label: Text(
                        ' Subir',
                        style: TextStyle(fontSize: 18),
                      )),
                ]
              : [
                  Text("Subiendo imágenes... "),
                  Container(
                      height: 35, width: 35, child: CircularProgressIndicator())
                ]),
    );
  }
}
