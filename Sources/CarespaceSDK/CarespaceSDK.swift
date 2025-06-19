/// CarespaceSDK - Swift SDK for Carespace API
///
/// CarespaceSDK provides a Swift interface for interacting with the Carespace API,
/// enabling developers to integrate Carespace functionality into their iOS, macOS,
/// tvOS, and watchOS applications.
///
/// ## Overview
///
/// The SDK provides:
/// - Authentication management with API key support
/// - User, client, and program management
/// - Type-safe request/response models
/// - Comprehensive error handling
/// - Async/await support for modern Swift concurrency
///
/// ## Getting Started
///
/// ```swift
/// import CarespaceSDK
///
/// // Create an API client
/// let api = CarespaceAPI(apiKey: "your-api-key")
///
/// // Or use the convenience function
/// let api = createCarespaceAPI(apiKey: "your-api-key")
///
/// // Make API calls
/// do {
///     let users = try await api.users.list()
///     print("Found \(users.count) users")
/// } catch {
///     print("Error: \(error)")
/// }
/// ```

// Re-export public APIs
@_exported import Foundation

// MARK: - Main API Class

/// Type alias for the main Carespace API client.
/// This provides a shorter, more convenient name for the API client.
///
/// ## Example
/// ```swift
/// let api = Carespace(apiKey: "your-api-key")
/// ```
public typealias Carespace = CarespaceAPI

// MARK: - Convenience Functions

/// Creates a Carespace API client with the specified configuration.
///
/// Use this function when you need full control over the SDK configuration,
/// including custom base URLs, timeouts, and headers.
///
/// - Parameter configuration: The SDK configuration to use. Defaults to `CarespaceConfiguration()`.
/// - Returns: A configured `CarespaceAPI` instance.
///
/// ## Example
/// ```swift
/// let config = CarespaceConfiguration(
///     baseURL: URL(string: "https://api.carespace.ai")!,
///     apiKey: "your-api-key",
///     timeout: 60.0
/// )
/// let api = createCarespaceAPI(configuration: config)
/// ```
public func createCarespaceAPI(configuration: CarespaceConfiguration = CarespaceConfiguration()) -> CarespaceAPI {
    return CarespaceAPI(configuration: configuration)
}

/// Creates a Carespace API client with the specified API key.
///
/// This is the most common way to create an API client. The client will use
/// the default base URL and configuration settings.
///
/// - Parameter apiKey: The API key for authentication. You can obtain this from your Carespace dashboard.
/// - Returns: A configured `CarespaceAPI` instance.
///
/// ## Example
/// ```swift
/// let api = createCarespaceAPI(apiKey: "your-api-key")
/// 
/// // Use the API client
/// let programs = try await api.programs.list()
/// ```
public func createCarespaceAPI(apiKey: String) -> CarespaceAPI {
    return CarespaceAPI(apiKey: apiKey)
}

/// Creates a Carespace API client with a custom base URL and API key.
///
/// Use this function when connecting to a custom Carespace instance or
/// development/staging environments.
///
/// - Parameters:
///   - baseURL: The base URL for the API endpoints. Must be a valid HTTPS URL.
///   - apiKey: The API key for authentication.
/// - Returns: A configured `CarespaceAPI` instance.
///
/// ## Example
/// ```swift
/// let stagingURL = URL(string: "https://staging-api.carespace.ai")!
/// let api = createCarespaceAPI(baseURL: stagingURL, apiKey: "your-api-key")
/// ```
///
/// - Important: The base URL should not include a trailing slash or API version path.
public func createCarespaceAPI(baseURL: URL, apiKey: String) -> CarespaceAPI {
    return CarespaceAPI(baseURL: baseURL, apiKey: apiKey)
}