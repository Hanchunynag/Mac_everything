import AppKit
import Foundation
import UniformTypeIdentifiers

struct FileResult: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let path: String
    let directory: String
    let kind: String
    let sizeDescription: String
    let modifiedDescription: String
    let isDirectory: Bool

    init(path: String) {
        let url = URL(fileURLWithPath: path)
        let attributes = (try? FileManager.default.attributesOfItem(atPath: path)) ?? [:]
        let isDirectory = (attributes[.type] as? FileAttributeType) == .typeDirectory
        let size = attributes[.size] as? NSNumber
        let modified = attributes[.modificationDate] as? Date

        self.id = path
        self.name = url.lastPathComponent.isEmpty ? path : url.lastPathComponent
        self.path = path
        self.directory = url.deletingLastPathComponent().path
        self.kind = Self.kind(for: url, isDirectory: isDirectory)
        self.sizeDescription = isDirectory
            ? ""
            : ByteCountFormatter.string(fromByteCount: size?.int64Value ?? 0, countStyle: .file)
        self.modifiedDescription = modified.map {
            $0.formatted(date: .numeric, time: .shortened)
        } ?? ""
        self.isDirectory = isDirectory
    }

    private static func kind(for url: URL, isDirectory: Bool) -> String {
        if isDirectory {
            return "Folder"
        }

        let ext = url.pathExtension
        if let type = UTType(filenameExtension: ext),
           let description = type.localizedDescription {
            return description
        }

        return ext.isEmpty ? "File" : ext.uppercased() + " File"
    }

}
