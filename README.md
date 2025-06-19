# Carespace Swift SDK

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-purple.svg)](https://docs.carespace.ai/swift-sdk)

A modern, type-safe Swift SDK for the Carespace API with full async/await support, comprehensive error handling, and seamless integration with Apple platforms.

## 🚀 Features

- **Modern Swift Concurrency**: Built with async/await for clean, efficient asynchronous code
- **Type Safety**: Strongly typed request/response models with Codable support
- **Comprehensive API Coverage**: Full access to authentication, users, clients, and programs endpoints
- **Error Handling**: Detailed error types with localized descriptions
- **Platform Support**: Universal framework supporting iOS, macOS, tvOS, and watchOS
- **SwiftUI Ready**: Designed to work seamlessly with SwiftUI and Combine
- **Customizable**: Flexible configuration options for different environments
- **Well Documented**: Extensive documentation with code examples

## 📋 Requirements

- **iOS** 13.0+ / **macOS** 10.15+ / **tvOS** 13.0+ / **watchOS** 6.0+
- **Xcode** 14.0+
- **Swift** 5.7+

## 📦 Installation

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

## 🏁 Quick Start

### Basic Setup

Get up and running in just a few lines of code:

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

## 📖 Usage Examples

### 🔐 Authentication

The SDK provides comprehensive authentication support including login, logout, password reset, and token management.

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

### 👥 Working with Users

Manage user accounts, profiles, and permissions with ease:

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

### 🏥 Working with Clients

Comprehensive client (patient) management capabilities:

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

### 📋 Working with Programs

Create and manage healthcare programs with exercises:

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

## ⚠️ Error Handling

The SDK provides comprehensive error handling with the `CarespaceError` enum, making it easy to handle different error scenarios gracefully:

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

## 🎨 SwiftUI Integration

The SDK is designed to work seamlessly with SwiftUI, supporting the latest concurrency features:

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

## ⚙️ Configuration Options

### CarespaceConfiguration

Customize the SDK behavior with comprehensive configuration options:

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

## 🔒 Thread Safety

The SDK is designed to be thread-safe and can be used from any queue. All network operations are performed asynchronously and return to the caller's queue.

## 🏗️ Architecture

The SDK follows a modular architecture:

- **API Layer**: `CarespaceAPI` serves as the main entry point
- **Service Layer**: Dedicated services for each API domain (Auth, Users, Clients, Programs)
- **Network Layer**: `HTTPClient` handles all network communication
- **Model Layer**: Type-safe Codable models for requests and responses
- **Error Layer**: Comprehensive error handling with `CarespaceError`

## 🧪 Testing

The SDK includes comprehensive unit tests covering all major functionality.

### Running Tests

```bash
# Run all tests
swift test

# Run tests with coverage
swift test --enable-code-coverage

# Run specific test
swift test --filter CarespaceSDKTests.testLoginRequest
```

### Test Coverage

The SDK maintains high test coverage for:
- Configuration management
- Request/response models
- Error handling
- API endpoint integration

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`swift test`)
6. Update documentation as needed
7. Commit your changes (`git commit -m 'Add amazing feature'`)
8. Push to the branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

### Development Guidelines

- Follow Swift API Design Guidelines
- Maintain backward compatibility
- Add unit tests for new features
- Update documentation and examples
- Use SwiftLint for code style consistency

## 📄 License

This SDK is released under the MIT License. See [LICENSE](LICENSE) file for details.

## 💬 Support

- **Documentation**: [https://docs.carespace.ai/swift-sdk](https://docs.carespace.ai/swift-sdk)
- **API Reference**: [https://api.carespace.ai/docs](https://api.carespace.ai/docs)
- **Email**: support@carespace.ai
- **Issues**: [GitHub Issues](https://github.com/carespace/swift-sdk/issues)
- **Discussions**: [GitHub Discussions](https://github.com/carespace/swift-sdk/discussions)

## 🙏 Acknowledgments

Thanks to all contributors who have helped make this SDK better!

---

<p align="center">Made with ❤️ by the Carespace Team</p>