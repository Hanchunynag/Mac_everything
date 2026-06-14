import Testing
@testable import MacEverything

struct SearchQueryCompilerTests {
    @Test func plainTokensUseSelectedDefaultMode() {
        let predicate = SearchQueryCompiler.predicate(for: "report final", defaultMode: .name)

        #expect(predicate == #"kMDItemFSName == "*report*"cd && kMDItemFSName == "*final*"cd"#)
    }

    @Test func quotedPhrasesStayTogether() {
        let predicate = SearchQueryCompiler.predicate(for: #"content:"orbital elements" ext:pdf"#, defaultMode: .name)

        #expect(predicate.contains(#"kMDItemTextContent == "*orbital elements*"cd"#))
        #expect(predicate.contains(#"kMDItemFSName == "*.pdf"cd"#))
    }

    @Test func sizeOperatorsCompileToByteComparisons() {
        let predicate = SearchQueryCompiler.predicate(for: "size:>10mb", defaultMode: .name)

        #expect(predicate == "kMDItemFSSize > 10485760")
    }

    @Test func relativeDatesUseSpotlightTimeMacros() {
        let predicate = SearchQueryCompiler.predicate(for: "date:week", defaultMode: .name)

        #expect(predicate == "kMDItemFSContentChangeDate >= $time.this_week")
    }

    @Test func isoDatesUseSpotlightISOTimeMacro() {
        let predicate = SearchQueryCompiler.predicate(for: "modified:<2026-06-01", defaultMode: .name)

        #expect(predicate == "kMDItemFSContentChangeDate < $time.iso(2026-06-01)")
    }

    @Test func folderTypeCompilesToContentTypeClause() {
        let predicate = SearchQueryCompiler.predicate(for: "type:folder", defaultMode: .name)

        #expect(predicate == #"kMDItemContentType == "public.folder""#)
    }
}
