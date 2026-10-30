import XCTest
@testable import BRAVPlayer

final class BRAVTests: XCTestCase {
    func testM3UParserReadsChannelAndCategory() {
        let playlist = """
        #EXTM3U
        #EXTINF:-1 tvg-logo="https://example.com/logo.png" group-title="Notícias",Canal Exemplo
        https://example.com/live/index.m3u8
        """
        let result = M3UParser.parse(playlist)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Canal Exemplo")
        XCTAssertEqual(result.first?.category, "Notícias")
        XCTAssertEqual(result.first?.streamURL.absoluteString, "https://example.com/live/index.m3u8")
    }
}
