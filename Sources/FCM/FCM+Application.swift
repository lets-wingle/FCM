import Vapor

extension Application {
    private struct FCMKey: StorageKey {
        typealias Value = FCM
    }

    public var fcm: FCM {
        get {
            let key = FCMKey.self
            if let existing = self.storage[key] {
                return existing
            }
            let fcm = FCM(application: self)
            self.storage[key] = fcm
            return fcm
        }
        set {
            self.storage[FCMKey.self] = newValue
        }
    }
}
