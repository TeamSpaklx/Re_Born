/// 가입·로그인 입력 검증 (SPEC F-01·P-03): 이메일 형식, 비밀번호 8자 이상, 닉네임 1~12자.
abstract final class AuthValidator {
  static const minPasswordLength = 8;
  static const maxNicknameLength = 12;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validateEmail(String email) {
    final value = email.trim();
    if (value.isEmpty) return '이메일을 입력해 주세요.';
    if (!_email.hasMatch(value)) return '이메일 형식이 올바르지 않아요.';
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return '비밀번호를 입력해 주세요.';
    if (password.length < minPasswordLength) {
      return '비밀번호는 $minPasswordLength자 이상이어야 해요.';
    }
    return null;
  }

  static String? validatePasswordConfirm(String password, String confirm) {
    if (confirm.isEmpty) return '비밀번호를 한 번 더 입력해 주세요.';
    if (password != confirm) return '비밀번호가 서로 달라요.';
    return null;
  }

  static String? validateNickname(String nickname) {
    final value = nickname.trim();
    if (value.isEmpty) return '닉네임을 입력해 주세요.';
    if (value.length > maxNicknameLength) {
      return '닉네임은 $maxNicknameLength자 이내로 입력해 주세요.';
    }
    return null;
  }
}
