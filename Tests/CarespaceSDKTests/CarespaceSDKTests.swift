import XCTest
@testable import CarespaceSDK

final class CarespaceSDKTests: XCTestCase {
    
    func testCarespaceConfigurationInit() {
        let config = CarespaceConfiguration()
        
        XCTAssertEqual(config.baseURL.absoluteString, "https://api-dev.carespace.ai")
        XCTAssertNil(config.apiKey)
        XCTAssertEqual(config.timeout, 30.0)
        XCTAssertTrue(config.additionalHeaders.isEmpty)
    }
    
    func testCarespaceConfigurationWithCustomValues() {
        let baseURL = URL(string: "https://api.carespace.ai")!
        let apiKey = "test-api-key"
        let timeout = 60.0
        let headers = ["X-Custom": "value"]
        
        let config = CarespaceConfiguration(
            baseURL: baseURL,
            apiKey: apiKey,
            timeout: timeout,
            additionalHeaders: headers
        )
        
        XCTAssertEqual(config.baseURL, baseURL)
        XCTAssertEqual(config.apiKey, apiKey)
        XCTAssertEqual(config.timeout, timeout)
        XCTAssertEqual(config.additionalHeaders, headers)
    }
    
    func testCarespaceAPIInit() {
        let api = CarespaceAPI()
        
        XCTAssertNotNil(api.auth)
        XCTAssertNotNil(api.users)
        XCTAssertNotNil(api.clients)
        XCTAssertNotNil(api.programs)
    }
    
    func testCarespaceAPIInitWithAPIKey() {
        let apiKey = "test-api-key"
        let api = CarespaceAPI(apiKey: apiKey)
        
        XCTAssertEqual(api.getConfiguration().apiKey, apiKey)
    }
    
    func testCarespaceAPISetAPIKey() {
        let api = CarespaceAPI()
        let apiKey = "new-api-key"
        
        api.setAPIKey(apiKey)
        
        XCTAssertEqual(api.getConfiguration().apiKey, apiKey)
    }
    
    func testLoginRequestInit() {
        let email = "test@example.com"
        let password = "password123"
        
        let request = LoginRequest(email: email, password: password)
        
        XCTAssertEqual(request.email, email)
        XCTAssertEqual(request.password, password)
    }
    
    func testCreateUserRequestInit() {
        let email = "test@example.com"
        let name = "Test User"
        let firstName = "Test"
        let lastName = "User"
        
        let request = CreateUserRequest(
            email: email,
            name: name,
            firstName: firstName,
            lastName: lastName
        )
        
        XCTAssertEqual(request.email, email)
        XCTAssertEqual(request.name, name)
        XCTAssertEqual(request.firstName, firstName)
        XCTAssertEqual(request.lastName, lastName)
    }
    
    func testCreateClientRequestInit() {
        let name = "Test Client"
        let email = "client@example.com"
        let phone = "+1234567890"
        
        let request = CreateClientRequest(
            name: name,
            email: email,
            phone: phone
        )
        
        XCTAssertEqual(request.name, name)
        XCTAssertEqual(request.email, email)
        XCTAssertEqual(request.phone, phone)
    }
    
    func testCreateProgramRequestInit() {
        let name = "Test Program"
        let description = "Test Description"
        let category = "Rehabilitation"
        let duration = 45
        
        let request = CreateProgramRequest(
            name: name,
            description: description,
            category: category,
            duration: duration
        )
        
        XCTAssertEqual(request.name, name)
        XCTAssertEqual(request.description, description)
        XCTAssertEqual(request.category, category)
        XCTAssertEqual(request.duration, duration)
    }
    
    func testPaginationParametersQueryParameters() {
        let parameters = PaginationParameters(
            page: 1,
            limit: 20,
            search: "test",
            sortBy: "name",
            sortOrder: "asc"
        )
        
        let queryParams = parameters.queryParameters
        
        XCTAssertEqual(queryParams["page"] as? Int, 1)
        XCTAssertEqual(queryParams["limit"] as? Int, 20)
        XCTAssertEqual(queryParams["search"] as? String, "test")
        XCTAssertEqual(queryParams["sort_by"] as? String, "name")
        XCTAssertEqual(queryParams["sort_order"] as? String, "asc")
    }
    
    func testPaginationParametersEmptyQueryParameters() {
        let parameters = PaginationParameters()
        let queryParams = parameters.queryParameters
        
        XCTAssertTrue(queryParams.isEmpty)
    }
    
    func testCarespaceErrorDescriptions() {
        XCTAssertEqual(CarespaceError.invalidURL.localizedDescription, "Invalid URL")
        XCTAssertEqual(CarespaceError.noData.localizedDescription, "No data received")
        XCTAssertEqual(CarespaceError.authenticationFailed.localizedDescription, "Authentication failed. Please check your API key.")
        XCTAssertEqual(CarespaceError.timeout.localizedDescription, "Request timeout")
        XCTAssertEqual(CarespaceError.invalidResponse.localizedDescription, "Invalid response format")
        XCTAssertEqual(CarespaceError.missingAPIKey.localizedDescription, "API key is required")
    }
    
    func testCarespaceErrorHTTPError() {
        let statusCode = 404
        let message = "Not Found"
        let error = CarespaceError.httpError(statusCode: statusCode, message: message)
        
        XCTAssertEqual(error.localizedDescription, "HTTP 404: Not Found")
    }
    
    func testConvenienceFunctions() {
        let api1 = createCarespaceAPI()
        XCTAssertNotNil(api1)
        
        let apiKey = "test-key"
        let api2 = createCarespaceAPI(apiKey: apiKey)
        XCTAssertEqual(api2.getConfiguration().apiKey, apiKey)
        
        let baseURL = URL(string: "https://test.example.com")!
        let api3 = createCarespaceAPI(baseURL: baseURL, apiKey: apiKey)
        XCTAssertEqual(api3.getConfiguration().baseURL, baseURL)
        XCTAssertEqual(api3.getConfiguration().apiKey, apiKey)
    }
}