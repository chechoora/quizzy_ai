import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:isolates/isolate_runner.dart';
import 'package:poc_ai_quiz/data/api/text_similarity/text_similarity_api_service.dart';
import 'package:poc_ai_quiz/data/api/text_similarity/text_similarity_header_interceptor.dart';
import 'package:poc_ai_quiz/data/db/database.dart';
import 'package:poc_ai_quiz/data/db/deck/deck_database_repository.dart';
import 'package:poc_ai_quiz/data/db/quiz_card/quiz_card_database_repository.dart';
import 'package:poc_ai_quiz/domain/deck/deck_database_mapper.dart';
import 'package:poc_ai_quiz/domain/deck/deck_repository.dart';
import 'package:poc_ai_quiz/domain/quiz_card_repository/quiz_card_database_mapper.dart';
import 'package:poc_ai_quiz/domain/quiz_card_repository/quiz_card_repository.dart';
import 'package:poc_ai_quiz/domain/text_similiarity/text_similiarity_api_mapper.dart';
import 'package:poc_ai_quiz/domain/text_similiarity/text_similarity_service.dart';
import 'package:poc_ai_quiz/domain/quiz_service.dart';
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
}

Future<void> _setupAPI() async {
  final runner = await IsolateRunner.spawn();
  final textSimilarityApiClient = ChopperClient(
    baseUrl: Uri.parse('https://twinword-text-similarity-v1.p.rapidapi.com/similarity/'),
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
  getIt.registerSingleton<QuizService>(QuizService(textSimilarityService));

  final database = getIt.get<AppDatabase>();

  // deck
  final deckDataBaseRepository = DeckDataBaseRepository(database);
  getIt.registerSingleton<DeckDataBaseRepository>(deckDataBaseRepository);
  final deckRepository = DeckRepository(
    dataBaseRepository: deckDataBaseRepository,
    deckDatBaseMapper: DeckDatBaseMapper(),
  );
  getIt.registerSingleton<DeckRepository>(deckRepository);

  // quizcardlist
  final quizCardDataBaseRepository = QuizCardDataBaseRepository(database);
  getIt.registerSingleton<QuizCardDataBaseRepository>(quizCardDataBaseRepository);
  final quizCardRepository = QuizCardRepository(
    dataBaseRepository: quizCardDataBaseRepository,
    dataBaseMapper: QuizCardDataBaseMapper(),
  );
  getIt.registerSingleton<QuizCardRepository>(quizCardRepository);
}
