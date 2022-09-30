import 'dart:core';

class NegociosModel {
  final int? id;
  final String? imagenUrl;
  final String? nombre;
  final String? direccion;
  final String? telefono;
  final String? web;
  final String? descripcion;
  final String? servicios;
  final String? preciomin;
  final String? preciomax;
  final int? categoriaid;
  final dynamic categoria;
  final dynamic ubicacion;
  final int? ubicacionid;
  final String? mapa;
  final dynamic puntuacion;
  final dynamic tramites;
  final int? status;
  final String? distancia;

  NegociosModel(
      {this.categoria,
      this.descripcion,
      this.direccion,
      this.id,
      this.imagenUrl,
      this.mapa,
      this.nombre,
      this.preciomax,
      this.preciomin,
      this.servicios,
      this.status,
      this.telefono,
      this.tramites,
      this.ubicacion,
      this.web,
      this.categoriaid,
      this.puntuacion,
      this.ubicacionid,
      this.distancia});

  factory NegociosModel.fromJson(Map<String, dynamic> json) {
    return NegociosModel(
      id: json['id'] as int? ?? 0,
      imagenUrl: json['imagen'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      web: json['web'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      servicios: json['servicios'] as String? ?? '',
      preciomin: json['precio_min'] as String? ?? '',
      preciomax: json['precio_max'] as String? ?? '',
      categoriaid: json['categoria_id'] as int?,
      categoria: json['categoria'] as dynamic,
      ubicacionid: json['ubicacion_id'] as int?,
      ubicacion: json['ubicacion'] as dynamic,
      mapa: json['mapa'] as String?,
      puntuacion: json['puntuacion'] as dynamic,
      tramites: json['tramites'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      distancia: json['distancia'] as String? ?? '',
    );
  }
}

class Criterios {
  final String? nombre;

  Criterios({this.nombre});
  factory Criterios.fromJson(Map<String, dynamic> json) {
    return Criterios(nombre: json['nombre'] ?? '');
  }
}

class UsuarioModel {
  final int? id;
  final String? name;
  final String? email;
  final int? empresa;
  final String? password;
  final String? remembertoken;
  final String? tokentype;
  final String? expire;
  final String? phone;

  UsuarioModel(
      {this.id,
      this.name,
      this.email,
      this.empresa,
      this.password,
      this.remembertoken,
      this.tokentype,
      this.expire,
      this.phone});

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as int? ?? 0,
      name: json['nombre'] as String? ?? '',
      email: json['email'] as String?,
      empresa: json['empresa'] as int? ?? 0,
      password: json['password'] as String?,
      remembertoken: json['access_token'] as String?,
      tokentype: json['token_type'] as String?,
      expire: json['expires_at'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

class GaleriaModel {
  final int? id;
  final String? imagen;
  final String? preview;

  GaleriaModel({this.id, this.imagen, this.preview});

  factory GaleriaModel.fromJson(Map<String, dynamic> json) {
    return GaleriaModel(
      id: json['id'] as int? ?? 0,
      imagen: json['imagen'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
    );
  }
}

class ComentarioModel {
  final int? id;
  final String? nombre;
  final String? correo;
  final String? contenido;
  final dynamic puntuacion;

  final int? status;
  final String? fecha;

  ComentarioModel(
      {this.nombre,
      this.correo,
      this.contenido,
      this.puntuacion,
      this.status,
      this.id,
      this.fecha});

  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
        id: json['id'] as int? ?? 0,
        nombre: json['nombre'] as String? ?? '',
        correo: json['correo'] as String? ?? '',
        contenido: json['contenido'] as String? ?? '',
        puntuacion: json['puntuacion'] as dynamic ?? 0,
        fecha: json['created_at'] as String? ?? '',
        status: json['status'] as int? ?? 0);
  }
}

class UbicacionModel {
  final int? id;
  final String? nombre;
  final String? coordenadas;

  UbicacionModel({this.id, this.nombre, this.coordenadas});
  factory UbicacionModel.fromJson(Map<String, dynamic> json) {
    return UbicacionModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      coordenadas: json['coordenadas'] as String? ?? '',
    );
  }
}

class CategoriaModel {
  final int? id;
  final String? nombre;
  final String? imagen;

  CategoriaModel({this.id, this.nombre, this.imagen});
  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      imagen: json['imagen'] as String? ?? '',
    );
  }
}

class PAgosModel {
  final String? periodo;
  final String? total;
  final String? pagado;
  final String? status;

  PAgosModel({
    this.periodo,
    this.total,
    this.pagado,
    this.status,
  });
  factory PAgosModel.fromJson(Map<String, dynamic> json) {
    return PAgosModel(
      periodo: json['periodo'] as String? ?? '',
      total: json['total'] as String? ?? '',
      pagado: json['pagado'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class TramitesModel {
  final String? comentario;
  final int? aprobado;
  final int? status;

  TramitesModel({this.comentario, this.aprobado, this.status});
  factory TramitesModel.fromJson(Map<String, dynamic> json) {
    return TramitesModel(
      comentario: json['comentarios'] as String? ?? '',
      aprobado: json['aprobado'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
    );
  }
}

class RedesModel {
  final String? nombre;
  final String? url;

  RedesModel({this.nombre, this.url});
  factory RedesModel.fromJson(Map<String, dynamic> json) {
    return RedesModel(
      nombre: json['nombre'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class NotificacionModel {
  final int? id;
  final String? remitente;
  final String? notificacion;
  final String? fecha;
  final String? hora;
  final int? nuevo;
  final int? leido;

  NotificacionModel(
      {this.id,
      this.remitente,
      this.notificacion,
      this.fecha,
      this.hora,
      this.nuevo,
      this.leido});

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: json['id'] as int? ?? 0,
      remitente: json['remitente'] as String? ?? '',
      notificacion: json['notificacion'] as String? ?? '',
      fecha: json['fecha'] as String? ?? '',
      hora: json['hora'] as String? ?? '',
      nuevo: json['nuevo'] as int? ?? 0,
      leido: json['leido'] as int? ?? 0,
    );
  }
}

class FrasesModel {
  final String? frase;

  FrasesModel({this.frase});
  factory FrasesModel.fromJson(Map<String, dynamic> json) {
    return FrasesModel(frase: json['frase'] as String? ?? '');
  }
}

class FichaModel {
  final int? monto;
  final String? moneda;
  final String? referencia;

  FichaModel({this.monto, this.moneda, this.referencia});
  factory FichaModel.fromJson(Map<String, dynamic> json) {
    return FichaModel(
      monto: json['monto'] as int? ?? 0,
      moneda: json['moneda'] as String? ?? '',
      referencia: json['referencia'] as String? ?? '',
    );
  }
}

// class UsuarioFromFirebase {
//   String id;
//   String token;
//   int empresa;
//   String notificacion;
//   DocumentReference reference;

//   UsuarioFromFirebase({this.id, this.empresa, this.token, this.notificacion});

//   UsuarioFromFirebase.fromDocumentSnapshots(DocumentSnapshot data) {
//     var doc = data.data();
//     id = data.id.toString();
//     token = doc['token'] ?? '';
//     empresa = doc['empresa'];
//     notificacion = doc[notificacion];
//     reference = data.reference;
//   }
// }

