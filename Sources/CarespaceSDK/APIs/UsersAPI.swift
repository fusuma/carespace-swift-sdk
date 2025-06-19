import Foundation

/// Users API endpoints
public class UsersAPI {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    /// Get list of users
    /// - Parameter parameters: Pagination and filtering parameters
    /// - Returns: List of users with pagination info
    public func getUsers(_ parameters: PaginationParameters = PaginationParameters()) async throws -> UsersListResponse {
        try await httpClient.get(
            "/users",
            queryParameters: parameters.queryParameters,
            responseType: UsersListResponse.self
        )
    }
    
    /// Get specific user by ID
    /// - Parameter userId: User ID
    /// - Returns: User details
    public func getUser(_ userId: String) async throws -> User {
        try await httpClient.get(
            "/users/\(userId)",
            responseType: User.self
        )
    }
    
    /// Create new user
    /// - Parameter request: User creation data
    /// - Returns: Created user
    public func createUser(_ request: CreateUserRequest) async throws -> User {
        try await httpClient.post(
            "/users",
            body: request,
            responseType: User.self
        )
    }
    
    /// Update existing user
    /// - Parameters:
    ///   - userId: User ID
    ///   - request: User update data
    /// - Returns: Updated user
    public func updateUser(_ userId: String, _ request: UpdateUserRequest) async throws -> User {
        try await httpClient.put(
            "/users/\(userId)",
            body: request,
            responseType: User.self
        )
    }
    
    /// Delete user
    /// - Parameter userId: User ID
    /// - Returns: Empty response
    public func deleteUser(_ userId: String) async throws -> EmptyResponse {
        try await httpClient.delete(
            "/users/\(userId)",
            responseType: EmptyResponse.self
        )
    }
    
    /// Get current user's profile
    /// - Returns: User profile
    public func getUserProfile() async throws -> UserProfile {
        try await httpClient.get(
            "/users/profile",
            responseType: UserProfile.self
        )
    }
    
    /// Update current user's profile
    /// - Parameter request: Profile update data
    /// - Returns: Updated profile
    public func updateUserProfile(_ request: UpdateProfileRequest) async throws -> UserProfile {
        try await httpClient.put(
            "/users/profile",
            body: request,
            responseType: UserProfile.self
        )
    }
    
    /// Get user settings
    /// - Parameter userId: User ID
    /// - Returns: User settings
    public func getUserSettings(_ userId: String) async throws -> UserSettings {
        try await httpClient.get(
            "/users/\(userId)/settings",
            responseType: UserSettings.self
        )
    }
    
    /// Update user settings
    /// - Parameters:
    ///   - userId: User ID
    ///   - settings: Settings to update
    /// - Returns: Updated settings
    public func updateUserSettings(_ userId: String, _ settings: UserSettings) async throws -> UserSettings {
        try await httpClient.put(
            "/users/\(userId)/settings",
            body: settings,
            responseType: UserSettings.self
        )
    }
}