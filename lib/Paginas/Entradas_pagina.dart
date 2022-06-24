import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared_expenses/Grafico/Circulo_Porcentagem.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:collection/collection.dart';

class NewEntryLog extends StatefulWidget {
  final Function callback;
  final BuildContext context;
  final int index;
  NewEntryLog({Key key, this.callback, this.context, this.index = -999})
      : super(key: key);
  @override
  _NewEntryLogState createState() => _NewEntryLogState();
}

class _NewEntryLogState extends State<NewEntryLog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _itemEditor = TextEditingController();
  TextEditingController _personEditor = TextEditingController();
  TextEditingController _amountEditor = TextEditingController();
  TextEditingController _dateEditor =
      TextEditingController(text: DateTime.now().toString());
  TextEditingController _categoryEditor = TextEditingController();
  List<TextEditingController> _shareControler;

  Map<String, String> shareList;
  Grafico_Despesas model;
  bool showError = false;
  List<String> _Usuarios;
  List<double> _sharedRatio;

  bool editRecord;

  @override
  void dispose() {
    super.dispose();
    _itemEditor.dispose();
    _personEditor.dispose();
    _amountEditor.dispose();
    _dateEditor.dispose();
    _categoryEditor.dispose();
    _shareControler.forEach((element) {
      element.dispose();
    });
  }

  @override
  void initState() {
    model = ScopedModel.of(widget.context);
    super.initState();
    editRecord = widget.index != -999;
    _Usuarios = model.getUsuarios;

    if (editRecord) {
      Map<String, dynamic> data = {...model.getDespesas[widget.index]};
      _itemEditor.text = data['item'];
      _personEditor.text = data['pessoa'];
      _amountEditor.text = data['valor'];
      _dateEditor.text =
          DateFormat("dd-MM-yyyy").parse(data['data']).toString();
      _categoryEditor.text = data['categoria'];
      shareList =
          Map<String, String>.from(model.getDespesas[widget.index]["shareBy"]);

      if (_Usuarios.length != shareList.length) {
        for (String u in model.getUsuarios) {
          if (!shareList.containsKey(u)) {
            shareList[u] = "0.00";
          }
        }
      }
      _sharedRatio = _Usuarios.map((e) => double.parse(
          (double.parse(shareList[e]) *
                  _Usuarios.length /
                  double.parse(data['valor']))
              .toStringAsFixed(2))).toList();
    } else {
      shareList = {for (var u in model.getUsuarios) u: "0.00"};
      _sharedRatio = _Usuarios.map((e) => 1.0).toList();
    }
    _shareControler =
        _Usuarios.map((e) => TextEditingController(text: shareList[e]))
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (editRecord) model.deletaDespesa(widget.index);
              Navigator.pop(context);
            },
            icon: Icon(Icons.delete),
            color: Colors.white,
            tooltip: "Deletar",
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: SingleChildScrollView(
        child:
            (model.getUsuarios.length == 0 || model.getCategorias.length == 0)
                ? Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Nenhum usuario ou categoria adicionado",
                          style: TextStyle(fontSize: 21),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                            onPressed: () {
                              widget.callback(2);
                              Navigator.pop(context);
                            },
                            child: Text("Ir para as configurações"))
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            autovalidateMode: AutovalidateMode.disabled,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.shopping_cart_outlined),
                              labelText: 'Item',
                            ),
                            controller: _itemEditor,
                            validator: (value) =>
                                value.isEmpty ? "Required filed *" : null,
                          ),
                          SizedBox(height: 9),
                          SelectFormField(
                            icon: Icon(Icons.person_outline),
                            labelText: 'Quem Gastou?',
                            controller: _personEditor,
                            items: model.getUsuarios
                                .map((e) => {
                                      "value": e,
                                      "label": e,
                                    })
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList(),
                            validator: (value) =>
                                value.isEmpty ? "Required filed *" : null,
                          ),
                          TextFormField(
                            autovalidateMode: AutovalidateMode.disabled,
                            keyboardType: TextInputType.number,
                            controller: _amountEditor,
                            onChanged: (value) {
                              updateSharingDetails();
                            },
                            decoration: const InputDecoration(
                              icon: Icon(Icons.account_balance_wallet_outlined),
                              labelText: "Valor",
                            ),
                            validator: (val) {
                              if (val.isEmpty) return "Required filed *";
                              if (double.tryParse(val) == null) {
                                return "Entre com um Número Válido";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 9),
                          DateTimePicker(
                            controller: _dateEditor,
                            type: DateTimePickerType.date,
                            dateMask: 'd MMM, yyyy',
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            icon: Icon(Icons.event),
                            dateLabelText: 'Data',
                            validator: (value) =>
                                value.isEmpty ? "Required field *" : null,
                          ),
                          SizedBox(height: 9),
                          SelectFormField(
                            autovalidate: false,
                            type: SelectFormFieldType.dropdown,
                            controller: _categoryEditor,
                            icon: Icon(Icons.category),
                            labelText: 'Categoria',
                            items: model.getCategorias
                                .map((e) => {
                                      "value": e,
                                      "label": e,
                                    })
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList(),
                            validator: (value) =>
                                value.isEmpty ? "Required field *" : null,
                          ),
                          SizedBox(height: 9),
                          SizedBox(height: 9),
                          if (showError)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [],
                            ),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                bool saved = saveRecord();
                if (saved) {
                  widget.callback(0);
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Salvar",
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  saveRecord() {
    print('saverecord');
    if (formKey.currentState.validate() && sharedProperly()) {
      Map<String, dynamic> data = {
        "data": DateFormat('dd-MM-yyyy')
            .format(DateFormat('yyyy-MM-dd').parse(_dateEditor.text)),
        "pessoa": _personEditor.text,
        "item": _itemEditor.text,
        "categoria": _categoryEditor.text,
        "valor": _amountEditor.text,
        "shareBy": shareList
      };
      editRecord
          ? model.editaDespesa(widget.index, data)
          : model.adicionaDespesa(data);
      return true;
    }
  }

  clearForm() {
    bool saved = saveRecord();
    if (!saved) return;
    formKey.currentState.reset();
    _itemEditor.clear();
    _amountEditor.clear();
    shareList = {for (var u in model.getUsuarios) u: "0.00"};
    _sharedRatio = _Usuarios.map((e) => 1.0).toList();
    for (TextEditingController e in _shareControler) {
      e.text = "0.00";
    }
    editRecord = false;
    setState(() {});
  }

  sharedProperly() {
    double val = double.parse(_amountEditor.text);
    if (val == null) return false;

    for (int i = 0; i < _Usuarios.length; i++) {
      shareList[_Usuarios[i]] =
          double.parse(_shareControler[i].text).toStringAsFixed(2);
    }

    List<double> sharedAmount =
        _Usuarios.map((e) => double.parse(shareList[e])).toList(); //
    double summed = sharedAmount.sum;
    int len = _Usuarios.length;

    if (summed == val) {
      _sharedRatio = sharedAmount
          .map((e) => double.parse((e * len / summed).toStringAsFixed(2)))
          .toList();
      showError = false;
      setState(() {});

      return true;
    } else {
      showError = true;
      setState(() {});

      return false;
    }
  }

  updateSharingDetails() {
    if (_amountEditor.text.trim().isEmpty) {
      return;
    }
    double value = double.parse(_amountEditor.text);

    List<double> iAmount = _sharedRatio
        .map((e) =>
            double.parse((value * e / _sharedRatio.sum).toStringAsFixed(2)))
        .toList();

    double diff = value;
    for (double e in iAmount) {
      diff -= e;
    }

    if (diff != 0) {
      for (int i = 0; i < _Usuarios.length; i++) {
        if (_sharedRatio[i] != 0) {
          iAmount[i] += diff;
          break;
        }
      }
    }
    for (int i = 0; i < _Usuarios.length; i++) {
      _shareControler[i].text = iAmount[i].toStringAsFixed(2);
      shareList[_Usuarios[i]] = iAmount[i].toStringAsFixed(2);
    }
    setState(() {});
  }
}
