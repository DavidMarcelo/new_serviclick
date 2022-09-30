import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serviclick/services/services.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double? toolbarHeight;
  final PreferredSizeWidget? bottom;

  const MyAppBar({Key? key, this.toolbarHeight, this.bottom}) : super(key: key);

  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(
      toolbarHeight ?? kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    Controller controller = Provider.of<Controller>(context);

    return AppBar(
      title: Text('Serviclick'),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.one_k),
            onPressed: () {
              print(controller.negocio);
            }),

        TextButton.icon(
            onPressed: () {
              if (controller.nombre == '') {
                Navigator.of(context).pushNamed('/logIn');
              } else {
                controller.singOut();
                // controller.singOut();
                print(controller.nombre);
                controller.nombre = '';
                setState(() {
                  controller.sinIncheck = false;
                });
              }
            },
            icon: Icon(
              controller.nombre == '' ? Icons.person : Icons.exit_to_app,
              color: Colors.white,
            ),
            label: Text(
              controller.nombre == '' ? 'Iniciar sesión' : controller.nombre!,
              style: TextStyle(color: Colors.white),
            )),

        // Center(child: Text(controller.usuarioActual.name ==null ? controller.usuarioActual.name : 'Inicar sesión')),
        IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            })
      ],
    );
  }
}
