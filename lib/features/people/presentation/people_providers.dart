import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../core/utils/dates.dart';
import '../../analysis/relation_index.dart';
import '../models/person.dart';
import '../models/relation_type.dart';

/// 인물 목록. 데이터가 바뀌면([dataRevisionProvider]) 다시 불러온다.
final peopleProvider = FutureProvider<List<Person>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(peopleRepositoryProvider).list();
});

/// 인물 한 명. 없으면 null.
final personProvider = Provider.family<Person?, String>((ref, id) {
  final people = ref.watch(peopleProvider).value ?? const [];
  for (final p in people) {
    if (p.id == id) return p;
  }
  return null;
});

/// 인물 목록 카드에 보여 줄 요약: 오늘 기준 지수(데이터 부족이면 null)와 마지막 기록 후 일수.
class PersonSummary {
  const PersonSummary({
    required this.person,
    required this.index,
    required this.daysSinceLastRecord,
    required this.entryCount,
  });

  final Person person;
  final int? index;
  final int? daysSinceLastRecord;
  final int entryCount;
}

final personSummariesProvider = FutureProvider<List<PersonSummary>>((
  ref,
) async {
  ref.watch(dataRevisionProvider);
  final now = ref.watch(clockProvider)();
  final people = await ref.watch(peopleRepositoryProvider).list();
  final entries = await ref.watch(entriesRepositoryProvider).list();
  return [
    for (final p in people)
      () {
        final own = entries.where((e) => e.personId == p.id).toList();
        return PersonSummary(
          person: p,
          index: RelationIndex.compute(own, now)?.index,
          daysSinceLastRecord: own.isEmpty
              ? null
              : daysBetween(own.first.createdAt, now),
          entryCount: own.length,
        );
      }(),
  ];
});

/// 인물 추가·수정·삭제. 끝나면 목록들이 다시 불러오도록 알린다.
class PeopleActions {
  PeopleActions(this._ref);

  final Ref _ref;

  Future<Person> create({
    required String name,
    required RelationType relationType,
    String? memo,
  }) async {
    final person = await _ref
        .read(peopleRepositoryProvider)
        .create(
          name: name.trim(),
          relationType: relationType,
          memo: (memo == null || memo.trim().isEmpty) ? null : memo.trim(),
        );
    _ref.read(dataRevisionProvider.notifier).bump();
    return person;
  }

  Future<void> update(Person person) async {
    await _ref.read(peopleRepositoryProvider).update(person);
    _ref.read(dataRevisionProvider.notifier).bump();
  }

  Future<void> delete(String id, {required bool deleteEntries}) async {
    await _ref
        .read(analysisServiceProvider)
        .deletePerson(id, deleteEntries: deleteEntries);
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

final peopleActionsProvider = Provider<PeopleActions>(PeopleActions.new);
