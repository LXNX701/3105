import Foundation

// MARK: - KeyAuth Configuration
enum KeyAuthConfig {
    static let appName = "moonzadahk"          // ← REEMPLAZA con tu app name
    static let ownerId = "SQc5dKoope"          // ← REEMPLAZA con tu owner ID
    static let appSecret = "7bd5e05e74b37ab5c8e5f26e00cb27ac21ffa80367b8fac1a372c5848569abc7" // ← REEMPLAZA
    static let appVersion = "1.0"              // ← REEMPLAZA con tu versión
    static let baseURL = "https://keyauth.win/api/1.0/"
}

// MARK: - KeyAuth Error
enum KeyAuthError: LocalizedError {
    case invalidResponse
    case serverMessage(String)
    case networkError(Error)
    case missingCredentials
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from KeyAuth server."
        case .serverMessage(let msg):
            return msg
        case .networkError(let err):
            return "Network error: \(err.localizedDescription)"
        case .missingCredentials:
            return "Please fill in all fields."
        }
    }
}

// MARK: - KeyAuth Service
@MainActor
class KeyAuthService: ObservableObject {
    @Published var isLoading = false
    @Published var onlineUsers: Int = 0
    @Published var appVersionInfo: String = "v1.0"
    
    func login(username: String, password: String, licenseKey: String) async throws -> KeyAuthSession {
        guard !username.isEmpty, !password.isEmpty, !licenseKey.isEmpty else {
            throw KeyAuthError.missingCredentials
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let sessionId = UUID().uuidString
        let parameters: [String: String] = [
            "type": "login",
            "username": username,
            "pass": password,
            "key": licenseKey,
            "name": KeyAuthConfig.appName,
            "ownerid": KeyAuthConfig.ownerId,
            "sessionid": sessionId,
            "ver": KeyAuthConfig.appVersion
        ]
        
        guard let url = URL(string: KeyAuthConfig.baseURL) else {
            throw KeyAuthError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyString = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let json = json,
                  let success = json["success"] as? Bool else {
                throw KeyAuthError.invalidResponse
            }
            
            if !success {
                let message = json["message"] as? String ?? "Unknown error"
                throw KeyAuthError.serverMessage(message)
            }
            
            // Parse user info
            let info = json["info"] as? [String: Any]
            let user = info?["username"] as? String ?? username
            let subscriptions = info?["subscriptions"] as? [[String: Any]] ?? []
            let expiry = subscriptions.first?["expiry"] as? String ?? "N/A"
            
            // Update stats (async, no need to wait)
            Task { await fetchStats() }
            
            return KeyAuthSession(
                username: user,
                token: sessionId,
                onlineUsers: self.onlineUsers,
                appVersion: KeyAuthConfig.appVersion,
                subscriptionExpiry: expiry
            )
            
        } catch let error as KeyAuthError {
            throw error
        } catch {
            throw KeyAuthError.networkError(error)
        }
    }
    
    func fetchStats() async {
        let parameters: [String: String] = [
            "type": "stats",
            "name": KeyAuthConfig.appName,
            "ownerid": KeyAuthConfig.ownerId
        ]
        
        guard let url = URL(string: KeyAuthConfig.baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyString = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            if let success = json?["success"] as? Bool, success,
               let users = json?["onlineUsers"] as? Int {
                await MainActor.run {
                    self.onlineUsers = users
                }
            }
        } catch {
            print("[KeyAuth] Stats fetch failed: \(error)")
        }
    }
}

// MARK: - Session Model
struct KeyAuthSession: Codable {
    let username: String
    let token: String
    let onlineUsers: Int
    let appVersion: String
    let subscriptionExpiry: String
}