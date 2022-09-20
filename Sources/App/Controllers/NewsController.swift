//
//  NewsController.swift
//  
//
//  Created by Saddam Satouyev on 12/09/2022.
//

import Fluent
import Vapor

struct NewsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let newsRoutes = routes.grouped("news")
        newsRoutes.get(use: index)
        newsRoutes.post(use: create)
        newsRoutes.group(":newsID") { news in
            news.delete(use: delete)
        }
    }
    
    
    func index(req: Request) throws -> EventLoopFuture<[News]> {
        return News.query(on: req.db)
            .sort(\.$titleNews, .ascending)
            .all()
    }

    func create(req: Request) throws -> EventLoopFuture<News> {
        let news = try req.content.decode(News.self)
        return news.save(on: req.db).map { news }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return News.find(req.parameters.get("newsID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }


}
