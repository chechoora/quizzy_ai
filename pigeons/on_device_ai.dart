import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/data/api/on_device_ai/generated/on_device_ai.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/app/src/main/kotlin/com/example/poc_ai_quiz/OnDeviceAiApi.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut: 'ios/Runner/OnDeviceAiApi.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'poc_ai_quiz',
))
class CardAnswerResult {
  CardAnswerResult({
    required this.howCorrect,
    required this.reasoning,
  });

  /// How correct the answer is, from 0.0 to 1.0
  final double howCorrect;

  /// AI reasoning for the score
  final String reasoning;
}

@HostApi()
abstract class OnDeviceAiApi {
  /// Check if on-device AI is available on this platform
  @async
  bool isOnDeviceAIAvailable();

  /// Validate a user's answer against the correct answer using on-device AI
  @async
  CardAnswerResult validateAnswer(String userAnswer, String correctAnswer);
}