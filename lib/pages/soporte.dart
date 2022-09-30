import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class Soporte extends StatelessWidget {
  TextEditingController textEditingController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayuda y soporte técnico'),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height / 1.15,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .05),
              Text(
                  'En este apartado puedes pedir ayuda o soluciones a problemas que puedan surgir mientras usas la aplicación ServiClick.'),
              SizedBox(height: MediaQuery.of(context).size.height * .15),
              Text(
                  'Describenos tu problema enviándonos un mensaje a través de Whatsapp.'),
              SizedBox(
                height: 20,
              ),
              TextField(
                autofocus: true,
                controller: textEditingController2,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  labelText: 'Problema',
                  labelStyle: TextStyle(),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 5,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (textEditingController2.text.isNotEmpty) {
                      String number = '+5219612530968';

                      final _emailLaunchUri =
                          'https://wa.me/$number?text=${textEditingController2.text.trim()}';

                      await canLaunch(_emailLaunchUri.toString())
                          ? await launch(_emailLaunchUri)
                          : Fluttertoast.showToast(
                              msg:
                                  'No tienes ninguna aplicación disponible para poder enviar el mensaje');
                    } else {
                      Fluttertoast.showToast(
                          msg: 'No puedes dejar el campo vacío');
                    }
                  },
                  child: Text('Enviar')),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomLeft,
                child: SelectableText(
                    'Para más información puedes comunicarte al correo electrónico: soporte@serviclick.com.mx',
                    style: TextStyle(color: Colors.grey)),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
