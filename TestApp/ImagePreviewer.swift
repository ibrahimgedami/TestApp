//
//  ImagePreviewer.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 05/08/2025.
//

import SwiftUI
import SDWebImageSwiftUI

class ImageViewerViewModel: ObservableObject {
    
    @Published public var imageData: Data?
    @Published public var isLoading = true
    @Published public var error: Error?
    
    private let imageUrl: String
    
    public init(imageUrl: String) {
        self.imageUrl = imageUrl
        loadImage()
    }
    
    public func loadImage() {
        guard let url = URL(string: imageUrl) else {
            error = NSError(domain: "Invalid URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image URL"])
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
                    self?.error = NSError(domain: "No Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "No image data received"])
                    return
                }
                
                self?.imageData = data
            }
        }.resume()
    }
    
    public func retry() {
        loadImage()
    }
    
}

// MARK: - Views
public struct ImageViewer: View {
    
    @StateObject private var viewModel: ImageViewerViewModel
    @State private var isShowingFullScreen = false
    
    private let thumbnailSize: CGSize
    private let cornerRadius: CGFloat
    private let shadowRadius: CGFloat
    
    public init(
        imageUrl: String,
        thumbnailSize: CGSize,
        cornerRadius: CGFloat = 8,
        shadowRadius: CGFloat = 4
    ) {
        _viewModel = StateObject(wrappedValue: ImageViewerViewModel(imageUrl: imageUrl))
        self.thumbnailSize = thumbnailSize
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(width: thumbnailSize.width, height: thumbnailSize.height)
            } else if let error = viewModel.error {
                ErrorView(error: error, retryAction: viewModel.retry)
                    .frame(width: thumbnailSize.width, height: thumbnailSize.height)
            } else if let imageData = viewModel.imageData, let uiImage = UIImage(data: imageData) {
                thumbnailView(image: uiImage)
                    .sheet(isPresented: $isShowingFullScreen) {
                        FullScreenImageView(image: uiImage)
                    }
            }
        }
    }
    
    private func thumbnailView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: thumbnailSize.width, height: thumbnailSize.height)
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
            .onTapGesture {
                isShowingFullScreen = true
            }
    }
    
}

struct FullScreenImageView: View {
    
    let image: UIImage
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    public init(image: UIImage) {
        self.image = image
    }
    
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
                .accessibilityZoomAction { action in
                    if action.direction == .zoomIn {
                        withAnimation { scale *= 1.5 }
                    } else {
                        withAnimation { scale /= 1.5 }
                    }
                }
            
            closeButton
        }
    }
    
    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
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

// MARK: - Error View
public struct ErrorView: View {
    public let error: Error
    public let retryAction: () -> Void
    
    public init(error: Error, retryAction: @escaping () -> Void) {
        self.error = error
        self.retryAction = retryAction
    }
    
    public var body: some View {
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
    }
}

#Preview {
    ImageViewer(imageUrl: "http://172.150.2.73/photo_direct/M126200-0005.JPG", thumbnailSize: CGSize(width: 200, height: 200))
}
