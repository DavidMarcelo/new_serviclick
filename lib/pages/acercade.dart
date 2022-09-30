import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class AcercaDe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: Text(
          'ServiClick',
          style: TextStyle(
            fontSize: 28,
            color: const Color(0xffffffff),
            //height: 0.75,
          ),
          textAlign: TextAlign.left,
        ),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      //backgroundColor: const Color(0xffffffff),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.blue[900],
          image: DecorationImage(
            image: AssetImage('assets/fondo1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                'Desarrollado por Cybac',
                style: TextStyle(
                  fontSize: 20,
                  color: const Color(0xffffffff),
                  height: 0.75,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: GestureDetector(
                onTap: () async {
                  await canLaunch('https://www.grupocybac.com/')
                      ? launch('https://www.grupocybac.com/')
                      : Fluttertoast.showToast(
                          msg: 'No se ha podido lanzar el navegador.');
                },
                child: Container(
                  width: 127.0,
                  height: 132.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/cybac1.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            // SizedBox(
            //   height: 20,
            // ),
            Center(
              child: Text(
                'Versión 2.^',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white54,
                  height: 0.75,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: GestureDetector(
                onTap: () async {
                  await canLaunch('https://serviclick.com.mx/terminos')
                      ? launch('https://serviclick.com.mx/terminos')
                      : Fluttertoast.showToast(
                          msg: 'No se ha podido lanzar el navegador.');
                },
                child: Text(
                  'Términos y condiciones.',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent[100]),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: GestureDetector(
                onTap: () async {
                  await canLaunch('https://serviclick.com.mx/privacidad')
                      ? launch('https://serviclick.com.mx/privacidad')
                      : Fluttertoast.showToast(
                          msg: 'No se ha podido lanzar el navegador.');
                },
                child: Text(
                  'Aviso de privacidad.',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent[100]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
