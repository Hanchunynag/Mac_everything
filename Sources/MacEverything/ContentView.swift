import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var model = SearchViewModel()

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
            tableHeader
            Divider()
            resultList
            Divider()
            statusBar
        }
        .frame(minWidth: 900, minHeight: 560)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            #if SWIFT_PACKAGE
            WindowActivation.activateApp()
            #endif
        }
        .onChange(of: model.query) {
            model.scheduleSearch()
        }
        .onMoveCommand { direction in
            switch direction {
            case .up:
                model.moveSelection(by: -1)
            case .down:
                model.moveSelection(by: 1)
            default:
                break
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)

            NativeSearchField(
                text: $model.query,
                placeholder: "Search files and folders"
            ) {
                    model.openSelected()
            }
            .frame(minHeight: 24)
            .layoutPriority(1)

            if model.isSearching {
                ProgressView()
                    .controlSize(.small)
            }

            Picker("Mode", selection: $model.mode) {
                ForEach(SearchMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 250)

            Picker("Scope", selection: $model.scope) {
                ForEach(SearchScope.allCases) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .frame(width: 130)

            Picker("Limit", selection: $model.limit) {
                ForEach(SearchLimit.allCases) { limit in
                    Text(limit.label).tag(limit)
                }
            }
            .frame(width: 90)

            Button {
                model.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .keyboardShortcut("r", modifiers: [.command])
            .help("Refresh")

            Button {
                model.revealSelected()
            } label: {
                Image(systemName: "folder")
            }
            .keyboardShortcut(.return, modifiers: [.command])
            .disabled(model.selectedResult == nil)
            .help("Reveal in Finder")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            headerText("Name")
                .frame(minWidth: 220, maxWidth: .infinity, alignment: .leading)
            headerText("Path")
                .frame(minWidth: 260, maxWidth: .infinity, alignment: .leading)
            headerText("Kind")
                .frame(width: 140, alignment: .leading)
            headerText("Size")
                .frame(width: 90, alignment: .trailing)
            headerText("Modified")
                .frame(width: 150, alignment: .leading)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(nsColor: .textBackgroundColor))
    }

    private func headerText(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
    }

    private var resultList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(model.results) { result in
                        ResultRow(
                            result: result,
                            isSelected: result.id == model.selectedID
                        )
                        .id(result.id)
                        .onTapGesture {
                            model.select(result)
                        }
                        .onTapGesture(count: 2) {
                            model.select(result)
                            model.openSelected()
                        }
                        .contextMenu {
                            Button("Open") {
                                model.select(result)
                                model.openSelected()
                            }
                            Button("Reveal in Finder") {
                                model.select(result)
                                model.revealSelected()
                            }
                            Button("Copy Path") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(result.path, forType: .string)
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .overlay {
                if model.results.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text(model.statusText)
                    )
                }
            }
            .onChange(of: model.selectedID) {
                if let id = model.selectedID {
                    withAnimation(.easeOut(duration: 0.12)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
    }

    private var statusBar: some View {
        HStack {
            Text(model.statusText)
                .foregroundStyle(.secondary)

            Spacer()

            Text("Enter: open  Cmd+Enter: reveal  Cmd+R: refresh")
                .foregroundStyle(.tertiary)
        }
        .font(.system(size: 12))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

private struct ResultRow: View {
    let result: FileResult
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: result.path))
                    .resizable()
                    .frame(width: 18, height: 18)
                Text(result.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(minWidth: 220, maxWidth: .infinity, alignment: .leading)

            Text(result.directory)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(minWidth: 260, maxWidth: .infinity, alignment: .leading)

            Text(result.kind)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 140, alignment: .leading)

            Text(result.sizeDescription)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 90, alignment: .trailing)

            Text(result.modifiedDescription)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 150, alignment: .leading)
        }
        .font(.system(size: 13))
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .background(rowBackground)
    }

    private var rowBackground: some View {
        Group {
            if isSelected {
                Color.accentColor.opacity(0.22)
            } else {
                Color.clear
            }
        }
    }
}
