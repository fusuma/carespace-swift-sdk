# Carespace Swift SDK - Code Examples

This document provides practical examples for common use cases with the Carespace Swift SDK.

## Table of Contents

- [Getting Started](#getting-started)
- [Authentication Flows](#authentication-flows)
- [User Management](#user-management)
- [Client Management](#client-management)
- [Program Management](#program-management)
- [Error Handling](#error-handling)
- [SwiftUI Integration](#swiftui-integration)
- [Best Practices](#best-practices)

---

## Getting Started

### Basic Setup

```swift
import CarespaceSDK

// Option 1: Using the shared instance
CarespaceAPI.shared.setAPIKey("your-api-key")

// Option 2: Creating a dedicated instance
let api = CarespaceAPI(apiKey: "your-api-key")

// Option 3: Custom configuration
let config = CarespaceConfiguration(
    baseURL: URL(string: "https://api.carespace.ai")!,
    apiKey: "your-api-key",
    timeout: 60.0,
    additionalHeaders: ["X-App-Version": "1.0.0"]
)
let api = CarespaceAPI(configuration: config)
```

### Environment-Based Configuration

```swift
import CarespaceSDK

struct APIManager {
    static let shared = APIManager()
    let carespace: CarespaceAPI
    
    private init() {
        #if DEBUG
        let baseURL = URL(string: "https://api-dev.carespace.ai")!
        let apiKey = ProcessInfo.processInfo.environment["DEV_API_KEY"] ?? ""
        #else
        let baseURL = URL(string: "https://api.carespace.ai")!
        let apiKey = ProcessInfo.processInfo.environment["PROD_API_KEY"] ?? ""
        #endif
        
        self.carespace = CarespaceAPI(baseURL: baseURL, apiKey: apiKey)
    }
}
```

---

## Authentication Flows

### Complete Login Flow with Error Handling

```swift
import CarespaceSDK

class AuthenticationManager {
    private let api = CarespaceAPI.shared
    
    func login(email: String, password: String) async throws -> User {
        do {
            // Step 1: Perform login
            let loginRequest = LoginRequest(email: email, password: password)
            let loginResponse = try await api.auth.login(loginRequest)
            
            // Step 2: Store tokens securely
            try KeychainManager.shared.store(
                accessToken: loginResponse.accessToken,
                refreshToken: loginResponse.refreshToken
            )
            
            // Step 3: Configure API with access token
            api.setAPIKey(loginResponse.accessToken)
            
            // Step 4: Return user info
            guard let user = loginResponse.user else {
                throw CarespaceError.noData
            }
            
            return user
        } catch CarespaceError.httpError(let statusCode, let message) {
            switch statusCode {
            case 401:
                throw AuthError.invalidCredentials
            case 423:
                throw AuthError.accountLocked
            default:
                throw AuthError.loginFailed(message ?? "Unknown error")
            }
        } catch {
            throw error
        }
    }
}
```

### Token Refresh Implementation

```swift
class TokenManager {
    private let api = CarespaceAPI.shared
    private var refreshTask: Task<String, Error>?
    
    func refreshTokenIfNeeded() async throws -> String {
        // Prevent multiple simultaneous refresh attempts
        if let existingTask = refreshTask {
            return try await existingTask.value
        }
        
        let task = Task { () -> String in
            defer { refreshTask = nil }
            
            guard let refreshToken = try? KeychainManager.shared.getRefreshToken() else {
                throw AuthError.noRefreshToken
            }
            
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let response = try await api.auth.refreshToken(request)
            
            // Update stored tokens
            try KeychainManager.shared.store(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
            
            // Update API configuration
            api.setAPIKey(response.accessToken)
            
            return response.accessToken
        }
        
        refreshTask = task
        return try await task.value
    }
}
```

### Password Reset Flow

```swift
class PasswordResetManager {
    private let api = CarespaceAPI.shared
    
    func initiatePasswordReset(email: String) async throws {
        let request = ForgotPasswordRequest(email: email)
        let response = try await api.auth.forgotPassword(request)
        print("Reset email sent: \(response.message)")
    }
    
    func completePasswordReset(token: String, newPassword: String) async throws {
        let request = ResetPasswordRequest(
            token: token,
            password: newPassword
        )
        let response = try await api.auth.resetPassword(request)
        print("Password reset successful: \(response.message)")
    }
}
```

---

## User Management

### User Search with Pagination

```swift
class UserSearchViewController: UIViewController {
    private let api = CarespaceAPI.shared
    private var users: [User] = []
    private var currentPage = 1
    private var hasMorePages = true
    
    func searchUsers(query: String) async {
        currentPage = 1
        users.removeAll()
        await loadMoreUsers(query: query)
    }
    
    func loadMoreUsers(query: String) async {
        guard hasMorePages else { return }
        
        do {
            let parameters = PaginationParameters(
                page: currentPage,
                limit: 20,
                search: query,
                sortBy: "name",
                sortOrder: "asc"
            )
            
            let response = try await api.users.list(parameters)
            
            users.append(contentsOf: response.data)
            hasMorePages = currentPage < response.totalPages
            currentPage += 1
            
            await MainActor.run {
                tableView.reloadData()
            }
        } catch {
            await showError(error)
        }
    }
}
```

### Batch User Operations

```swift
class UserBatchOperations {
    private let api = CarespaceAPI.shared
    
    func createMultipleUsers(_ userData: [(email: String, name: String)]) async throws -> [User] {
        return try await withThrowingTaskGroup(of: User.self) { group in
            for (email, name) in userData {
                group.addTask {
                    let request = CreateUserRequest(
                        email: email,
                        name: name
                    )
                    return try await self.api.users.create(request)
                }
            }
            
            var users: [User] = []
            for try await user in group {
                users.append(user)
            }
            return users
        }
    }
}
```

---

## Client Management

### Client Profile with Statistics

```swift
struct ClientProfile {
    let client: Client
    let stats: ClientStats
    let activePrograms: [ClientProgram]
}

class ClientManager {
    private let api = CarespaceAPI.shared
    
    func loadCompleteProfile(clientId: String) async throws -> ClientProfile {
        async let client = api.clients.get(clientId)
        async let stats = api.clients.getStats(clientId)
        async let programs = api.clients.getPrograms(
            clientId,
            parameters: PaginationParameters(
                limit: 10,
                sortBy: "startDate",
                sortOrder: "desc"
            )
        )
        
        let (clientData, statsData, programsData) = try await (client, stats, programs)
        
        let activePrograms = programsData.data.filter { program in
            guard let endDate = program.endDate else { return true }
            return endDate > Date()
        }
        
        return ClientProfile(
            client: clientData,
            stats: statsData,
            activePrograms: activePrograms
        )
    }
}
```

### Client Import from CSV

```swift
class ClientImporter {
    private let api = CarespaceAPI.shared
    
    struct ImportResult {
        let successful: [Client]
        let failed: [(data: CreateClientRequest, error: Error)]
    }
    
    func importClients(from csvData: String) async -> ImportResult {
        let rows = parseCSV(csvData)
        var successful: [Client] = []
        var failed: [(CreateClientRequest, Error)] = []
        
        for row in rows {
            let request = CreateClientRequest(
                name: row["name"] ?? "",
                email: row["email"],
                phone: row["phone"],
                dateOfBirth: parseDate(row["dateOfBirth"]),
                address: parseAddress(row),
                notes: row["notes"],
                tags: parseTags(row["tags"])
            )
            
            do {
                let client = try await api.clients.create(request)
                successful.append(client)
            } catch {
                failed.append((request, error))
            }
        }
        
        return ImportResult(successful: successful, failed: failed)
    }
}
```

---

## Program Management

### Program Builder

```swift
class ProgramBuilder {
    private let api = CarespaceAPI.shared
    private var program: Program?
    private var exercises: [Exercise] = []
    
    func createProgram(
        name: String,
        description: String,
        category: String,
        difficulty: String
    ) async throws {
        let request = CreateProgramRequest(
            name: name,
            description: description,
            category: category,
            difficulty: difficulty,
            isPublic: false
        )
        
        program = try await api.programs.create(request)
    }
    
    func addExercise(
        name: String,
        instructions: String,
        duration: Int,
        sets: Int,
        reps: Int
    ) async throws {
        guard let programId = program?.id else {
            throw ProgramError.noProgramCreated
        }
        
        let request = CreateExerciseRequest(
            name: name,
            instructions: instructions,
            duration: duration,
            sets: sets,
            repetitions: reps,
            order: exercises.count + 1
        )
        
        let exercise = try await api.programs.addExercise(programId, request: request)
        exercises.append(exercise)
    }
    
    func publish() async throws -> Program {
        guard let programId = program?.id else {
            throw ProgramError.noProgramCreated
        }
        
        let request = UpdateProgramRequest(isPublic: true)
        return try await api.programs.update(programId, request: request)
    }
}
```

### Program Templates

```swift
class ProgramTemplateManager {
    private let api = CarespaceAPI.shared
    
    func createFromTemplate(
        templateId: String,
        clientId: String,
        customizations: [String: Any]
    ) async throws -> ClientProgram {
        // Step 1: Duplicate the template
        let duplicateRequest = DuplicateProgramRequest(
            name: "\(customizations["name"] ?? "Custom Program")",
            copyExercises: true
        )
        let newProgram = try await api.programs.duplicate(templateId, request: duplicateRequest)
        
        // Step 2: Customize the program
        if let duration = customizations["duration"] as? Int {
            let updateRequest = UpdateProgramRequest(duration: duration)
            _ = try await api.programs.update(newProgram.id, request: updateRequest)
        }
        
        // Step 3: Assign to client
        let assignRequest = AssignProgramRequest(
            startDate: customizations["startDate"] as? Date ?? Date(),
            endDate: customizations["endDate"] as? Date,
            notes: customizations["notes"] as? String
        )
        
        return try await api.clients.assignProgram(
            clientId,
            programId: newProgram.id,
            request: assignRequest
        )
    }
}
```

---

## Error Handling

### Comprehensive Error Handler

```swift
class ErrorHandler {
    static func handle(_ error: Error, in viewController: UIViewController) {
        let alert: UIAlertController
        
        switch error {
        case CarespaceError.authenticationFailed:
            alert = createAlert(
                title: "Authentication Required",
                message: "Please log in to continue.",
                actions: [
                    UIAlertAction(title: "Log In", style: .default) { _ in
                        viewController.presentLoginScreen()
                    }
                ]
            )
            
        case CarespaceError.httpError(let statusCode, let message):
            let title = HTTPStatusCodeHelper.title(for: statusCode)
            alert = createAlert(
                title: title,
                message: message ?? "An error occurred.",
                actions: [UIAlertAction(title: "OK", style: .default)]
            )
            
        case CarespaceError.timeout:
            alert = createAlert(
                title: "Request Timeout",
                message: "The server took too long to respond. Please try again.",
                actions: [
                    UIAlertAction(title: "Retry", style: .default) { _ in
                        viewController.retryLastAction()
                    },
                    UIAlertAction(title: "Cancel", style: .cancel)
                ]
            )
            
        case CarespaceError.networkError:
            alert = createAlert(
                title: "Network Error",
                message: "Please check your internet connection and try again.",
                actions: [UIAlertAction(title: "OK", style: .default)]
            )
            
        default:
            alert = createAlert(
                title: "Error",
                message: error.localizedDescription,
                actions: [UIAlertAction(title: "OK", style: .default)]
            )
        }
        
        viewController.present(alert, animated: true)
    }
}
```

### Retry Logic

```swift
class NetworkRetryHandler {
    static func withRetry<T>(
        maxAttempts: Int = 3,
        delay: TimeInterval = 1.0,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch CarespaceError.timeout, CarespaceError.networkError {
                lastError = error
                if attempt < maxAttempts {
                    try await Task.sleep(nanoseconds: UInt64(delay * Double(attempt) * 1_000_000_000))
                }
            } catch {
                throw error
            }
        }
        
        throw lastError ?? CarespaceError.networkError(NSError())
    }
}

// Usage
let users = try await NetworkRetryHandler.withRetry {
    try await api.users.list()
}
```

---

## SwiftUI Integration

### Observable API Wrapper

```swift
@MainActor
class CarespaceStore: ObservableObject {
    @Published var users: [User] = []
    @Published var clients: [Client] = []
    @Published var programs: [Program] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let api = CarespaceAPI.shared
    
    func loadUsers() async {
        isLoading = true
        error = nil
        
        do {
            let response = try await api.users.list()
            users = response.data
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func createClient(name: String, email: String) async {
        isLoading = true
        error = nil
        
        do {
            let request = CreateClientRequest(name: name, email: email)
            let client = try await api.clients.create(request)
            clients.append(client)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
```

### SwiftUI Views with Error Handling

```swift
struct ClientListView: View {
    @StateObject private var store = CarespaceStore()
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.clients) { client in
                    NavigationLink(destination: ClientDetailView(client: client)) {
                        ClientRow(client: client)
                    }
                }
            }
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        // Show add client sheet
                    }
                }
            }
            .task {
                await store.loadClients()
            }
            .refreshable {
                await store.loadClients()
            }
            .alert("Error", isPresented: $showingError, presenting: store.error) { _ in
                Button("OK") { }
            } message: { error in
                Text(error.localizedDescription)
            }
            .onChange(of: store.error) { error in
                showingError = error != nil
            }
        }
    }
}
```

### Async Image Loading

```swift
struct UserAvatarView: View {
    let user: User
    @State private var avatarImage: UIImage?
    
    var body: some View {
        Group {
            if let image = avatarImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ProgressView()
            }
        }
        .frame(width: 50, height: 50)
        .clipShape(Circle())
        .task {
            await loadAvatar()
        }
    }
    
    private func loadAvatar() async {
        guard let avatarURL = user.avatar,
              let url = URL(string: avatarURL) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            avatarImage = UIImage(data: data)
        } catch {
            // Use placeholder
        }
    }
}
```

---

## Best Practices

### 1. API Client Management

```swift
// DO: Create a single instance and reuse it
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let api = CarespaceAPI(apiKey: "your-api-key")
}

// DON'T: Create new instances for each request
func badExample() async {
    let api = CarespaceAPI(apiKey: "key") // Don't do this repeatedly
    let users = try await api.users.list()
}
```

### 2. Concurrent Operations

```swift
// DO: Use async let for parallel operations
func loadDashboardData() async throws -> DashboardData {
    async let users = api.users.list(PaginationParameters(limit: 5))
    async let clients = api.clients.list(PaginationParameters(limit: 5))
    async let programs = api.programs.list(PaginationParameters(limit: 5))
    
    let (usersData, clientsData, programsData) = try await (users, clients, programs)
    
    return DashboardData(
        recentUsers: usersData.data,
        recentClients: clientsData.data,
        recentPrograms: programsData.data
    )
}
```

### 3. Token Management

```swift
// DO: Implement proper token storage and refresh
class SecureTokenManager {
    private let keychain = KeychainWrapper()
    
    func storeTokens(_ response: LoginResponse) throws {
        try keychain.set(response.accessToken, forKey: "access_token")
        try keychain.set(response.refreshToken, forKey: "refresh_token")
        
        // Store expiration time
        let expirationDate = Date().addingTimeInterval(TimeInterval(response.expiresIn))
        UserDefaults.standard.set(expirationDate, forKey: "token_expiration")
    }
    
    func isTokenExpired() -> Bool {
        guard let expiration = UserDefaults.standard.object(forKey: "token_expiration") as? Date else {
            return true
        }
        return Date() >= expiration.addingTimeInterval(-300) // 5 minute buffer
    }
}
```

### 4. Error Recovery

```swift
// DO: Implement graceful error recovery
class APIRequestHandler {
    func performAuthenticatedRequest<T>(_ request: () async throws -> T) async throws -> T {
        do {
            return try await request()
        } catch CarespaceError.authenticationFailed {
            // Try to refresh token
            _ = try await TokenManager().refreshTokenIfNeeded()
            // Retry the request
            return try await request()
        } catch {
            throw error
        }
    }
}
```

### 5. Pagination Best Practices

```swift
// DO: Implement efficient pagination
class PaginatedDataLoader<T: Codable> {
    private var currentPage = 1
    private var hasMorePages = true
    private var isLoading = false
    var items: [T] = []
    
    func loadNextPage(
        using loader: (PaginationParameters) async throws -> PaginatedResponse<T>
    ) async throws {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let parameters = PaginationParameters(
            page: currentPage,
            limit: 20
        )
        
        let response = try await loader(parameters)
        items.append(contentsOf: response.data)
        hasMorePages = currentPage < response.totalPages
        currentPage += 1
    }
    
    func reset() {
        currentPage = 1
        hasMorePages = true
        items.removeAll()
    }
}
```