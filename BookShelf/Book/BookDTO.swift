//
//  BookDTO.swift
//  BookShelf
//

import Foundation

struct BookDTO {
    let id: String
    let title: String
    let author: String
    let genre: String?
    let publishedYear: Int?
    let description: String?
    let coverImageURL: String?
    let pageCount: Int?
    let rating: Double?
    let previewLink: String?
    let infoLink: String?
    
    init(from googleBook: GoogleBook) {
        self.id = googleBook.id
        self.title = googleBook.volumeInfo.title
        self.author = googleBook.volumeInfo.authors?.joined(separator: ", ") ?? "Неизвестный автор"
        self.description = googleBook.volumeInfo.description
        
        if let dateString = googleBook.volumeInfo.publishedDate {
            let yearString = String(dateString.prefix(4))
            self.publishedYear = Int(yearString)
        } else {
            self.publishedYear = nil
        }
        
        self.genre = googleBook.volumeInfo.categories?.first
        self.rating = googleBook.volumeInfo.averageRating
        self.pageCount = googleBook.volumeInfo.pageCount
        self.previewLink = googleBook.volumeInfo.previewLink
        self.infoLink = googleBook.volumeInfo.infoLink
        
        if let imageLinks = googleBook.volumeInfo.imageLinks {
            self.coverImageURL = imageLinks.bestAvailable
        } else {
            self.coverImageURL = nil
        }
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         author: String,
         genre: String? = nil,
         publishedYear: Int? = nil,
         description: String? = nil,
         coverImageURL: String? = nil,
         pageCount: Int? = nil,
         rating: Double? = nil,
         previewLink: String? = nil,
         infoLink: String? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.genre = genre
        self.publishedYear = publishedYear
        self.description = description
        self.coverImageURL = coverImageURL
        self.pageCount = pageCount
        self.rating = rating
        self.previewLink = previewLink
        self.infoLink = infoLink
    }
    
    init(from book: Book) {
        self.id = book.id?.uuidString ?? UUID().uuidString
        self.title = book.title ?? ""
        self.author = book.author ?? ""
        self.genre = book.genre
        self.publishedYear = book.publicationYear > 0 ? Int(book.publicationYear) : nil
        self.description = book.annotation
        self.coverImageURL = book.coverImageURL
        self.pageCount = book.pageCount > 0 ? Int(book.pageCount) : nil
        self.rating = book.rating > 0 ? book.rating : nil
        self.previewLink = book.externalLink
        self.infoLink = nil
    }
}
