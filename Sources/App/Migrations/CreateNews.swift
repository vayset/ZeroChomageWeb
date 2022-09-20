//
//  File.swift
//  
//
//  Created by Saddam Satouyev on 12/09/2022.
//

import Fluent

struct CreateNews: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("news")
            .id()
            .field("titleNews", .string, .required)
            .field("descriptionNews", .string, .required)
            .field("bodyNews", .string, .required)
            .field("createdAt", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("news").delete()
    }
}
