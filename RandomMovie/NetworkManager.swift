import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let apiKey = "0b542c861a1062a6d4962cfb5899f0f6"
    private let baseURL = "https://api.themoviedb.org/3"

    private init() {}
    
    // Fetch total pages from /discover/movie
    func getTotalPages(completion: @escaping (Int?) -> Void) {
        let urlString = "\(baseURL)/discover/movie?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { completion(nil); return }
            if let response = try? JSONDecoder().decode(MoviesResponse.self, from: data) {
                completion(response.totalPages)
            } else {
                completion(nil)
            }
        }.resume()
    }

    // Fetch total results from /discover/movie
    func getTotalResults(completion: @escaping (Int?) -> Void) {
        let url = URL(string: "\(baseURL)/discover/movie?api_key=\(apiKey)")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(MoviesResponse.self, from: data) else {
                completion(nil)
                return
            }
            completion(decoded.totalResults)
        }.resume()
    }

    // Fetch movies for a given page
    func getMovies(page: Int, completion: @escaping ([Movie]?) -> Void) {
        let urlString = "\(baseURL)/discover/movie?api_key=\(apiKey)&page=\(page)"
        guard let url = URL(string: urlString) else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { completion(nil); return }
            if let response = try? JSONDecoder().decode(MoviesResponse.self, from: data) {
                completion(response.results)
            } else {
                completion(nil)
            }
        }.resume()
    }

    // Fetch a true random number from random.org
    func getRandomOrgNumber(min: Int, max: Int, completion: @escaping (Int?) -> Void) {
        let urlString = "https://www.random.org/integers/?num=1&min=\(min)&max=\(max)&col=1&base=10&format=plain&rnd=new"
        guard let url = URL(string: urlString) else { completion(nil); return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let string = String(data: data, encoding: .utf8),
                  let number = Int(string.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                completion(nil)
                return
            }
            completion(number)
        }.resume()
    }
}
