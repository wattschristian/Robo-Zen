import Foundation


// Extension to make CGPoint Codable
extension CGPoint: Codable {}

func sendDrawingToServer(drawing: Drawing) {
    guard let url = URL(string: "http://10.7.83.129:8080/api/data") else {
        print("Invalid URL")
        return
    }
    
    // Create the URLRequest
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Convert Drawing to JSON
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(drawing)
        
        // Create URL session task
        let task = URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            // Handle the response
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                return
            }
            
            print("Status code: \(httpResponse.statusCode)")
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }
        
        // Start the network request
        task.resume()
        
    } catch {
        print("Failed to encode drawing: \(error)")
    }
}




