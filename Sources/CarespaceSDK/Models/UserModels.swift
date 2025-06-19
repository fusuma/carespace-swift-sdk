import Foundation

// MARK: - User Models

public struct User: Codable, Identifiable {
    public let id: String
    public let email: String
    public let name: String?
    public let firstName: String?
    public let lastName: String?
    public let role: String?
    public let isActive: Bool
    public let createdAt: Date?
    public let updatedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case role
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct CreateUserRequest: Codable {
    public let email: String
    public let name: String?
    public let firstName: String?
    public let lastName: String?
    public let role: String?
    public let password: String?
    
    private enum CodingKeys: String, CodingKey {
        case email
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case role
        case password
    }
    
    public init(
        email: String,
        name: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        role: String? = nil,
        password: String? = nil
    ) {
        self.email = email
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.password = password
    }
}

public struct UpdateUserRequest: Codable {
    public let name: String?
    public let firstName: String?
    public let lastName: String?
    public let role: String?
    public let isActive: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case role
        case isActive = "is_active"
    }
    
    public init(
        name: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        role: String? = nil,
        isActive: Bool? = nil
    ) {
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.isActive = isActive
    }
}

public struct UserProfile: Codable {
    public let id: String
    public let email: String
    public let name: String?
    public let firstName: String?
    public let lastName: String?
    public let avatar: String?
    public let timezone: String?
    public let locale: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
        case timezone
        case locale
    }
}

public struct UpdateProfileRequest: Codable {
    public let name: String?
    public let firstName: String?
    public let lastName: String?
    public let avatar: String?
    public let timezone: String?
    public let locale: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
        case timezone
        case locale
    }
    
    public init(
        name: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        avatar: String? = nil,
        timezone: String? = nil,
        locale: String? = nil
    ) {
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.timezone = timezone
        self.locale = locale
    }
}

public struct UserSettings: Codable {
    public let notifications: Bool
    public let emailNotifications: Bool
    public let theme: String?
    public let language: String?
    
    private enum CodingKeys: String, CodingKey {
        case notifications
        case emailNotifications = "email_notifications"
        case theme
        case language
    }
}

public struct UsersListResponse: Codable {
    public let data: [User]
    public let total: Int
    public let page: Int
    public let limit: Int
}