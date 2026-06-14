import Foundation

enum SearchQueryCompiler {
    static func predicate(for text: String, defaultMode: SearchMode) -> String {
        let clauses = tokenize(text).compactMap { token in
            clause(for: token, defaultMode: defaultMode)
        }

        return clauses.isEmpty ? "kMDItemFSName == \"*\"" : clauses.joined(separator: " && ")
    }

    private static func clause(for token: String, defaultMode: SearchMode) -> String? {
        guard !token.isEmpty else { return nil }

        if let split = splitOperator(token) {
            switch split.key {
            case "name", "n":
                return nameClause(split.value)
            case "path", "p":
                return pathClause(split.value)
            case "content", "text", "c":
                return contentClause(split.value)
            case "ext", "extension":
                return extensionClause(split.value)
            case "size", "sz":
                return sizeClause(split.value) ?? defaultClause(token, mode: defaultMode)
            case "date", "modified", "dm":
                return dateClause(split.value) ?? defaultClause(token, mode: defaultMode)
            case "type", "kind":
                return typeClause(split.value) ?? defaultClause(token, mode: defaultMode)
            default:
                return defaultClause(token, mode: defaultMode)
            }
        }

        return defaultClause(token, mode: defaultMode)
    }

    private static func defaultClause(_ value: String, mode: SearchMode) -> String {
        switch mode {
        case .name:
            return nameClause(value)
        case .path:
            return pathClause(value)
        case .content:
            let escaped = escapePattern(value)
            return "(kMDItemFSName == \"*\(escaped)*\"cd || kMDItemTextContent == \"*\(escaped)*\"cd)"
        }
    }

    private static func nameClause(_ value: String) -> String {
        "kMDItemFSName == \"*\(escapePattern(value))*\"cd"
    }

    private static func pathClause(_ value: String) -> String {
        "kMDItemPath == \"*\(escapePattern(value))*\"cd"
    }

    private static func contentClause(_ value: String) -> String {
        "kMDItemTextContent == \"*\(escapePattern(value))*\"cd"
    }

    private static func extensionClause(_ value: String) -> String? {
        let extensions = value
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { $0.hasPrefix(".") ? String($0.dropFirst()) : $0 }
            .filter { !$0.isEmpty }

        guard !extensions.isEmpty else { return nil }

        let clauses = extensions.map { ext in
            "kMDItemFSName == \"*.\(escapePattern(ext))\"cd"
        }
        return clauses.count == 1 ? clauses[0] : "(" + clauses.joined(separator: " || ") + ")"
    }

    private static func sizeClause(_ value: String) -> String? {
        guard let comparison = parseComparison(value, parseValue: parseByteCount) else {
            return nil
        }

        return "kMDItemFSSize \(comparison.operator) \(comparison.value)"
    }

    private static func dateClause(_ value: String) -> String? {
        let lower = value.lowercased()
        switch lower {
        case "today":
            return "kMDItemFSContentChangeDate >= $time.today"
        case "yesterday":
            return "(kMDItemFSContentChangeDate >= $time.yesterday && kMDItemFSContentChangeDate < $time.today)"
        case "week", "thisweek", "this_week":
            return "kMDItemFSContentChangeDate >= $time.this_week"
        case "month", "thismonth", "this_month":
            return "kMDItemFSContentChangeDate >= $time.this_month"
        case "year", "thisyear", "this_year":
            return "kMDItemFSContentChangeDate >= $time.this_year"
        default:
            break
        }

        guard let comparison = parseComparison(value, parseValue: parseISODate) else {
            return nil
        }

        return "kMDItemFSContentChangeDate \(comparison.operator) \(comparison.value)"
    }

    private static func typeClause(_ value: String) -> String? {
        switch value.lowercased() {
        case "folder", "dir", "directory":
            return "kMDItemContentType == \"public.folder\""
        case "file":
            return "kMDItemContentType != \"public.folder\""
        default:
            return nil
        }
    }

    private static func parseComparison<T>(
        _ input: String,
        parseValue: (String) -> T?
    ) -> (operator: String, value: T)? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let operators = [">=", "<=", ">", "<", "="]
        for op in operators where trimmed.hasPrefix(op) {
            let rawValue = String(trimmed.dropFirst(op.count))
            guard let parsed = parseValue(rawValue) else { return nil }
            return (op == "=" ? "==" : op, parsed)
        }

        guard let parsed = parseValue(trimmed) else { return nil }
        return (">=", parsed)
    }

    private static func parseByteCount(_ input: String) -> Int64? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let numberPart = trimmed.prefix { $0.isNumber || $0 == "." }
        let unitPart = trimmed.dropFirst(numberPart.count)
        guard let value = Double(numberPart), value >= 0 else { return nil }

        let multiplier: Double
        switch unitPart {
        case "", "b":
            multiplier = 1
        case "k", "kb":
            multiplier = 1_024
        case "m", "mb":
            multiplier = 1_024 * 1_024
        case "g", "gb":
            multiplier = 1_024 * 1_024 * 1_024
        case "t", "tb":
            multiplier = 1_024 * 1_024 * 1_024 * 1_024
        default:
            return nil
        }

        return Int64(value * multiplier)
    }

    private static func parseISODate(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil else {
            return nil
        }

        return "$time.iso(\(trimmed))"
    }

    private static func splitOperator(_ token: String) -> (key: String, value: String)? {
        guard let colonIndex = token.firstIndex(of: ":") else { return nil }

        let key = token[..<colonIndex].lowercased()
        let value = String(token[token.index(after: colonIndex)...])
        guard !key.isEmpty, !value.isEmpty else { return nil }
        return (String(key), value)
    }

    private static func tokenize(_ text: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        var isQuoted = false
        var isEscaping = false

        for character in text {
            if isEscaping {
                current.append(character)
                isEscaping = false
                continue
            }

            if character == "\\" {
                isEscaping = true
                continue
            }

            if character == "\"" {
                isQuoted.toggle()
                continue
            }

            if character.isWhitespace, !isQuoted {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
            } else {
                current.append(character)
            }
        }

        if isEscaping {
            current.append("\\")
        }

        if !current.isEmpty {
            tokens.append(current)
        }

        return tokens
    }

    private static func escapePattern(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}
