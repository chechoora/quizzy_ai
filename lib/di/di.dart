import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:isolates/isolate_runner.dart';
import 'package:poc_ai_quiz/data/api/text_similarity/text_similarity_api_service.dart';
import 'package:poc_ai_quiz/data/api/text_similarity/text_similarity_header_interceptor.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/deck/deck_database_repository.dart';
import 'package:poc_ai_quiz/data/db/quiz_card/quiz_card_database_repository.dart';
import 'package:poc_ai_quiz/data/db/user/user_database_repository.dart';
import 'package:poc_ai_quiz/domain/deck/deck_database_mapper.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/deck/premium/deck_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz/text_similarity_answer_validator.dart';
import 'package:poc_ai_quiz/domain/quiz_card/premium/quiz_card_premium_manager.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_database_mapper.dart';
import 'package:poc_ai_quiz/domain/quiz_card/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/text_similiarity/text_similiarity_api_mapper.dart';
import 'package:poc_ai_quiz/domain/text_similiarity/text_similarity_service.dart';
import 'package:poc_ai_quiz/domain/quiz/quiz_service.dart';
import 'package:poc_ai_quiz/domain/on_device_ai/on_device_ai_service.dart';
import 'package:poc_ai_quiz/domain/user/user_database_mapper.dart';
import 'package:poc_ai_quiz/domain/user/user_repository.dart';
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
}

Future<void> _setupAPI() async {
  final runner = await IsolateRunner.spawn();
  final textSimilarityApiClient = ChopperClient(
    baseUrl: Uri.parse(
        'https://twinword-text-similarity-v1.p.rapidapi.com/similarity/'),
    services: [
      TextSimilarityApiService.create(),
    ],
    interceptors: [
      TextSimilarityHeaderInterceptor(),
    ],
    converter: IsolateConverter(runner),
  );
  getIt.registerSingleton<ChopperClient>(textSimilarityApiClient);
}

void _setupServices() {
  final textSimilarityApiClient = getIt.get<ChopperClient>();
  final TextSimilarityService textSimilarityService = TextSimilarityService(
    apiService: textSimilarityApiClient.getService<TextSimilarityApiService>(),
    apiMapper: TextSimilarityApiMapper(),
  );
  getIt.registerSingleton<TextSimilarityService>(textSimilarityService);
  final textSimilarityAnswerValidator =
      TextSimilarityAnswerValidator(textSimilarityService);
  getIt.registerSingleton<TextSimilarityAnswerValidator>(
      textSimilarityAnswerValidator);
  getIt.registerSingleton<QuizService>(
      QuizService(textSimilarityAnswerValidator));

  // on-device AI
  final onDeviceAIService = OnDeviceAIService();
  getIt.registerSingleton<OnDeviceAIService>(onDeviceAIService);

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
