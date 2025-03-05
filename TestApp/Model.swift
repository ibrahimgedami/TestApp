//
//  Model.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 05/03/2025.
//

import Foundation

struct Brand: Identifiable {
    
    let id: UUID = UUID()
    let name: String
    let products: [Product]
    
}

struct Product: Identifiable {
    
    let id: UUID = UUID()
    let name: String
    let price: Double
    let description: String
    
}

struct CartItem: Identifiable {
    
    let id: UUID = UUID()
    let product: Product
    var quantity: Int
    
}
