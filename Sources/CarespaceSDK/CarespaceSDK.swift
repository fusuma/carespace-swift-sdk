// Main module file for CarespaceSDK

// Re-export public APIs
@_exported import Foundation

// MARK: - Main API Class
public typealias Carespace = CarespaceAPI

// MARK: - Convenience Functions

/// Create a Carespace API client with configuration
/// - Parameter configuration: SDK configuration
/// - Returns: Configured CarespaceAPI instance
public func createCarespaceAPI(configuration: CarespaceConfiguration = CarespaceConfiguration()) -> CarespaceAPI {
    return CarespaceAPI(configuration: configuration)
}

/// Create a Carespace API client with API key
/// - Parameter apiKey: API key for authentication
/// - Returns: Configured CarespaceAPI instance
public func createCarespaceAPI(apiKey: String) -> CarespaceAPI {
    return CarespaceAPI(apiKey: apiKey)
}

/// Create a Carespace API client with base URL and API key
/// - Parameters:
///   - baseURL: Base URL for the API
///   - apiKey: API key for authentication
/// - Returns: Configured CarespaceAPI instance
public func createCarespaceAPI(baseURL: URL, apiKey: String) -> CarespaceAPI {
    return CarespaceAPI(baseURL: baseURL, apiKey: apiKey)
}