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
            let predicate = request.mode.predicate(for: request.text)
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
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                let data = error.fileHandleForReading.readDataToEndOfFile()
                let message = String(data: data, encoding: .utf8) ?? "mdfind failed"
                throw SearchError.commandFailed(message.trimmingCharacters(in: .whitespacesAndNewlines))
            }

            let data = output.fileHandleForReading.readDataToEndOfFile()
            return data
                .split(separator: 0)
                .prefix(request.limit)
                .compactMap { String(data: Data($0), encoding: .utf8) }
                .map(FileResult.init(path:))
        }
        .value
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

    func predicate(for text: String) -> String {
        let tokens = text
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
            .filter { !$0.isEmpty }

        let clauses = tokens.map { token -> String in
            let pattern = SearchPredicate.escapePattern(token)
            switch self {
            case .name:
                return "kMDItemFSName == \"*\(pattern)*\"cd"
            case .path:
                return "kMDItemPath == \"*\(pattern)*\"cd"
            case .content:
                return "(kMDItemFSName == \"*\(pattern)*\"cd || kMDItemTextContent == \"*\(pattern)*\"cd)"
            }
        }

        return clauses.isEmpty ? "kMDItemFSName == \"*\"" : clauses.joined(separator: " && ")
    }
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

private enum SearchPredicate {
    static func escapePattern(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}
