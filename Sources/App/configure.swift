import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "zerochomage_db_manager",
        password: Environment.get("DATABASE_PASSWORD") ?? "passwordzero",
        database: Environment.get("DATABASE_NAME") ?? "zerochomage_db"
    ), as: .psql)

    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserToken())
    
    try app.autoMigrate().wait()

    app.views.use(.leaf)

    

    // register routes
    try routes(app)
}
