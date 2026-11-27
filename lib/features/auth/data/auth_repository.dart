import '../models/auth_user.dart';

/// 이메일 가입·로그인 저장소 (Supabase Auth, SPEC F-01·F-11). 실패하면 [AuthFailure]를 던진다.
/// 백엔드가 Supabase 구현을 만들면 `main.dart`의 override 한 줄만 바꾼다.
abstract interface class AuthRepository {
  /// 지금 로그인한 사용자. 없으면 null.
  AuthUser? get currentUser;

  /// 비밀번호가 다르거나 없는 계정이면 invalidCredentials.
  Future<AuthUser> signIn({required String email, required String password});

  /// 새 계정을 만들고 바로 로그인한다. 이미 있는 이메일이면 emailTaken.
  Future<AuthUser> signUp({required String email, required String password});

  Future<void> signOut();

  /// 비밀번호로 다시 확인한 뒤 계정을 지운다(F-11). 비밀번호가 다르면 invalidCredentials.
  Future<void> deleteAccount({required String password});
}
