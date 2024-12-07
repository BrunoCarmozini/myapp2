import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livros App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      supportedLocales: [
        const Locale('pt', 'BR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> data = [];
  List<dynamic> filteredData = [];
  bool isLoading = true;
  String errorMessage = "";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    searchController.addListener(() {
      filterBooks();
    });
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://arquivos.ectare.com.br/livros.json'));

    if (response.statusCode == 200) {
      final decodedData = utf8.decode(response.bodyBytes);
      setState(() {
        data = json.decode(decodedData);
        filteredData = List.from(data);
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = "Falha ao carregar os dados. Tente novamente.";
        isLoading = false;
      });
    }
  }

  void filterBooks() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredData = data.where((book) {
        return book['titulo'].toLowerCase().contains(query) || book['autor'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livros'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar livro',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : filteredData.isEmpty
                        ? Center(child: Text("Nenhum livro encontrado"))
                        : ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              var book = filteredData[index];
                              return Card(
                                margin: EdgeInsets.all(8.0),
                                elevation: 5.0,
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(10),
                                  leading: book['imagem'] != null
                                      ? Image.network(book['imagem'], width: 50, height: 70, fit: BoxFit.cover)
                                      : null,
                                  title: Text(book['titulo'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  subtitle: Text(book['autor']),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookDetailPage(book: book),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class BookDetailPage extends StatelessWidget {
  final dynamic book;

  BookDetailPage({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['titulo']),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            book['imagem'] != null
                ? Image.network(book['imagem'], height: 250, fit: BoxFit.cover)
                : Container(),
            SizedBox(height: 10),
            Text(
              book['titulo'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'Autor: ${book['autor']}',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text(
              'Ano: ${book['ano']}',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text(
              'Gênero: ${book['genero']}',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              'Descrição: ${book['descricao'] ?? 'Este é um livro fascinante que você não pode perder! Uma história envolvente com temas profundos que farão você refletir. Uma leitura imperdível para todos os amantes da literatura.'}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
