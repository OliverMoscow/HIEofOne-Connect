import Foundation

class NOSHconnect {
    static var shared = NOSHconnect()
    var baseURL: String? = "https://nosh-app-mj3xd.ondigitalocean.app/"
    
    public func updateResource(type: String, id: String, json: String, jwt: String, completion: ((_ error: String?) -> Void)? = nil) {
        guard let baseURL = baseURL else {
            completion?("Base URL is not set.")
            return
        }
        
        let urlString = "\(baseURL)\(type)/\(id)"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = json.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion?("HTTP request error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?("Invalid HTTP response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                // Resource updated successfully
                completion?(nil)
            } else {
                let errorDescription = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                completion?("HTTP request failed: \(errorDescription)")
            }
        }
        
        task.resume()
    }
}
