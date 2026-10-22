import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../models/app_settings.dart';

/// 닉네임·동의 설정.
final settingsProvider = FutureProvider<AppSettings>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(settingsRepositoryProvider).get();
});

/// 동의 변경과 데이터 삭제 (SPEC F-11).
class SettingsActions {
  SettingsActions(this._ref);

  final Ref _ref;

  Future<void> saveConsents(Consents consents) async {
    final repo = _ref.read(settingsRepositoryProvider);
    final current = await repo.get();
    await repo.save(current.copyWith(consents: consents));
    _ref.read(dataRevisionProvider.notifier).bump();
  }

  /// 기록 전체 삭제: 기록과 거기서 만들어진 지수 이력·인사이트를 지운다. 인물·체크리스트는 남긴다.
  Future<void> deleteAllRecords() async {
    await _ref.read(entriesRepositoryProvider).deleteAll();
    await _ref.read(indexHistoryRepositoryProvider).deleteAll();
    await _ref.read(insightsRepositoryProvider).deleteAll();
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

final settingsActionsProvider = Provider<SettingsActions>(SettingsActions.new);
