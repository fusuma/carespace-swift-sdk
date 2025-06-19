import Foundation

/// Comprehensive error types that can occur when using the Carespace SDK.
///
/// `CarespaceError` provides detailed error information for various failure scenarios,
/// including network issues, authentication problems, and data handling errors.
///
/// ## Error Handling
///
/// ```swift
/// do {
///     let users = try await api.users.list()
/// } catch CarespaceError.authenticationFailed {
///     print("Please check your API key")
/// } catch CarespaceError.httpError(let code, let message) {
///     print("HTTP Error \(code): \(message ?? "Unknown")")
/// } catch CarespaceError.timeout {
///     print("Request timed out")
/// } catch {
///     print("Unexpected error: \(error)")
/// }
/// ```
///
/// ## Common Error Scenarios
///
/// - **Authentication**: `.authenticationFailed`, `.missingAPIKey`
/// - **Network**: `.networkError`, `.timeout`
/// - **Data**: `.decodingError`, `.encodingError`, `.noData`
/// - **HTTP**: `.httpError` with status code and message
///
/// - SeeAlso: `LocalizedError` for user-friendly error descriptions
public enum CarespaceError: Error, LocalizedError {
    /// The provided URL is malformed or invalid.
    case invalidURL
    
    /// The server returned an empty response when data was expected.
    case noData
    
    /// Failed to decode the response data into the expected type.
    /// - Parameter error: The underlying decoding error.
    case decodingError(Error)
    
    /// Failed to encode the request data.
    /// - Parameter error: The underlying encoding error.
    case encodingError(Error)
    
    /// A network-level error occurred.
    /// - Parameter error: The underlying network error.
    case networkError(Error)
    
    /// The server returned an HTTP error.
    /// - Parameters:
    ///   - statusCode: The HTTP status code (e.g., 404, 500).
    ///   - message: Optional error message from the server.
    case httpError(statusCode: Int, message: String?)
    
    /// Authentication failed, typically due to an invalid or expired API key.
    case authenticationFailed
    
    /// The request exceeded the configured timeout duration.
    case timeout
    
    /// The server returned a response in an unexpected format.
    case invalidResponse
    
    /// An API key is required but was not provided.
    case missingAPIKey
    
    /// A localized description of the error suitable for display to users.
    ///
    /// This property provides user-friendly error messages that can be shown
    /// in alerts or error views.
    ///
    /// ## Example
    /// ```swift
    /// if let error = error as? CarespaceError {
    ///     showAlert(title: "Error", message: error.localizedDescription)
    /// }
    /// ```
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