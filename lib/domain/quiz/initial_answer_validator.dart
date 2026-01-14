class InitialAnswerValidator {
  ValidationResult validate(String answer) {
    final trimmedAnswer = answer.trim();

    if (trimmedAnswer.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Answer cannot be empty',
      );
    }

    return ValidationResult(isValid: true);
  }
}

class ValidationResult {
  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  final bool isValid;
  final String? errorMessage;
}