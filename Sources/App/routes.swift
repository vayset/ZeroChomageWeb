import Fluent
import Vapor
import ZeroChomageWebShared

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    
    let apiVersionGroup = app.grouped("api", "v1")
    let apiProtectedGroup = apiVersionGroup.grouped(UserToken.authenticator())
    
    apiProtectedGroup.get("user-account-info") { req -> User in
        let authenticatedUser = try req.auth.require(User.self)
        return authenticatedUser
    }
    
    apiProtectedGroup.post("questionnaire-upload") { req -> HTTPStatus in
        let authenticatedUser = try req.auth.require(User.self)
        
        
        let questionnaire = try req.content.decode(QuestionnaireRequestBody.self)
        
        
        authenticatedUser.lastName = questionnaire.lastName
        authenticatedUser.firstname = questionnaire.firstName
        authenticatedUser.address = questionnaire.address
        authenticatedUser.zipCode = questionnaire.zipCode
        authenticatedUser.city = questionnaire.city

        authenticatedUser.phoneNumber = questionnaire.phoneNumber
        authenticatedUser.dateOfBirth = questionnaire.dateOfBirth
        authenticatedUser.isAlreadyFilled = questionnaire.isAlreadyFilled
        authenticatedUser.gender = questionnaire.gender
        authenticatedUser.civilStatus = questionnaire.civilStatus
        
        try await authenticatedUser.update(on: req.db)
        
        return .accepted
    }
    
    
    apiVersionGroup.post("login") { req -> LoginResponse in
        
        let loginRequest = try req.content.decode(LoginRequest.self)

        
        guard let user = try await User
            .query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first()
        else {
            throw Abort(.notFound)
        }
        
        guard let _ = try? Bcrypt.verify(loginRequest.password, created: user.passwordHash) else {
            throw Abort(.badRequest, reason: "Email and password are not valid")
        }
        
        let userToken = try user.generateToken()
        try await userToken.save(on: req.db)
    
        return LoginResponse(userToken: userToken.value)
    }
    
    
    apiVersionGroup.post("signup") { req -> SignUpResponse in
        
        let signUpRequest = try req.content.decode(SignUpRequest.self)
        
        guard signUpRequest.password == signUpRequest.passwordConfirmation else {
            throw Abort(.badRequest, reason: "Password and password confirmation are not valid")
        }
        
        
        let user = User(
            email: signUpRequest.email.lowercased(),
            passwordHash: try Bcrypt.hash(signUpRequest.password)
        )
        
        try await user.create(on: req.db)
        
        let userToken = try user.generateToken()
        try await userToken.save(on: req.db)
    
        return SignUpResponse(userToken: userToken.value)
    }


    try app.register(collection: UserController())
}



extension LoginResponse: Content { }
extension SignUpResponse: Content { }



public struct SignUpResponse: Codable {
    
    public let userToken: String
    
    
    public init(userToken: String) {
        self.userToken = userToken
    }
}



public struct SignUpRequest: Codable {
  
    
    public let email: String
    public let password: String
    public let passwordConfirmation: String
    
    
    public init(
        email: String,
        password: String,
        passwordConfirmation: String
    ) {
        self.email = email
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }

}




struct QuestionnaireRequestBody: Decodable {
    let lastName: String
    let firstName: String
    let address: String
    let zipCode: String
    let city: String
    let phoneNumber: String
    let dateOfBirth: String
    let isAlreadyFilled: Bool
    let gender: String
    let civilStatus: String
}

