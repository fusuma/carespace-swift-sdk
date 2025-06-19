# Carespace Swift SDK

A modern Swift SDK for the Carespace API with async/await support, designed for iOS, macOS, tvOS, and watchOS applications.

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/carespace/swift-sdk.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version and add to your target

## Quick Start

### Basic Setup

```swift
import CarespaceSDK

// Initialize with configuration
let config = CarespaceConfiguration(
    baseURL: URL(string: "https://api.carespace.ai")!,
    apiKey: "your-api-key"
)
let carespace = CarespaceAPI(configuration: config)

// Or use convenience initializers
let carespace = CarespaceAPI(apiKey: "your-api-key")
let carespace = CarespaceAPI(baseURL: baseURL, apiKey: "your-api-key")

// Or use the shared instance
CarespaceAPI.shared.setAPIKey("your-api-key")
```

## Usage Examples

### Authentication

```swift
// Login
do {
    let loginRequest = LoginRequest(email: "user@example.com", password: "password")
    let loginResponse = try await carespace.auth.login(loginRequest)
    
    // Set the received token
    carespace.setAPIKey(loginResponse.accessToken)
    
    print("Logged in successfully!")
} catch {
    print("Login failed: \\(error.localizedDescription)")
}

// Logout
do {
    try await carespace.auth.logout()
    print("Logged out successfully!")
} catch {
    print("Logout failed: \\(error.localizedDescription)")
}

// Password reset
do {
    let request = ForgotPasswordRequest(email: "user@example.com")
    let response = try await carespace.auth.forgotPassword(request)
    print(response.message)
} catch {
    print("Password reset failed: \\(error.localizedDescription)")
}
```

### Working with Users

```swift
// Get all users with pagination
do {
    let parameters = PaginationParameters(page: 1, limit: 20, search: "john")
    let response = try await carespace.users.getUsers(parameters)
    
    print("Found \\(response.total) users")
    for user in response.data {
        print("User: \\(user.name ?? user.email)")
    }
} catch {
    print("Failed to fetch users: \\(error.localizedDescription)")
}

// Get specific user
do {
    let user = try await carespace.users.getUser("user-id")
    print("User: \\(user.name ?? user.email)")
} catch {
    print("Failed to fetch user: \\(error.localizedDescription)")
}

// Create user
do {
    let request = CreateUserRequest(
        email: "newuser@example.com",
        name: "John Doe",
        firstName: "John",
        lastName: "Doe"
    )
    let user = try await carespace.users.createUser(request)
    print("Created user: \\(user.id)")
} catch {
    print("Failed to create user: \\(error.localizedDescription)")
}

// Update user profile
do {
    let request = UpdateProfileRequest(
        name: "Jane Doe",
        firstName: "Jane",
        lastName: "Doe"
    )
    let profile = try await carespace.users.updateUserProfile(request)
    print("Updated profile: \\(profile.name ?? profile.email)")
} catch {
    print("Failed to update profile: \\(error.localizedDescription)")
}
```

### Working with Clients

```swift
// Get all clients
do {
    let parameters = PaginationParameters(page: 1, limit: 10)
    let response = try await carespace.clients.getClients(parameters)
    
    for client in response.data {
        print("Client: \\(client.name)")
    }
} catch {
    print("Failed to fetch clients: \\(error.localizedDescription)")
}

// Create client
do {
    let address = Address(
        street: "123 Main St",
        city: "New York",
        state: "NY",
        zipCode: "10001",
        country: "USA"
    )
    
    let request = CreateClientRequest(
        name: "John Smith",
        email: "john.smith@example.com",
        phone: "+1234567890",
        dateOfBirth: Date(),
        address: address
    )
    
    let client = try await carespace.clients.createClient(request)
    print("Created client: \\(client.id)")
} catch {
    print("Failed to create client: \\(error.localizedDescription)")
}

// Get client statistics
do {
    let stats = try await carespace.clients.getClientStats("client-id")
    print("Total sessions: \\(stats.totalSessions)")
    print("Completed exercises: \\(stats.completedExercises)")
} catch {
    print("Failed to fetch client stats: \\(error.localizedDescription)")
}

// Assign program to client
do {
    let request = AssignProgramRequest(
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
        notes: "Rehabilitation program for knee injury"
    )
    
    try await carespace.clients.assignProgramToClient("client-id", "program-id", request)
    print("Program assigned successfully!")
} catch {
    print("Failed to assign program: \\(error.localizedDescription)")
}
```

