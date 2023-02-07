import Foundation

protocol MemosAPI {
    associatedtype Param = ()
    associatedtype Input: Encodable = Data
    associatedtype Output: Decodable = Data
    
    static var path: String { get }
    static var method: HTTPMethod { get }
    static var encodeMode: HTTPBodyEncodeMode { get }
    static var decodeMode: HTTPBodyDecodeMode { get }
    static func path(_ memos: Memos, _ param: Param) -> String
}

extension MemosAPI {
    static var path: String {
        return "/"
    }
}

extension MemosAPI where Self.Param == () {
    static func path(_ memos: Memos, _ param: Param) -> String {
        return Self.path
    }
}

public struct MemosOutput<T: Decodable>: Decodable {
    public let data: T
}

public struct MemosSignIn: MemosAPI {
    public struct Input: Encodable {
        public let email: String
        public let username: String
        public let password: String
    }

    public typealias Output = MemosOutput<MemosUser>
    
    static let method: HTTPMethod = .post
    static let encodeMode: HTTPBodyEncodeMode = .json
    static let decodeMode: HTTPBodyDecodeMode = .json
    static let path = "/api/auth/signin"
}

public struct MemosLogout: MemosAPI {
    static let method: HTTPMethod = .post
    static let encodeMode: HTTPBodyEncodeMode = .none
    static let decodeMode: HTTPBodyDecodeMode = .none
    static let path = "/api/auth/signout"
}

public struct MemosMe: MemosAPI {
    public typealias Output = MemosOutput<MemosUser>
    
    static let method: HTTPMethod = .get
    static let encodeMode: HTTPBodyEncodeMode = .none
    static let decodeMode: HTTPBodyDecodeMode = .json
    static let path = "/api/user/me"
}

public struct MemosListMemo: MemosAPI {
    public struct Input: Encodable {
        public let creatorId: Int?
        public let rowStatus: MemosRowStatus?
        public let visibility: MemosVisibility?
    }

    public typealias Output = MemosOutput<[Memo]>
    
    static let method: HTTPMethod = .get
    static let encodeMode: HTTPBodyEncodeMode = .urlencoded
    static let decodeMode: HTTPBodyDecodeMode = .json
    static let path = "/api/memo"
}

public struct MemosTag: MemosAPI {
    public struct Input: Encodable {
        public let creatorId: Int?
    }

    public typealias Output = MemosOutput<[String]>
    
    static let method: HTTPMethod = .get
    static let encodeMode: HTTPBodyEncodeMode = .urlencoded
    static let decodeMode: HTTPBodyDecodeMode = .json
    static let path = "/api/tag"
}


public struct MemosCreate: MemosAPI {
    public struct Input: Encodable {
         let content: String
         let visibility: MemosVisibility?
         let resourceIdList: [Int]?
        public init(content: String, visibility: MemosVisibility?, resourceIdList: [Int]?) {
            self.content = content
            self.visibility = visibility
            self.resourceIdList = resourceIdList
        }
        
    }

    public typealias Output = MemosOutput<Memo>
    
    static let method: HTTPMethod = .post
    static let encodeMode: HTTPBodyEncodeMode = .json
    static let decodeMode: HTTPBodyDecodeMode = .json
    static let path = "/api/memo"
}

public struct MemosOrganizer: MemosAPI {
    public struct Input: Encodable {
        public let pinned: Bool
    }

    public typealias Output = MemosOutput<Memo>
    public typealias Param = Int
    
    static let method: HTTPMethod = .post
    static let encodeMode: HTTPBodyEncodeMode = .json
    static let decodeMode: HTTPBodyDecodeMode = .json
    static func path(_ memos: Memos, _ params: Int) -> String { "/api/memo/\(params)/organizer" }
}

public struct MemosPatch: MemosAPI {
    public struct Input: Encodable {
        public let id: Int
        public let createdTs: Date?
        public let rowStatus: MemosRowStatus?
        public let content: String?
        public let visibility: MemosVisibility?
        public let resourceIdList: [Int]?
    }

