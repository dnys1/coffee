import 'package:amplify_db_common_dart/amplify_db_common_dart.dart'
    as db_common;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor get inMemoryDatabase => NativeDatabase.memory();

QueryExecutor connect() {
  return db_common.connect(
    name: 'coffee',
    path: Future.sync(() async {
      return p.join(
        (await getApplicationDocumentsDirectory()).path,
        'coffee.db',
      );
    }),
  );
}
