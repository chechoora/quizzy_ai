import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:poc_ai_quiz/quiz_serive/quiz_service.dart';
import 'package:poc_ai_quiz/text_similarity/api/text_similarity_api_service.dart';
import 'package:poc_ai_quiz/text_similarity/api/text_similarity_header_interceptor.dart';
import 'package:poc_ai_quiz/text_similarity/api/text_similiarity_api_mapper.dart';
import 'package:poc_ai_quiz/text_similarity/text_similarity_service.dart';

final getIt = GetIt.instance;

void setupDi() {
  _setupAPI();
  _setupServices();
}

void _setupAPI() {
  final textSimilarityApiClient = ChopperClient(
    baseUrl: Uri.parse('https://twinword-text-similarity-v1.p.rapidapi.com/'),
    services: [
      TextSimilarityApiService.create(),
    ],
    interceptors: [
      TextSimilarityHeaderInterceptor(),
    ],
    converter: const JsonConverter(),
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
}
