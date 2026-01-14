import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poc_ai_quiz/domain/quiz/initial_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz/model/quiz_results.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_engine.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_match_builder.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';
import 'package:poc_ai_quiz/domain/quiz_card/model/quiz_card_item.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/model/validator_item.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/domain/settings/validators_manager.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class QuizExeCubit extends Cubit<QuizExeState> {
  QuizExeCubit({
    required this.quizCardItems,
    required this.quizService,
    required this.quizMatchBuilder,
    required this.settingsService,
    required this.validatorsManager,
    required this.initialAnswerValidator,
  }) : super(QuizExeLoadingState());

  final InitialAnswerValidator initialAnswerValidator;
  final List<QuizCardItem> quizCardItems;
  final QuizService quizService;
  final QuizMatchBuilder quizMatchBuilder;
  final SettingsService settingsService;
  final ValidatorsManager validatorsManager;

  final _logger = Logger.withTag('QuizExeCubit');

  late final quizEngine = QuizEngine(
    cards: quizCardItems,
    quizService: quizService,
    onTestNewCard: (card) async {
      // Get current state to preserve validator data
      final currentState = state;
      if (currentState is QuizExeDisplayCardState) {
        emit(
          QuizExeDisplayCardState(
            quizCardItem: card,
            selectedValidator: currentState.selectedValidator,
            availableValidators: currentState.availableValidators,
          ),
        );
      } else {
        final validatorType = await settingsService.getCurrentValidatorType();
        final availableValidators =
            await validatorsManager.getValidatorsWithApiKeys();
        emit(QuizExeDisplayCardState(
          quizCardItem: card,
          selectedValidator: validatorType,
          availableValidators: availableValidators,
        ));
      }
    },
  );

  void launchQuiz() {
    _logger.d('Launching quiz with ${quizCardItems.length} cards');
    if (quizEngine.hasNext) {
      quizEngine.nextCard();
    }
  }

  void checkTheAnswer(
    QuizCardItem quizCardItem,
    String possibleAnswer,
  ) async {
    final lastDisplayState = state as QuizExeDisplayCardState;
    try {
      _logger.d('Checking answer for card: ${quizCardItem.id}');
      emit(lastDisplayState.copyWith(
        isProcessing: true,
      ));

      // Validate answer before sending to AI
      final validationResult = initialAnswerValidator.validate(possibleAnswer);
      if (!validationResult.isValid) {
        _logger.w(
            'Initial answer validation failed: ${validationResult.errorMessage}');
        emit(QuizExeErrorState(
          message: validationResult.errorMessage ?? 'Invalid answer',
        ));

        // Restore display card state
        emit(lastDisplayState.copyWith(
          isProcessing: false,
        ));
        return;
      }

      final result =
          await quizEngine.checkPossibleAnswer(quizCardItem, possibleAnswer);
      _logger.i('Answer validation result: $result (threshold: 0.6)');
      quizMatchBuilder.saveResult(quizCardItem, possibleAnswer, result);
      emit(QuizCardResultState(isCorrect: result >= 0.6));

      if (quizEngine.hasNext) {
        _logger.d('Moving to next card');
        quizEngine.nextCard();
      } else {
        final results = quizMatchBuilder.getResults();
        _logger.i('Quiz completed. Results: $results');
        emit(QuizDoneState(quizResults: results));
      }
    } catch (e, stackTrace) {
      _logger.e('Error checking answer for card: ${quizCardItem.id}',
          ex: e, stacktrace: stackTrace);
      emit(QuizExeErrorState(
        message: 'Failed to validate answer: ${e.toString()}',
      ));

      emit(lastDisplayState);
    }
  }

  void changeValidator(AnswerValidatorType? newValidator) async {
    if (newValidator == null) return;

    _logger.d('Changing validator to: ${newValidator.toDisplayString()}');
    await settingsService.updateValidatorType(newValidator);

    // Re-emit current state with updated validator
    if (state is QuizExeDisplayCardState) {
      final currentState = state as QuizExeDisplayCardState;
      emit(QuizExeDisplayCardState(
        quizCardItem: currentState.quizCardItem,
        selectedValidator: newValidator,
        availableValidators: currentState.availableValidators,
        isProcessing: currentState.isProcessing,
      ));
    }
  }
}

abstract class QuizExeState {}

class QuizExeLoadingState extends QuizExeState {}

class QuizExeDisplayCardState extends QuizExeState {
  QuizExeDisplayCardState({
    required this.quizCardItem,
    required this.selectedValidator,
    required this.availableValidators,
    this.isProcessing = false,
  });

  final QuizCardItem quizCardItem;
  final bool isProcessing;
  final AnswerValidatorType selectedValidator;
  final List<ValidatorItem> availableValidators;

  QuizExeDisplayCardState copyWith({
    QuizCardItem? quizCardItem,
    bool? isProcessing,
    AnswerValidatorType? selectedValidator,
    List<ValidatorItem>? availableValidators,
  }) {
    return QuizExeDisplayCardState(
      quizCardItem: quizCardItem ?? this.quizCardItem,
      isProcessing: isProcessing ?? this.isProcessing,
      selectedValidator: selectedValidator ?? this.selectedValidator,
      availableValidators: availableValidators ?? this.availableValidators,
    );
  }
}

class QuizCardResultState extends QuizExeState {
  QuizCardResultState({
    required this.isCorrect,
  });

  final bool isCorrect;
}

class QuizDoneState extends QuizExeState {
  QuizDoneState({required this.quizResults});

  final QuizResults quizResults;
}

class QuizExeErrorState extends QuizExeState {
  QuizExeErrorState({required this.message});

  final String message;
}
