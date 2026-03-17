//
//  BookCategory.swift
//  BookShelf
//

import Foundation

struct BookCategory: Identifiable {
    let id = UUID()
    let name: String
    let query: String
    
    static let categories: [BookCategory] = [
        BookCategory(name: "Фантастика", query: "subject:science+fiction"),
        BookCategory(name: "Детективы", query: "subject:mystery"),
        BookCategory(name: "Романы", query: "subject:romance"),
        BookCategory(name: "История", query: "subject:history"),
        BookCategory(name: "Наука", query: "subject:science"),
        BookCategory(name: "Бизнес", query: "subject:business"),
        BookCategory(name: "Детские", query: "subject:children"),
        BookCategory(name: "Поэзия", query: "subject:poetry"),
        BookCategory(name: "Приключения", query: "subject:adventure"),
        BookCategory(name: "Фэнтези", query: "subject:fantasy"),
        BookCategory(name: "Биографии", query: "subject:biography"),
        BookCategory(name: "Психология", query: "subject:psychology")
    ]
}
