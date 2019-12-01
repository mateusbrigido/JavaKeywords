import Foundation

final class QuestionService {
 
    static let shared = QuestionService()
    let endpoint = "https://codechallenge.arctouch.com/quiz/1"
    
    func loadData(completion: @escaping (Question?, ErrorResult?) -> Void) {
        guard let url = URL(string: endpoint) else { return }
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(nil, .network(string: "Network error"))
                return
            }
            guard let data = data else {
                completion(nil, .custom(string: "Request returned with no data"))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let question = try decoder.decode(Question.self, from: data)
                completion(question, nil)
            } catch {
                completion(nil, .decode(string: "Error while decoding the JSON"))
            }
        }
        
        task.resume()
    }
    
}
