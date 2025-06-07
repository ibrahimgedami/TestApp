//
//  CachedImage.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 07/06/2025.
//

import SwiftUI
import Combine
import UIKit

class ImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    
    private var cancellable: AnyCancellable?
    private static let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        return cache
    }()
    
    func load(from url: URL) {
        if let cachedImage = ImageLoader.cache.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .handleEvents(receiveOutput: { image in
                if let image = image {
                    ImageLoader.cache.setObject(image, forKey: url as NSURL)
                }
            })
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .sink { [weak self] in self?.image = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
    }

}

struct CachedAsyncImage<Content: View>: View {
    
    @StateObject private var loader = ImageLoader()
    let url: URL
    let content: (UIImage?) -> Content
    
    init(url: URL, @ViewBuilder content: @escaping (UIImage?) -> Content) {
        self.url = url
        self.content = content
    }
    
    var body: some View {
        content(loader.image)
            .onAppear { loader.load(from: url) }
            .onDisappear { loader.cancel() }
    }

}

struct CachedImageViewer: View {
        
    @State private var isPresented: Bool = false
    @State private var loadedImage: UIImage?
    
    var body: some View {
        VStack {
            if let url = URL(string: "https://d3sftlgbtusmnv.cloudfront.net/blog/wp-content/uploads/2025/01/Al-Aqsa-Mosque-Cover-Photo-840x425.jpg") {
                CachedAsyncImage(url: url) { image in
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                loadedImage = image
                                isPresented.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    print("Loaded image set:", loadedImage != nil)
                                }
                            }
                    } else {
                        ProgressView()
                    }
                }
                .clipped()
                .cornerRadius(8)
                .background(Color.white)
                .background(Color(uiColor: .blue))
            }
        }
        .popover(isPresented: $isPresented) {
            DetailsView(image: $loadedImage, isPresented: $isPresented)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .secondarySystemBackground))
        .ignoresSafeArea()
    }

}

struct DetailsView: View {
    
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
            
            Button("Close") {
                isPresented = false
            }
        }
        .padding()
    }

}

#Preview {
    CachedImageViewer()
}

