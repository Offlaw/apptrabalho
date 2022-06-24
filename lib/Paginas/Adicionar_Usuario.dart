import 'package:flutter/material.dart';
import 'package:shared_expenses/Grafico/Circulo_Porcentagem.dart';
import 'package:scoped_model/scoped_model.dart';

// adiciona uma opção para remover ou editar usuários
class AddUserCat extends StatefulWidget {
  final BuildContext context;
  final int type;
  // tipo 0 signifca lista de usuários e tipo 1 signifca categoria
  AddUserCat({Key key, this.context, this.type}) : super(key: key);

  @override
  _AddUserCatState createState() => _AddUserCatState();
}

class _AddUserCatState extends State<AddUserCat> {
  Grafico_Despesas model;
  List<String> _usuariosLista;
  bool isUsuarios;
  TextEditingController userControler = TextEditingController();

  @override
  void initState() {
    super.initState();
    isUsuarios = widget.type == 0;
    model = ScopedModel.of(widget.context);
    _usuariosLista = isUsuarios ? model.getUsuarios : model.getCategorias;
  }

  @override
  void dispose() {
    super.dispose();
    userControler.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isUsuarios ? "Usuarios" : "Categorias"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              isUsuarios
                  ? model.definirUsuario(_usuariosLista)
                  : model.definirCategoria(_usuariosLista);
              Navigator.pop(context);
            },
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showUserDialog,
        child: Icon(Icons.add),
      ),
      body: Container(
        child: ListView(
          children: _usuariosLista
              .map(
                (e) => ListTile(
                  leading: isUsuarios
                      ? Icon(Icons.person_outline)
                      : Icon(Icons.category_outlined),
                  title: Text(e),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void showUserDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New ${isUsuarios ? "Usuario" : "Categoria"}:'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: userControler,
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _usuariosLista.add(userControler.text);
                  userControler.clear();
                });
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
}
