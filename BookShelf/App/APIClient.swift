//
//  APIClient.swift
//  BookShelf
//
//  Created by Kriss Osina on 02.01.2026.
//

import Foundation

// MARK: - Google Books API Models
struct GoogleBook: Codable {
    let id: String
    let volumeInfo: VolumeInfo
    
    struct VolumeInfo: Codable {
        let title: String
        let authors: [String]?
        let description: String?
        let publishedDate: String?
        let pageCount: Int?
        let categories: [String]?
        let averageRating: Double?
        let ratingsCount: Int?
        let imageLinks: ImageLinks?
        let language: String?
        let previewLink: String?
        let infoLink: String?
        
        struct ImageLinks: Codable {
            let smallThumbnail: String?
            let thumbnail: String?
            let small: String?
            let medium: String?
            let large: String?
            let extraLarge: String?
            
            var secureThumbnail: String? {
                return thumbnail?.replacingOccurrences(of: "http://", with: "https://").replacingOccurrences(of: "&edge=curl", with: "")
            }
            
            var secureSmallThumbnail: String? {
                return smallThumbnail?.replacingOccurrences(of: "http://", with: "https://").replacingOccurrences(of: "&edge=curl", with: "")
            }
            
            var bestAvailable: String? {
                return extraLarge ?? large ?? medium ?? small ?? secureThumbnail ?? secureSmallThumbnail
            }
        }
    }
}

struct GoogleBooksResponse: Codable {
    let items: [GoogleBook]?
    let totalItems: Int
}



// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case networkError(Error)
    case noResults
    case rateLimitExceeded
    case quotaExceeded
}

// MARK: - APIClient Protocol
protocol APIClientProtocol {
    func searchBooks(query: String, genre: String?) async throws -> [BookDTO]
    func searchBooksByAuthor(author: String) async throws -> [BookDTO]
    func searchBooksByISBN(isbn: String) async throws -> [BookDTO]
    func loadImage(from urlString: String) async throws -> Data
    func getBookDetails(bookId: String) async throws -> BookDTO
}

// MARK: - APIClient Implementation
final class APIClient: APIClientProtocol {
    static let shared = APIClient()
    private let session = URLSession.shared
    private let baseURL = "https://www.googleapis.com/books/v1"
    private let decoder = JSONDecoder()
    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - Public Methods
    func searchBooks(query: String, genre: String? = nil) async throws -> [BookDTO] {
        var searchQuery = query
        if let genre = genre, !genre.isEmpty {
            searchQuery += "+subject:\(genre)"
        }
        
        return try await performSearch(query: searchQuery)
    }
    
    func searchBooksByAuthor(author: String) async throws -> [BookDTO] {
        let query = "inauthor:\(author)"
        return try await performSearch(query: query)
    }
    
    func searchBooksByISBN(isbn: String) async throws -> [BookDTO] {
        let query = "isbn:\(isbn)"
        return try await performSearch(query: query)
    }
    
    func getBookDetails(bookId: String) async throws -> BookDTO {
        guard let url = URL(string: "\(baseURL)/volumes/\(bookId)") else {
            throw APIError.invalidURL
        }
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            try validateResponse(httpResponse)
            let googleBook = try decoder.decode(GoogleBook.self, from: data)
            return BookDTO(from: googleBook)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func loadImage(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        let (data, _) = try await session.data(from: url)
        return data
    }
    
    // MARK: - Private Methods
    private func performSearch(query: String, maxResults: Int = 20) async throws -> [BookDTO] {
        var components = URLComponents(string: "\(baseURL)/volumes")
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        components?.queryItems = [
            URLQueryItem(name: "q", value: encodedQuery),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "printType", value: "books"),
            URLQueryItem(name: "langRestrict", value: "ru"),
            URLQueryItem(name: "orderBy", value: "relevance")
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            try validateResponse(httpResponse)
            let searchResponse = try decoder.decode(GoogleBooksResponse.self, from: data)
            guard let items = searchResponse.items, !items.isEmpty else {
                throw APIError.noResults
            }
            let books = items.map { BookDTO(from: $0) }
            return books
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func validateResponse(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 400:
            throw APIError.invalidURL
        case 403:
            throw APIError.quotaExceeded
        case 429:
            throw APIError.rateLimitExceeded
        case 404:
            throw APIError.noResults
        default:
            throw APIError.invalidResponse
        }
    }
}

extension APIClient {
    func searchBooks(query: String, genre: String? = nil, startIndex: Int = 0, maxResults: Int = 20) async throws -> ([BookDTO], totalItems: Int) {
        var searchQuery = query
        if let genre = genre, !genre.isEmpty {
            searchQuery += "+subject:\(genre)"
        }
        var components = URLComponents(string: "\(baseURL)/volumes")
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchQuery
    
        components?.queryItems = [
            URLQueryItem(name: "q", value: encodedQuery),
            URLQueryItem(name: "startIndex", value: "\(startIndex)"),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "printType", value: "books"),
            URLQueryItem(name: "langRestrict", value: "ru"),
            URLQueryItem(name: "orderBy", value: "relevance")
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            try validateResponse(httpResponse)
            let searchResponse = try decoder.decode(GoogleBooksResponse.self, from: data)
            let items = searchResponse.items ?? []
            let books = items.map { BookDTO(from: $0) }
            return (books, searchResponse.totalItems)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
