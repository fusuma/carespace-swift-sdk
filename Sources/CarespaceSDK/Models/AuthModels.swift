import Foundation

// MARK: - Authentication Models

/// A request to authenticate a user with email and password.
///
/// Use this model to log in a user and obtain authentication tokens.
///
/// ## Example
/// ```swift
/// let request = LoginRequest(
///     email: "user@example.com",
///     password: "securePassword123"
/// )
/// 
/// do {
///     let response = try await api.auth.login(request)
///     // Store the access token for future requests
///     api.setAPIKey(response.accessToken)
/// } catch {
///     print("Login failed: \(error)")
/// }
/// ```
public struct LoginRequest: Codable {
    /// The user's email address.
    public let email: String
    
    /// The user's password.
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

/// The response returned after successful authentication.
///
/// Contains authentication tokens and user information.
///
/// ## Token Management
/// - `accessToken`: Use this for API authentication
/// - `refreshToken`: Use this to obtain new access tokens when they expire
/// - `expiresIn`: Time in seconds until the access token expires
///
/// ## Example
/// ```swift
/// let response = try await api.auth.login(loginRequest)
/// print("Logged in as: \(response.user?.name ?? "Unknown")")
/// print("Token expires in: \(response.expiresIn) seconds")
/// ```
public struct LoginResponse: Codable {
    /// The access token to use for authenticated API requests.
    public let accessToken: String
    
    /// The refresh token to use for obtaining new access tokens.
    public let refreshToken: String
    
    /// The lifetime of the access token in seconds.
    public let expiresIn: Int
    
    /// The type of token (typically "Bearer").
    public let tokenType: String
    
    /// The authenticated user's information, if included in the response.
    public let user: User?
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case user
    }
}

/// A request to refresh an expired access token.
///
/// Use this when the access token has expired but you have a valid refresh token.
///
/// ## Example
/// ```swift
/// let request = RefreshTokenRequest(refreshToken: savedRefreshToken)
/// let response = try await api.auth.refreshToken(request)
/// api.setAPIKey(response.accessToken)
/// ```
public struct RefreshTokenRequest: Codable {
    /// The refresh token obtained from a previous login.
    public let refreshToken: String
    
    private enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

/// A request to initiate the password reset process.
///
/// Sends a password reset email to the specified address if the account exists.
///
/// ## Example
/// ```swift
/// let request = ForgotPasswordRequest(email: "user@example.com")
/// try await api.auth.forgotPassword(request)
/// // User will receive an email with reset instructions
/// ```
public struct ForgotPasswordRequest: Codable {
    /// The email address of the account to reset.
    public let email: String
    
    public init(email: String) {
        self.email = email
    }
}

/// A request to reset a user's password using a reset token.
///
/// The token is typically received via email after initiating the forgot password flow.
///
/// ## Example
/// ```swift
/// let request = ResetPasswordRequest(
///     token: "reset-token-from-email",
///     password: "newSecurePassword123"
/// )
/// try await api.auth.resetPassword(request)
/// ```
public struct ResetPasswordRequest: Codable {
    /// The password reset token received via email.
    public let token: String
    
    /// The new password to set for the account.
    public let password: String
    
    public init(token: String, password: String) {
        self.token = token
        self.password = password
    }
}

/// A request to change the current user's password.
///
/// Requires authentication and the current password for security.
///
/// ## Example
/// ```swift
/// let request = ChangePasswordRequest(
///     currentPassword: "oldPassword123",
///     newPassword: "newSecurePassword456"
/// )
/// try await api.auth.changePassword(request)
/// ```
///
/// - Important: This endpoint requires authentication with a valid access token.
public struct ChangePasswordRequest: Codable {
    /// The user's current password for verification.
    public let currentPassword: String
    
    /// The new password to set.
    public let newPassword: String
    
    private enum CodingKeys: String, CodingKey {
        case currentPassword = "current_password"
        case newPassword = "new_password"
    }
    
    public init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}

/// A request to verify a user's email address.
///
/// Uses a verification token sent to the user's email during registration.
///
/// ## Example
/// ```swift
/// let request = VerifyEmailRequest(token: "verification-token-from-email")
/// try await api.auth.verifyEmail(request)
/// ```
public struct VerifyEmailRequest: Codable {
    /// The email verification token.
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}

/// A request to resend the email verification link.
///
/// Use this when the user didn't receive or lost the original verification email.
///
/// ## Example
/// ```swift
/// let request = ResendVerificationRequest(email: "user@example.com")
/// try await api.auth.resendVerification(request)
/// ```
public struct ResendVerificationRequest: Codable {
    /// The email address to resend verification to.
    public let email: String
    
    public init(email: String) {
        self.email = email
    }
}