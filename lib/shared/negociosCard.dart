import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:serviclick/pages/negocioDetails.dart';
import 'package:serviclick/services/models.dart';
import 'package:serviclick/shared/colores.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class NegociosCard extends StatelessWidget {
  NegociosModel? negocio;
  int? index;
  NegociosCard({this.negocio, this.index});
  Widget build(BuildContext context) {
    var largo = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NegocioDetails(
                      negocio: negocio,
                    )));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Card(
              margin: EdgeInsets.only(left: 30, top: 10, bottom: 10, right: 8),
              //color: Colors.grey[300],
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                margin: EdgeInsets.only(left: 40),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ListTile(
                          title: Text(
                            negocio!.nombre!,
                          ),
                          subtitle: RatingBar.builder(
                              itemSize: 18,
                              initialRating:
                                  double.parse(negocio!.puntuacion!.toString()),
                              allowHalfRating: true,
                              itemCount: 5,
                              ignoreGestures: true,
                              itemPadding: EdgeInsets.symmetric(horizontal: 0),
                              itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber[800],
                                    size: 15,
                                  ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              }),
                          trailing: negocio!.distancia == ""
                              ? Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  size: 20,
                                  color: primaryDark,
                                )
                              : Text(
                                  "a " + negocio!.distancia!,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11),
                                )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Html(
                              data: negocio!.descripcion!,

                              /*style: {
                                "body": Style(),
                              },*/
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                color: Colors.white,
                child: Container(
                  height: 80,
                  width: 80,
                  child: Hero(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FadeInImage(
                        fit: BoxFit.cover,
                        placeholder: AssetImage('assets/logo01.png'),
                        image: NetworkImage(negocio!.imagenUrl!),
                      ),
                    ),
                    tag: negocio!.id!,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
