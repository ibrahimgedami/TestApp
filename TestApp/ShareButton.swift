//
//  ShareButton.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 12/03/2025.
//

import SwiftUI
import UniformTypeIdentifiers

protocol SharableContent {
    
    func shareItems() -> [Any]
    
}

struct ShareButton<T: SharableContent>: View {
    
    var content: T
    var buttonTitle: String = "Share"
    var iconName: String = "square.and.arrow.up"
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    
    @State private var isShowingShareSheet = false
    
    var body: some View {
        Button(action: {
            isShowingShareSheet = true
        }) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                Text(buttonTitle)
                    .fontWeight(.semibold)
            }
            .padding()
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(10)
        }
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(activityItems: content.shareItems())
        }
    }
    
}

struct ShareSheet: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
}

struct ShareProduct: SharableContent {
    
    let brand: String
    let stock: String
    let description: String
    let imageUrl: String
    
    func shareItems() -> [Any] {
        return ["\(brand) - Stock: \(stock)\n\(description)", imageUrl]
    }

}

struct ContentView: View {
    
    let product = ShareProduct(
        brand: "Apple",
        stock: "2",
        description: "The latest iPhone with amazing performance!",
        imageUrl: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.pinterest.com%2Fpin%2Fapple-logo-iphone-5s-wallpaper-download--361625045050945712%2F&psig=AOvVaw0Q523Bsrp8Y9ZAQNMUVoYS&ust=1741845577930000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCNi_gMvug4wDFQAAAAAdAAAAABAE"
    )
    
    var body: some View {
        ShareButton(content: product, buttonTitle: "Share", backgroundColor: .green)
    }

}
