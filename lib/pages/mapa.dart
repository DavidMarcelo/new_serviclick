import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviclick/services/controller.dart';
import 'package:serviclick/shared/colores.dart';

class Mapa extends StatefulWidget {
  final double? latitud;
  final double? longitud;
  final Controller? controller;

  Mapa({Key? key, this.latitud, this.longitud, this.controller})
      : super(key: key);

  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  List<Marker> marcadores = [];

  Completer<GoogleMapController> _controller = Completer();

  late CameraPosition _camera;

  void initState() {
    super.initState();
    marcadores.add(Marker(
        markerId: MarkerId('hola'),
        draggable: true,
        position: LatLng(widget.latitud!, widget.longitud!),
        onDragEnd: (value) {
          setState(() {
            double newLat = value.latitude;
            double newLong = value.longitude;
            widget.controller!.latFinal = newLat;
            widget.controller!.longFinal = newLong;
            print(
                '${widget.controller!.latFinal}+ ${widget.controller!.longFinal}');
          });
        }));
  }

  Widget build(BuildContext context) {
    _camera = CameraPosition(
        target: LatLng(widget.latitud!, widget.longitud!), zoom: 14.47);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text('Selecciona la ubicación'),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            print(
                '${widget.controller!.latFinal}+ ${widget.controller!.longFinal}');
            Navigator.of(context).pop();
          },
          label: Text('Guardar')),
      body: Stack(
        children: [
          GoogleMap(
            zoomGesturesEnabled: true,
            markers: Set.from(marcadores),
            mapType: MapType.normal,
            initialCameraPosition: _camera,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              } else {}
            },
          ),
          Column(
            children: [
              Container(
                  color: primaryColor,
                  child: ListTile(
                      leading: Icon(
                        FontAwesomeIcons.mapMarkerAlt,
                        color: Colors.redAccent,
                        size: 35,
                      ),
                      title: Text(
                        'Para seleccionar una ubicación nueva manten presionado el puntero que aparece en la parte del centro y arrastralo',
                        style: TextStyle(color: Colors.white),
                      ))),
            ],
          ),
        ],
      ),
    );
  }
}
