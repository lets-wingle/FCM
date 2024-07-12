import Foundation
import JWT

extension FCM {
    func generateJWT() async throws -> String {
        guard let configuration = self.configuration else {
            fatalError("FCM not configured. Use app.fcm.configuration = ...")
        }
        guard var gAuth = gAuth else {
            fatalError("FCM gAuth can't be nil")
        }
        guard let pemData = configuration.key.data(using: .utf8) else {
            fatalError("FCM unable to prepare PEM data for JWT")
        }
        gAuth = gAuth.updated()
        self.gAuth = gAuth
        let pk = try Insecure.RSA.PrivateKey(pem: pemData)
        let keys = JWTKeyCollection()
        await keys.add(rsa: pk, digestAlgorithm: .sha256)
        return try await keys.sign(gAuth)
    }

    func generateJWTSync() throws -> String {
        try UnsafeTask {
            try await self.generateJWT()
        }.get()
    }

    func getJWT() async throws -> String {
        guard let gAuth = gAuth else { fatalError("FCM gAuth can't be nil") }
        if !gAuth.hasExpired, let jwt = jwt {
            return jwt
        }
        let jwt = try await generateJWT()
        self.jwt = jwt
        return jwt
    }

    func getJWTSync() throws -> String {
        try UnsafeTask {
            try await self.getJWT()
        }.get()
    }
}

class UnsafeTask<T> {
    let semaphore = DispatchSemaphore(value: 0)
    private var result: T?
    private var receivedError: Error?
    init(block: @escaping () async throws -> T) {
        Task {
            do {
                result = try await block()
            } catch {
                receivedError = error
            }
            semaphore.signal()
        }
    }

    func get() throws -> T {
        if let result = result { return result }
        semaphore.wait()
        if let receivedError {
            throw receivedError
        }
        return result!
    }
}
