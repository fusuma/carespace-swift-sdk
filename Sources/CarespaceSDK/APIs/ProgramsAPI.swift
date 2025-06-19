import Foundation

/// Programs API endpoints
public class ProgramsAPI {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    /// Get list of programs
    /// - Parameter parameters: Pagination and filtering parameters
    /// - Returns: List of programs with pagination info
    public func getPrograms(_ parameters: PaginationParameters = PaginationParameters()) async throws -> ProgramsListResponse {
        try await httpClient.get(
            "/programs",
            queryParameters: parameters.queryParameters,
            responseType: ProgramsListResponse.self
        )
    }
    
    /// Get specific program by ID
    /// - Parameter programId: Program ID
    /// - Returns: Program details
    public func getProgram(_ programId: String) async throws -> Program {
        try await httpClient.get(
            "/programs/\(programId)",
            responseType: Program.self
        )
    }
    
    /// Create new program
    /// - Parameter request: Program creation data
    /// - Returns: Created program
    public func createProgram(_ request: CreateProgramRequest) async throws -> Program {
        try await httpClient.post(
            "/programs",
            body: request,
            responseType: Program.self
        )
    }
    
    /// Update existing program
    /// - Parameters:
    ///   - programId: Program ID
    ///   - request: Program update data
    /// - Returns: Updated program
    public func updateProgram(_ programId: String, _ request: UpdateProgramRequest) async throws -> Program {
        try await httpClient.put(
            "/programs/\(programId)",
            body: request,
            responseType: Program.self
        )
    }
    
    /// Delete program
    /// - Parameter programId: Program ID
    /// - Returns: Empty response
    public func deleteProgram(_ programId: String) async throws -> EmptyResponse {
        try await httpClient.delete(
            "/programs/\(programId)",
            responseType: EmptyResponse.self
        )
    }
    
    /// Get exercises in program
    /// - Parameters:
    ///   - programId: Program ID
    ///   - parameters: Pagination parameters
    /// - Returns: List of exercises in program
    public func getProgramExercises(_ programId: String, _ parameters: PaginationParameters = PaginationParameters()) async throws -> ExercisesListResponse {
        try await httpClient.get(
            "/programs/\(programId)/exercises",
            queryParameters: parameters.queryParameters,
            responseType: ExercisesListResponse.self
        )
    }
    
    /// Add exercise to program
    /// - Parameters:
    ///   - programId: Program ID
    ///   - request: Exercise data
    /// - Returns: Created exercise
    public func addExerciseToProgram(_ programId: String, _ request: CreateExerciseRequest) async throws -> Exercise {
        try await httpClient.post(
            "/programs/\(programId)/exercises",
            body: request,
            responseType: Exercise.self
        )
    }
    
    /// Update exercise in program
    /// - Parameters:
    ///   - programId: Program ID
    ///   - exerciseId: Exercise ID
    ///   - request: Exercise update data
    /// - Returns: Updated exercise
    public func updateProgramExercise(_ programId: String, _ exerciseId: String, _ request: CreateExerciseRequest) async throws -> Exercise {
        try await httpClient.put(
            "/programs/\(programId)/exercises/\(exerciseId)",
            body: request,
            responseType: Exercise.self
        )
    }
    
    /// Remove exercise from program
    /// - Parameters:
    ///   - programId: Program ID
    ///   - exerciseId: Exercise ID
    /// - Returns: Empty response
    public func removeProgramExercise(_ programId: String, _ exerciseId: String) async throws -> EmptyResponse {
        try await httpClient.delete(
            "/programs/\(programId)/exercises/\(exerciseId)",
            responseType: EmptyResponse.self
        )
    }
    
    /// Duplicate program
    /// - Parameters:
    ///   - programId: Program ID to duplicate
    ///   - request: Duplication options
    /// - Returns: Duplicated program
    public func duplicateProgram(_ programId: String, _ request: DuplicateProgramRequest = DuplicateProgramRequest()) async throws -> Program {
        try await httpClient.post(
            "/programs/\(programId)/duplicate",
            body: request,
            responseType: Program.self
        )
    }
    
    /// Get program templates
    /// - Parameter parameters: Pagination parameters
    /// - Returns: List of program templates
    public func getProgramTemplates(_ parameters: PaginationParameters = PaginationParameters()) async throws -> ProgramsListResponse {
        try await httpClient.get(
            "/programs/templates",
            queryParameters: parameters.queryParameters,
            responseType: ProgramsListResponse.self
        )
    }
}