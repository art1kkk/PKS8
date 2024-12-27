import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

const mongoConnectionString = "mongodb://localhost:27017";
const dbName = "db_pks";
const collectionName = "products";

void main() async {
  final db = mongo.Db(mongoConnectionString);
  await db.open();
  print("Connected to MongoDB");

  final productsCollection = db.collection(collectionName);
  final app = Router();

  // Добавление продукта
  app.post('/add-product', (Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      // Добавляем уникальный идентификатор
      data['_id'] = mongo.ObjectId();
      await productsCollection.insert(data);

      return Response.ok(
        jsonEncode({'message': 'Product added successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Error in add-product: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Получение всех продуктов
  app.get('/get-products', (Request request) async {
    try {
      final products = await productsCollection.find().toList();
      return Response.ok(
        jsonEncode(products),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print("Error in get-products: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Удаление продукта
  app.delete('/delete-product/<id>', (Request request, String id) async {
    try {
      final result = await productsCollection.remove(
        where.eq('_id', mongo.ObjectId.parse(id)),
      );

      if (result['n'] > 0) {
        return Response.ok(
          jsonEncode({'message': 'Product deleted successfully'}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.notFound(
          jsonEncode({'error': 'Product not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e) {
      print("Error in delete-product: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Запуск сервера
  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(app);
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('Server running on http://${server.address.host}:${server.port}');
}
