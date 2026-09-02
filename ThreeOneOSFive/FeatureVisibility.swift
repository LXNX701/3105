import Foundation

struct FeatureVisibility {
    static let cleanerStorageKey = "feature.cleaner.enabled"
    static let developerModeStorageKey = "developerModeEnabled"

    let developerModeEnabled: Bool

    var visibleSections: [AppSection] {
        var sections: [AppSection] = [
            .home,
            .new,
            .sources,
            .installed,
            .moonzaza
        ]
        if developerModeEnabled {
            sections.append(contentsOf: [.files, .search])
        }
        return sections
    }

    func isVisible(_ section: AppSection) -> Bool {
        visibleSections.contains(section)
    }
}