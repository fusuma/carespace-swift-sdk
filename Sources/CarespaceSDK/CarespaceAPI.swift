import Foundation

/// The main Carespace API client that provides access to all API endpoints.
///
/// `CarespaceAPI` is the central entry point for interacting with the Carespace platform.
/// It manages authentication, configuration, and provides access to all available API endpoints.
///
/// ## Overview
///
/// The API client provides access to:
/// - **Authentication**: Login and token management
/// - **Users**: User creation and management
/// - **Clients**: Client (patient) management
/// - **Programs**: Healthcare program management
///
/// ## Usage
///
/// ### Basic Initialization
/// ```swift
/// // Using API key
/// let api = CarespaceAPI(apiKey: "your-api-key")
///
/// // Using custom configuration
/// let config = CarespaceConfiguration(
///     baseURL: URL(string: "https://api.carespace.ai")!,
///     apiKey: "your-api-key",
///     timeout: 60.0
/// )
/// let api = CarespaceAPI(configuration: config)
/// ```
///
/// ### Making API Calls
/// ```swift
/// // List users
/// do {
///     let users = try await api.users.list()
///     for user in users {
///         print("User: \(user.name)")
///     }
/// } catch {
///     print("Error fetching users: \(error)")
/// }
///
/// // Create a new client
/// let newClient = CreateClientRequest(
///     name: "John Doe",
///     email: "john@example.com",
///     phone: "+1234567890"
/// )
/// let client = try await api.clients.create(newClient)
/// ```
///
/// ## Thread Safety
///
/// `CarespaceAPI` is thread-safe and can be shared across multiple concurrent operations.
/// The underlying HTTP client handles request queuing and connection management.
///
/// ## Error Handling
///
/// All API methods throw `CarespaceError` for various error conditions:
/// - `.authenticationFailed`: Invalid or missing API key
/// - `.httpError`: HTTP errors with status code and message
/// - `.timeout`: Request timeout
/// - `.invalidResponse`: Malformed response data
///
/// - SeeAlso: `CarespaceConfiguration`, `CarespaceError`
public class CarespaceAPI {
    private let httpClient: HTTPClient
    private var configuration: CarespaceConfiguration
    
    /// Provides access to authentication endpoints.
    ///
    /// Use this property to perform authentication operations such as login.
    ///
    /// ## Example
    /// ```swift
    /// let loginRequest = LoginRequest(
    ///     email: "user@example.com",
    ///     password: "password"
    /// )
    /// let authResponse = try await api.auth.login(loginRequest)
    /// api.setAPIKey(authResponse.token)
    /// ```
    public let auth: AuthAPI
    
    /// Provides access to user management endpoints.
    ///
    /// Use this property to create, retrieve, update, and list users.
    ///
    /// ## Example
    /// ```swift
    /// // List all users
    /// let users = try await api.users.list()
    ///
    /// // Get a specific user
    /// let user = try await api.users.get("user-id")
    /// ```
    public let users: UsersAPI
    
    /// Provides access to client (patient) management endpoints.
    ///
    /// Use this property to manage healthcare clients/patients in the system.
    ///
    /// ## Example
    /// ```swift
    /// // Create a new client
    /// let request = CreateClientRequest(
    ///     name: "Jane Smith",
    ///     email: "jane@example.com"
    /// )
    /// let client = try await api.clients.create(request)
    /// ```
    public let clients: ClientsAPI
    
    /// Provides access to healthcare program management endpoints.
    ///
    /// Use this property to create and manage healthcare programs.
    ///
    /// ## Example
    /// ```swift
    /// // List all programs
    /// let programs = try await api.programs.list(
    ///     PaginationParameters(limit: 50)
    /// )
    /// ```
    public let programs: ProgramsAPI
    
