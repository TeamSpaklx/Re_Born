import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../models/person.dart';

/// 인물 목록. 데이터가 바뀌면([dataRevisionProvider]) 다시 불러온다.
final peopleProvider = FutureProvider<List<Person>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(peopleRepositoryProvider).list();
});
