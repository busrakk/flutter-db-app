import 'package:dbapp/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allBooks = []; // bütün dataları tutacak
  bool _isLoading = true;

  // dataları çekme
  void _refreshData() async {
    final books = await SQLHelper.getAllData();
    setState(() {
      _allBooks = books;
      _isLoading = false;
    });
  }

  // ekran açılır açılmaz datalar görünsün istersek
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // controller
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // data ekleme
  Future<void> _addBook() async {
    await SQLHelper.createBook(_titleController.text, _descController.text);
    _refreshData();
  }

  // data güncelleme
  Future<void> _updateBook(int id) async {
    await SQLHelper.updatedBook(
        id, _titleController.text, _descController.text);
    _refreshData();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Bood Deleted')));
  }

  // data silme
  Future<void> _deleteBook(int id) async {
    await SQLHelper.deleteBook(id);
    _refreshData();
  }

  //
  void showBottomSheet(int? id) async {
    if (id != null) {
      // bir id geldiği için güncelleme
      final existingBook = _allBooks.firstWhere((book) => book['id'] == id);
      _titleController.text = existingBook['title'];
      _descController.text = existingBook['desc'];
    } else {
      // id boş bu yüzden yeni kayıt ekleme
      _titleController.clear();
      _descController.clear();
    }

    // alttan ekran çıkartma
    showModalBottomSheet(
      context: context,
      elevation: 0,
      isScrollControlled: true,
      // builder : her bir elemanı temsil eder)
      builder: (context) => Container(
        padding: EdgeInsets.only(
            top: 30,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 50),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Title'),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: _descController,
                maxLines: 4, // 4 satırdan oluşsun
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Description'),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (id == null) {
                      // yeni kitap ekleme
                      await _addBook();
                    } else {
                      // güncelleme
                      await _updateBook(id);
                    }
                    _titleController.clear();
                    _descController.clear();

                    Navigator.of(context).pop(); // son açılan ekranı kapat
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      id == null ? "Add a Book" : "Update a Book",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MP Library"),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allBooks.length, // toplam kaç data var
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(5),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _allBooks[index]['title'],
                      style: const TextStyle(fontSize: 25),
                    ),
                  ),
                  subtitle: Text(
                    _allBooks[index]['desc'],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            showBottomSheet(_allBooks[index]['id']);
                          },
                          icon: const Icon(Icons.edit, color: Colors.indigo)),
                      IconButton(
                          onPressed: () {
                            _deleteBook(_allBooks[index]['id']);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
