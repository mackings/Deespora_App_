import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Initialize Google Maps with better error handling
        initializeGoogleMaps()
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func initializeGoogleMaps() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String else {
            print("❌ GOOGLE_MAPS_API_KEY not found in Info.plist")
            return
        }
        
        guard !apiKey.isEmpty else {
            print("❌ GOOGLE_MAPS_API_KEY is empty")
            return
        }
        
        print("✅ Initializing Google Maps with API key: \(apiKey.prefix(10))...")
        
        // Provide the API key
        GMSServices.provideAPIKey(apiKey)
        
        // Verify initialization after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if GMSServices.sdkVersion() != nil {
                print("✅ Google Maps iOS SDK initialized successfully")
            } else {
                print("❌ Google Maps iOS SDK failed to initialize")
            }
        }
    }
}