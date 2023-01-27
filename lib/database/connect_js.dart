import 'package:amplify_db_common_dart/amplify_db_common_dart.dart'
    as db_common;
import 'package:aws_common/aws_common.dart';
import 'package:drift/drift.dart';

QueryExecutor get inMemoryDatabase => connect(name: uuid());

QueryExecutor connect({String name = 'coffee'}) {
  return db_common.connect(name: name);
}
