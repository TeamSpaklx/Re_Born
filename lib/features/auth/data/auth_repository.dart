import '../models/auth_user.dart';

/// 로그인·가입 저장소 (Supabase Auth, SPEC F-01·F-11). 실패하면 [AuthFailure]를 던진다.
/// 백엔드가 Supabase 구현을 만들면 `app/data_providers.dart`의 provider 한 줄만 바꾼다.
abstract interface class AuthRepository {
  /// 지금 로그인한 사용자. 없으면 null.
  AuthUser? get currentUser;

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> signUp({required String email, required String password});

  /// 구글·카카오로 로그인(처음이면 계정이 만들어진다). 실제 연결은 Supabase OAuth로 교체한다.
  Future<SocialSignInResult> signInWithSocial(SocialProvider provider);

  Future<void> signOut();

  /// 비밀번호로 다시 확인한 뒤 계정을 지운다(F-11). 비밀번호가 다르면 invalidCredentials.
  /// 소셜 계정은 비밀번호가 없어 [password]를 생략한다.
  Future<void> deleteAccount({String? password});
}
