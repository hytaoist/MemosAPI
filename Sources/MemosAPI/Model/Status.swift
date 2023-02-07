import Foundation

public struct MemosProfile: Decodable {
    public let data: String
    public let dsn: String
    public let mode: String
    public let port: Int
    public let version: String
}

public struct MemosServerStatus: Decodable {
    public let host: MemosUser
    public let profile: MemosProfile
}
