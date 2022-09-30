import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../shared/shared.dart';
import 'models.dart';
import 'dart:convert';

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate() : super(searchFieldLabel: 'Buscar Servicios');

  Future<List<NegociosModel>> getDatas() async {
    var url1 = Uri.parse('https://serviclick.com.mx/api/negocios');
    var response = await http.post(url1).timeout(Duration(seconds: 20));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      String response2 = jsonEncode(parsed['result']);
      var finalResult = await compute(parseJson, response2);
      return finalResult;
    } else {
      print("error -- " + response.statusCode.toString());
      return [];
    }
  }

  static List<NegociosModel> parseJson(String response) {
    final parsed = jsonDecode(response);
    List<NegociosModel> negocios = parsed['negocios']
        .map<NegociosModel>((json) => NegociosModel.fromJson(json))
        .toList();
    negocios.removeWhere((element) => element.status == 0);
    return negocios;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print(query);

    return FutureBuilder(
      future: getDatas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Container();
        } else {
          if (snapshot.hasData) {
            final list = snapshot.data as List<NegociosModel>;
            return NegocioFilter(
              negocio: list,
              query: query,
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }
      },
    );
    //return Text('hello');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
        future: getDatas(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Container();
          } else {
            if (snapshot.hasData) {
              final list = snapshot.data as List<NegociosModel>;
              return NegocioFilter(
                negocio: list,
                query: query,
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }
        });
  }
}

// ignore: must_be_immutable
class NegocioFilter extends StatefulWidget {
  List<NegociosModel>? negocio;
  String? query;
  NegocioFilter({this.negocio, this.query});

  @override
  _NegocioFilterState createState() => _NegocioFilterState();
}

class _NegocioFilterState extends State<NegocioFilter> {
  RegExp exp = RegExp(r"<[^>]*>", caseSensitive: true, multiLine: true);
  late List<NegociosModel> negocioactual;
  List<NegociosModel>? negocioactual1;

  Widget build(BuildContext context) {
    negocioactual = widget.negocio!
        .where((element) => element.servicios!
            .replaceAll(exp, '')
            .toLowerCase()
            .contains(widget.query!))
        .toList();

    //negocioactual = widget.negocio;
    negocioactual.removeWhere((element) => element.status == 0);
    // print(negocioactual.length);
    return negocioactual.length == 0
        ? Center(child: Text('No se encontraron coincidencias'))
        : ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: negocioactual.length,
            itemBuilder: (context, index) {
              //print(negocioactual.length);
              return negocioactual.isNotEmpty
                  ? NegociosCard(
                      negocio: negocioactual[index],
                      index: index,
                    )
                  : CircularProgressIndicator();
            });
  }
}
