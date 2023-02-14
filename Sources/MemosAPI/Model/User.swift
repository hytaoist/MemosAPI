import Foundation

public struct MemosUserSetting: Decodable {
    public let key: String
    public let value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
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
    
    public init(createdTs: Date, email: String?, username: String?, id: Int, name: String?, nickname: String?, openId: String, role: String, rowStatus: MemosRowStatus, updatedTs: Date, userSettingList: [MemosUserSetting]?) {
        self.createdTs = createdTs
        self.email = email
        self.username = username
        self.id = id
        self.name = name
        self.nickname = nickname
        self.openId = openId
        self.role = role
        self.rowStatus = rowStatus
        self.updatedTs = updatedTs
        self.userSettingList = userSettingList
    }
}
