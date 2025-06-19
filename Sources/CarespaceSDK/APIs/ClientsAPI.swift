import Foundation

/// Clients API endpoints
public class ClientsAPI {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    /// Get list of clients
    /// - Parameter parameters: Pagination and filtering parameters
    /// - Returns: List of clients with pagination info
    public func getClients(_ parameters: PaginationParameters = PaginationParameters()) async throws -> ClientsListResponse {
        try await httpClient.get(
            "/clients",
            queryParameters: parameters.queryParameters,
            responseType: ClientsListResponse.self
        )
    }
    
    /// Get specific client by ID
    /// - Parameter clientId: Client ID
    /// - Returns: Client details
    public func getClient(_ clientId: String) async throws -> Client {
        try await httpClient.get(
            "/clients/\(clientId)",
            responseType: Client.self
        )
    }
    
    /// Create new client
    /// - Parameter request: Client creation data
    /// - Returns: Created client
    public func createClient(_ request: CreateClientRequest) async throws -> Client {
        try await httpClient.post(
            "/clients",
            body: request,
            responseType: Client.self
        )
    }
    
    /// Update existing client
    /// - Parameters:
    ///   - clientId: Client ID
    ///   - request: Client update data
    /// - Returns: Updated client
    public func updateClient(_ clientId: String, _ request: UpdateClientRequest) async throws -> Client {
        try await httpClient.put(
            "/clients/\(clientId)",
            body: request,
            responseType: Client.self
        )
    }
    
    /// Delete client
    /// - Parameter clientId: Client ID
    /// - Returns: Empty response
    public func deleteClient(_ clientId: String) async throws -> EmptyResponse {
        try await httpClient.delete(
            "/clients/\(clientId)",
            responseType: EmptyResponse.self
        )
    }
    
    /// Get client statistics
    /// - Parameter clientId: Client ID
    /// - Returns: Client statistics
    public func getClientStats(_ clientId: String) async throws -> ClientStats {
        try await httpClient.get(
            "/clients/\(clientId)/stats",
            responseType: ClientStats.self
        )
    }
    
    /// Get programs assigned to client
    /// - Parameters:
    ///   - clientId: Client ID
    ///   - parameters: Pagination parameters
    /// - Returns: List of programs assigned to client
    public func getClientPrograms(_ clientId: String, _ parameters: PaginationParameters = PaginationParameters()) async throws -> ProgramsListResponse {
        try await httpClient.get(
            "/clients/\(clientId)/programs",
            queryParameters: parameters.queryParameters,
            responseType: ProgramsListResponse.self
        )
    }
    
    /// Assign program to client
    /// - Parameters:
    ///   - clientId: Client ID
    ///   - programId: Program ID
    ///   - request: Assignment details
    /// - Returns: Success response
    public func assignProgramToClient(_ clientId: String, _ programId: String, _ request: AssignProgramRequest = AssignProgramRequest()) async throws -> SuccessResponse {
        try await httpClient.post(
            "/clients/\(clientId)/programs/\(programId)",
            body: request,
            responseType: SuccessResponse.self
        )
    }
    
    /// Remove program from client
    /// - Parameters:
    ///   - clientId: Client ID
    ///   - programId: Program ID
    /// - Returns: Empty response
    public func removeClientProgram(_ clientId: String, _ programId: String) async throws -> EmptyResponse {
        try await httpClient.delete(
            "/clients/\(clientId)/programs/\(programId)",
            responseType: EmptyResponse.self
        )
    }
}