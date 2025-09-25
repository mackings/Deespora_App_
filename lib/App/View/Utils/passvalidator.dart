class PasswordValidator {
  static bool hasMinLength(String password) => password.length >= 8;
  static bool hasUppercase(String password) => password.contains(RegExp(r'[A-Z]'));
  static bool hasLowercase(String password) => password.contains(RegExp(r'[a-z]'));
  static bool hasNumber(String password) => password.contains(RegExp(r'[0-9]'));
  static bool hasSpecialChar(String password) => password.contains(RegExp(r'[!@#\$&*~]'));

  static int strength(String password) {
    int score = 0;
    if (hasMinLength(password)) score++;
    if (hasUppercase(password)) score++;
    if (hasLowercase(password)) score++;
    if (hasNumber(password)) score++;
    if (hasSpecialChar(password)) score++;
    return score;
  }

  static bool isStrong(String password) => strength(password) == 5;
}
