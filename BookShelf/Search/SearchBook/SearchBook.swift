//
//  SearchBook.swift
//  BookShelf
//

import Foundation

struct SearchBook {
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
    
    init(from dto: BookDTO) {
        self.id = dto.id
        self.title = dto.title
        self.author = dto.author
        self.genre = dto.genre
        self.publishedYear = dto.publishedYear
        self.description = dto.description
        self.coverImageURL = dto.coverImageURL
        self.pageCount = dto.pageCount
        self.rating = dto.rating
        self.previewLink = dto.previewLink
        self.infoLink = dto.infoLink
    }
    
    func toBookDTO() -> BookDTO {
        return BookDTO(
            id: id,
            title: title,
            author: author,
            genre: genre,
            publishedYear: publishedYear,
            description: description,
            coverImageURL: coverImageURL,
            pageCount: pageCount,
            rating: rating,
            previewLink: previewLink,
            infoLink: infoLink
        )
    }
}
