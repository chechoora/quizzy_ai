import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:poc_ai_quiz/data/api/claude/claude_answer_validator.dart';
import 'package:poc_ai_quiz/data/api/claude/claude_api_service.dart';
import 'package:poc_ai_quiz/data/api/claude/claude_header_interceptor.dart';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_answer_validator.dart';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_api_service.dart';
import 'package:poc_ai_quiz/data/api/gemini_ai/gemini_header_interceptor.dart';
import 'package:poc_ai_quiz/data/api/openai/openai_answer_validator.dart';
import 'package:poc_ai_quiz/data/api/openai/openai_api_service.dart';
import 'package:poc_ai_quiz/data/api/openai/openai_header_interceptor.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/deck/deck_database_repository.dart';
import 'package:poc_ai_quiz/data/db/quiz_card/quiz_card_database_repository.dart';
import 'package:poc_ai_quiz/data/db/user/user_database_repository.dart';
import 'package:poc_ai_quiz/data/db/user_settings/user_settings_database_repository.dart';
import 'package:poc_ai_quiz/data/in_app_purchase/mock_revenue_cat_purchase_manager.dart';
import 'package:poc_ai_quiz/data/in_app_purchase/revenue_cat_purchase_manager.dart';
import 'package:poc_ai_quiz/domain/quiz/ml_answer_validator.dart';
import 'package:poc_ai_quiz/util/env.dart';
import 'package:poc_ai_quiz/domain/deck/deck_database_mapper.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz/on_device_ai_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz_card/premium/quiz_card_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_exe_validator.dart';
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
import 'package:poc_ai_quiz/domain/user_settings/api_keys_provider.dart';
import 'package:poc_ai_quiz/util/logger.dart';

import '../domain/in_app_purchase/in_app_purchase_service.dart';

final getIt = GetIt.instance;

