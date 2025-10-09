class Validators {
  static String? requiredField(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  static String? email(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }

  static String? password(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    if (value.length < 6) {
      return errorMessage;
    }
    return null;
  }

  static String? phoneNumber(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    if (!RegExp(r'^\+?\d{8,}$').hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }
}