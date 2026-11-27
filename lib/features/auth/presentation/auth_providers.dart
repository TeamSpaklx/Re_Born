import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../../settings/models/app_settings.dart';
import '../models/auth_user.dart';

/// 지금 로그인한 사용자. null이면 로그인 화면으로 보낸다.
class SessionNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => ref.read(authRepositoryProvider).currentUser;

  void set(AuthUser? user) => state = user;
}

final sessionProvider = NotifierProvider<SessionNotifier, AuthUser?>(
  SessionNotifier.new,
);

/// 로그인·로그아웃·계정 삭제. 실패하면 [AuthFailure]가 그대로 나간다.
class AuthActions {
  AuthActions(this._ref);

  final Ref _ref;

  Future<void> signIn(String email, String password) async {
    final user = await _ref
        .read(authRepositoryProvider)
        .signIn(email: email, password: password);
    _ref.read(sessionProvider.notifier).set(user);
  }

  /// 이메일 가입. 가입하면 바로 로그인 상태가 되어 투데이로 간다.
  /// 가입 화면 문구("가입은 … 동의하는 것으로 간주")대로 필수 동의(개인정보·감정 분석)를 켜고
  /// 선택 동의(사용 분석)는 끈 채로 시작한다. 닉네임은 가입 화면에서 받은 값이다.
  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final user = await _ref
        .read(authRepositoryProvider)
        .signUp(email: email, password: password);
    final settings = _ref.read(settingsRepositoryProvider);
    final current = await settings.get();
    await settings.save(
      current.copyWith(
        nickname: nickname.trim(),
        consents: const Consents(
          privacy: true,
          aiAnalysis: true,
          analytics: false,
        ),
      ),
    );
    _ref.read(dataRevisionProvider.notifier).bump();
    _ref.read(sessionProvider.notifier).set(user);
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    _ref.read(sessionProvider.notifier).set(null);
  }

  /// 비밀번호로 다시 확인한 뒤 계정과 모든 데이터를 지운다(F-11).
  Future<void> deleteAccount(String password) async {
    await _ref.read(authRepositoryProvider).deleteAccount(password: password);
    await _ref.read(entriesRepositoryProvider).deleteAll();
    await _ref.read(indexHistoryRepositoryProvider).deleteAll();
    await _ref.read(insightsRepositoryProvider).deleteAll();
    await _ref.read(peopleRepositoryProvider).deleteAll();
    await _ref.read(todosRepositoryProvider).deleteAll();
    _ref.read(sessionProvider.notifier).set(null);
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

final authActionsProvider = Provider<AuthActions>(AuthActions.new);
