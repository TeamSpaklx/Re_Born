import '../models/auth_user.dart';
import 'auth_repository.dart';
import 'auth_session_store.dart';

/// 메모리에 두는 임시 인증(Supabase 연결 전).
///
/// - 계정(이메일·비밀번호)은 메모리에만 있어, 앱을 다시 켜면 시연용 [demoEmail] / [demoPassword]만 남는다.
/// - [store]가 있으면 로그인한 이메일을 기기에 남겨, 앱을 다시 켜도 로그인이 유지되는 것처럼 보이게 한다.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({
    Map<String, String>? accounts,
    String? signedInEmail,
    AuthSessionStore? store,
  }) : _accounts = {demoEmail: demoPassword, ...?accounts},
       _store = store,
       _current = switch (signedInEmail ?? store?.sessionEmail) {
         final email? => AuthUser(email: email),
         null => null,
       };

  static const demoEmail = 'demo@reborn.app';
  static const demoPassword = 'reborn1234';

  final Map<String, String> _accounts;
  final AuthSessionStore? _store;
  AuthUser? _current;

  static String _key(String email) => email.trim().toLowerCase();

  Future<AuthUser> _signInAs(String email) async {
    final user = _current = AuthUser(email: email);
    await _store?.save(email);
    return user;
  }

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final key = _key(email);
    if (_accounts[key] != password) {
      throw const AuthFailure(AuthFailureType.invalidCredentials);
    }
    return _signInAs(key);
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    final key = _key(email);
    if (_accounts.containsKey(key)) {
      throw const AuthFailure(AuthFailureType.emailTaken);
    }
    _accounts[key] = password;
    return _signInAs(key);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    await _store?.save(null);
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    final user = _current;
    if (user == null || _accounts[user.email] != password) {
      throw const AuthFailure(AuthFailureType.invalidCredentials);
    }
    _accounts.remove(user.email);
    _current = null;
    await _store?.save(null);
  }
}
