import Foundation

// MARK: - Client Models

public struct Client: Codable, Identifiable {
    public let id: String
    public let name: String
    public let email: String?
    public let phone: String?
    public let dateOfBirth: Date?
    public let gender: String?
    public let address: Address?
    public let medicalHistory: String?
    public let notes: String?
    public let isActive: Bool
    public let createdAt: Date?
    public let updatedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case dateOfBirth = "date_of_birth"
        case gender
        case address
        case medicalHistory = "medical_history"
        case notes
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct Address: Codable {
    public let street: String?
    public let city: String?
    public let state: String?
    public let zipCode: String?
    public let country: String?
    
    private enum CodingKeys: String, CodingKey {
        case street
        case city
        case state
        case zipCode = "zip_code"
        case country
    }
}

public struct CreateClientRequest: Codable {
    public let name: String
    public let email: String?
    public let phone: String?
    public let dateOfBirth: Date?
    public let gender: String?
    public let address: Address?
    public let medicalHistory: String?
    public let notes: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case phone
        case dateOfBirth = "date_of_birth"
        case gender
        case address
        case medicalHistory = "medical_history"
        case notes
    }
    
    public init(
        name: String,
        email: String? = nil,
        phone: String? = nil,
        dateOfBirth: Date? = nil,
        gender: String? = nil,
        address: Address? = nil,
        medicalHistory: String? = nil,
        notes: String? = nil
    ) {
        self.name = name
        self.email = email
        self.phone = phone
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.address = address
        self.medicalHistory = medicalHistory
        self.notes = notes
    }
}

public struct UpdateClientRequest: Codable {
    public let name: String?
    public let email: String?
    public let phone: String?
    public let dateOfBirth: Date?
    public let gender: String?
    public let address: Address?
    public let medicalHistory: String?
    public let notes: String?
    public let isActive: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case email
        case phone
        case dateOfBirth = "date_of_birth"
        case gender
        case address
        case medicalHistory = "medical_history"
        case notes
        case isActive = "is_active"
    }
    
    public init(
        name: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        dateOfBirth: Date? = nil,
        gender: String? = nil,
        address: Address? = nil,
        medicalHistory: String? = nil,
        notes: String? = nil,
        isActive: Bool? = nil
    ) {
        self.name = name
        self.email = email
        self.phone = phone
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.address = address
        self.medicalHistory = medicalHistory
        self.notes = notes
        self.isActive = isActive
    }
}

public struct ClientStats: Codable {
    public let totalSessions: Int
    public let completedExercises: Int
    public let averageScore: Double?
    public let lastSessionDate: Date?
    
    private enum CodingKeys: String, CodingKey {
        case totalSessions = "total_sessions"
        case completedExercises = "completed_exercises"
        case averageScore = "average_score"
        case lastSessionDate = "last_session_date"
    }
}

public struct ClientsListResponse: Codable {
    public let data: [Client]
    public let total: Int
    public let page: Int
    public let limit: Int
}

public struct AssignProgramRequest: Codable {
    public let startDate: Date?
    public let endDate: Date?
    public let notes: String?
    
    private enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
        case notes
    }
    
    public init(
        startDate: Date? = nil,
        endDate: Date? = nil,
        notes: String? = nil
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }
}