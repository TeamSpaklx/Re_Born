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

/// 가입 화면들(정보 입력 → 동의)이 값을 이어 받는 임시 보관함.
class SignupDraft {
  const SignupDraft({
    this.email = '',
    this.password = '',
    this.nickname = '',
    this.consents = const Consents(
      privacy: false,
      aiAnalysis: false,
      analytics: false,
    ),
  });

  final String email;
  final String password;
  final String nickname;
  final Consents consents;

  SignupDraft copyWith({
    String? email,
    String? password,
    String? nickname,
    Consents? consents,
  }) {
    return SignupDraft(
      email: email ?? this.email,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      consents: consents ?? this.consents,
    );
  }
}

class SignupDraftNotifier extends Notifier<SignupDraft> {
  @override
  SignupDraft build() => const SignupDraft();

  void update(SignupDraft Function(SignupDraft) change) =>
      state = change(state);

  void clear() => state = const SignupDraft();
}

final signupDraftProvider = NotifierProvider<SignupDraftNotifier, SignupDraft>(
  SignupDraftNotifier.new,
);

/// 로그인·가입·로그아웃·계정 삭제. 실패하면 [AuthFailure]가 그대로 나간다.
class AuthActions {
  AuthActions(this._ref);

  final Ref _ref;

  Future<void> signIn(String email, String password) async {
    final user = await _ref
        .read(authRepositoryProvider)
        .signIn(email: email, password: password);
    _ref.read(sessionProvider.notifier).set(user);
  }

  /// 가입을 끝내고 닉네임·동의를 저장한다.
  Future<void> signUp(SignupDraft draft) async {
    final user = await _ref
        .read(authRepositoryProvider)
        .signUp(email: draft.email, password: draft.password);
    final settings = _ref.read(settingsRepositoryProvider);
    final current = await settings.get();
    await settings.save(
      current.copyWith(
        nickname: draft.nickname.trim(),
        consents: draft.consents,
      ),
    );
    _ref.read(signupDraftProvider.notifier).clear();
    _ref.read(sessionProvider.notifier).set(user);
    _ref.read(dataRevisionProvider.notifier).bump();
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
