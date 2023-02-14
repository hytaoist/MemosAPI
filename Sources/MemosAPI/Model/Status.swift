import Foundation

public struct MemosProfile: Decodable {
    public let data: String
    public let dsn: String
    public let mode: String
    public let port: Int
    public let version: String
    
    public init(data: String, dsn: String, mode: String, port: Int, version: String) {
        self.data = data
        self.dsn = dsn
        self.mode = mode
        self.port = port
        self.version = version
    }
}

public struct MemosServerStatus: Decodable {
    public let host: MemosUser
    public let profile: MemosProfile
    
    public init(host: MemosUser, profile: MemosProfile) {
        self.host = host
        self.profile = profile
    }
}
