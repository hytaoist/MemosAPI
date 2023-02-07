import Foundation
import CryptoKit

private let cookieStorage = HTTPCookieStorage.sharedCookieStorage(forGroupContainerIdentifier: groupContainerIdentifier)

private let urlSessionConfiguration = {
    let configuration = URLSessionConfiguration.default
    configuration.httpCookieStorage = cookieStorage
    return configuration
}()

public class Memos {
    public let host: URL
    public let openId: String?
    public let session: URLSession
    private(set) var status: MemosServerStatus? = nil
    
    public init(host: URL, openId: String?) {
        self.host = host
        self.openId = (openId?.isEmpty ?? true) ? nil : openId
        session = URLSession(configuration: urlSessionConfiguration)
        
        // Migrate cookies to group container
        let legacyCookieStorage = HTTPCookieStorage.shared
        if let legacyCookies = legacyCookieStorage.cookies(for: host), !legacyCookies.isEmpty {
            cookieStorage.setCookies(legacyCookies, for: host, mainDocumentURL: nil)
            legacyCookies.forEach(legacyCookieStorage.deleteCookie)
        }
        
        // No longer uses cookie when logged-in with Open API
        if let openId = openId, !openId.isEmpty {
            session.configuration.httpCookieStorage?.removeCookies(since: .distantPast)
        }
    }
    
    public func signIn(data: MemosSignIn.Input) async throws -> MemosSignIn.Output {
        return try await MemosSignIn.request(self, data: data, param: ())
    }
    
    public func logout() async throws {
        do {
            _ = try await MemosLogout.request(self, data: nil, param: ())
        } catch {
            print(error)
        }
        session.configuration.httpCookieStorage?.removeCookies(since: .distantPast)
    }
    
    public func me() async throws -> MemosMe.Output {
        return try await MemosMe.request(self, data: nil, param: ())
    }
    
    public func listMemos(data: MemosListMemo.Input?) async throws -> MemosListMemo.Output {
        return try await MemosListMemo.request(self, data: data, param: ())
    }
    
    public func tags(data: MemosTag.Input?) async throws -> MemosTag.Output {
        return try await MemosTag.request(self, data: data, param: ())
    }
    
    public func createMemo(data: MemosCreate.Input) async throws -> MemosCreate.Output {
        return try await MemosCreate.request(self, data: data, param: ())
    }
    
    public func updateMemoOrganizer(memoId: Int, data: MemosOrganizer.Input) async throws -> MemosOrganizer.Output {
        return try await MemosOrganizer.request(self, data: data, param: memoId)
    }
    
    public func updateMemo(data: MemosPatch.Input) async throws -> MemosPatch.Output {
        return try await MemosPatch.request(self, data: data, param: data.id)
    }
    
    public func deleteMemo(id: Int) async throws -> MemosDelete.Output {
        return try await MemosDelete.request(self, data: nil, param: id)
    }
    
    public func listResources() async throws -> MemosListResource.Output {
        return try await MemosListResource.request(self, data: nil, param: ())
    }
    
    public func uploadResource(imageData: Data, filename: String, contentType: String) async throws -> MemosUploadResource.Output {
        return try await MemosUploadResource.request(self, data: [Multipart(name: "file", filename: filename, contentType: contentType, data: imageData)], param: ())
    }
    
    public func deleteResource(id: Int) async throws -> MemosDeleteResource.Output {
        return try await MemosDeleteResource.request(self, data: nil, param: id)
    }
    
    public func auth() async throws {
        _ = try await MemosAuth.request(self, data: nil, param: ())
    }
    
    public func loadStatus() async throws {
        let response = try await MemosStatus.request(self, data: nil, param: ())
        status = response.data
    }
    
    public func url(for resource: Resource) -> URL {
        // to be compatible with future Memos release with resource visibility
        var url = host.appendingPathComponent(resource.path())
        if let openId = openId, !openId.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            var queryItems = components.queryItems ?? []
            queryItems.append(URLQueryItem(name: "openId", value: openId))
            components.queryItems = queryItems
            url = components.url!
        }
        return url
    }
    
    @available(iOS 15.0, *)
    public func download(url: URL) async throws -> URL {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupContainerIdentifier) else { throw MemosError.unknown }
        
        let hash = SHA256.hash(data: url.absoluteString.data(using: .utf8)!)
        let hex = hash.map { String(format: "%02X", $0) }[0...10].joined()
        
        let downloadDestination = containerURL.appendingPathComponent("Library/Caches")
            .appendingPathComponent(hex).appendingPathExtension(url.pathExtension)
        
        try FileManager.default.createDirectory(at: downloadDestination.deletingLastPathComponent(), withIntermediateDirectories: true)

        do {
            if try downloadDestination.checkResourceIsReachable() {
                return downloadDestination
            }
        } catch {}
        
        let (tmpURL, response) = try await session.download(for: URLRequest(url: url))
        guard let response = response as? HTTPURLResponse else {
            throw MemosError.unknown
        }
        if response.statusCode < 200 || response.statusCode >= 300 {
            throw MemosError.invalidStatusCode(response.statusCode, url.absoluteString)
        }
        
        try FileManager.default.moveItem(at: tmpURL, to: downloadDestination)
        return downloadDestination
    }
}
