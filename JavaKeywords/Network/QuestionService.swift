import Foundation

final class QuestionService {
 
    static let shared = QuestionService()
    let endpoint = "https://codechallenge.arctouch.com/quiz/1"
    
    func loadData(completion: @escaping (Question) -> Void) {
        guard let url = URL(string: endpoint) else { return }
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let question = try decoder.decode(Question.self, from: data)
                
                completion(question)
            } catch {
                print("\(error)")
            }
        }
        
        task.resume()
    }
    
}
