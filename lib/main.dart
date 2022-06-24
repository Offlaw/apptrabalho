import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_expenses/Grafico/Circulo_Porcentagem.dart';
import 'package:shared_expenses/paginas/Aba_rool.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Grafico_Despesas meuGraficoDespesa = Grafico_Despesas();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<Grafico_Despesas>(
      model: meuGraficoDespesa,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RootApp(),
      ),
    );
  }
}
