import Vapor
import Foundation
import JWT

// MARK: Engine

public class FCM {
    let application: Application
    
    let client: Client
    
    let scope = "https://www.googleapis.com/auth/cloud-platform"
    let audience = "https://www.googleapis.com/oauth2/v4/token"
    let actionsBaseURL = "https://fcm.googleapis.com/v1/projects/"
    let iidURL = "https://iid.googleapis.com/iid/v1:"
    let batchURL = "https://fcm.googleapis.com/batch"

    public var configuration: FCMConfiguration? {
        didSet {
            if let configuration, configuration.projectId != oldValue?.projectId {
                warmUpCache(with: configuration.email)
            }
        }
    }

    private func warmUpCache(with email: String) {
        if gAuth == nil {
            gAuth = GAuthPayload(iss: email, sub: email, scope: scope, aud: audience)
        }
        if jwt == nil {
            do {
                jwt = try generateJWTSync()
            } catch {
                fatalError("FCM Unable to generate JWT: \(error)")
            }
        }
    }

    var jwt: String?
    var accessToken: String?
    var gAuth: GAuthPayload?

    // MARK: Default configurations
    
    public var apnsDefaultConfig: FCMApnsConfig<FCMApnsPayload>? {
        get { configuration?.apnsDefaultConfig }
        set { configuration?.apnsDefaultConfig = newValue }
    }
    
    public var androidDefaultConfig: FCMAndroidConfig? {
        get { configuration?.androidDefaultConfig }
        set { configuration?.androidDefaultConfig = newValue }
    }
    
    public var webpushDefaultConfig: FCMWebpushConfig? {
        get { configuration?.webpushDefaultConfig }
        set { configuration?.webpushDefaultConfig = newValue }
    }
    
    // MARK: Initialization

    init(application: Application, client: Client) {
        self.application = application
        self.client = client
    }

    public convenience init(application: Application) {
        self.init(application: application, client: application.client)
    }

    public convenience init(request: Request) {
        self.init(application: request.application, client: request.client)
    }
}
