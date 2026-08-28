import 'package:get_it/get_it.dart';
import '../utils/cache_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final cacheService = MemoryService();
  await cacheService.init();
  locator.registerSingleton<CacheService>(cacheService);
}