    public typealias Output = MemosOutput<Memo>
    public typealias Param = Int
    
    static let method: HTTPMethod = .patch
    static let encodeMode: HTTPBodyEncodeMode = .json
    static let decodeMode: HTTPBodyDecodeMode = .json
    static func path(_ memos: Memos, _ params: Int) -> String { "/api/memo/\(params)" }
}

public struct MemosDelete: MemosAPI {
    public typealias Output = Bool
    public typealias Param = Int
    
    static let method: HTTPMethod = .delete
    static let encodeMode: HTTPBodyEncodeMode = .none
    static let decodeMode: HTTPBodyDecodeMode = .json
    static func path(_ memos: Memos, _ params: Int) -> String { "/api/memo/\(params)" }
}

public struct MemosListResource: MemosAPI {
    public typealias Output = MemosOutput<[Resource]>
    
    static let method: HTTPMethod = .get
    static let encodeMode: HTTPBodyEncodeMode = .none
    static let decodeMode: HTTPBodyDecodeMode = .json
    static let path = "/api/resource"
}

public struct MemosUploadResource: MemosAPI {
    public typealias Input = [Multipart]
    public typealias Output = MemosOutput<Resource>
    
    static let method: HTTPMethod = .post
    static let encodeMode: HTTPBodyEncodeMode = .multipart(boundary: UUID().uuidString)
    static let decodeMode: HTTPBodyDecodeMode = .json
    static func path(_ memos: Memos, _ params: ()) -> String {
        memos.status != nil && memos.status?.profile.version.compare("0.10.2", options: .numeric)
            != .orderedDescending ? "/api/resource/blob" : "/api/resource"
    }
}

public struct MemosDeleteResource: MemosAPI {
    public typealias Output = Bool
    public typealias Param = Int
    
    static let method: HTTPMethod = .delete
    static let encodeMode: HTTPBodyEncodeMode = .none
    static let decodeMode: HTTPBodyDecodeMode = .json
    static func path(_ memos: Memos, _ params: Int) -> String { "/api/resource/\(params)" }
}

public struct MemosAuth: MemosAPI {
    static let method: HTTPMethod = .get
    static let encodeMode: HTTPBodyEncodeMode = .none
    static let decodeMode: HTTPBodyDecodeMode = .none
    static let path = "/auth"
}

public struct MemosStatus: MemosAPI {
    public typealias Output = MemosOutput<MemosServerStatus>
    
    static let method: HTTPMethod = .get
    static let encodeMode: HTTPBodyEncodeMode = .none
    static let decodeMode: HTTPBodyDecodeMode = .json
    static let path = "/api/status"
}

public struct MemosErrorOutput: Decodable {
    public let error: String
    public let message: String
}

extension MemosAPI {
    static func request(_ memos: Memos, data: Input?, param: Param) async throws -> Output {
        var url = memos.host.appendingPathComponent(Self.path(memos, param))
                
        if method == .get && encodeMode == .urlencoded && data != nil {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = try encodeToQueryItems(data)
            url = components.url!
        }
        
        if let openId = memos.openId, !openId.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            var queryItems = components.queryItems ?? []
            queryItems.append(URLQueryItem(name: "openId", value: openId))
            components.queryItems = queryItems
            url = components.url!
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let accept = decodeMode.contentType() {
            request.setValue(accept, forHTTPHeaderField: "Accept")
        }

        if (method == .post || method == .put || method == .patch) && data != nil {
            if let contentType = encodeMode.contentType() {
                request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            }
            request.httpBody = try encodeMode.encode(data)
        }
        
        let (data, response) = try await memos.session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw MemosError.unknown
        }
        if response.statusCode < 200 || response.statusCode >= 300 {
            let errorOutput: MemosErrorOutput
            do {
                errorOutput = try decodeMode.decode(data)
            } catch {
                throw MemosError.invalidStatusCode(response.statusCode, String(data: data, encoding: .utf8))
            }
            throw MemosError.invalidStatusCode(response.statusCode, errorOutput.message)
        }
        
        return try decodeMode.decode(data)
    }
}
