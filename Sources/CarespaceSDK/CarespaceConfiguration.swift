import Foundation

/// Configuration for the Carespace SDK
public struct CarespaceConfiguration {
    public let baseURL: URL
    public var apiKey: String?
    public let timeout: TimeInterval
    public let additionalHeaders: [String: String]
    
    public init(
        baseURL: URL = URL(string: "https://api-dev.carespace.ai")!,
        apiKey: String? = nil,
        timeout: TimeInterval = 30.0,
        additionalHeaders: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.timeout = timeout
        self.additionalHeaders = additionalHeaders
    }
    
    public mutating func setAPIKey(_ apiKey: String) {
        self.apiKey = apiKey
    }
}