# Error Handling & Best Practices Guide

This guide provides comprehensive information about error handling strategies and best practices when using the Carespace Swift SDK.

## Table of Contents

- [Error Handling](#error-handling)
  - [Understanding CarespaceError](#understanding-carespaceerror)
  - [Error Types and Recovery](#error-types-and-recovery)
  - [Implementing Robust Error Handling](#implementing-robust-error-handling)
- [Best Practices](#best-practices)
  - [API Client Management](#api-client-management)
  - [Authentication & Security](#authentication--security)
  - [Performance Optimization](#performance-optimization)
  - [Memory Management](#memory-management)
  - [Testing Strategies](#testing-strategies)

---

## Error Handling

### Understanding CarespaceError

The SDK uses a comprehensive error enum that covers all possible failure scenarios:

```swift
public enum CarespaceError: Error, LocalizedError {
    case invalidURL                                    // Malformed URL
    case noData                                       // Empty response
    case decodingError(Error)                         // JSON decoding failed
    case encodingError(Error)                         // Request encoding failed
    case networkError(Error)                          // Network-level error
    case httpError(statusCode: Int, message: String?) // HTTP error response
    case authenticationFailed                         // 401 Unauthorized
    case timeout                                      // Request timeout
    case invalidResponse                              // Unexpected response format
    case missingAPIKey                               // No API key configured
}
```

### Error Types and Recovery

#### Authentication Errors

```swift
func handleAuthenticationError() async throws {
    do {
        let users = try await api.users.list()
    } catch CarespaceError.authenticationFailed {
        // Option 1: Refresh the token
        if let refreshToken = getStoredRefreshToken() {
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let response = try await api.auth.refreshToken(request)
            api.setAPIKey(response.accessToken)
            // Retry the original request
        } else {
            // Option 2: Redirect to login
            presentLoginScreen()
        }
    } catch CarespaceError.missingAPIKey {
        // API key was never set
        print("Please configure your API key")
    }
}
```

#### Network Errors

```swift
func handleNetworkErrors() async {
    do {
        let clients = try await api.clients.list()
    } catch CarespaceError.networkError(let underlyingError) {
        // Check for specific network conditions
        if (underlyingError as NSError).code == NSURLErrorNotConnectedToInternet {
            showOfflineAlert()
        } else if (underlyingError as NSError).code == NSURLErrorTimedOut {
            showTimeoutAlert()
        } else {
            showGenericNetworkError()
        }
    } catch CarespaceError.timeout {
        // Handle timeout specifically
        showTimeoutAlert(with: "The server is taking too long to respond")
    }
}
```

#### HTTP Errors

```swift
func handleHTTPErrors() async {
    do {
        let user = try await api.users.get("user-id")
    } catch CarespaceError.httpError(let statusCode, let message) {
        switch statusCode {
        case 400:
            print("Bad Request: \(message ?? "Invalid request parameters")")
        case 403:
            print("Forbidden: You don't have permission to access this resource")
        case 404:
            print("Not Found: The requested resource doesn't exist")
        case 429:
            print("Rate Limited: Too many requests. Please try again later")
        case 500...599:
            print("Server Error: Something went wrong on our end")
        default:
            print("HTTP Error \(statusCode): \(message ?? "Unknown error")")
        }
    }
}
```

#### Data Errors

```swift
func handleDataErrors() async {
    do {
        let programs = try await api.programs.list()
    } catch CarespaceError.decodingError(let error) {
        // Log the specific decoding error for debugging
        print("Failed to decode response: \(error)")
        
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, _):
                print("Missing key: \(key.stringValue)")
            case .typeMismatch(let type, _):
                print("Type mismatch for type: \(type)")
            case .valueNotFound(let type, _):
                print("Value not found for type: \(type)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context)")
            @unknown default:
                print("Unknown decoding error")
            }
        }
    } catch CarespaceError.noData {
        print("The server returned an empty response")
    }
}
```

### Implementing Robust Error Handling

#### Error Handler Protocol

```swift
protocol ErrorHandler {
    func handle(_ error: Error) async
}

class DefaultErrorHandler: ErrorHandler {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func handle(_ error: Error) async {
        guard let viewController = viewController else { return }
        
        let action = determineAction(for: error)
        
        await MainActor.run {
            switch action {
            case .showAlert(let title, let message):
                showAlert(title: title, message: message, in: viewController)
            case .retry(let operation):
                Task { try await operation() }
            case .logout:
                logoutUser()
            case .ignore:
                break
            }
        }
    }
    
    private func determineAction(for error: Error) -> ErrorAction {
        switch error {
        case CarespaceError.authenticationFailed:
            return .logout
        case CarespaceError.timeout, CarespaceError.networkError:
            return .retry { /* retry operation */ }
        case let carespaceError as CarespaceError:
            return .showAlert(
                title: "Error",
                message: carespaceError.localizedDescription
            )
        default:
            return .showAlert(
                title: "Unexpected Error",
                message: error.localizedDescription
            )
        }
    }
}

enum ErrorAction {
    case showAlert(title: String, message: String)
    case retry(() async throws -> Void)
    case logout
    case ignore
}
```

#### Retry Mechanism

```swift
class RetryManager {
    struct RetryConfiguration {
        let maxAttempts: Int
        let initialDelay: TimeInterval
        let maxDelay: TimeInterval
        let multiplier: Double
        
        static let `default` = RetryConfiguration(
            maxAttempts: 3,
            initialDelay: 1.0,
            maxDelay: 10.0,
            multiplier: 2.0
        )
    }
    
    static func retry<T>(
        configuration: RetryConfiguration = .default,
        shouldRetry: (Error) -> Bool = { _ in true },
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var currentDelay = configuration.initialDelay
        var lastError: Error?
        
        for attempt in 1...configuration.maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                guard attempt < configuration.maxAttempts,
                      shouldRetry(error) else {
                    throw error
                }
                
                // Exponential backoff with jitter
                let jitter = Double.random(in: 0.8...1.2)
                let delay = min(currentDelay * jitter, configuration.maxDelay)
                
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                currentDelay = min(currentDelay * configuration.multiplier, configuration.maxDelay)
            }
        }
        
        throw lastError ?? CarespaceError.networkError(NSError())
    }
}

// Usage
let users = try await RetryManager.retry(
    shouldRetry: { error in
        // Only retry network and timeout errors
        if case CarespaceError.networkError = error { return true }
        if case CarespaceError.timeout = error { return true }
        return false
    }
) {
    try await api.users.list()
}
```

---

## Best Practices

### API Client Management

#### Singleton vs Instance

```swift
// GOOD: Shared instance for app-wide configuration
extension CarespaceAPI {
    static let configured: CarespaceAPI = {
        let config = CarespaceConfiguration(
            baseURL: AppConfig.apiBaseURL,
            apiKey: AppConfig.apiKey,
            timeout: 30.0
        )
        return CarespaceAPI(configuration: config)
    }()
}

// GOOD: Separate instances for different contexts
class MultiTenantManager {
    private var apiClients: [String: CarespaceAPI] = [:]
    
    func client(for tenant: String) -> CarespaceAPI {
        if let existing = apiClients[tenant] {
            return existing
        }
        
        let config = CarespaceConfiguration(
            baseURL: URL(string: "https://\(tenant).carespace.ai")!,
            apiKey: getAPIKey(for: tenant)
        )
        let client = CarespaceAPI(configuration: config)
        apiClients[tenant] = client
        return client
    }
}
```

#### Configuration Management

```swift
// GOOD: Environment-based configuration
struct APIConfiguration {
    static var current: CarespaceConfiguration {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }
}

extension CarespaceConfiguration {
    static let development = CarespaceConfiguration(
        baseURL: URL(string: "https://api-dev.carespace.ai")!,
        timeout: 60.0 // Longer timeout for development
    )
    
    static let staging = CarespaceConfiguration(
        baseURL: URL(string: "https://api-staging.carespace.ai")!,
        timeout: 45.0
    )
    
    static let production = CarespaceConfiguration(
        baseURL: URL(string: "https://api.carespace.ai")!,
        timeout: 30.0
    )
}
```

### Authentication & Security

#### Secure Token Storage

```swift
// GOOD: Use Keychain for sensitive data
import Security

class KeychainTokenStorage {
    private let service = "com.yourapp.carespace"
    
    func store(accessToken: String, refreshToken: String) throws {
        try store(accessToken, for: "access_token")
        try store(refreshToken, for: "refresh_token")
    }
    
    private func store(_ value: String, for key: String) throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary) // Delete existing
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.storeFailed(status)
        }
    }
}

// BAD: Don't store tokens in UserDefaults
class InsecureTokenStorage {
    func storeTokens(_ tokens: LoginResponse) {
        // DON'T DO THIS
        UserDefaults.standard.set(tokens.accessToken, forKey: "access_token")
        UserDefaults.standard.set(tokens.refreshToken, forKey: "refresh_token")
    }
}
```

#### Token Lifecycle Management

```swift
class TokenLifecycleManager {
    private let api: CarespaceAPI
    private let storage: KeychainTokenStorage
    private var refreshTimer: Timer?
    
    init(api: CarespaceAPI, storage: KeychainTokenStorage) {
        self.api = api
        self.storage = storage
    }
    
    func startTokenRefreshCycle(expiresIn: Int) {
        // Refresh 5 minutes before expiration
        let refreshInterval = TimeInterval(expiresIn - 300)
        
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: refreshInterval,
            repeats: false
        ) { [weak self] _ in
            Task {
                try await self?.refreshToken()
            }
        }
    }
    
    func refreshToken() async throws {
        guard let refreshToken = try? storage.getRefreshToken() else {
            throw AuthError.noRefreshToken
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let response = try await api.auth.refreshToken(request)
        
        try storage.store(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        api.setAPIKey(response.accessToken)
        startTokenRefreshCycle(expiresIn: response.expiresIn)
    }
}
```

### Performance Optimization

#### Efficient Data Loading

```swift
// GOOD: Load data in parallel
func loadDashboard() async throws -> Dashboard {
    async let stats = api.users.getStats()
    async let recentUsers = api.users.list(PaginationParameters(limit: 5))
    async let activeClients = api.clients.list(
        PaginationParameters(
            limit: 10,
            filters: ["status": "active"]
        )
    )
    
    return try await Dashboard(
        stats: stats,
        recentUsers: recentUsers.data,
        activeClients: activeClients.data
    )
}

// BAD: Sequential loading
func loadDashboardBad() async throws -> Dashboard {
    let stats = try await api.users.getStats()
    let recentUsers = try await api.users.list(PaginationParameters(limit: 5))
    let activeClients = try await api.clients.list(
        PaginationParameters(
            limit: 10,
            filters: ["status": "active"]
        )
    )
    
    return Dashboard(
        stats: stats,
        recentUsers: recentUsers.data,
        activeClients: activeClients.data
    )
}
```

#### Caching Strategy

```swift
actor CacheManager<Key: Hashable, Value> {
    private var cache: [Key: CacheEntry<Value>] = [:]
    private let ttl: TimeInterval
    
    struct CacheEntry<T> {
        let value: T
        let timestamp: Date
    }
    
    init(ttl: TimeInterval = 300) { // 5 minutes default
        self.ttl = ttl
    }
    
    func get(_ key: Key) -> Value? {
        guard let entry = cache[key] else { return nil }
        
        if Date().timeIntervalSince(entry.timestamp) > ttl {
            cache.removeValue(forKey: key)
            return nil
        }
        
        return entry.value
    }
    
    func set(_ key: Key, value: Value) {
        cache[key] = CacheEntry(value: value, timestamp: Date())
    }
    
    func clear() {
        cache.removeAll()
    }
}

// Usage with API
class CachedUserService {
    private let api: CarespaceAPI
    private let cache = CacheManager<String, User>(ttl: 600) // 10 minutes
    
    init(api: CarespaceAPI) {
        self.api = api
    }
    
    func getUser(_ id: String) async throws -> User {
        if let cached = await cache.get(id) {
            return cached
        }
        
        let user = try await api.users.get(id)
        await cache.set(id, value: user)
        return user
    }
}
```

### Memory Management

#### Weak References in Closures

```swift
// GOOD: Prevent retain cycles
class UserListViewModel {
    private let api = CarespaceAPI.shared
    private var loadTask: Task<Void, Never>?
    
    func loadUsers() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let response = try await self.api.users.list()
                await MainActor.run { [weak self] in
                    self?.users = response.data
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.handleError(error)
                }
            }
        }
    }
    
    deinit {
        loadTask?.cancel()
    }
}
```

#### Image Loading and Caching

```swift
actor ImageCache {
    private let cache = NSCache<NSString, UIImage>()
    private var loadingTasks: [URL: Task<UIImage?, Never>] = [:]
    
    init() {
        cache.countLimit = 100
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }
    
    func image(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString
        
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        if let existingTask = loadingTasks[url] {
            return await existingTask.value
        }
        
        let task = Task<UIImage?, Never> {
            guard let image = await downloadImage(from: url) else {
                return nil
            }
            
            cache.setObject(image, forKey: key, cost: image.jpegData(compressionQuality: 1.0)?.count ?? 0)
            return image
        }
        
        loadingTasks[url] = task
        let image = await task.value
        loadingTasks.removeValue(forKey: url)
        
        return image
    }
    
    private func downloadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
}
```

### Testing Strategies

#### Mock API Client

```swift
class MockCarespaceAPI: CarespaceAPI {
    var mockUsers: [User] = []
    var mockError: Error?
    var requestCount = 0
    
    override func users.list(_ parameters: PaginationParameters) async throws -> PaginatedResponse<User> {
        requestCount += 1
        
        if let error = mockError {
            throw error
        }
        
        return PaginatedResponse(
            data: mockUsers,
            total: mockUsers.count,
            page: parameters.page ?? 1,
            limit: parameters.limit ?? 20,
            totalPages: 1
        )
    }
}

// Usage in tests
func testUserLoading() async throws {
    let mockAPI = MockCarespaceAPI()
    mockAPI.mockUsers = [
        User(id: "1", email: "test@example.com", name: "Test User")
    ]
    
    let viewModel = UserListViewModel(api: mockAPI)
    await viewModel.loadUsers()
    
    XCTAssertEqual(viewModel.users.count, 1)
    XCTAssertEqual(mockAPI.requestCount, 1)
}
```

#### Testing Error Scenarios

```swift
func testErrorHandling() async {
    let mockAPI = MockCarespaceAPI()
    let testCases: [(Error, String)] = [
        (CarespaceError.authenticationFailed, "Authentication required"),
        (CarespaceError.timeout, "Request timed out"),
        (CarespaceError.httpError(statusCode: 404, message: "Not found"), "Resource not found")
    ]
    
    for (error, expectedMessage) in testCases {
        mockAPI.mockError = error
        
        let viewModel = UserListViewModel(api: mockAPI)
        await viewModel.loadUsers()
        
        XCTAssertEqual(viewModel.errorMessage, expectedMessage)
    }
}
```

#### Integration Tests

```swift
class CarespaceAPIIntegrationTests: XCTestCase {
    var api: CarespaceAPI!
    
    override func setUp() {
        super.setUp()
        
        // Use test configuration
        let config = CarespaceConfiguration(
            baseURL: URL(string: "https://api-test.carespace.ai")!,
            apiKey: ProcessInfo.processInfo.environment["TEST_API_KEY"] ?? ""
        )
        api = CarespaceAPI(configuration: config)
    }
    
    func testFullAuthenticationFlow() async throws {
        // 1. Login
        let loginRequest = LoginRequest(
            email: "test@example.com",
            password: "testpassword"
        )
        let loginResponse = try await api.auth.login(loginRequest)
        
        XCTAssertFalse(loginResponse.accessToken.isEmpty)
        XCTAssertNotNil(loginResponse.user)
        
        // 2. Use access token
        api.setAPIKey(loginResponse.accessToken)
        
        // 3. Make authenticated request
        let user = try await api.users.getCurrentUser()
        XCTAssertEqual(user.email, "test@example.com")
        
        // 4. Logout
        try await api.auth.logout()
    }
}
```

---

## Summary

Following these error handling strategies and best practices will help you build robust, performant, and maintainable applications with the Carespace Swift SDK. Remember to:

1. **Handle errors gracefully** - Provide meaningful feedback to users
2. **Implement retry logic** - For transient network failures
3. **Secure sensitive data** - Use Keychain for tokens
4. **Optimize performance** - Use parallel loading and caching
5. **Test thoroughly** - Cover both success and failure scenarios
6. **Monitor and log** - Track errors in production for continuous improvement

For more examples and detailed API documentation, refer to the [API Reference](API-Reference.md) and [Examples](Examples.md) guides.