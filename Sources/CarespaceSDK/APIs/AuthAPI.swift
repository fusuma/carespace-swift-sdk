import Foundation

/// Authentication API endpoints
public class AuthAPI {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    /// Login with email and password
    /// - Parameter credentials: Login credentials
    /// - Returns: Login response with access token
    public func login(_ credentials: LoginRequest) async throws -> LoginResponse {
        try await httpClient.post(
            "/auth/login",
            body: credentials,
            responseType: LoginResponse.self
        )
    }
    
    /// Logout the current user
    /// - Returns: Empty response
    public func logout() async throws -> EmptyResponse {
        try await httpClient.post(
            "/auth/logout",
            body: EmptyResponse(),
            responseType: EmptyResponse.self
        )
    }
    
    /// Refresh access token
    /// - Parameter request: Refresh token request
    /// - Returns: New login response with fresh tokens
    public func refreshToken(_ request: RefreshTokenRequest) async throws -> LoginResponse {
        try await httpClient.post(
            "/auth/refresh",
            body: request,
            responseType: LoginResponse.self
        )
    }
    
    /// Request password reset
    /// - Parameter request: Forgot password request with email
    /// - Returns: Message response
    public func forgotPassword(_ request: ForgotPasswordRequest) async throws -> MessageResponse {
        try await httpClient.post(
            "/auth/forgot-password",
            body: request,
            responseType: MessageResponse.self
        )
    }
    
    /// Reset password with token
    /// - Parameter request: Reset password request with token and new password
    /// - Returns: Message response
    public func resetPassword(_ request: ResetPasswordRequest) async throws -> MessageResponse {
        try await httpClient.post(
            "/auth/reset-password",
            body: request,
            responseType: MessageResponse.self
        )
    }
    
    /// Change password for authenticated user
    /// - Parameter request: Change password request
    /// - Returns: Message response
    public func changePassword(_ request: ChangePasswordRequest) async throws -> MessageResponse {
        try await httpClient.post(
            "/auth/change-password",
            body: request,
            responseType: MessageResponse.self
        )
    }
    
    /// Verify email address
    /// - Parameter request: Email verification request with token
    /// - Returns: Message response
    public func verifyEmail(_ request: VerifyEmailRequest) async throws -> MessageResponse {
        try await httpClient.post(
            "/auth/verify-email",
            body: request,
            responseType: MessageResponse.self
        )
    }
    
    /// Resend email verification
    /// - Parameter request: Resend verification request with email
    /// - Returns: Message response
    public func resendVerification(_ request: ResendVerificationRequest) async throws -> MessageResponse {
        try await httpClient.post(
            "/auth/resend-verification",
            body: request,
            responseType: MessageResponse.self
        )
    }
}