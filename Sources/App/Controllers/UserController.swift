import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let userRoutes = routes.grouped("users")
        userRoutes.get(use: index)
        userRoutes.post(use: create)
        userRoutes.group(":userID") { user in
            user.delete(use: delete)
        }
        
        let validateGroup = userRoutes.grouped("validate")
        validateGroup.post(use: validateUserIndex)
    }
    

    func index(req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.save(on: req.db).map { user }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
    
    
    func validateUserIndex(req: Request) async throws -> HTTPStatus {
        let authenticatedUser = try req.auth.require(User.self)
        guard authenticatedUser.isAdmin else { throw Abort(.unauthorized) }
        
        
        let validateUserBody = try req.content.decode(ValidateUserBody.self)
        
        let validateUserEmail = validateUserBody.userToValidateEmail
        
        
        guard let userToValidate = try await User
            .query(on: req.db)
            .filter(\.$email == validateUserEmail)
            .first()
        else {
            throw Abort(.notFound)
        }
        
        userToValidate.isValidated = true
        
        try await userToValidate.update(on: req.db)
        
        return .accepted
    }
}


struct ValidateUserBody: Decodable {
    let userToValidateEmail: String
}
