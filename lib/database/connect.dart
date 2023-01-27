import 'package:drift/drift.dart';

/// An in-memory database that can be used for testing.
QueryExecutor get inMemoryDatabase => throw UnsupportedError(
      'In memory database is not available in this environment',
    );

/// Creates a platform-specific [QueryExecutor] that connects to a database.
QueryExecutor connect() {
  throw UnsupportedError('Cannot connect to database in this environment');
}
