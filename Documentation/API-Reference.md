# Carespace Swift SDK API Reference

This document provides a comprehensive reference for all public APIs in the Carespace Swift SDK.

## Table of Contents

- [Core Classes](#core-classes)
  - [CarespaceAPI](#carespaceapi)
  - [CarespaceConfiguration](#carespaceconfiguration)
- [API Services](#api-services)
  - [AuthAPI](#authapi)
  - [UsersAPI](#usersapi)
  - [ClientsAPI](#clientsapi)
  - [ProgramsAPI](#programsapi)
- [Models](#models)
  - [Authentication Models](#authentication-models)
  - [User Models](#user-models)
  - [Client Models](#client-models)
  - [Program Models](#program-models)
- [Error Handling](#error-handling)
  - [CarespaceError](#carespaceerror)

---

## Core Classes

### CarespaceAPI

The main entry point for interacting with the Carespace platform.

```swift
public class CarespaceAPI
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `auth` | `AuthAPI` | Authentication service |
| `users` | `UsersAPI` | User management service |
| `clients` | `ClientsAPI` | Client management service |
| `programs` | `ProgramsAPI` | Program management service |
| `shared` | `CarespaceAPI` | Shared singleton instance |

#### Methods

##### `init(configuration:)`
```swift
public init(configuration: CarespaceConfiguration = CarespaceConfiguration())
```
Initializes a new API client with the specified configuration.

##### `init(apiKey:)`
```swift
public convenience init(apiKey: String)
```
Initializes a new API client with only an API key.

##### `init(baseURL:apiKey:)`
```swift
public convenience init(baseURL: URL, apiKey: String)
```
Initializes a new API client with a custom base URL and API key.

##### `setAPIKey(_:)`
```swift
public func setAPIKey(_ apiKey: String)
```
Updates the API key used for authentication.

##### `getConfiguration()`
```swift
public func getConfiguration() -> CarespaceConfiguration
```
Returns the current configuration.

---

### CarespaceConfiguration

Configuration settings for the SDK.

```swift
public struct CarespaceConfiguration
```

#### Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `baseURL` | `URL` | Base URL for API requests | `https://api-dev.carespace.ai` |
| `apiKey` | `String?` | API key for authentication | `nil` |
| `timeout` | `TimeInterval` | Request timeout in seconds | `30.0` |
| `additionalHeaders` | `[String: String]` | Custom headers for all requests | `[:]` |

#### Methods

##### `init(baseURL:apiKey:timeout:additionalHeaders:)`
```swift
public init(
    baseURL: URL = URL(string: "https://api-dev.carespace.ai")!,
    apiKey: String? = nil,
    timeout: TimeInterval = 30.0,
    additionalHeaders: [String: String] = [:]
)
```
Creates a new configuration with the specified settings.

##### `setAPIKey(_:)`
```swift
public mutating func setAPIKey(_ apiKey: String)
```
Updates the API key in the configuration.

---

## API Services

### AuthAPI

Handles authentication operations.

#### Methods

##### `login(_:)`
```swift
public func login(_ request: LoginRequest) async throws -> LoginResponse
```
Authenticates a user with email and password.

##### `logout()`
```swift
public func logout() async throws
```
Logs out the current user.

##### `refreshToken(_:)`
```swift
public func refreshToken(_ request: RefreshTokenRequest) async throws -> LoginResponse
```
Refreshes an expired access token.

##### `forgotPassword(_:)`
```swift
public func forgotPassword(_ request: ForgotPasswordRequest) async throws -> MessageResponse
```
Initiates the password reset process.

##### `resetPassword(_:)`
```swift
public func resetPassword(_ request: ResetPasswordRequest) async throws -> MessageResponse
```
Resets a password using a reset token.

##### `changePassword(_:)`
```swift
public func changePassword(_ request: ChangePasswordRequest) async throws -> MessageResponse
```
Changes the current user's password.

##### `verifyEmail(_:)`
```swift
public func verifyEmail(_ request: VerifyEmailRequest) async throws -> MessageResponse
```
Verifies a user's email address.

##### `resendVerification(_:)`
```swift
public func resendVerification(_ request: ResendVerificationRequest) async throws -> MessageResponse
```
Resends the email verification link.

---

### UsersAPI

Manages user accounts and profiles.

#### Methods

##### `list(_:)`
```swift
public func list(_ parameters: PaginationParameters = PaginationParameters()) async throws -> PaginatedResponse<User>
```
Retrieves a paginated list of users.

##### `get(_:)`
```swift
public func get(_ id: String) async throws -> User
```
Retrieves a specific user by ID.

##### `create(_:)`
```swift
public func create(_ request: CreateUserRequest) async throws -> User
```
Creates a new user account.

##### `update(_:request:)`
```swift
public func update(_ id: String, request: UpdateUserRequest) async throws -> User
```
Updates an existing user.

##### `delete(_:)`
```swift
public func delete(_ id: String) async throws
```
Deletes a user account.

##### `getCurrentUser()`
```swift
public func getCurrentUser() async throws -> User
```
Retrieves the currently authenticated user.

##### `updateProfile(_:)`
```swift
public func updateProfile(_ request: UpdateProfileRequest) async throws -> User
```
Updates the current user's profile.

---

### ClientsAPI

Manages healthcare clients/patients.

#### Methods

##### `list(_:)`
```swift
public func list(_ parameters: PaginationParameters = PaginationParameters()) async throws -> PaginatedResponse<Client>
```
Retrieves a paginated list of clients.

##### `get(_:)`
```swift
public func get(_ id: String) async throws -> Client
```
Retrieves a specific client by ID.

##### `create(_:)`
```swift
public func create(_ request: CreateClientRequest) async throws -> Client
```
Creates a new client.

##### `update(_:request:)`
```swift
public func update(_ id: String, request: UpdateClientRequest) async throws -> Client
```
Updates an existing client.

##### `delete(_:)`
```swift
public func delete(_ id: String) async throws
```
Deletes a client.

##### `getStats(_:)`
```swift
public func getStats(_ id: String) async throws -> ClientStats
```
Retrieves statistics for a client.

##### `getPrograms(_:parameters:)`
```swift
public func getPrograms(_ id: String, parameters: PaginationParameters = PaginationParameters()) async throws -> PaginatedResponse<ClientProgram>
```
Retrieves programs assigned to a client.

##### `assignProgram(_:programId:request:)`
```swift
public func assignProgram(_ id: String, programId: String, request: AssignProgramRequest) async throws -> ClientProgram
```
Assigns a program to a client.

---

### ProgramsAPI

Manages healthcare programs and exercises.

#### Methods

##### `list(_:)`
```swift
public func list(_ parameters: PaginationParameters = PaginationParameters()) async throws -> PaginatedResponse<Program>
```
Retrieves a paginated list of programs.

##### `get(_:)`
```swift
public func get(_ id: String) async throws -> Program
```
Retrieves a specific program by ID.

##### `create(_:)`
```swift
public func create(_ request: CreateProgramRequest) async throws -> Program
```
Creates a new program.

##### `update(_:request:)`
```swift
public func update(_ id: String, request: UpdateProgramRequest) async throws -> Program
```
Updates an existing program.

##### `delete(_:)`
```swift
public func delete(_ id: String) async throws
```
Deletes a program.

##### `getExercises(_:)`
```swift
public func getExercises(_ id: String) async throws -> [Exercise]
```
Retrieves exercises in a program.

##### `addExercise(_:request:)`
```swift
public func addExercise(_ id: String, request: CreateExerciseRequest) async throws -> Exercise
```
Adds an exercise to a program.

##### `duplicate(_:request:)`
```swift
public func duplicate(_ id: String, request: DuplicateProgramRequest) async throws -> Program
```
Creates a copy of an existing program.

---

## Models

### Authentication Models

#### LoginRequest
```swift
public struct LoginRequest: Codable {
    public let email: String
    public let password: String
}
```

#### LoginResponse
```swift
public struct LoginResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int
    public let tokenType: String
    public let user: User?
}
```

#### RefreshTokenRequest
```swift
public struct RefreshTokenRequest: Codable {
    public let refreshToken: String
}
```

#### ForgotPasswordRequest
```swift
public struct ForgotPasswordRequest: Codable {
    public let email: String
}
```

#### ResetPasswordRequest
```swift
public struct ResetPasswordRequest: Codable {
    public let token: String
    public let password: String
}
```

#### ChangePasswordRequest
```swift
public struct ChangePasswordRequest: Codable {
    public let currentPassword: String
    public let newPassword: String
}
```

---

### User Models

#### User
```swift
public struct User: Codable, Identifiable {
    public let id: String
    public let email: String
    public let name: String?
    public let firstName: String?
    public let lastName: String?
    public let role: String?
    public let avatar: String?
    public let isActive: Bool
    public let isVerified: Bool
    public let createdAt: Date
    public let updatedAt: Date
}
```

#### CreateUserRequest
```swift
public struct CreateUserRequest: Codable {
    public let email: String
    public let name: String?
    public let firstName: String?
    public let lastName: String?
    public let role: String?
    public let password: String?
}
```

#### UpdateUserRequest
```swift
public struct UpdateUserRequest: Codable {
    public let name: String?
    public let firstName: String?
    public let lastName: String?
    public let role: String?
    public let isActive: Bool?
}
```

---

### Client Models

#### Client
```swift
public struct Client: Codable, Identifiable {
    public let id: String
    public let name: String
    public let email: String?
    public let phone: String?
    public let dateOfBirth: Date?
    public let address: Address?
    public let notes: String?
    public let tags: [String]
    public let isActive: Bool
    public let createdAt: Date
    public let updatedAt: Date
}
```

#### CreateClientRequest
```swift
public struct CreateClientRequest: Codable {
    public let name: String
    public let email: String?
    public let phone: String?
    public let dateOfBirth: Date?
    public let address: Address?
    public let notes: String?
    public let tags: [String]?
}
```

#### ClientStats
```swift
public struct ClientStats: Codable {
    public let totalPrograms: Int
    public let activePrograms: Int
    public let completedPrograms: Int
    public let totalSessions: Int
    public let completedSessions: Int
    public let totalExercises: Int
    public let completedExercises: Int
    public let lastActivityDate: Date?
}
```

---

### Program Models

#### Program
```swift
public struct Program: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String?
    public let category: String?
    public let difficulty: String?
    public let duration: Int?
    public let tags: [String]
    public let isActive: Bool
    public let isPublic: Bool
    public let createdBy: String
    public let createdAt: Date
    public let updatedAt: Date
}
```

#### CreateProgramRequest
```swift
public struct CreateProgramRequest: Codable {
    public let name: String
    public let description: String?
    public let category: String?
    public let difficulty: String?
    public let duration: Int?
    public let tags: [String]?
    public let isPublic: Bool?
}
```

#### Exercise
```swift
public struct Exercise: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String?
    public let instructions: String?
    public let duration: Int?
    public let repetitions: Int?
    public let sets: Int?
    public let restTime: Int?
    public let order: Int
    public let mediaUrls: [String]
    public let createdAt: Date
    public let updatedAt: Date
}
```

---

## Error Handling

### CarespaceError

Comprehensive error types for SDK operations.

```swift
public enum CarespaceError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case networkError(Error)
    case httpError(statusCode: Int, message: String?)
    case authenticationFailed
    case timeout
    case invalidResponse
    case missingAPIKey
}
```

#### Error Descriptions

| Case | Description |
|------|-------------|
| `invalidURL` | The provided URL is malformed or invalid |
| `noData` | The server returned an empty response |
| `decodingError` | Failed to decode the response data |
| `encodingError` | Failed to encode the request data |
| `networkError` | A network-level error occurred |
| `httpError` | The server returned an HTTP error |
| `authenticationFailed` | Authentication failed (invalid/expired token) |
| `timeout` | The request exceeded the timeout duration |
| `invalidResponse` | The server returned an unexpected format |
| `missingAPIKey` | API key is required but not provided |

---

## Common Patterns

### Pagination

Use `PaginationParameters` for list endpoints:

```swift
public struct PaginationParameters {
    public let page: Int?
    public let limit: Int?
    public let search: String?
    public let sortBy: String?
    public let sortOrder: String?
}
```

### Paginated Responses

List endpoints return `PaginatedResponse`:

```swift
public struct PaginatedResponse<T: Codable>: Codable {
    public let data: [T]
    public let total: Int
    public let page: Int
    public let limit: Int
    public let totalPages: Int
}
```

### Date Handling

All dates are automatically encoded/decoded as ISO 8601 strings.

### Network Requests

All network operations:
- Are asynchronous (async/await)
- Throw `CarespaceError` on failure
- Include automatic retry logic for transient failures
- Support cancellation via Swift's Task API