Future<void> setupDi() async {
  await _setupDataBase();
  await _setupRepositories();
  await _setupApiKeysProvider();
  await _setupInAppPurchase();
  await _setupAPI();
  await _setupServices();
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

Future<void> _setupRepositories() async {
  // user
  final userRepository = UserRepository(
    dataBaseRepository: getIt.get<UserDataBaseRepository>(),
    userDataBaseMapper: UserDataBaseMapper(),
  );
  await userRepository.fetchCurrentUser();
  getIt.registerSingleton<UserRepository>(userRepository);

  // user settings
  final userSettingsRepository = UserSettingsRepository(
    dataBaseRepository: getIt.get<UserSettingsDataBaseRepository>(),
    userSettingsDataBaseMapper: UserSettingsDataBaseMapper(),
  );
  getIt.registerSingleton<UserSettingsRepository>(userSettingsRepository);

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
}

Future<void> _setupApiKeysProvider() async {
  final apiKeysProvider = ValidatorConfigProvider(
    userRepository: getIt.get<UserRepository>(),
    userSettingsRepository: getIt.get<UserSettingsRepository>(),
  );
  await apiKeysProvider.initialize();
  getIt.registerSingleton<ValidatorConfigProvider>(apiKeysProvider);
}

Future<void> _setupInAppPurchase() async {
  final RevenueCatPurchaseManager revenueCatPurchaseManager;
  switch (AppEnv.purchaseType) {
    case AppEnv.purchaseTypeMockPref:
      revenueCatPurchaseManager = MockPrefRevenueCatPurchaseManager();
    case AppEnv.purchaseTypeMockCache:
      revenueCatPurchaseManager = MockCacheRevenueCatPurchaseManager();
    default:
      revenueCatPurchaseManager = RevenueCatPurchaseManager(
        Logger.withTag('RevenueCatPurchaseManager'),
      );
  }
  await revenueCatPurchaseManager.initialize();
  getIt.registerSingleton<RevenueCatPurchaseManager>(revenueCatPurchaseManager);
  final inAppPurchaseService = InAppPurchaseService(
    revenueCatPurchaseManager: revenueCatPurchaseManager,
  );
  getIt.registerSingleton<InAppPurchaseService>(inAppPurchaseService);
}

Future<void> _setupAPI() async {
  final apiKeysProvider = getIt.get<ValidatorConfigProvider>();

  // Gemini API client
  final geminiApiClient = ChopperClient(
    baseUrl:
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/'),
    services: [
      GeminiApiService.create(),
    ],
    interceptors: [
      GeminiHeaderInterceptor(apiKeysProvider),
    ],
    converter: const JsonConverter(),
  );
  getIt.registerSingleton<ChopperClient>(geminiApiClient,
      instanceName: 'gemini');

  // Claude API client
  final claudeApiClient = ChopperClient(
    baseUrl: Uri.parse('https://api.anthropic.com/v1'),
    services: [
      ClaudeApiService.create(),
    ],
    interceptors: [
      ClaudeHeaderInterceptor(apiKeysProvider),
    ],
    converter: const JsonConverter(),
  );
  getIt.registerSingleton<ChopperClient>(claudeApiClient,
      instanceName: 'claude');

  // OpenAI API client
  final openAIApiClient = ChopperClient(
    baseUrl: Uri.parse('https://api.openai.com/v1'),
    services: [
      OpenAIApiService.create(),
    ],
    interceptors: [
      OpenAIHeaderInterceptor(apiKeysProvider),
    ],
    converter: const JsonConverter(),
  );
  getIt.registerSingleton<ChopperClient>(openAIApiClient,
      instanceName: 'openai');
}

Future<void> _setupServices() async {
  final onDeviceAIService = OnDeviceAIService();
  getIt.registerSingleton<OnDeviceAIService>(onDeviceAIService);
  final onDeviceAIAnswerValidator =
      OnDeviceAIAnswerValidator(onDeviceAIService);
  getIt.registerSingleton<OnDeviceAIAnswerValidator>(onDeviceAIAnswerValidator);

  final mlAnswerValidator = MlAnswerValidator();
  await mlAnswerValidator.initialize();
  getIt.registerSingleton<MlAnswerValidator>(mlAnswerValidator);

  // Gemini answer validator
  final geminiApiClient = getIt.get<ChopperClient>(instanceName: 'gemini');
  final geminiAnswerValidator = GeminiAnswerValidator(
    geminiApiClient.getService<GeminiApiService>(),
  );
  getIt.registerSingleton<GeminiAnswerValidator>(geminiAnswerValidator);

  // Claude answer validator
  final claudeApiClient = getIt.get<ChopperClient>(instanceName: 'claude');
  final claudeAnswerValidator = ClaudeAnswerValidator(
    claudeApiClient.getService<ClaudeApiService>(),
  );
  getIt.registerSingleton<ClaudeAnswerValidator>(claudeAnswerValidator);

  // OpenAI answer validator
  final openAIApiClient = getIt.get<ChopperClient>(instanceName: 'openai');
  final openAIAnswerValidator = OpenAIAnswerValidator(
    openAIApiClient.getService<OpenAIApiService>(),
  );
  getIt.registerSingleton<OpenAIAnswerValidator>(openAIAnswerValidator);

  // Get already registered repositories
  final userRepository = getIt.get<UserRepository>();
  final userSettingsRepository = getIt.get<UserSettingsRepository>();
  final deckRepository = getIt.get<DeckRepository>();
  final quizCardRepository = getIt.get<QuizCardRepository>();

  // settings
  final validatorsManager = ValidatorsManager(
    userRepository: userRepository,
    userSettingsRepository: userSettingsRepository,
    onDeviceAIService: onDeviceAIService,
  );
  getIt.registerSingleton<ValidatorsManager>(validatorsManager);

  final settingsService = SettingsService(
      userRepository: userRepository,
      userSettingsRepository: userSettingsRepository,
      validators: {
        AnswerValidatorType.onDeviceAI: onDeviceAIAnswerValidator,
        AnswerValidatorType.gemini: geminiAnswerValidator,
        AnswerValidatorType.claude: claudeAnswerValidator,
        AnswerValidatorType.openAI: openAIAnswerValidator,
        AnswerValidatorType.ml: mlAnswerValidator,
      });
  getIt.registerSingleton<SettingsService>(settingsService);

  // quiz service - uses settings to get the correct validator
  getIt.registerSingleton<QuizService>(QuizService(settingsService));

  // premium
  final deckManager = DeckPremiumManager(
    inAppPurchaseService: getIt<InAppPurchaseService>(),
    deckRepository: deckRepository,
  );
  getIt.registerSingleton<DeckPremiumManager>(deckManager);

  final quizManager = QuizCardPremiumManager(
    inAppPurchaseService: getIt<InAppPurchaseService>(),
    quizCardRepository: quizCardRepository,
  );
  getIt.registerSingleton<QuizCardPremiumManager>(quizManager);

  // quiz card exe validator
  final quizCardExeValidator = QuizCardExeValidator(
    userRepository: userRepository,
    userSettingsRepository: userSettingsRepository,
  );
  getIt.registerSingleton<QuizCardExeValidator>(quizCardExeValidator);
}