    /// Initializes a new Carespace API client with the specified configuration.
    ///
    /// - Parameter configuration: The configuration for the API client. If not provided,
    ///   uses the default configuration.
    ///
    /// - Note: If no API key is set in the configuration, you must call `setAPIKey(_:)`
    ///   before making authenticated requests.
    public init(configuration: CarespaceConfiguration = CarespaceConfiguration()) {
        self.configuration = configuration
        self.httpClient = HTTPClient(configuration: configuration)
        
        // Initialize API endpoints
        self.auth = AuthAPI(httpClient: httpClient)
        self.users = UsersAPI(httpClient: httpClient)
        self.clients = ClientsAPI(httpClient: httpClient)
        self.programs = ProgramsAPI(httpClient: httpClient)
    }
    
    /// Sets or updates the API key used for authentication.
    ///
    /// Call this method to set or update the API key after initialization.
    /// This is useful when the API key is obtained dynamically (e.g., after user login).
    ///
    /// - Parameter apiKey: The API key to use for authentication.
    ///
    /// ## Example
    /// ```swift
    /// let api = CarespaceAPI()
    /// // Later, after obtaining the API key...
    /// api.setAPIKey("your-api-key")
    /// ```
    ///
    /// - Important: This method updates both the configuration and the underlying HTTP client.
    public func setAPIKey(_ apiKey: String) {
        configuration.setAPIKey(apiKey)
        httpClient.setAPIKey(apiKey)
    }
    
    /// Returns the current configuration of the API client.
    ///
    /// Use this method to inspect the current configuration settings,
    /// including the base URL, API key, timeout, and custom headers.
    ///
    /// - Returns: The current `CarespaceConfiguration` instance.
    ///
    /// ## Example
    /// ```swift
    /// let config = api.getConfiguration()
    /// print("Base URL: \(config.baseURL)")
    /// print("Timeout: \(config.timeout) seconds")
    /// ```
    public func getConfiguration() -> CarespaceConfiguration {
        return configuration
    }
}

// MARK: - Convenience Initializers

public extension CarespaceAPI {
    /// Initializes a new Carespace API client with only an API key.
    ///
    /// This convenience initializer creates a client with default configuration
    /// settings and the specified API key.
    ///
    /// - Parameter apiKey: The API key for authentication.
    ///
    /// ## Example
    /// ```swift
    /// let api = CarespaceAPI(apiKey: "your-api-key")
    /// ```
    ///
    /// - Note: Uses the default base URL: `https://api-dev.carespace.ai`
    convenience init(apiKey: String) {
        var config = CarespaceConfiguration()
        config.setAPIKey(apiKey)
        self.init(configuration: config)
    }
    
    /// Initializes a new Carespace API client with a custom base URL and API key.
    ///
    /// Use this initializer when connecting to custom Carespace instances or
    /// different environments (staging, production, etc.).
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for all API requests. Must be a valid HTTPS URL.
    ///   - apiKey: The API key for authentication.
    ///
    /// ## Example
    /// ```swift
    /// let productionURL = URL(string: "https://api.carespace.ai")!
    /// let api = CarespaceAPI(baseURL: productionURL, apiKey: "your-api-key")
    /// ```
    convenience init(baseURL: URL, apiKey: String) {
        let config = CarespaceConfiguration(
            baseURL: baseURL,
            apiKey: apiKey
        )
        self.init(configuration: config)
    }
}

// MARK: - Shared Instance (Optional)

public extension CarespaceAPI {
    /// A shared singleton instance of the Carespace API client.
    ///
    /// The shared instance provides a convenient way to access the API client
    /// throughout your application without passing references.
    ///
    /// ## Usage
    /// ```swift
    /// // Configure the shared instance once
    /// CarespaceAPI.shared.setAPIKey("your-api-key")
    ///
    /// // Use it anywhere in your app
    /// let users = try await CarespaceAPI.shared.users.list()
    /// ```
    ///
    /// - Warning: You must configure the shared instance with an API key before
    ///   using it for authenticated requests. Attempting to use it without
    ///   configuration will result in authentication errors.
    ///
    /// - Note: If you need multiple API clients with different configurations,
    ///   create separate instances instead of using the shared instance.
    static let shared = CarespaceAPI()
}