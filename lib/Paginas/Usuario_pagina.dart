import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_expenses/Grafico/Circulo_Porcentagem.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_expenses/paginas/Adicionar_Usuario.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatefulWidget {
  final Grafico_Despesas model;
  ProfilePage({Key key, @required this.model}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController userControler = TextEditingController();
  TextEditingController categoryControler = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    userControler.dispose();
    categoryControler.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userControler.text = widget.model.getUsuarios.join(',');
    categoryControler.text = widget.model.getCategorias.join(',');
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[200],
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 56, // Tamanha da nav bar
          child: getBody(),
        ));
  }

  Widget getBody() {
    return Column(
      children: <Widget>[
        Container(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 50, right: 20, left: 20, bottom: 25),
            child: Row(
              children: <Widget>[],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Column(
          children: [
            SizedBox(
              height: 13,
            ),
            SizedBox(height: 13),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                closedElevation: 0,
                openElevation: 0,
                middleColor: Colors.transparent,
                openColor: Colors.transparent,
                closedColor: Colors.transparent,
                closedBuilder: (_, __) => Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 10),
                    Text(
                      "Usuarios",
                      style: TextStyle(
                        fontSize: 21,
                      ),
                    )
                  ],
                ),
                openBuilder: (_, __) => AddUserCat(context: context, type: 0),
              ),
              Divider(
                indent: 30,
                thickness: 1.0,
                height: 15,
              ),
              SizedBox(height: 10),
              OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                closedElevation: 0,
                openElevation: 0,
                middleColor: Colors.transparent,
                openColor: Colors.transparent,
                closedColor: Colors.transparent,
                closedBuilder: (_, __) => Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 10),
                    Text(
                      "Categorias",
                      style: TextStyle(
                        fontSize: 21,
                      ),
                    )
                  ],
                ),
                openBuilder: (_, __) => AddUserCat(context: context, type: 1),
              ),
              SizedBox(
                height: 13,
              )
            ],
          ),
        ),
      ],
    );
  }

  bool notContains(List<String> source, List<String> dest) {
    // Checa se os elementos existem na lista
    for (String elem in dest) {
      if (!source.contains(elem)) {
        return true;
      }
    }
    return false;
  }

  void importData() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                loadUserData();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void loadUserData() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }

    String fileName = result.files.single.path;
    var data = json.decode(File(fileName).readAsStringSync());
    List<String> _uList =
        (data["users"] as List).map((e) => e as String).toList();

    List<String> _cList =
        (data["Categorias"] as List).map((e) => e as String).toList();

    List<Map<String, dynamic>> _exList = (data["despesas"] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    widget.model.newDataLoaded(_uList, _cList, _exList);
  }

  void exportData() async {
    String timeStamp = DateFormat('dd_MM_yyyy').format(DateTime.now());

    final directory = await getExternalStorageDirectory();
    String fileName = "${directory.path}/Expenses_$timeStamp.txt";
    File file = File(fileName);

    file.writeAsString(json.encode({
      "users": widget.model.getUsuarios,
      "Categorias": widget.model.getCategorias,
      "despesas": widget.model.getDespesas
    }));
  }
}
