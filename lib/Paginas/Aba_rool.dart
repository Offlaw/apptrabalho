import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_expenses/Grafico/Circulo_Porcentagem.dart';
import 'package:shared_expenses/paginas/Info_Pagina.dart';
import 'package:shared_expenses/paginas/Pagina_status.dart';
import 'package:shared_expenses/paginas/Usuario_pagina.dart';
import 'package:shared_expenses/paginas/Entradas_pagina.dart';
import 'package:animations/animations.dart';

class RootApp extends StatefulWidget {
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int pageIndex = 0;
  PageController controller = PageController(initialPage: 0);

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScopedModelDescendant<Grafico_Despesas>(
        builder: (context, child, model) => PageView(
          controller: controller,
          children: [
            DailyPage(model: model, callback: callback),
            StatsPage(model: model, callback: callback),
            ProfilePage(model: model),
          ],
          onPageChanged: (val) {
            setState(() {
              pageIndex = val;
            });
          },
          physics: ClampingScrollPhysics(),
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        activeColor: Colors.amber,
        splashColor: Colors.blue,
        inactiveColor: Colors.black.withOpacity(0.5),
        icons: <IconData>[
          Ionicons.md_calendar,
          Ionicons.md_stats,
          Ionicons.md_settings,
        ],
        activeIndex: pageIndex,
        notchSmoothness: NotchSmoothness.softEdge,
        iconSize: 30,
        onTap: (index) {
          setState(() {
            pageIndex = index;
            controller.animateToPage(
              pageIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        openBuilder: (BuildContext context, _) =>
            NewEntryLog(callback: callback, context: context),
        closedElevation: 5.0,
        openElevation: 0,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        closedColor: Colors.green,
        closedBuilder: (_, __) => SizedBox(
          height: 50,
          width: 50,
          child: Center(
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  callback(int index) {
    setState(() {
      index ??= 2;
      pageIndex = index;
      controller.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }
}
