import Foundation

public struct MemosUserSetting: Decodable {
    public let key: String
    public let value: String
}

public struct MemosUser: Decodable {
    public let createdTs: Date
    public let email: String?
    public let username: String?
    public let id: Int
    public let name: String?
    public let nickname: String?
    public let openId: String
    public let role: String
    public let rowStatus: MemosRowStatus
    public let updatedTs: Date
    public let userSettingList: [MemosUserSetting]?
    
    public var displayName: String {
        nickname ?? name ?? ""
    }
    
    public var displayEmail: String {
        email ?? username ?? ""
    }
}
