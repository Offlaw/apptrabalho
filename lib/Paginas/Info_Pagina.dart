import 'package:flutter/material.dart';
import 'package:shared_expenses/Grafico/Circulo_Porcentagem.dart';
import 'package:shared_expenses/paginas/Entradas_pagina.dart';
import 'package:animations/animations.dart';

class DailyPage extends StatelessWidget {
  final Grafico_Despesas model;
  final Function callback;
  const DailyPage({Key key, @required this.model, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    List<Map<String, dynamic>> _despesas = model.getDespesas;

    return Scaffold(
      body: Column(
        children: [
          AppBar(
            title: Text('Saidas'),
            backgroundColor: Colors.red,
          ),
          model.getDespesas.length == 0
              ? semDespesaPadrao(context)
              : Expanded(
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(13),
                    children: List.generate(
                      _despesas.length,
                      (i) => OpenContainer(
                        transitionType: ContainerTransitionType.fadeThrough,
                        closedElevation: 0,
                        openElevation: 0,
                        middleColor: Colors.transparent,
                        openColor: Colors.transparent,
                        closedColor: Colors.transparent,
                        closedBuilder: (_, __) => makeRecordTile(
                          size,
                          _despesas[i],
                        ),
                        openBuilder: (_, __) => NewEntryLog(
                          callback: callback,
                          context: context,
                          index: i,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Column semDespesaPadrao(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        Text(
          "Nenhumas saida Registrada",
          style: TextStyle(fontSize: 21),
        ),
        TextButton(
          child: Text("Adicionar Novas Saidas"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewEntryLog(
                  callback: callback,
                  context: context,
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Column makeRecordTile(Size size, Map<String, dynamic> record) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  record['item'],
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  record['pessoa'],
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                    //color: Colors.green
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "R\$: ${record['valor']}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  record['data'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              ],
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, right: 10),
          child: Divider(
            indent: 0,
            thickness: 0.8,
          ),
        ),
      ],
    );
  }
}
