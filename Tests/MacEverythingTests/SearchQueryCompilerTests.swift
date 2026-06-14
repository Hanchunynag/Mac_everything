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

    @Test func pathModeUsesPathByDefault() {
        let predicate = SearchQueryCompiler.predicate(for: "Downloads report", defaultMode: .path)

        #expect(predicate == #"kMDItemPath == "*Downloads*"cd && kMDItemPath == "*report*"cd"#)
    }

    @Test func contentModeSearchesNameAndTextByDefault() {
        let predicate = SearchQueryCompiler.predicate(for: "invoice", defaultMode: .content)

        #expect(predicate == #"(kMDItemFSName == "*invoice*"cd || kMDItemTextContent == "*invoice*"cd)"#)
    }

    @Test func multipleExtensionsCompileToOrGroup() {
        let predicate = SearchQueryCompiler.predicate(for: "ext:pdf,docx", defaultMode: .name)

        #expect(predicate == #"(kMDItemFSName == "*.pdf"cd || kMDItemFSName == "*.docx"cd)"#)
    }

    @Test func dottedExtensionsAreNormalized() {
        let predicate = SearchQueryCompiler.predicate(for: "ext:.swift", defaultMode: .name)

        #expect(predicate == #"kMDItemFSName == "*.swift"cd"#)
    }

    @Test func sizeOperatorsCompileToByteComparisons() {
        let predicate = SearchQueryCompiler.predicate(for: "size:>10mb", defaultMode: .name)

        #expect(predicate == "kMDItemFSSize > 10485760")
    }

    @Test func decimalSizeValuesAreSupported() {
        let predicate = SearchQueryCompiler.predicate(for: "size:>=1.5gb", defaultMode: .name)

        #expect(predicate == "kMDItemFSSize >= 1610612736")
    }

    @Test func invalidSizeFallsBackToDefaultSearch() {
        let predicate = SearchQueryCompiler.predicate(for: "size:huge", defaultMode: .name)

        #expect(predicate == #"kMDItemFSName == "*size:huge*"cd"#)
    }

    @Test func relativeDatesUseSpotlightTimeMacros() {
        let predicate = SearchQueryCompiler.predicate(for: "date:week", defaultMode: .name)

        #expect(predicate == "kMDItemFSContentChangeDate >= $time.this_week")
    }

    @Test func yesterdayBuildsBoundedDateRange() {
        let predicate = SearchQueryCompiler.predicate(for: "date:yesterday", defaultMode: .name)

        #expect(predicate == "(kMDItemFSContentChangeDate >= $time.yesterday && kMDItemFSContentChangeDate < $time.today)")
    }

    @Test func isoDatesUseSpotlightISOTimeMacro() {
        let predicate = SearchQueryCompiler.predicate(for: "modified:<2026-06-01", defaultMode: .name)

        #expect(predicate == "kMDItemFSContentChangeDate < $time.iso(2026-06-01)")
    }

    @Test func folderTypeCompilesToContentTypeClause() {
        let predicate = SearchQueryCompiler.predicate(for: "type:folder", defaultMode: .name)

        #expect(predicate == #"kMDItemContentType == "public.folder""#)
    }

    @Test func fileTypeCompilesToContentTypeExclusion() {
        let predicate = SearchQueryCompiler.predicate(for: "type:file", defaultMode: .name)

        #expect(predicate == #"kMDItemContentType != "public.folder""#)
    }

    @Test func unknownOperatorsFallBackToDefaultMode() {
        let predicate = SearchQueryCompiler.predicate(for: "owner:me", defaultMode: .name)

        #expect(predicate == #"kMDItemFSName == "*owner:me*"cd"#)
    }

    @Test func quotesAndBackslashesAreEscaped() {
        let predicate = SearchQueryCompiler.predicate(for: #"name:"a \"quoted\" path\\file""#, defaultMode: .name)

        #expect(predicate == #"kMDItemFSName == "*a \"quoted\" path\\file*"cd"#)
    }

    @Test func danglingEscapeIsKeptAsLiteralBackslash() {
        let predicate = SearchQueryCompiler.predicate(for: #"name:abc\"#, defaultMode: .name)

        #expect(predicate == #"kMDItemFSName == "*abc\\*"cd"#)
    }

    @Test func compilerStressDoesNotProduceEmptyPredicates() {
        let fragments = [
            "report", "final", "ext:pdf", "ext:swift,md", "size:>10mb",
            "date:today", "date:>2026-01-01", #"content:"orbital elements""#,
            "type:folder", "path:Downloads", "unknown:value", #"name:quote\"test"#
        ]

        for first in fragments {
            for second in fragments {
                let predicate = SearchQueryCompiler.predicate(for: "\(first) \(second)", defaultMode: .name)
                #expect(!predicate.isEmpty)
                #expect(!predicate.contains("  "))
            }
        }
    }
}
