import Foundation

let apiKey = "AIzaSyCQ8OYWsU2iTxOEvYG86fgXqB2UtLtdaB4"
let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models?key=\(apiKey)")!

let semaphore = DispatchSemaphore(value: 0)

URLSession.shared.dataTask(with: url) { data, response, error in
    if let error = error {
        print("Error: \(error)")
    } else if let data = data {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []),
           let dict = json as? [String: Any],
           let models = dict["models"] as? [[String: Any]] {
            for model in models {
                if let name = model["name"] as? String {
                    print(name)
                }
            }
        } else {
            print("Failed to parse JSON")
            if let str = String(data: data, encoding: .utf8) {
                print(str)
            }
        }
    }
    semaphore.signal()
}.resume()

semaphore.wait()
