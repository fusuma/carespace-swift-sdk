import Foundation

/// Errors that can occur when using the Carespace SDK
public enum CarespaceError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case httpError(statusCode: Int, message: String?)
    case authenticationFailed
    case timeout
    case invalidResponse
    case missingAPIKey
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode, let message):
            return "HTTP \(statusCode): \(message ?? "Unknown error")"
        case .authenticationFailed:
            return "Authentication failed. Please check your API key."
        case .timeout:
            return "Request timeout"
        case .invalidResponse:
            return "Invalid response format"
        case .missingAPIKey:
            return "API key is required"
        }
    }
}