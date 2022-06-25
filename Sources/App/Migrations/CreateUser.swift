import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users")
            .id()
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("first_name", .string)
            .field("last_name", .string)
            .field("address", .string)
            .field("zip_code", .string)
            .field("city", .string)
            .field("phone_number", .string)
            .field("date_of_birth", .string)
            .field("gender", .string)
            .field("civil_status", .string)
            .unique(on: "email")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("users").delete()
    }
}
