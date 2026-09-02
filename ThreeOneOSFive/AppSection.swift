import Foundation

enum AppSection: Int, CaseIterable, Identifiable {
    case home = 0
    case new = 1
    case sources = 2
    case installed = 3
    case files = 4
    case search = 5
    case moonzaza = 6
    
    var id: Int { rawValue }
}