import 'dart:math';

import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:poc_ai_quiz/domain/quiz/i_answer_validator.dart';
import 'package:poc_ai_quiz/util/logger.dart';

class MlAnswerValidator extends IAnswerValidator {
  OrtSession? _session;
  final _vocab = <String, int>{};
  final _cache = <String, List<double>>{};
  final Logger _logger = Logger.withTag('MlAnswerValidator');

  @override
  Future<void> initialize() async {
    _logger.d('Initializing ML Answer Validator...');
    final vocabText = await rootBundle.loadString('assets/model/vocab.txt');
    _vocab.clear();
    final lines = vocabText.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].isNotEmpty) _vocab[lines[i]] = i;
    }
    _logger.d('Vocabulary loaded: ${_vocab.length} tokens');

    // Load ONNX model
    // Load ONNX model from asset
    final modelBytes =
        await rootBundle.load('assets/model/all_minilm_l6_v2.onnx');
    final modelData = modelBytes.buffer.asUint8List();

    final sessionOptions = OrtSessionOptions();
    _session = OrtSession.fromBuffer(modelData, sessionOptions);
    _logger.d('ONNX model loaded successfully.');
  }

  @override
  Future<AnswerResult> validateAnswer({
    required String question,
    required String correctAnswer,
    required String userAnswer,
  }) async {
    final correctEmbed =
        _cache[correctAnswer] ?? await _getEmbedding(userAnswer);
    _cache[correctAnswer] = correctEmbed;

    final userEmbed = await _getEmbedding(userAnswer);
    final score = _cosineSimilarity(correctEmbed, userEmbed);
    return AnswerResult(correctAnswer: correctAnswer, score: score);
  }

  Future<List<double>> _getEmbedding(String text) async {
    // Tokenize
    final tokens = _tokenize(text.toLowerCase());
    final inputIds = tokens.map((t) => _vocab[t] ?? _vocab['[UNK]']!).toList();

    // Pad to 128
    while (inputIds.length < 128) {
      inputIds.add(_vocab['[PAD]']!);
    }
    if (inputIds.length > 128) inputIds.removeRange(128, inputIds.length);

    final attentionMask = List.generate(128, (i) => i < tokens.length ? 1 : 0);
    final tokenTypeIds = List.filled(128, 0);

    // Run ONNX inference with 3 inputs
    final inputOrt =
        OrtValueTensor.createTensorWithDataList([inputIds], [1, 128]);
    final maskOrt =
        OrtValueTensor.createTensorWithDataList([attentionMask], [1, 128]);
    final typeOrt =
        OrtValueTensor.createTensorWithDataList([tokenTypeIds], [1, 128]);

    final outputs = _session!.run(
      OrtRunOptions(),
      {
        'input_ids': inputOrt,
        'attention_mask': maskOrt,
        'token_type_ids': typeOrt,
      },
    );

    // ⭐ FIX: The output is [batch, sequence, hidden_dim]
    // We need to do mean pooling ourselves
    final lastHiddenState = outputs?[0]?.value as List;

    // Mean pooling: average all token embeddings
    final batchOutput = lastHiddenState[0] as List; // Get first batch
    final embeddingDim = (batchOutput[0] as List).length;

    // Calculate mean across all tokens (ignoring padding)
    final embedding = List<double>.filled(embeddingDim, 0.0);
    int validTokens = attentionMask.where((m) => m == 1).length;

    for (int i = 0; i < validTokens; i++) {
      final tokenEmbed = batchOutput[i] as List;
      for (int j = 0; j < embeddingDim; j++) {
        embedding[j] += (tokenEmbed[j] as num).toDouble();
      }
    }

    // Average
    for (int j = 0; j < embeddingDim; j++) {
      embedding[j] /= validTokens;
    }

    // Normalize (L2 normalization)
    double norm = 0.0;
    for (var val in embedding) {
      norm += val * val;
    }
    norm = sqrt(norm);

    for (int i = 0; i < embedding.length; i++) {
      embedding[i] /= norm;
    }

    // Clean up
    inputOrt.release();
    maskOrt.release();
    typeOrt.release();
    outputs?[0]?.release();

    return embedding;
  }

  List<String> _tokenize(String text) {
    final tokens = ['[CLS]'];

    for (final word in text.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;

      if (_vocab.containsKey(word)) {
        tokens.add(word);
      } else {
        // Simple subword tokenization
        tokens.addAll(_subwordTokenize(word));
      }
    }

    tokens.add('[SEP]');
    return tokens;
  }

  List<String> _subwordTokenize(String word) {
    if (_vocab.containsKey(word)) return [word];

    final result = <String>[];
    var remaining = word;

    while (remaining.isNotEmpty) {
      bool found = false;
      for (int i = remaining.length; i > 0; i--) {
        final sub = remaining.substring(0, i);
        final token = result.isEmpty ? sub : '##$sub';

        if (_vocab.containsKey(token)) {
          result.add(token);
          remaining = remaining.substring(i);
          found = true;
          break;
        }
      }
      if (!found) {
        result.add('[UNK]');
        break;
      }
    }

    return result;
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0, normA = 0, normB = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }
}
