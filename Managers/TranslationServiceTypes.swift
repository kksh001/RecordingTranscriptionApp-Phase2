import Foundation

// MARK: - Translation Service Types
enum TranslationServiceType: String, CaseIterable, Codable {
    case qianwen = "qianwen"
    case google = "google"
    
    var displayName: String {
        switch self {
        case .qianwen:
            return "Qianwen"
        case .google:
            return "Google Translate"
        }
    }
    
    var iconName: String {
        switch self {
        case .qianwen:
            return "brain.head.profile"
        case .google:
            return "globe"
        }
    }
}

enum NetworkRegion {
    case mainlandChina
    case overseas
    case unknown
    
    var displayName: String {
        switch self {
        case .mainlandChina:
            return "Mainland China"
        case .overseas:
            return "Overseas"
        case .unknown:
            return "Unknown"
        }
    }
    
    var recommendedService: TranslationServiceType {
        switch self {
        case .mainlandChina:
            return .qianwen
        case .overseas:
            return .google
        case .unknown:
            return .qianwen  // Default fallback
        }
    }
}