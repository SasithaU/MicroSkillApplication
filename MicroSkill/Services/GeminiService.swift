import Foundation

struct GeminiLesson: Codable {
    let title: String
    let content: String
    let difficulty: String // beginner, intermediate, advanced
    let quiz: GeminiQuiz
}

struct GeminiQuiz: Codable {
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
}

struct GeminiCurriculum: Codable {
    let subject: String
    let lessons: [GeminiLesson]
}

class GeminiService {
    static let shared = GeminiService()
    
    // REPLACE WITH YOUR ACTUAL API KEY
    private let apiKey = "AIzaSyCQ8OYWsU2iTxOEvYG86fgXqB2UtLtdaB4"
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
    
    func generateCurriculum(for subject: String) async throws -> GeminiCurriculum {
        guard apiKey != "AIzaSyCQ8OYWsU2iTxOEvYG86fgXqB2UtLtdaB4" else {
            throw NSError(domain: "GeminiService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Please provide a valid Gemini API Key in GeminiService.swift"])
        }
        
        let prompt = """
        Create a 4-lesson curriculum for the subject: "\(subject)".
        Return ONLY a JSON object in this format:
        {
          "subject": "\(subject)",
          "lessons": [
            {
              "title": "Lesson Title",
              "content": "Deep, factual educational content (approx 200 words)",
              "difficulty": "beginner",
              "quiz": {
                "question": "A challenging question",
                "options": ["A", "B", "C", "D"],
                "correctAnswerIndex": 0
              }
            }
          ]
        }
        Ensure lessons follow a logical progression (Beginner -> Intermediate -> Advanced).
        """
        
        guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else {
            throw NSError(domain: "GeminiService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "response_mime_type": "application/json"
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let message = (errorJson?["error"] as? [String: Any])?["message"] as? String ?? "API Error"
            throw NSError(domain: "GeminiService", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        // Parse Gemini's nested response structure
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let jsonString = geminiResponse.candidates.first?.content.parts.first?.text else {
            throw NSError(domain: "GeminiService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Empty response from AI"])
        }
        
        return try JSONDecoder().decode(GeminiCurriculum.self, from: jsonString.data(using: .utf8)!)
    }
}

// MARK: - API Response Models
struct GeminiResponse: Codable {
    let candidates: [Candidate]
}

struct Candidate: Codable {
    let content: Content
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}
