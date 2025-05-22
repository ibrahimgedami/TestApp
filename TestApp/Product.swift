//
//  Untitled.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 22/05/2025.
//

import SwiftUI

struct Product: Identifiable {
    
    let id = UUID()
    let name: String
    let imageUrl: String // now expects a URL string
    let price: String
    
    static let dummyData: [Product] = [
        Product(name: "Apple", imageUrl: "https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg", price: "$1.20"),
        Product(name: "Banana", imageUrl: "https://images.pexels.com/photos/208450/pexels-photo-208450.jpeg", price: "$0.99"),
        Product(name: "Cherry", imageUrl: "https://images.pexels.com/photos/157184/cherry-fruit-red-juicy-157184.jpeg", price: "$2.50"),
        Product(name: "Grapes", imageUrl: "https://images.pexels.com/photos/708777/pexels-photo-708777.jpeg", price: "$3.40"),
        Product(name: "Orange", imageUrl: "https://images.pexels.com/photos/42059/orange-fruit-vitamins-healthy-eating-42059.jpeg", price: "$1.10"),
        Product(name: "Pineapple", imageUrl: "https://images.pexels.com/photos/615705/pexels-photo-615705.jpeg", price: "$2.99"),
        Product(name: "Mango", imageUrl: "https://images.pexels.com/photos/675951/pexels-photo-675951.jpeg", price: "$1.75"),
        Product(name: "Strawberry", imageUrl: "https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg", price: "$2.60"),
        Product(name: "Blueberry", imageUrl: "https://images.pexels.com/photos/708777/pexels-photo-708777.jpeg", price: "$3.10"),
        Product(name: "Watermelon", imageUrl: "https://images.pexels.com/photos/615705/pexels-photo-615705.jpeg", price: "$4.20"),
        Product(name: "Peach", imageUrl: "https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg", price: "$1.85"),
        Product(name: "Plum", imageUrl: "https://images.pexels.com/photos/157184/cherry-fruit-red-juicy-157184.jpeg", price: "$2.10"),
        Product(name: "Lemon", imageUrl: "https://images.pexels.com/photos/42059/orange-fruit-vitamins-healthy-eating-42059.jpeg", price: "$0.89"),
        Product(name: "Lime", imageUrl: "https://images.pexels.com/photos/208450/pexels-photo-208450.jpeg", price: "$0.79"),
        Product(name: "Kiwi", imageUrl: "https://images.pexels.com/photos/675951/pexels-photo-675951.jpeg", price: "$1.55"),
        Product(name: "Papaya", imageUrl: "https://images.pexels.com/photos/615705/pexels-photo-615705.jpeg", price: "$2.35"),
        Product(name: "Guava", imageUrl: "https://images.pexels.com/photos/708777/pexels-photo-708777.jpeg", price: "$2.00"),
        Product(name: "Pomegranate", imageUrl: "https://images.pexels.com/photos/157184/cherry-fruit-red-juicy-157184.jpeg", price: "$2.90"),
        Product(name: "Coconut", imageUrl: "https://images.pexels.com/photos/208450/pexels-photo-208450.jpeg", price: "$3.50"),
        Product(name: "Avocado", imageUrl: "https://images.pexels.com/photos/675951/pexels-photo-675951.jpeg", price: "$2.80"),
        Product(name: "Raspberry", imageUrl: "https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg", price: "$3.20"),
        Product(name: "Blackberry", imageUrl: "https://images.pexels.com/photos/708777/pexels-photo-708777.jpeg", price: "$3.30"),
        Product(name: "Apricot", imageUrl: "https://images.pexels.com/photos/615705/pexels-photo-615705.jpeg", price: "$1.95"),
        Product(name: "Fig", imageUrl: "https://images.pexels.com/photos/157184/cherry-fruit-red-juicy-157184.jpeg", price: "$2.25"),
        Product(name: "Date", imageUrl: "https://images.pexels.com/photos/208450/pexels-photo-208450.jpeg", price: "$1.70"),
        Product(name: "Jackfruit", imageUrl: "https://images.pexels.com/photos/675951/pexels-photo-675951.jpeg", price: "$4.10"),
        Product(name: "Dragon Fruit", imageUrl: "https://images.pexels.com/photos/615705/pexels-photo-615705.jpeg", price: "$3.70"),
        Product(name: "Starfruit", imageUrl: "https://images.pexels.com/photos/708777/pexels-photo-708777.jpeg", price: "$2.40"),
        Product(name: "Lychee", imageUrl: "https://images.pexels.com/photos/157184/cherry-fruit-red-juicy-157184.jpeg", price: "$2.65"),
        Product(name: "Passion Fruit", imageUrl: "https://images.pexels.com/photos/208450/pexels-photo-208450.jpeg", price: "$3.00"),
        Product(name: "Cantaloupe", imageUrl: "https://images.pexels.com/photos/675951/pexels-photo-675951.jpeg", price: "$1.50"),
        Product(name: "Honeydew", imageUrl: "https://images.pexels.com/photos/615705/pexels-photo-615705.jpeg", price: "$1.45"),
        Product(name: "Tangerine", imageUrl: "https://images.pexels.com/photos/708777/pexels-photo-708777.jpeg", price: "$1.30"),
        Product(name: "Mandarin", imageUrl: "https://images.pexels.com/photos/157184/cherry-fruit-red-juicy-157184.jpeg", price: "$1.60"),
        Product(name: "Nectarine", imageUrl: "https://images.pexels.com/photos/208450/pexels-photo-208450.jpeg", price: "$2.20"),
        Product(name: "Currant", imageUrl: "https://images.pexels.com/photos/675951/pexels-photo-675951.jpeg", price: "$2.75"),
        Product(name: "Cranberry", imageUrl: "https://images.pexels.com/photos/615705/pexels-photo-615705.jpeg", price: "$2.95"),
        Product(name: "Gooseberry", imageUrl: "https://images.pexels.com/photos/708777/pexels-photo-708777.jpeg", price: "$2.10"),
        Product(name: "Mulberry", imageUrl: "https://images.pexels.com/photos/157184/cherry-fruit-red-juicy-157184.jpeg", price: "$3.15"),
        Product(name: "Persimmon", imageUrl: "https://images.pexels.com/photos/208450/pexels-photo-208450.jpeg", price: "$2.85"),
        Product(name: "Quince", imageUrl: "https://images.pexels.com/photos/675951/pexels-photo-675951.jpeg", price: "$1.95"),
        Product(name: "Sapodilla", imageUrl: "https://images.pexels.com/photos/615705/pexels-photo-615705.jpeg", price: "$3.45"),
        Product(name: "Soursop", imageUrl: "https://images.pexels.com/photos/708777/pexels-photo-708777.jpeg", price: "$3.60"),
        Product(name: "Breadfruit", imageUrl: "https://images.pexels.com/photos/157184/cherry-fruit-red-juicy-157184.jpeg", price: "$4.30"),
        Product(name: "Tamarind", imageUrl: "https://images.pexels.com/photos/208450/pexels-photo-208450.jpeg", price: "$1.40"),
        Product(name: "Durian", imageUrl: "https://images.pexels.com/photos/675951/pexels-photo-675951.jpeg", price: "$5.00"),
        Product(name: "Rambutan", imageUrl: "https://images.pexels.com/photos/615705/pexels-photo-615705.jpeg", price: "$2.95"),
        Product(name: "Longan", imageUrl: "https://images.pexels.com/photos/708777/pexels-photo-708777.jpeg", price: "$2.75"),
        Product(name: "Jujube", imageUrl: "https://images.pexels.com/photos/157184/cherry-fruit-red-juicy-157184.jpeg", price: "$2.00")
    ]

}

struct ProductCardView: View {
    
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
            } placeholder: {
                ProgressView()
                    .frame(height: 100)
            }
            
            Text(product.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(product.price)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

}
