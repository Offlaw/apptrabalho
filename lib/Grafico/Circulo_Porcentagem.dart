import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Expense {
  final int id;
  final String data;
  final String pessoa;
  final String item;
  final String categoria;
  final String valor;

  Expense({
    this.id,
    this.data,
    this.pessoa,
    this.item,
    this.categoria,
    this.valor,
  });
}

class Grafico_Despesas extends Model {
  Grafico_Despesas() {
    definirValoresIniciais();
  }
  List<String> _categorias = [];
  List<String> _usuarios = [];
  List<Map<String, dynamic>> _despesas = [];
  String _mesAtual = '6'; //incia o gráfico no mês informado.

  List<Map<String, dynamic>> get getDespesas => _despesas;
  List<String> get getCategorias => _categorias;
  List<String> get getUsuarios => _usuarios;
  String get getMesAtual => _mesAtual;

  void definirUsuario(List<String> usuariosLista) {
    _usuarios = usuariosLista;
    atualizaUsuario(true, false, false, false);
  }

  void definirCategoria(List<String> categoriaLista) {
    _categorias = categoriaLista;
    atualizaUsuario(false, true, false, false);
  }

  void resetAll() {
    _categorias = [];
    _usuarios = [];
    _despesas = [];
  }

  void adicionaDespesa(Map<String, dynamic> novaEntradaDespesa) {
    _despesas.insert(0, novaEntradaDespesa);
    atualizaUsuario(false, false, true, false);
  }

  void deletaDespesa(int index) {
    _despesas.removeAt(index);
    atualizaUsuario(false, false, true, false);
  }

  void editaDespesa(int index, Map<String, dynamic> atualizacaoEntradaDespesa) {
    _despesas[index] = atualizacaoEntradaDespesa;

    atualizaUsuario(false, false, true, false);
  }

  void definiMesAtual(String cMonth) {
    _mesAtual = cMonth;
    atualizaUsuario(false, false, false, true);
    calculateShares();
  }

  void definirValoresIniciais() {
    if (!kReleaseMode) {
      testData();
      return;
    }
  }

  void atualizaUsuario(bool u, bool c, bool e, bool d) async {
    SharedPreferences.getInstance().then((prefs) => {
          if (e) prefs.setString('despesas', json.encode(_despesas)),
          if (u) prefs.setStringList('usuarios', _usuarios),
          if (c) prefs.setStringList('Categorias', _categorias),
          if (d) prefs.setString('mesAtual', _mesAtual)
        });
  }

  void newDataLoaded(List<String> uList, List<String> cList,
      List<Map<String, dynamic>> exList) {
    _usuarios = uList;
    _categorias = cList;
    _despesas = exList;
    atualizaUsuario(true, true, true, false);
  }

  Map<String, Map<String, double>> calculateShares() {
    Map<String, Map<String, double>> tmpStats = {
      "Total Gasto": {for (var v in _usuarios) v: 0},
      "Total Owe": {for (var v in _usuarios) v: 0},
      "Net Owe": {for (var v in _usuarios) v: 0}
    };

    for (Map entrada in _despesas) {
      String mes = int.parse(entrada['data'].split('-')[1]).toString();

      if (_mesAtual != '13' && _mesAtual != mes) {
        continue;
      }
      double valor = double.parse(entrada["valor"]);
      tmpStats["Total Gasto"][entrada["pessoa"]] += valor;
      for (MapEntry val in entrada["shareBy"].entries) {
        tmpStats["Total Owe"][val.key] += double.parse(val.value);
        tmpStats["Net Owe"][val.key] += double.parse(val.value);
      }
    }

    for (String u in _usuarios) {
      tmpStats["Net Owe"][u] =
          tmpStats["Total Owe"][u] - tmpStats["Total Gasto"][u];
    }

    return tmpStats;
  }

  Map<String, double> calculateCategoryShare() {
    Map<String, double> cShare = {for (var v in _categorias) v: 0};
    for (Map entrada in _despesas) {
      String mes = int.parse(entrada['data'].split('-')[1]).toString();

      if (_mesAtual != '13' && _mesAtual != mes) {
        continue;
      }
      cShare[entrada['categoria']] += double.parse(entrada['valor']);
    }

    Map pieData = <String, double>{};
    for (String en in _categorias) {
      pieData[en + " R\$: ${cShare[en]}"] = cShare[en];
    }
    return pieData;
  }

  testData() {
    // dados para teste
    _categorias = ["Trabalho", "Comida", "Outros"];
    _usuarios = ["Jean", "Mikael", "Maikel"];

    _despesas = [
      {
        "data": "01-06-2022",
        "pessoa": "Jean",
        "item": "Jean",
        "categoria": "Comida",
        "valor": "300",
        "shareBy": {"Jean": "100", "Maikel": "100", "Mikael": "100"}
      },
    ];
  }
}
