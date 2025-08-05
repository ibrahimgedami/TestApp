//
//  ImagePreviewer.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 05/08/2025.
//

import SwiftUI
import SDWebImageSwiftUI

class ImageViewerViewModel: ObservableObject {
    
    let imageUrl: String
    @Published var imageData: Data?
    @Published var isLoading = true
    @Published var error: Error?
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
        loadImage()
    }
    
    func loadImage() {
        guard let url = URL(string: imageUrl) else {
            error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            isLoading = false
            return
        }
        
        isLoading = true
        error = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let data = data else {
                    self?.error = NSError(domain: "No data received", code: 0, userInfo: nil)
                    return
                }
                
                self?.imageData = data
            }
        }.resume()
    }
    
    func retry() {
        loadImage()
    }
    
}

// MARK: - Views
struct ImageViewer: View {
    
    @StateObject var viewModel: ImageViewerViewModel
    @State private var isShowingFullScreen = false
    
    init(imageUrl: String) {
        _viewModel = StateObject(wrappedValue: ImageViewerViewModel(imageUrl: imageUrl))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(width: 100, height: 100)
            } else if let error = viewModel.error {
                ErrorView(error: error, retryAction: viewModel.retry)
            } else if let imageData = viewModel.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 200, maxHeight: 200)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .onTapGesture {
                        isShowingFullScreen = true
                    }
                    .sheet(isPresented: $isShowingFullScreen) {
                        FullScreenImageView(image: uiImage)
                    }
            }
        }
    }
}

struct FullScreenImageView: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale *= delta
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            if scale < 1.0 {
                                withAnimation {
                                    scale = 1.0
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .simultaneousGesture(
                    TapGesture(count: 2)
                        .onEnded {
                            if scale != 1.0 {
                                withAnimation {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            } else {
                                withAnimation {
                                    scale = 2.0
                                }
                            }
                        }
                )
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Failed to load image")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
        .frame(width: 200, height: 200)
    }
}

#Preview {
    ImageViewer(imageUrl: "http://172.150.2.73/photo_direct/M126200-0005.JPG")
}
