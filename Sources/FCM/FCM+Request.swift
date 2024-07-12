import Vapor

extension Request {
    public var fcm: FCM {
        application.fcm
    }
}
