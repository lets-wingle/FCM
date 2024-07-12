import Foundation
import Vapor

extension FCM {
    func getAccessToken() -> EventLoopFuture<String> {
        guard let gAuth = gAuth else {
            fatalError("FCM gAuth can't be nil")
        }
        if !gAuth.hasExpired, let token = accessToken {
            return client.eventLoop.future(token)
        }

        return client.post(URI(string: audience)) { (req) in
            try req.content.encode([
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": try self.getJWTSync(),
            ])
        }
        .validate()
        .flatMapThrowing { res -> String in
            struct Result: Codable {
                let access_token: String
            }

            return try res.content.decode(Result.self, using: JSONDecoder()).access_token
        }
    }
}


//extension FCM {
//    func getAccessToken() -> EventLoopFuture<String> {
//        let promise = client.eventLoop.makePromise(of: String.self)
//
//        Task {
//            do {
//                let accessToken = try await getAccessToken()
//                promise.succeed(accessToken)
//            } catch {
//                promise.fail(error)
//            }
//        }
//
//        return promise.futureResult
//    }
//
//    func getAccessToken() async throws -> String {
//        struct Result: Codable {
//            let access_token: String
//        }
//
//        guard let gAuth = gAuth else {
//            fatalError("FCM gAuth can't be nil")
//        }
//        if !gAuth.hasExpired, let token = accessToken {
//            return token
//        }
//
//        let jwt = try await self.getJWT()
//
//        let response = try await client.post(URI(string: audience), beforeSend: { req in
//            try req.content.encode([
//                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
//                "assertion": jwt,
//            ])
//        })
//
//        return try response.content.decode(Result.self, using: JSONDecoder()).access_token
//    }
//}
