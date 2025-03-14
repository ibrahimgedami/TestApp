//
//  Item.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 13/03/2025.
//

import Foundation

struct Item: Identifiable {
    
    var id: String = UUID().uuidString
    var title: String
    var image: String?
}

extension Item {
    
    static let mockData: [Item] = [
        Item(title: "Watch", image: "https://images.pexels.com/photos/277390/pexels-photo-277390.jpeg"),
        Item(title: "Phone", image: "https://images.pexels.com/photos/1334597/pexels-photo-1334597.jpeg"),
        Item(title: "Laptop", image: "https://images.pexels.com/photos/18105/pexels-photo.jpg"),
        Item(title: "Tablet", image: "https://images.pexels.com/photos/1092644/pexels-photo-1092644.jpeg"),
        Item(title: "Headphones", image: "https://images.pexels.com/photos/373892/pexels-photo-373892.jpeg"),
        Item(title: "Smartwatch", image: "https://images.pexels.com/photos/2767433/pexels-photo-2767433.jpeg"),
        Item(title: "Camera", image: "https://images.pexels.com/photos/274973/pexels-photo-274973.jpeg"),
        Item(title: "Shoes", image: "https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg"),
        Item(title: "Backpack", image: "https://images.pexels.com/photos/374574/pexels-photo-374574.jpeg"),
        Item(title: "Sunglasses", image: "https://images.pexels.com/photos/46710/pexels-photo-46710.jpeg"),
        Item(title: "Car", image: "https://images.pexels.com/photos/261985/pexels-photo-261985.jpeg"),
        Item(title: "Bike", image: "https://images.pexels.com/photos/276517/pexels-photo-276517.jpeg"),
        Item(title: "Coffee", image: "https://images.pexels.com/photos/312418/pexels-photo-312418.jpeg"),
        Item(title: "Burger", image: "https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg"),
        Item(title: "Pizza", image: "https://images.pexels.com/photos/825661/pexels-photo-825661.jpeg"),
        Item(title: "Pasta", image: "https://images.pexels.com/photos/64208/pexels-photo-64208.jpeg"),
        Item(title: "Cake", image: "https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg"),
        Item(title: "Ice Cream", image: "https://images.pexels.com/photos/205961/pexels-photo-205961.jpeg"),
        Item(title: "Book", image: "https://images.pexels.com/photos/1112048/pexels-photo-1112048.jpeg"),
        Item(title: "Notebook", image: "https://images.pexels.com/photos/1448709/pexels-photo-1448709.jpeg"),
        Item(title: "Pen", image: "https://images.pexels.com/photos/159866/books-notes-notebook-pen-159866.jpeg"),
        Item(title: "Keyboard", image: "https://images.pexels.com/photos/1202401/pexels-photo-1202401.jpeg"),
        Item(title: "Mouse", image: "https://images.pexels.com/photos/1591060/pexels-photo-1591060.jpeg"),
        Item(title: "Monitor", image: "https://images.pexels.com/photos/18105/pexels-photo.jpg"),
        Item(title: "Gaming Console", image: "https://images.pexels.com/photos/3945683/pexels-photo-3945683.jpeg"),
        Item(title: "Speaker", image: "https://images.pexels.com/photos/374703/pexels-photo-374703.jpeg"),
        Item(title: "Smart TV", image: "https://images.pexels.com/photos/1201996/pexels-photo-1201996.jpeg"),
        Item(title: "Remote Control", image: "https://images.pexels.com/photos/3945684/pexels-photo-3945684.jpeg"),
        Item(title: "Drone", image: "https://images.pexels.com/photos/229034/pexels-photo-229034.jpeg"),
        Item(title: "VR Headset", image: "https://images.pexels.com/photos/577585/pexels-photo-577585.jpeg")
    ]

}