### Working with Programs

```swift
// Get all programs
do {
    let parameters = PaginationParameters(page: 1, limit: 20)
    let response = try await carespace.programs.getPrograms(parameters)
    
    for program in response.data {
        print("Program: \\(program.name)")
        print("Duration: \\(program.duration ?? 0) minutes")
    }
} catch {
    print("Failed to fetch programs: \\(error.localizedDescription)")
}

// Create program
do {
    let request = CreateProgramRequest(
        name: "Knee Rehabilitation",
        description: "Post-surgery knee rehabilitation program",
        category: "Rehabilitation",
        difficulty: "Intermediate",
        duration: 45
    )
    
    let program = try await carespace.programs.createProgram(request)
    print("Created program: \\(program.id)")
} catch {
    print("Failed to create program: \\(error.localizedDescription)")
}

// Add exercise to program
do {
    let request = CreateExerciseRequest(
        name: "Knee Flexion",
        description: "Gentle knee bending exercise",
        instructions: "Slowly bend your knee to 90 degrees",
        duration: 30,
        repetitions: 10,
        sets: 3,
        restTime: 60
    )
    
    let exercise = try await carespace.programs.addExerciseToProgram("program-id", request)
    print("Added exercise: \\(exercise.name)")
} catch {
    print("Failed to add exercise: \\(error.localizedDescription)")
}

// Duplicate program
do {
    let request = DuplicateProgramRequest(
        name: "Knee Rehabilitation - Advanced",
        copyExercises: true
    )
    
    let duplicated = try await carespace.programs.duplicateProgram("program-id", request)
    print("Duplicated program: \\(duplicated.id)")
} catch {
    print("Failed to duplicate program: \\(error.localizedDescription)")
}
```

## Error Handling

The SDK provides comprehensive error handling with the `CarespaceError` enum:

```swift
do {
    let user = try await carespace.users.getUser("invalid-id")
} catch let error as CarespaceError {
    switch error {
    case .authenticationFailed:
        print("Please log in again")
    case .httpError(let statusCode, let message):
        print("HTTP \\(statusCode): \\(message ?? "Unknown error")")
    case .networkError(let underlyingError):
        print("Network error: \\(underlyingError.localizedDescription)")
    case .decodingError(let underlyingError):
        print("Data parsing error: \\(underlyingError.localizedDescription)")
    case .timeout:
        print("Request timed out")
    default:
        print("Unknown error: \\(error.localizedDescription)")
    }
} catch {
    print("Unexpected error: \\(error.localizedDescription)")
}
```

## SwiftUI Integration

The SDK works seamlessly with SwiftUI and the `@MainActor`:

```swift
import SwiftUI
import CarespaceSDK

struct ContentView: View {
    @State private var users: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let carespace = CarespaceAPI.shared
    
    var body: some View {
        NavigationView {
            List(users) { user in
                Text(user.name ?? user.email)
            }
            .navigationTitle("Users")
            .task {
                await loadUsers()
            }
        }
    }
    
    @MainActor
    private func loadUsers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await carespace.users.getUsers()
            users = response.data
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

## Configuration Options

### CarespaceConfiguration

```swift
let config = CarespaceConfiguration(
    baseURL: URL(string: "https://api.carespace.ai")!,
    apiKey: "your-api-key",
    timeout: 30.0, // Request timeout in seconds
    additionalHeaders: [
        "X-Custom-Header": "custom-value"
    ]
)
```

### Environment-specific URLs

```swift
// Development
let devConfig = CarespaceConfiguration(
    baseURL: URL(string: "https://api-dev.carespace.ai")!
)

// Production
let prodConfig = CarespaceConfiguration(
    baseURL: URL(string: "https://api.carespace.ai")!
)
```

## Thread Safety

The SDK is designed to be thread-safe and can be used from any queue. All network operations are performed asynchronously and return to the caller's queue.

## Testing

The SDK includes comprehensive unit tests. To run tests:

```bash
swift test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This SDK is released under the MIT License. See LICENSE file for details.

## Support

For support, please contact support@carespace.ai or create an issue on GitHub.