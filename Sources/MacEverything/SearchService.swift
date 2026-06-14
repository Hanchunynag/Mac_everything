import Foundation

struct SearchRequest: Sendable {
    let text: String
    let scope: SearchScope
    let mode: SearchMode
    let limit: Int
}

struct SearchService: Sendable {
    func search(_ request: SearchRequest) async throws -> [FileResult] {
        try await Task.detached(priority: .userInitiated) {
            let limit = max(request.limit, 0)
            let predicate = SearchQueryCompiler.predicate(for: request.text, defaultMode: request.mode)
            var arguments = ["-0"]

            for root in request.scope.roots {
                arguments.append("-onlyin")
                arguments.append(root)
            }

            arguments.append(predicate)

            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/mdfind")
            process.arguments = arguments

            let output = Pipe()
            let error = Pipe()
            process.standardOutput = output
            process.standardError = error

            try process.run()
            let outputResult = try SearchOutputCollector.readLimitedData(
                from: output.fileHandleForReading,
                process: process,
                limit: limit
            )
            process.waitUntilExit()

            guard process.terminationStatus == 0 || outputResult.terminatedAfterLimit else {
                let data = error.fileHandleForReading.readDataToEndOfFile()
                let message = String(data: data, encoding: .utf8) ?? "mdfind failed"
                throw SearchError.commandFailed(message.trimmingCharacters(in: .whitespacesAndNewlines))
            }

            return outputResult.data
                .split(separator: 0)
                .prefix(limit)
                .compactMap { String(data: Data($0), encoding: .utf8) }
                .map(FileResult.init(path:))
        }
        .value
    }
}

private enum SearchOutputCollector {
    static func readLimitedData(
        from handle: FileHandle,
        process: Process,
        limit: Int
    ) throws -> (data: Data, terminatedAfterLimit: Bool) {
        guard limit > 0 else {
            process.terminate()
            return (Data(), true)
        }

        var data = Data()
        var resultCount = 0
        var terminatedAfterLimit = false

        while true {
            try Task.checkCancellation()

            let chunk = handle.availableData
            if chunk.isEmpty {
                break
            }

            data.append(chunk)
            resultCount += chunk.reduce(0) { count, byte in
                count + (byte == 0 ? 1 : 0)
            }

            if resultCount >= limit {
                process.terminate()
                terminatedAfterLimit = true
                break
            }
        }

        return (data, terminatedAfterLimit)
    }
}

enum SearchError: LocalizedError {
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .commandFailed(let message):
            return message.isEmpty ? "Search command failed." : message
        }
    }
}

enum SearchMode: String, CaseIterable, Identifiable, Sendable {
    case name = "Name"
    case path = "Path"
    case content = "Content"

    var id: String { rawValue }
}

enum SearchScope: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case home = "Home"
    case desktop = "Desktop"
    case documents = "Documents"
    case downloads = "Downloads"

    var id: String { rawValue }

    var roots: [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        switch self {
        case .all:
            return []
        case .home:
            return [home]
        case .desktop:
            return [home + "/Desktop"]
        case .documents:
            return [home + "/Documents"]
        case .downloads:
            return [home + "/Downloads"]
        }
    }
}

enum SearchLimit: Int, CaseIterable, Identifiable {
    case twoHundred = 200
    case fiveHundred = 500
    case thousand = 1000
    case fiveThousand = 5000

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .twoHundred:
            return "200"
        case .fiveHundred:
            return "500"
        case .thousand:
            return "1,000"
        case .fiveThousand:
            return "5,000"
        }
    }
}
