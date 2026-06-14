import AppKit
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var scope: SearchScope = .all {
        didSet { scheduleSearch() }
    }
    @Published var mode: SearchMode = .name {
        didSet { scheduleSearch() }
    }
    @Published var limit: SearchLimit = .fiveHundred {
        didSet { scheduleSearch() }
    }
    @Published private(set) var results: [FileResult] = []
    @Published private(set) var isSearching = false
    @Published private(set) var statusText = "Type to search indexed files."
    @Published var selectedID: FileResult.ID?

    private let service = SearchService()
    private var searchTask: Task<Void, Never>?

    func scheduleSearch() {
        searchTask?.cancel()

        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            results = []
            selectedID = nil
            isSearching = false
            statusText = "Type to search indexed files."
            return
        }

        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(130))
            guard !Task.isCancelled else { return }
            await self?.performSearch(text)
        }
    }

    func refresh() {
        scheduleSearch()
    }

    func moveSelection(by offset: Int) {
        guard !results.isEmpty else {
            selectedID = nil
            return
        }

        let currentIndex = selectedID.flatMap { id in results.firstIndex { $0.id == id } } ?? -1
        let nextIndex = min(max(currentIndex + offset, 0), results.count - 1)
        selectedID = results[nextIndex].id
    }

    func select(_ result: FileResult) {
        selectedID = result.id
    }

    func openSelected() {
        guard let selected = selectedResult else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: selected.path))
    }

    func revealSelected() {
        guard let selected = selectedResult else { return }
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: selected.path)])
    }

    var selectedResult: FileResult? {
        guard let selectedID else { return results.first }
        return results.first { $0.id == selectedID } ?? results.first
    }

    private func performSearch(_ text: String) async {
        isSearching = true
        statusText = "Searching..."

        do {
            let request = SearchRequest(text: text, scope: scope, mode: mode, limit: limit.rawValue)
            let found = try await service.search(request)
            guard !Task.isCancelled else { return }

            results = found
            selectedID = found.first?.id
            isSearching = false
            statusText = found.isEmpty
                ? "No results. Spotlight may not index this location."
                : "\(found.count) result\(found.count == 1 ? "" : "s")"
        } catch {
            guard !Task.isCancelled else { return }
            results = []
            selectedID = nil
            isSearching = false
            statusText = error.localizedDescription
        }
    }
}
