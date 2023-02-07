import XCTest
@testable import MemosAPI

let memosServer = URL(string: "http://your.domain.com")!
let memosOpenId = "your openid"
let memos = Memos(host: memosServer, openId: memosOpenId)


final class MemosAPITests: XCTestCase {
    
    func testListMemos() async throws {
        let listmemos = try await memos.listMemos(data: nil)
        debugPrint("listMemos:", listmemos)
        XCTAssertNotNil(listmemos)
    }
    
}
