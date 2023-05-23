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
  Future<void> _addBook(int id) async {
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

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
