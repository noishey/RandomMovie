//
//  Movie.swift
//  RandomMovie
//
//  Created by Arjun Shenoy on 18/11/25.

import Foundation

struct Movie: Decodable, Identifiable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let releaseDate: String?   // Make sure this is included

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}

struct MoviesResponse: Decodable {
    let results: [Movie]
    let totalResults: Int
    let totalPages: Int
    enum CodingKeys: String, CodingKey {
        case results
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }
}

