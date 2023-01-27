import 'package:integration_test/integration_test.dart';

import 'coffee_image_test.dart' as coffee_image_tests;
import 'database_test.dart' as database_tests;
import 'resize_worker_test.dart' as resize_worker_tests;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  coffee_image_tests.main();
  database_tests.main();
  resize_worker_tests.main();
}
