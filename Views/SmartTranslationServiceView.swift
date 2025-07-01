import SwiftUI

struct SmartTranslationServiceView: View {
    @EnvironmentObject var networkRegionManager: NetworkRegionManager
    @EnvironmentObject var developerConfigManager: DeveloperConfigManager
    @EnvironmentObject var translationCacheManager: TranslationCacheManager
    @StateObject private var apiKeyManager = APIKeyManager.shared
    @State private var isTestingTranslation = false
    @State private var testResult = ""
    @State private var showTestResult = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 智能推荐服务
            ServiceRecommendationCard()
            
            // 服务状态
            ServiceStatusGrid()
            
            // 快速操作
            QuickActionsView()
            
            // 测试结果显示
            if showTestResult {
                TestResultView(result: testResult)
            }
        }
        .padding()
        .navigationTitle("Smart Translation")
    }
    
    @ViewBuilder
    private func ServiceRecommendationCard() -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
                Text("Recommended for your region")
                    .font(.headline)
                Spacer()
                
                // 刷新按钮
                Button(action: {
                    networkRegionManager.forceRefreshDetection()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(networkRegionManager.recommendedService.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Based on: \(networkRegionManager.currentRegion.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 检测状态
                    HStack {
                        Circle()
                            .fill(networkRegionManager.isDetectionComplete ? .green : .orange)
                            .frame(width: 8, height: 8)
                        Text(networkRegionManager.isDetectionComplete ? "Detection Complete" : "Detecting...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func ServiceStatusGrid() -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(Array(TranslationServiceType.allCases), id: \.self) { service in
                ServiceStatusCard(service: service)
            }
        }
    }
    
    @ViewBuilder
    private func ServiceStatusCard(service: TranslationServiceType) -> some View {
        let isAvailable = developerConfigManager.availableServices.contains(service)
        let isRecommended = networkRegionManager.recommendedService == service
        
        VStack(spacing: 8) {
            ZStack {
                Image(systemName: service.iconName)
                    .font(.title2)
                    .foregroundColor(isAvailable ? .green : .gray)
                
                if isRecommended {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                        .offset(x: 15, y: -15)
                }
            }
            
            Text(service.displayName)
                .font(.headline)
            
            Text(isAvailable ? "Ready" : "Unavailable")
                .font(.caption)
                .foregroundColor(isAvailable ? .green : .red)
            
            if isRecommended {
                Text("Recommended")
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isAvailable ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isRecommended ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
    
    @ViewBuilder
    private func QuickActionsView() -> some View {
        VStack(spacing: 12) {
            Button(action: {
                testTranslation()
            }) {
                HStack {
                    if isTestingTranslation {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "play.circle.fill")
                    }
                    Text(isTestingTranslation ? "Testing..." : "Test Translation")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isTestingTranslation || !developerConfigManager.isConfigured)
            
            HStack(spacing: 12) {
                Button("Refresh Services") {
                    Task {
                        await refreshServices()
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Clear Cache") {
                    clearTranslationCache()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    @ViewBuilder
    private func TestResultView(result: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Test Result")
                    .font(.headline)
                Spacer()
                Button("×") {
                    showTestResult = false
                }
                .foregroundColor(.secondary)
            }
            
            Text(result)
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .background(result.contains("✅") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Actions
    
    private func testTranslation() {
        isTestingTranslation = true
        showTestResult = false
        
        Task {
            let recommendedService = networkRegionManager.recommendedService
            
            do {
                var result = "🧪 Translation Test Results:\n\n"
                result += "📍 Region: \(networkRegionManager.currentRegion.displayName)\n"
                result += "🎯 Recommended Service: \(recommendedService.displayName)\n\n"
                
                // 测试推荐服务
                if let apiKey = developerConfigManager.getAPIKey(for: recommendedService) {
                    result += "🔑 API Key: Found (\(apiKey.count) chars)\n"
                    
                    if recommendedService == .qianwen {
                        let translation = try await QianwenTranslateManager.shared.translateText(
                            "Hello, smart translation!",
                            from: "en",
                            to: "zh"
                        )
                        result += "✅ Translation: \(translation)\n"
                    } else {
                        result += "🔄 Google Translate integration pending...\n"
                    }
                } else {
                    result += "❌ No API key available for \(recommendedService.displayName)\n"
                }
                
                await MainActor.run {
                    testResult = result
                    showTestResult = true
                    isTestingTranslation = false
                }
                
            } catch {
                await MainActor.run {
                    testResult = "❌ Test failed: \(error.localizedDescription)"
                    showTestResult = true
                    isTestingTranslation = false
                }
            }
        }
    }
    
    @MainActor
    private func refreshServices() async {
        networkRegionManager.forceRefreshDetection()
        developerConfigManager.refreshConfiguration()
        apiKeyManager.refreshConfiguration()
    }
    
    private func clearTranslationCache() {
        translationCacheManager.clearAllCache()
    }
}

#Preview {
    NavigationView {
        SmartTranslationServiceView()
            .environmentObject(NetworkRegionManager())
            .environmentObject(DeveloperConfigManager.shared)
            .environmentObject(TranslationCacheManager.shared)
    }
} 