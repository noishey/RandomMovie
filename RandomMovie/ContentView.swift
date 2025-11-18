//
//  ContentView.swift
//  RandomMovie
//
//  Created by Arjun Shenoy on 18/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentMovie: Movie?
    @State private var skipCount = 0
    @State private var totalResults: Int?
    @State private var loading = false
    let maxSkips = 10
    
    var body: some View {
        VStack(spacing: 20) {
            if loading {
                ProgressView("Loading...")
            } else if let movie = currentMovie {
                // Show poster image
                if let posterPath = movie.posterPath {
                    AsyncImage(
                        url: URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
                    ) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                Text(movie.title)
                    .font(.title)
                
                // Show year
                if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                    let year = String(releaseDate.prefix(4))
                    Text(year)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                if let overview = movie.overview, !overview.isEmpty {
                    Text(overview).padding()
                }
            } else {
                Text("No movie found.")
            }
            
            HStack {
                Button("Spin!") {
                    rollMovie()
                }
                .disabled(loading || skipCount >= maxSkips)
                
                Button("Skip") {
                    rollMovie()
                }
                .disabled(skipCount >= maxSkips || currentMovie == nil)
            }
            Text("\(skipCount) / \(maxSkips) skips used")
                .padding(.vertical)
        }
        .padding()
        .onAppear {
            if totalResults == nil {
                loading = true
                NetworkManager.shared.getTotalResults { results in
                    DispatchQueue.main.async {
                        self.totalResults = results
                        loading = false
                        rollMovie()
                    }
                }
            }
        }
    }
    
    func rollMovie() {
        guard let total = totalResults, total > 0 else {
            print("No totalResults available")
            loading = false
            return
        }
        skipCount += 1
        loading = true
        print("Rolling... totalMovies: \(total)")

        let moviesPerPage = 20
        let maxPages = 500
        let randomPage = Int.random(in: 1...maxPages)
        let indexInPage = Int.random(in: 0..<moviesPerPage)

        print("Requesting page \(randomPage), index \(indexInPage)")
        NetworkManager.shared.getMovies(page: randomPage) { movies in
            DispatchQueue.main.async {
                loading = false
                if let movies = movies, movies.count > indexInPage {
                    self.currentMovie = movies[indexInPage]
                    print("Fetched movie:", movies[indexInPage].title)
                } else if let movies = movies, let anyMovie = movies.randomElement() {
                    self.currentMovie = anyMovie
                    print("Fallback random movie:", anyMovie.title)
                } else {
                    print("No movies found in results!")
                    self.currentMovie = nil
                }
            }
        }
    }
}
