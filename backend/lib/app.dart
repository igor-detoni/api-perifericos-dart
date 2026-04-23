import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:backend/controllers/marca_controller.dart';
import 'package:backend/controllers/produto_controller.dart';
import 'package:backend/controllers/auth_controller.dart';
import 'package:backend/middlewares/auth_middleware.dart';

class App {
  Handler get handler {
    final router = Router();

    router.get('/', (Request request) {
      return Response.ok('Servidor rodando e API de Perifericos conectada!');
    });

    router.mount('/auth', AuthController().router.call);
    router.mount('/marcas', MarcaController().router.call);
    router.mount('/produtos', ProdutoController().router.call);

    final pipeline = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(authMiddleware())
        .addHandler(router.call);

    return pipeline;
  }
}