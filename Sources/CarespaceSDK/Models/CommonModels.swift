import Foundation

// MARK: - Common Response Models

public struct EmptyResponse: Codable {
    // Empty response for endpoints that don't return data
}

public struct MessageResponse: Codable {
    public let message: String
}

public struct IDResponse: Codable {
    public let id: String
}

public struct SuccessResponse: Codable {
    public let success: Bool
    public let message: String?
}

// MARK: - Common Request Parameters

public struct PaginationParameters {
    public let page: Int?
    public let limit: Int?
    public let search: String?
    public let sortBy: String?
    public let sortOrder: String?
    
    public init(
        page: Int? = nil,
        limit: Int? = nil,
        search: String? = nil,
        sortBy: String? = nil,
        sortOrder: String? = nil
    ) {
        self.page = page
        self.limit = limit
        self.search = search
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
    
    public var queryParameters: [String: Any] {
        var params: [String: Any] = [:]
        
        if let page = page { params["page"] = page }
        if let limit = limit { params["limit"] = limit }
        if let search = search { params["search"] = search }
        if let sortBy = sortBy { params["sort_by"] = sortBy }
        if let sortOrder = sortOrder { params["sort_order"] = sortOrder }
        
        return params
    }
}

// MARK: - Date Formatting

extension JSONDecoder {
    static var carespace: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension JSONEncoder {
    static var carespace: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}