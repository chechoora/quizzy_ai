import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:isolates/isolate_runner.dart';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_answer_validator.dart';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_api_service.dart';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_header_interceptor.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/deck/deck_database_repository.dart';
import 'package:poc_ai_quiz/data/db/quiz_card/quiz_card_database_repository.dart';
import 'package:poc_ai_quiz/data/db/user/user_database_repository.dart';
import 'package:poc_ai_quiz/data/db/user_settings/user_settings_database_repository.dart';
import 'package:poc_ai_quiz/domain/deck/deck_database_mapper.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz/on_device_ai_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz_card/premium/quiz_card_premium_manager.dart';
import 'package:poc_ai_quiz/domain/settings/answer_validator_type.dart';
import 'package:poc_ai_quiz/domain/settings/settings_service.dart';
import 'package:poc_ai_quiz/domain/settings/validators_manager.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_database_mapper.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';
import 'package:poc_ai_quiz/domain/on_device_ai/on_device_ai_service.dart';
import 'package:poc_ai_quiz/domain/user/user_database_mapper.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_database_mapper.dart';
import 'package:poc_ai_quiz/domain/user_settings/user_settings_repository.dart';
import 'package:poc_ai_quiz/util/api/isolate_converter.dart';

final getIt = GetIt.instance;

Future<void> setupDi() async {
  await _setupDataBase();
  await _setupAPI();
  _setupServices();
}

Future<void> _setupDataBase() async {
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);

  final deckDataBaseRepository = DeckDataBaseRepository(database);
  getIt.registerSingleton<DeckDataBaseRepository>(deckDataBaseRepository);

  final quizCardDataBaseRepository = QuizCardDataBaseRepository(database);
  getIt.registerSingleton<QuizCardDataBaseRepository>(
      quizCardDataBaseRepository);

  final userDataBaseRepository = UserDataBaseRepository(database);
  getIt.registerSingleton<UserDataBaseRepository>(userDataBaseRepository);

  final userSettingsDataBaseRepository =
      UserSettingsDataBaseRepository(database);
  getIt.registerSingleton<UserSettingsDataBaseRepository>(
      userSettingsDataBaseRepository);
}

Future<void> _setupAPI() async {
  final runner = await IsolateRunner.spawn();
  // Gemini API client
  final geminiApiClient = ChopperClient(
    baseUrl:
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/'),
    services: [
      GeminiApiService.create(),
    ],
    interceptors: [
      GeminiHeaderInterceptor('AIzaSyA101cvgIAiseZSUYNr_i87Y4LqcRAPx_k'),
    ],
    converter: const JsonConverter(),
  );
  getIt.registerSingleton<ChopperClient>(geminiApiClient,
      instanceName: 'gemini');
}

void _setupServices() {
  final onDeviceAIService = OnDeviceAIService();
  getIt.registerSingleton<OnDeviceAIService>(onDeviceAIService);
  final onDeviceAIAnswerValidator =
      OnDeviceAIAnswerValidator(onDeviceAIService);
  getIt.registerSingleton<OnDeviceAIAnswerValidator>(onDeviceAIAnswerValidator);

  // Gemini answer validator
  final geminiApiClient = getIt.get<ChopperClient>(instanceName: 'gemini');
  final geminiAnswerValidator = GeminiAnswerValidator(
    geminiApiClient.getService<GeminiApiService>(),
  );
  getIt.registerSingleton<GeminiAnswerValidator>(geminiAnswerValidator);

  // deck
  final deckRepository = DeckRepository(
    dataBaseRepository: getIt.get<DeckDataBaseRepository>(),
    deckDatBaseMapper: DeckDatBaseMapper(),
  );
  getIt.registerSingleton<DeckRepository>(deckRepository);

  // quizcardlist
  final quizCardRepository = QuizCardRepository(
    dataBaseRepository: getIt.get<QuizCardDataBaseRepository>(),
    dataBaseMapper: QuizCardDataBaseMapper(),
  );
  getIt.registerSingleton<QuizCardRepository>(quizCardRepository);

  // user
  final userRepository = UserRepository(
    dataBaseRepository: getIt.get<UserDataBaseRepository>(),
    userDataBaseMapper: UserDataBaseMapper(),
  );
  getIt.registerSingleton<UserRepository>(userRepository);

  // user settings
  final userSettingsRepository = UserSettingsRepository(
    dataBaseRepository: getIt.get<UserSettingsDataBaseRepository>(),
    userSettingsDataBaseMapper: UserSettingsDataBaseMapper(),
  );
  getIt.registerSingleton<UserSettingsRepository>(userSettingsRepository);

  // settings
  final validatorsManager = ValidatorsManager(
    userRepository: userRepository,
    onDeviceAIService: onDeviceAIService,
  );
  getIt.registerSingleton<ValidatorsManager>(validatorsManager);

  final settingsService = SettingsService(
      userRepository: userRepository,
      userSettingsRepository: userSettingsRepository,
      validators: {
        AnswerValidatorType.onDeviceAI: onDeviceAIAnswerValidator,
        AnswerValidatorType.gemini: geminiAnswerValidator,
      });
  getIt.registerSingleton<SettingsService>(settingsService);

  // quiz service - uses settings to get the correct validator
  getIt.registerSingleton<QuizService>(QuizService(settingsService));

  // premium
  final deckManager = DeckPremiumManager(
    userRepository: userRepository,
    deckRepository: deckRepository,
  );
  getIt.registerSingleton<DeckPremiumManager>(deckManager);

  final quizManager = QuizCardPremiumManager(
    userRepository: userRepository,
    quizCardRepository: quizCardRepository,
  );
  getIt.registerSingleton<QuizCardPremiumManager>(quizManager);
}
