import '../models/auth_user.dart';
import 'auth_repository.dart';

/// 메모리에만 두는 임시 인증. 앱을 다시 켜면 시연용 계정만 남는다(Supabase 연결 전).
/// 시연용 계정: [demoEmail] / [demoPassword].
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({Map<String, String>? accounts, String? signedInEmail})
    : _accounts = {demoEmail: demoPassword, ...?accounts},
      _current = signedInEmail == null ? null : AuthUser(email: signedInEmail);

  static const demoEmail = 'demo@reborn.app';
  static const demoPassword = 'reborn1234';

  final Map<String, String> _accounts;
  final Set<SocialProvider> _socialMembers = {};
  AuthUser? _current;

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
    final isNew = _socialMembers.add(provider);
    final user = AuthUser(
      email: '${provider.name}.user@social.reborn.app',
      provider: provider,
    );
    _current = user;
    return SocialSignInResult(user: user, isNewUser: isNew);
  }

  @override
  Future<void> signOut() async => _current = null;

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
  }
}
