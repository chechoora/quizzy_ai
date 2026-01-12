import Foundation
import FoundationModels

/// Implementation of OnDeviceAiApi using Apple's Foundation Models framework
class OnDeviceAiApiImplementation: OnDeviceAiApi {
    
    // Reference to the system language model
    private lazy var model: Any? = {
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default
        }
        return nil
    }()
    
    /// Check if on-device AI is available on this platform
    func isOnDeviceAIAvailable(completion: @escaping (Result<Bool, Error>) -> Void) {
        if #available(iOS 26.0, *) {
            guard let model = model as? SystemLanguageModel else {
                completion(.success(false))
                return
            }
            switch model.availability {
            case .available:
                completion(.success(true))
            case .unavailable:
                completion(.success(false))
            }
        } else {
            completion(.success(false))
        }
    }
    
    /// Validate a user's answer against the correct answer using on-device AI
    func validateAnswer(userAnswer: String, correctAnswer: String, completion: @escaping (Result<CardAnswerResult, Error>) -> Void) {
        Task {
            do {
                // First check if the model is available
                if #available(iOS 26.0, *) {
                    guard let model = model as? SystemLanguageModel,
                          model.availability == .available else {
                        completion(.failure(PigeonError(
                            code: "MODEL_UNAVAILABLE",
                            message: "On-device AI model is not available",
                            details: nil
                        )))
                        return
                    }
                    // Create a session with specific instructions for answer validation
                    let instructions = """
                    You are an educational assessment assistant that evaluates student answers for quiz questions.
                    Your job is to compare a student's answer with the correct answer and provide:
                    1. A correctness score from 0.0 to 1.0 (where 1.0 is completely correct)
                    2. Clear reasoning for the score
                    
                    Consider the following when scoring:
                    - Exact matches should score 1.0
                    - Answers with the same meaning but different wording should score highly (0.8-1.0)
                    - Partially correct answers should receive partial credit (0.3-0.7)
                    - Completely wrong answers should score close to 0.0
                    - Consider context, synonyms, and alternative valid expressions
                    
                    Always provide constructive reasoning that explains why the score was given.
                    Keep reasoning concise but informative, focusing on what was correct or incorrect.
                    """
                    
                    let session = LanguageModelSession(instructions: instructions)
                    
                    // Create the validation prompt
                    let prompt = """
                    Please evaluate this student answer:
                    
                    Student Answer: "\(userAnswer)"
                    Correct Answer: "\(correctAnswer)"
                    
                    Provide your assessment as a structured response with the score and reasoning.
                    """
                    
                    // Use guided generation to get structured response
                    let response = try await session.respond(
                        to: prompt,
                        generating: ValidationResult.self
                    )
                    
                    // Convert to CardAnswerResult
                    let result = CardAnswerResult(
                        howCorrect: response.content.score,
                        reasoning: response.content.reasoning
                    )
                    
                    completion(.success(result))
                } else {
                    completion(.failure(PigeonError(
                        code: "MODEL_UNAVAILABLE",
                        message: "On-device AI model is not available",
                        details: nil
                    )))
                    return
                }
            } catch {
                completion(.failure(PigeonError(
                    code: "VALIDATION_ERROR",
                    message: "Failed to validate answer: \(error.localizedDescription)",
                    details: nil
                )))
            }
        }
    }
}

/// Structure for guided generation of validation results
@available(iOS 26.0, *)
@Generable(description: "Assessment result for a student's answer")
private struct ValidationResult {
    @Guide(description: "Correctness score from 0.0 to 1.0", .range(0.0...1.0))
    var score: Double
    
    @Guide(description: "Clear explanation of why this score was given, focusing on correctness and accuracy")
    var reasoning: String
}
