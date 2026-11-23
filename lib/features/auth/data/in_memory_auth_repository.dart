import '../models/auth_user.dart';
import 'auth_repository.dart';
import 'auth_session_store.dart';

/// 디버그 패널에서 고르는 "다음 소셜 로그인 결과". 백엔드가 없어서 실패 상황을 직접 만들어 본다.
enum SocialOutcome {
  /// 평소 동작: 약관 동의를 마친 적이 있으면 기존 회원, 아니면 신규 회원.
  auto('평소대로'),
  newUser('신규 회원 → 약관 동의'),
  existingUser('기존 회원 → 홈'),
  cancelled('사용자가 취소'),
  network('네트워크 오류'),
  unknown('알 수 없는 오류');

  const SocialOutcome(this.label);

  final String label;
}

/// 메모리에 두는 임시 인증(Supabase 연결 전).
///
/// - 이메일 계정: 시연용 [demoEmail] / [demoPassword]. 앱을 다시 켜면 이것만 남는다.
/// - 소셜 로그인: [store]가 있으면 로그인 상태와 가입을 마친 소셜 종류를 기기에 남겨,
///   앱을 다시 켜도 로그인이 유지되는 것처럼 보이게 한다.
/// - [nextOutcome]·[latency]는 디버그 패널이 바꾼다(실패·로딩 확인용).
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({
    Map<String, String>? accounts,
    String? signedInEmail,
    AuthSessionStore? store,
  }) : _accounts = {demoEmail: demoPassword, ...?accounts},
       _store = store,
       _socialMembers = {...?store?.members},
       _current = signedInEmail != null
           ? AuthUser(email: signedInEmail)
           : _socialUser(store?.session);

  static const demoEmail = 'demo@reborn.app';
  static const demoPassword = 'reborn1234';

  final Map<String, String> _accounts;
  final AuthSessionStore? _store;

  /// 약관 동의까지 마친 소셜 종류.
  final Set<SocialProvider> _socialMembers;
  AuthUser? _current;

  SocialOutcome nextOutcome = SocialOutcome.auto;
  Duration latency = Duration.zero;

  static AuthUser? _socialUser(SocialProvider? provider) => provider == null
      ? null
      : AuthUser(
          email: '${provider.name}.user@social.reborn.app',
          provider: provider,
        );

  /// 소셜 로그인 상태만 기기에 남긴다(가입 중인 신규 회원은 동의를 마칠 때 저장).
  Future<void> _persist({bool keepSession = true}) async {
    final provider = _current?.provider;
    await _store?.save(
      session:
          keepSession && provider != null && _socialMembers.contains(provider)
          ? provider
          : null,
      members: _socialMembers,
    );
  }

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    if (_accounts[key] != password) {
      throw const AuthFailure(AuthFailureType.invalidCredentials);
    }
    return _current = AuthUser(email: key);
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthFailure(AuthFailureType.emailTaken);
    }
    _accounts[key] = password;
    return _current = AuthUser(email: key);
  }

  @override
  Future<SocialSignInResult> signInWithSocial(SocialProvider provider) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    switch (nextOutcome) {
      case SocialOutcome.cancelled:
        throw const AuthFailure(AuthFailureType.cancelled);
      case SocialOutcome.network:
        throw const AuthFailure(AuthFailureType.network);
      case SocialOutcome.unknown:
        throw StateError('디버그 패널: 알 수 없는 오류');
      case SocialOutcome.newUser:
        _socialMembers.remove(provider);
      case SocialOutcome.existingUser:
        _socialMembers.add(provider);
      case SocialOutcome.auto:
        break;
    }
    final isNew = !_socialMembers.contains(provider);
    final user = _socialUser(provider)!;
    _current = user;
    await _persist();
    return SocialSignInResult(user: user, isNewUser: isNew);
  }

  @override
  Future<void> completeSocialSignup() async {
    final provider = _current?.provider;
    if (provider == null) return;
    _socialMembers.add(provider);
    await _persist();
  }

  @override
  Future<void> signOut() async {
    _current = null;
    await _persist(keepSession: false);
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    final user = _current;
    if (user == null) {
      throw const AuthFailure(AuthFailureType.invalidCredentials);
    }
    if (user.isSocial) {
      _socialMembers.remove(user.provider);
    } else {
      if (_accounts[user.email] != password) {
        throw const AuthFailure(AuthFailureType.invalidCredentials);
      }
      _accounts.remove(user.email);
    }
    _current = null;
    await _persist(keepSession: false);
  }
}
