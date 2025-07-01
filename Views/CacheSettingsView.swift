import SwiftUI

struct CacheSettingsView: View {
    @StateObject private var cacheManager = TranslationCacheManager.shared
    @State private var showConfirmClear = false
    
    var body: some View {
        List {
            Section("Cache Status") {
                HStack {
                    Image(systemName: "memorychip")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("Cache Enabled")
                        Toggle("", isOn: $cacheManager.isEnabled)
                    }
                }
                
                if cacheManager.isEnabled {
                    CacheStatisticsView()
                }
            }
            
            Section("Cache Management") {
                Button("Clear Expired Cache") {
                    cacheManager.clearExpiredCache()
                }
                
                Button("Preheat Common Translations") {
                    cacheManager.preheatCache()
                }
                
                Button("Clear All Cache", role: .destructive) {
                    showConfirmClear = true
                }
                .confirmationDialog(
                    "Clear all cached translations?",
                    isPresented: $showConfirmClear
                ) {
                    Button("Clear All", role: .destructive) {
                        cacheManager.clearAllCache()
                    }
                }
            }
        }
        .navigationTitle("Translation Cache")
    }
    
    @ViewBuilder
    private func CacheStatisticsView() -> some View {
        VStack(spacing: 8) {
            StatRow("Total Entries", value: "\(cacheManager.cacheStatistics.totalEntries)")
            StatRow("Hit Rate", value: cacheManager.cacheStatistics.hitRatePercentage)
            StatRow("Cache Size", value: cacheManager.cacheStatistics.cacheSize)
            StatRow("Expired Entries", value: "\(cacheManager.cacheStatistics.expiredEntries)")
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func StatRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.caption)
    }
}

#Preview {
    NavigationView {
        CacheSettingsView()
    }
} 