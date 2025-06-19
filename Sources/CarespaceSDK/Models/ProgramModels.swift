import Foundation

// MARK: - Program Models

public struct Program: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String?
    public let category: String?
    public let difficulty: String?
    public let duration: Int? // in minutes
    public let isTemplate: Bool
    public let isActive: Bool
    public let createdBy: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case difficulty
        case duration
        case isTemplate = "is_template"
        case isActive = "is_active"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct CreateProgramRequest: Codable {
    public let name: String
    public let description: String?
    public let category: String?
    public let difficulty: String?
    public let duration: Int?
    public let isTemplate: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case category
        case difficulty
        case duration
        case isTemplate = "is_template"
    }
    
    public init(
        name: String,
        description: String? = nil,
        category: String? = nil,
        difficulty: String? = nil,
        duration: Int? = nil,
        isTemplate: Bool? = nil
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.duration = duration
        self.isTemplate = isTemplate
    }
}

public struct UpdateProgramRequest: Codable {
    public let name: String?
    public let description: String?
    public let category: String?
    public let difficulty: String?
    public let duration: Int?
    public let isTemplate: Bool?
    public let isActive: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case category
        case difficulty
        case duration
        case isTemplate = "is_template"
        case isActive = "is_active"
    }
    
    public init(
        name: String? = nil,
        description: String? = nil,
        category: String? = nil,
        difficulty: String? = nil,
        duration: Int? = nil,
        isTemplate: Bool? = nil,
        isActive: Bool? = nil
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.duration = duration
        self.isTemplate = isTemplate
        self.isActive = isActive
    }
}

public struct Exercise: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String?
    public let instructions: String?
    public let videoURL: String?
    public let imageURL: String?
    public let duration: Int? // in seconds
    public let repetitions: Int?
    public let sets: Int?
    public let restTime: Int? // in seconds
    public let order: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case instructions
        case videoURL = "video_url"
        case imageURL = "image_url"
        case duration
        case repetitions
        case sets
        case restTime = "rest_time"
        case order
    }
}

public struct CreateExerciseRequest: Codable {
    public let name: String
    public let description: String?
    public let instructions: String?
    public let videoURL: String?
    public let imageURL: String?
    public let duration: Int?
    public let repetitions: Int?
    public let sets: Int?
    public let restTime: Int?
    public let order: Int?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case instructions
        case videoURL = "video_url"
        case imageURL = "image_url"
        case duration
        case repetitions
        case sets
        case restTime = "rest_time"
        case order
    }
    
    public init(
        name: String,
        description: String? = nil,
        instructions: String? = nil,
        videoURL: String? = nil,
        imageURL: String? = nil,
        duration: Int? = nil,
        repetitions: Int? = nil,
        sets: Int? = nil,
        restTime: Int? = nil,
        order: Int? = nil
    ) {
        self.name = name
        self.description = description
        self.instructions = instructions
        self.videoURL = videoURL
        self.imageURL = imageURL
        self.duration = duration
        self.repetitions = repetitions
        self.sets = sets
        self.restTime = restTime
        self.order = order
    }
}

public struct DuplicateProgramRequest: Codable {
    public let name: String?
    public let description: String?
    public let copyExercises: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case copyExercises = "copy_exercises"
    }
    
    public init(
        name: String? = nil,
        description: String? = nil,
        copyExercises: Bool? = nil
    ) {
        self.name = name
        self.description = description
        self.copyExercises = copyExercises
    }
}

public struct ProgramsListResponse: Codable {
    public let data: [Program]
    public let total: Int
    public let page: Int
    public let limit: Int
}

public struct ExercisesListResponse: Codable {
    public let data: [Exercise]
    public let total: Int
    public let page: Int
    public let limit: Int
}