import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:isolates/isolate_runner.dart';
import 'package:poc_ai_quiz/data/text_similarity/api/text_similarity_api_service.dart';
import 'package:poc_ai_quiz/data/text_similarity/api/text_similarity_header_interceptor.dart';
import 'package:poc_ai_quiz/data/text_similarity/api/text_similiarity_api_mapper.dart';
import 'package:poc_ai_quiz/domain/text_similarity_service.dart';
import 'package:poc_ai_quiz/domain/quiz_service.dart';
import 'package:poc_ai_quiz/util/api/isolate_converter.dart';

final getIt = GetIt.instance;

Future<void> setupDi() async {
  await _setupAPI();
  _setupServices();
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
}
