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
    this.social,
  });

  final String email;
  final String password;
  final String nickname;
  final Consents consents;

  /// 소셜 로그인으로 들어온 신규 가입이면 그 종류(비밀번호 입력 없이 약관 동의부터 이어 간다).
  final SocialProvider? social;

  SignupDraft copyWith({
    String? email,
    String? password,
    String? nickname,
    Consents? consents,
    SocialProvider? social,
  }) {
    return SignupDraft(
      email: email ?? this.email,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      consents: consents ?? this.consents,
      social: social ?? this.social,
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

  /// 구글·카카오 로그인. 처음 온 사용자면 `true`를 돌려주고, 약관 동의부터 이어 가도록 가입 임시 보관함에 표시한다.
  Future<bool> signInWithSocial(SocialProvider provider) async {
    final pendingSignup = _ref.read(signupDraftProvider).social;
    final result = await _ref
        .read(authRepositoryProvider)
        .signInWithSocial(provider);
    _ref.read(sessionProvider.notifier).set(result.user);
    if (result.isNewUser) {
      _ref
          .read(signupDraftProvider.notifier)
          .update(
            (d) => d.copyWith(
              social: provider,
              nickname: '${provider.label} 사용자',
              email: result.user.email,
            ),
          );
    } else if (pendingSignup != provider) {
      _ref.read(signupDraftProvider.notifier).clear();
    }
    return result.isNewUser || pendingSignup == provider;
  }

  /// 소셜 신규 가입의 약관 동의를 저장하고 가입을 마친다(계정은 로그인 때 이미 만들어졌다).
  Future<void> completeSocialSignup(SignupDraft draft) async {
    final settings = _ref.read(settingsRepositoryProvider);
    final current = await settings.get();
    await settings.save(
      current.copyWith(
        nickname: draft.nickname.trim(),
        consents: draft.consents,
      ),
    );
    _ref.read(signupDraftProvider.notifier).clear();
    _ref.read(dataRevisionProvider.notifier).bump();
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    _ref.read(sessionProvider.notifier).set(null);
  }

  /// 비밀번호로 다시 확인한 뒤 계정과 모든 데이터를 지운다(F-11).
  Future<void> deleteAccount(String? password) async {
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
