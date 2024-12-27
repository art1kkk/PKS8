import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _addProduct() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
      return;
    }

    // Преобразуем изображение в Base64
    final imageBytes = await _imageFile!.readAsBytes();
    final imageBase64 = base64Encode(imageBytes);

    final newProduct = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'image': imageBase64, // Сохраняем изображение в Base64
    };

    print('Отправляем данные: $newProduct'); // Логируем данные перед отправкой

    try {
      final productService = ProductService();
      await productService.addProduct(newProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар успешно добавлен')),
      );

      Navigator.of(context).pop(); // Возвращаемся на предыдущий экран
    } catch (error) {
      print('Ошибка при отправке данных: $error'); // Логируем ошибку
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при добавлении товара')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить товар'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название товара'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Цена товара'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Описание товара'),
            ),
            const SizedBox(height: 20),
            _imageFile == null
                ? const Text('Изображение не выбрано.')
                : Image.file(
              _imageFile!,
              height: 150,
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Выбрать изображение товара'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Добавить товар'),
            ),
          ],
        ),
      ),
    );
  }
}
