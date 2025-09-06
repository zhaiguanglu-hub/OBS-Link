import SwiftUI

/// Main content view that manages the app's primary interface
struct ContentView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showingOnboarding = false
    
    var body: some View {
        Group {
            if shouldShowOnboarding {
                OnboardingView(settingsViewModel: settingsViewModel)
            } else {
                StreamingView()
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    // MARK: - Computed Properties
    
    private var shouldShowOnboarding: Bool {
        // Show onboarding if RTMP URL is not configured
        settingsViewModel.configuration.rtmpURL.isEmpty
    }
    
    // MARK: - Methods
    
    private func checkOnboardingStatus() {
        // This could be expanded to check for other onboarding conditions
        // For now, we just check if RTMP URL is configured
    }
}

/// Onboarding view for first-time users
struct OnboardingView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State private var rtmpURL = ""
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to OBS Live",
            subtitle: "Professional mobile streaming made simple",
            image: "video.circle.fill",
            description: "Stream high-quality video from your iPhone to any RTMP server with professional-grade controls."
        ),
        OnboardingPage(
            title: "Configure Your Stream",
            subtitle: "Set up your streaming server",
            image: "server.rack",
            description: "Enter your RTMP server URL to start streaming. You can use services like Twitch, YouTube, or your own server."
        ),
        OnboardingPage(
            title: "Start Streaming",
            subtitle: "Go live with one tap",
            image: "play.circle.fill",
            description: "Choose your video quality, frame rate, and other settings, then tap 'Go Live' to start streaming."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? .blue : .gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .padding(.top, 20)
            
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Bottom section
            VStack(spacing: 20) {
                // RTMP URL input (only on page 1)
                if currentPage == 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RTMP Server URL")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("rtmp://live.example.com/app/streamkey", text: $rtmpURL)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)
                        
                        Text("Example: rtmp://live.twitch.tv/live/YOUR_STREAM_KEY")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Action buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Get Started") {
                            completeOnboarding()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(rtmpURL.isEmpty)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    private func completeOnboarding() {
        settingsViewModel.updateRTMPURL(rtmpURL)
        // Additional onboarding completion logic can be added here
    }
}

/// Individual onboarding page view
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: page.image)
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .symbolEffect(.bounce, value: page.title)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

/// Onboarding page data model
struct OnboardingPage {
    let title: String
    let subtitle: String
    let image: String
    let description: String
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDisplayName("Main App")
            
            OnboardingView(settingsViewModel: SettingsViewModel())
                .previewDisplayName("Onboarding")
        }
    }
}