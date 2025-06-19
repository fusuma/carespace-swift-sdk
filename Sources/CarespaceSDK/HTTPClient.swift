import Foundation

/// HTTP client for making API requests
public class HTTPClient {
    private let session: URLSession
    private var configuration: CarespaceConfiguration
    
    public init(configuration: CarespaceConfiguration) {
        self.configuration = configuration
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = configuration.timeout
        config.timeoutIntervalForResource = configuration.timeout
        
        self.session = URLSession(configuration: config)
    }
    
    public func setAPIKey(_ apiKey: String) {
        configuration.setAPIKey(apiKey)
    }
    
    // MARK: - Request Methods
    
    public func get<T: Codable>(
        _ path: String,
        queryParameters: [String: Any] = [:],
        responseType: T.Type
    ) async throws -> T {
        try await request(
            path: path,
            method: .GET,
            queryParameters: queryParameters,
            responseType: responseType
        )
    }
    
    public func post<T: Codable, U: Codable>(
        _ path: String,
        body: U?,
        responseType: T.Type
    ) async throws -> T {
        try await request(
            path: path,
            method: .POST,
            body: body,
            responseType: responseType
        )
    }
    
    public func put<T: Codable, U: Codable>(
        _ path: String,
        body: U?,
        responseType: T.Type
    ) async throws -> T {
        try await request(
            path: path,
            method: .PUT,
            body: body,
            responseType: responseType
        )
    }
    
    public func patch<T: Codable, U: Codable>(
        _ path: String,
        body: U?,
        responseType: T.Type
    ) async throws -> T {
        try await request(
            path: path,
            method: .PATCH,
            body: body,
            responseType: responseType
        )
    }
    
    public func delete<T: Codable>(
        _ path: String,
        responseType: T.Type
    ) async throws -> T {
        try await request(
            path: path,
            method: .DELETE,
            responseType: responseType
        )
    }
    
    // MARK: - Private Methods
    
    private func request<T: Codable, U: Codable>(
        path: String,
        method: HTTPMethod,
        queryParameters: [String: Any] = [:],
        body: U? = nil,
        responseType: T.Type
    ) async throws -> T {
        let url = try buildURL(path: path, queryParameters: queryParameters)
        var request = URLRequest(url: url)
        
        // Set HTTP method
        request.httpMethod = method.rawValue
        
        // Set headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let apiKey = configuration.apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        // Add additional headers
        for (key, value) in configuration.additionalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw CarespaceError.encodingError(error)
            }
        }
        
        // Perform request
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CarespaceError.invalidResponse
            }
            
            // Check for HTTP errors
            if httpResponse.statusCode == 401 {
                throw CarespaceError.authenticationFailed
            } else if !(200...299).contains(httpResponse.statusCode) {
                let errorMessage = try? JSONDecoder().decode(ErrorResponse.self, from: data).message
                throw CarespaceError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            
            // Decode response
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw CarespaceError.decodingError(error)
            }
            
        } catch let error as CarespaceError {
            throw error
        } catch {
            if let urlError = error as? URLError {
                if urlError.code == .timedOut {
                    throw CarespaceError.timeout
                }
            }
            throw CarespaceError.networkError(error)
        }
    }
    
    private func buildURL(path: String, queryParameters: [String: Any]) throws -> URL {
        guard var components = URLComponents(url: configuration.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true) else {
            throw CarespaceError.invalidURL
        }
        
        if !queryParameters.isEmpty {
            components.queryItems = queryParameters.compactMap { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = components.url else {
            throw CarespaceError.invalidURL
        }
        
        return url
    }
}

// MARK: - HTTP Method Enum

private enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

// MARK: - Error Response Model

private struct ErrorResponse: Codable {
    let message: String
}