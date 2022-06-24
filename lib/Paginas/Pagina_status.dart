import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_expenses/Grafico/Circulo_Porcentagem.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class StatsPage extends StatefulWidget {
  final Grafico_Despesas model;
  final Function callback;

  StatsPage({Key key, @required this.model, this.callback}) : super(key: key);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  Map<String, Map<String, double>> expenseShares;
  Map<String, double> pieData;
  List<String> users;
  final _screenShotController = ScreenshotController();
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
        vsync: this,
        length: 13,
        initialIndex: int.parse(widget.model.getMesAtual) - 1);
    users = widget.model.getUsuarios;
    expenseShares = widget.model.calculateShares();
    pieData = widget.model.calculateCategoryShare();
    print(pieData);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: getBody(),
    );
  }

  Widget getBody() {
    Map<String, String> months = {
      "1": "Janeiro",
      "2": "Fevereiro",
      "3": "Março",
      "4": "Abril",
      "5": "Maio",
      "6": "Junho",
      "7": "Julho",
      "8": "Agosto",
      "9": "Setembro",
      "10": "Outubro",
      "11": "Novembro",
      "12": "Dezembro",
      "13": "All"
    };

    return Column(
      children: [
        AppBar(
          title: Text('Gráfico'),
        ),
        (widget.model.getUsuarios.length == 0 ||
                widget.model.getCategorias.length == 0)
            ? Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    widget.model.getUsuarios.length == 0
                        ? "Nenhum Usuario Adicionado"
                        : "Nenhuma Categoria Adicionada",
                    style: TextStyle(fontSize: 21),
                  ),
                  TextButton(
                      onPressed: () {
                        widget.callback(2);
                      },
                      child: Text("Ir para as Configurações"))
                ],
              )
            : Expanded(
                child: SingleChildScrollView(
                  child: Screenshot(
                    controller: _screenShotController,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black38, width: 1.5)),
                                ),
                                child: TabBar(
                                  controller: _controller,
                                  onTap: _updateMonthTab,
                                  labelColor: Colors.blue,
                                  unselectedLabelColor: Colors.black,
                                  isScrollable: true,
                                  tabs: List.generate(
                                      months.length,
                                      (i) => Tab(
                                            child: Text(
                                              months.values.toList()[i],
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          )),
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(1)),
                              Container(
                                child: PieChart(
                                  dataMap: pieData,
                                  animationDuration:
                                      Duration(milliseconds: 800),
                                  chartLegendSpacing: 10,
                                  chartRadius:
                                      MediaQuery.of(context).size.width / 2,
                                  initialAngleInDegree: 0,
                                  chartType: ChartType.disc,
                                  ringStrokeWidth: 20,
                                  legendOptions: LegendOptions(
                                    showLegendsInRow: false,
                                    legendPosition: LegendPosition.right,
                                    showLegends: true,
                                    legendTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  chartValuesOptions: ChartValuesOptions(
                                    showChartValueBackground: false,
                                    showChartValues: true,
                                    showChartValuesInPercentage: true,
                                    showChartValuesOutside: false,
                                  ),
                                ),
                              ),
                              makeStatCrad("Total Gasto", Colors.pink,
                                  MaterialCommunityIcons.shopping),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  void _updateMonthTab(int v) {
    widget.model.definiMesAtual((v + 1).toString());
    setState(() {
      expenseShares = widget.model.calculateShares();
      pieData = widget.model.calculateCategoryShare();
    });
  }

  Widget makeStatCrad(String cardType, MaterialColor color, IconData icon) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Card(
        elevation: 5.0,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200],
                  spreadRadius: 10,
                  blurRadius: 3,
                ),
              ]),
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Icon(icon),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            cardType,
                            style: TextStyle(
                              fontSize: 20,
                              color: color.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                      Divider(
                        thickness: 3.0,
                        height: 15,
                        color: color.shade50,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(7),
                child: Column(
                    children: List.generate(
                  users.length,
                  (index) {
                    return Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Text(
                                " ${users[index]}",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                "R\$:  ${expenseShares[cardType][users[index]].toStringAsFixed(2)}  ",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Divider(
                            thickness: index == users.length - 1 ? 0.01 : 0.9,
                            indent: 5,
                            endIndent: 5,
                          ),
                        ),
                      ],
                    );
                  },
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
