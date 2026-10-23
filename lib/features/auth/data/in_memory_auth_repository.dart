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
  Future<void> signOut() async => _current = null;

  @override
  Future<void> deleteAccount({required String password}) async {
    final user = _current;
    if (user == null || _accounts[user.email] != password) {
      throw const AuthFailure(AuthFailureType.invalidCredentials);
    }
    _accounts.remove(user.email);
    _current = null;
  }
}
