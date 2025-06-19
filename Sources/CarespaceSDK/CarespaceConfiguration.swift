import Foundation

/// Configuration settings for the Carespace SDK.
///
/// `CarespaceConfiguration` allows you to customize various aspects of the SDK behavior,
/// including the API endpoint, authentication, timeouts, and custom headers.
///
/// ## Default Configuration
/// ```swift
/// let config = CarespaceConfiguration()
/// // Uses default settings:
/// // - Base URL: https://api-dev.carespace.ai
/// // - Timeout: 30 seconds
/// // - No API key (must be set later)
/// ```
///
/// ## Custom Configuration
/// ```swift
/// let config = CarespaceConfiguration(
///     baseURL: URL(string: "https://api.carespace.ai")!,
///     apiKey: "your-api-key",
///     timeout: 60.0,
///     additionalHeaders: [
///         "X-Client-Version": "1.0.0",
///         "X-Platform": "iOS"
///     ]
/// )
/// ```
///
/// ## Environment-Specific Configurations
/// ```swift
/// // Development
/// let devConfig = CarespaceConfiguration(
///     baseURL: URL(string: "https://api-dev.carespace.ai")!,
///     apiKey: ProcessInfo.processInfo.environment["DEV_API_KEY"]
/// )
///
/// // Production
/// let prodConfig = CarespaceConfiguration(
///     baseURL: URL(string: "https://api.carespace.ai")!,
///     apiKey: ProcessInfo.processInfo.environment["PROD_API_KEY"],
///     timeout: 45.0
/// )
/// ```
///
/// - Note: The configuration is immutable except for the API key, which can be
///   updated using `setAPIKey(_:)` method.
public struct CarespaceConfiguration {
    /// The base URL for all API requests.
    ///
    /// This should be the root URL of the Carespace API without any path components.
    /// Default: `https://api-dev.carespace.ai`
    public let baseURL: URL
    
    /// The API key used for authentication.
    ///
    /// This can be set during initialization or updated later using `setAPIKey(_:)`.
    /// Most API endpoints require a valid API key.
    public var apiKey: String?
    
    /// The request timeout interval in seconds.
    ///
    /// Requests that take longer than this will fail with a timeout error.
    /// Default: `30.0` seconds
    public let timeout: TimeInterval
    
    /// Additional HTTP headers to include with every request.
    ///
    /// These headers are added to all requests made by the SDK. Common uses include:
    /// - Client version information
    /// - Platform identification
    /// - Custom tracking headers
    ///
    /// Default: Empty dictionary
    public let additionalHeaders: [String: String]
    
    /// Creates a new configuration with the specified settings.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for API requests. Defaults to the development server.
    ///   - apiKey: Optional API key for authentication. Can be set later if needed.
    ///   - timeout: Request timeout in seconds. Defaults to 30 seconds.
    ///   - additionalHeaders: Additional headers to include with every request. Defaults to empty.
    ///
    /// - Note: The base URL should not include a trailing slash or version path.
    public init(
        baseURL: URL = URL(string: "https://api-dev.carespace.ai")!,
        apiKey: String? = nil,
        timeout: TimeInterval = 30.0,
        additionalHeaders: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.timeout = timeout
        self.additionalHeaders = additionalHeaders
    }
    
    /// Updates the API key in the configuration.
    ///
    /// Use this method to set or update the API key after initialization.
    /// This is useful when the API key is obtained dynamically (e.g., after user login).
    ///
    /// - Parameter apiKey: The new API key to use for authentication.
    ///
    /// ## Example
    /// ```swift
    /// var config = CarespaceConfiguration()
    /// // Later, after obtaining the API key...
    /// config.setAPIKey("new-api-key")
    /// ```
    ///
    /// - Important: This method mutates the configuration. Make sure to update
    ///   any `CarespaceAPI` instances that use this configuration.
    public mutating func setAPIKey(_ apiKey: String) {
        self.apiKey = apiKey
    }
}