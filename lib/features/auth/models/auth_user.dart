/// 로그인한 사용자 (SPEC F-01). 비밀번호는 인증 서비스가 관리하고 앱에는 두지 않는다.
class AuthUser {
  const AuthUser({required this.email, this.provider});

  final String email;

  /// 소셜 로그인으로 들어온 계정이면 그 종류. 이메일 가입이면 null(비밀번호가 있는 계정).
  final SocialProvider? provider;

  bool get isSocial => provider != null;
}

/// 소셜 로그인 종류. 이름표는 버튼 글자에 쓴다.
enum SocialProvider {
  google('Google'),
  kakao('카카오');

  const SocialProvider(this.label);

  final String label;
}

/// 소셜 로그인 결과. 처음 들어온 사용자면 [isNewUser]가 true라 닉네임·필수 동의를 기본값으로 채운다.
class SocialSignInResult {
  const SocialSignInResult({required this.user, required this.isNewUser});

  final AuthUser user;
  final bool isNewUser;
}

/// 인증 실패 종류 (SPEC F-01 예외: 이미 가입된 이메일, 비밀번호 오류, 네트워크 끊김).
/// [cancelled]는 사용자가 구글·카카오 창을 스스로 닫은 경우라 오류 안내를 띄우지 않는다.
enum AuthFailureType {
  invalidCredentials,
  emailTaken,
  network,
  cancelled,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.type);

  final AuthFailureType type;

  /// 사용자에게 보이는 문구(기술 내용 없음).
  String get message => switch (type) {
    AuthFailureType.invalidCredentials => '이메일 또는 비밀번호가 맞지 않아요.',
    AuthFailureType.emailTaken => '이미 가입된 이메일이에요. 로그인해 주세요.',
    AuthFailureType.network => '네트워크에 연결할 수 없어요. 연결을 확인하고 다시 시도해 주세요.',
    AuthFailureType.cancelled => '로그인을 취소했어요.',
    AuthFailureType.unknown => '문제가 생겼어요. 잠시 뒤에 다시 시도해 주세요.',
  };
}
