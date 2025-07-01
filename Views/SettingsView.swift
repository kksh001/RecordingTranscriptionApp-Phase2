import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var networkRegionManager: NetworkRegionManager
    @EnvironmentObject var developerConfigManager: DeveloperConfigManager
    @EnvironmentObject var translationCacheManager: TranslationCacheManager
    
    var body: some View {
        NavigationView {
            List {
                // 原有功能保持不变
                Section("General") {
                    SettingsRow(icon: "mic", title: "Audio Settings", description: "Microphone and recording preferences")
                    SettingsRow(icon: "textformat", title: "Transcription", description: "Language and format options")
                    SettingsRow(icon: "globe", title: "Translation", description: "Translation preferences")
                }
                
                Section("Data & Privacy") {
                    SettingsRow(icon: "lock", title: "Privacy", description: "Data protection settings")
                    SettingsRow(icon: "icloud", title: "iCloud Sync", description: "Sync recordings across devices")
                    SettingsRow(icon: "trash", title: "Clear Data", description: "Delete all recordings and transcriptions")
                }
                
                // Phase 2 新功能
                Section("🚀 Smart Translation") {
                    NavigationLink(destination: SmartTranslationServiceView()) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text("Smart Service Selection")
                                Text("Automatic translation service selection")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            // 状态指示器
                            if networkRegionManager.isDetectionComplete {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    
                    NavigationLink(destination: CacheSettingsView()) {
                        HStack {
                            Image(systemName: "memorychip")
                                .foregroundColor(.purple)
                            VStack(alignment: .leading) {
                                Text("Translation Cache")
                                Text("Performance optimization")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            // 缓存状态
                            if translationCacheManager.isEnabled {
                                Text("\(translationCacheManager.cacheStatistics.totalEntries)")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.purple.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                Section("🧪 Development Testing") {
                    NavigationLink(destination: Phase1TestView()) {
                        HStack {
                            Image(systemName: "hammer")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text("Phase 1 Architecture Tests")
                                Text("Manager and service testing")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("Version 1.5.0 - Phase 2")
                            .foregroundColor(.secondary)
                    }
                    
                    SettingsRow(icon: "questionmark.circle", title: "Help", description: "User guide and FAQ")
                    SettingsRow(icon: "envelope", title: "Contact", description: "Get support or send feedback")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
        .environmentObject(NetworkRegionManager())
        .environmentObject(DeveloperConfigManager.shared)
        .environmentObject(TranslationCacheManager.shared)
} 