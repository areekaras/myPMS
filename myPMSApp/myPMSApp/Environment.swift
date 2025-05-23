import Foundation

enum AppEnvironment {
    static let supabaseURL: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("SUPABASE_URL not set in config")
        }
        return url
    }()
    
    static let supabaseKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String else {
            fatalError("SUPABASE_KEY not set in config")
        }
        return key
    }()
    
    static let googleCallbackUrlString: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_CALLBACK_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("GOOGLE_CALLBACK_URL not set in config")
        }
        return url
    }()
}
