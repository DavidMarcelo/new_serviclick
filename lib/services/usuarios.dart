class UsuariosFirebase {
  String? nombre;
  String? token;
  String? email;
  int? id;
  int? telefono;

  UsuariosFirebase({
    this.id,
    this.nombre,
    this.token,
    this.email,
    this.telefono,
  });

  factory UsuariosFirebase.fromMap(map) {
    return UsuariosFirebase(
      id: map['id'],
      nombre: map['nombre'],
      token: map['token'],
      email: map['email'],
      telefono: map['telefono'],
    );
  }

  //sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'token': token,
      'email': email,
      'telefono': telefono
    };
  }
}
