import Foundation

// MARK: - Authentication Models

public struct LoginRequest: Codable {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct LoginResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int
    public let tokenType: String
    public let user: User?
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case user
    }
}

public struct RefreshTokenRequest: Codable {
    public let refreshToken: String
    
    private enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

public struct ForgotPasswordRequest: Codable {
    public let email: String
    
    public init(email: String) {
        self.email = email
    }
}

public struct ResetPasswordRequest: Codable {
    public let token: String
    public let password: String
    
    public init(token: String, password: String) {
        self.token = token
        self.password = password
    }
}

public struct ChangePasswordRequest: Codable {
    public let currentPassword: String
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

public struct VerifyEmailRequest: Codable {
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}

public struct ResendVerificationRequest: Codable {
    public let email: String
    
    public init(email: String) {
        self.email = email
    }
}