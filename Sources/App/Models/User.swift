import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @OptionalField(key: "first_name")
    var firstname: String?
    
    @OptionalField(key: "last_name")
    var lastName: String?
    
    @OptionalField(key: "address")
    var adresse: String?
    
    @OptionalField(key: "zip_code")
    var zipCode: String?
    
    @OptionalField(key: "city")
    var city: String?
    
    @OptionalField(key: "phone_number")
    var phoneNumber: String?
    
    @OptionalField(key: "date_of_birth")
    var dateOfBirth: String?
    
    @OptionalField(key: "gender")
    var gender: String?
    
    @OptionalField(key: "civil_status")
    var civilStatus: String?
    

    
    

    init() { }

    init(
        id: UUID? = nil,
        firstname: String? = nil,
        email: String,
        passwordHash: String,
        lastName: String? = nil,
        addresse: String? = nil,
        zipCode: String? = nil,
        city: String? = nil,
        phoneNumber: String? = nil,
        dateOfBirth: String? = nil,
        gender: String? = nil,
        civilStatus: String? = nil
    ) {
        self.id = id
        self.passwordHash = passwordHash
        self.firstname = firstname
        self.email = email
        self.lastName = lastName
        self.adresse = addresse
        self.zipCode = zipCode
        self.city = city
        self.phoneNumber = phoneNumber
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.civilStatus = civilStatus
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}


extension User {
    func generateToken() throws -> UserToken {
        try UserToken(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}
