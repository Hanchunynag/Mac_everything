import Foundation
import Testing
@testable import MacEverything

struct SearchServiceStressTests {
    @Test func limitedSearchesReturnWithinRequestedLimit() async throws {
        let service = SearchService()
        let request = SearchRequest(text: "a", scope: .home, mode: .name, limit: 5)

        let results = try await service.search(request)

        #expect(results.count <= 5)
    }

    @Test func zeroLimitReturnsNoResults() async throws {
        let service = SearchService()
        let request = SearchRequest(text: "a", scope: .home, mode: .name, limit: 0)

        let results = try await service.search(request)

        #expect(results.isEmpty)
    }

    @Test func concurrentSearchesDoNotDeadlock() async throws {
        let service = SearchService()
        let queries = ["a", "e", "README", "swift", "ext:md", "date:today"]

        try await withThrowingTaskGroup(of: [FileResult].self) { group in
            for query in queries {
                group.addTask {
                    let request = SearchRequest(text: query, scope: .home, mode: .name, limit: 10)
                    return try await service.search(request)
                }
            }

            for try await results in group {
                #expect(results.count <= 10)
            }
        }
    }
}
