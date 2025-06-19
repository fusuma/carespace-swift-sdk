import Foundation

/// Main Carespace API client
public class CarespaceAPI {
    private let httpClient: HTTPClient
    private var configuration: CarespaceConfiguration
    
    /// Authentication API
    public let auth: AuthAPI
    
    /// Users API
    public let users: UsersAPI
    
    /// Clients API
    public let clients: ClientsAPI
    
    /// Programs API
    public let programs: ProgramsAPI
    
    /// Initialize Carespace API client
    /// - Parameter configuration: SDK configuration
    public init(configuration: CarespaceConfiguration = CarespaceConfiguration()) {
        self.configuration = configuration
        self.httpClient = HTTPClient(configuration: configuration)
        
        // Initialize API endpoints
        self.auth = AuthAPI(httpClient: httpClient)
        self.users = UsersAPI(httpClient: httpClient)
        self.clients = ClientsAPI(httpClient: httpClient)
        self.programs = ProgramsAPI(httpClient: httpClient)
    }
    
    /// Set API key for authentication
    /// - Parameter apiKey: API key
    public func setAPIKey(_ apiKey: String) {
        configuration.setAPIKey(apiKey)
        httpClient.setAPIKey(apiKey)
    }
    
    /// Get current configuration
    /// - Returns: Current configuration
    public func getConfiguration() -> CarespaceConfiguration {
        return configuration
    }
}

// MARK: - Convenience Initializers

public extension CarespaceAPI {
    /// Initialize with API key
    /// - Parameter apiKey: API key
    convenience init(apiKey: String) {
        var config = CarespaceConfiguration()
        config.setAPIKey(apiKey)
        self.init(configuration: config)
    }
    
    /// Initialize with base URL and API key
    /// - Parameters:
    ///   - baseURL: Base URL for API
    ///   - apiKey: API key
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
    /// Shared instance for singleton pattern usage
    /// - Note: You must configure this instance before using it
    static let shared = CarespaceAPI()
}