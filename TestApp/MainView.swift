//
//  MainView.swift
//  TestApp
// 
//  Created by Ibrahim Gedami on 21/10/2024.
//

import SwiftUI
import UIKit
import AVKit

// MARK: - Media Model
enum MediaType: Equatable {
    
    case image(UIImage)
    case video(URL)
    
    static func == (lhs: MediaType, rhs: MediaType) -> Bool {
        switch (lhs, rhs) {
        case (.image(let lImage), .image(let rImage)):
            return lImage.pngData() == rImage.pngData()
        case (.video(let lURL), .video(let rURL)):
            return lURL == rURL
        default:
            return false
        }
    }
    
}

struct MediaItem: Identifiable, Equatable {
    
    let id = UUID()
    let type: MediaType
    
}

// MARK: - Media List View
struct MediaListView: View {
    
    let mediaItems: [MediaItem]
    @State private var currentIndex = 0
    @State private var timer: Timer?
    
    private let autoScrollInterval: TimeInterval = 2
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(mediaItems.enumerated()), id: \.1.id) { index, item in
                            NavigationLink {
                                MediaPagerView(items: mediaItems, startIndex: index)
                            } label: {
                                mediaPreview(for: item)
                                    .frame(width: 250, height: 200)
                                    .cornerRadius(10)
                                    .id(index)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    startAutoScroll(proxy: proxy)
                }
                .onDisappear {
                    stopAutoScroll()
                }
            }
            .navigationTitle("Media Gallery")
        }
    }
    
    private func startAutoScroll(proxy: ScrollViewProxy) {
        // Prevent multiple timers
        stopAutoScroll()
        
        timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                currentIndex = (currentIndex + 1) % mediaItems.count
                withAnimation {
                    proxy.scrollTo(currentIndex, anchor: .center)
                }
            }
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    @ViewBuilder
    private func mediaPreview(for item: MediaItem) -> some View {
        switch item.type {
        case .image(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        case .video:
            ZStack {
                Color.black
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
            }
        }
    }
}


// MARK: - Media Pager View

struct MediaPagerView: View {
    
    let items: [MediaItem]
    @State private var currentIndex: Int
    @State private var timer: Timer?
    private let autoScrollInterval: TimeInterval = 3
    
    init(items: [MediaItem], startIndex: Int) {
        self.items = items
        _currentIndex = State(initialValue: startIndex)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            TabView(selection: $currentIndex) {
                ForEach(0..<items.count, id: \.self) { index in
                    mediaView(for: items[index])
                        .tag(index)
                        .ignoresSafeArea()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .background(Color.black)
            .onAppear {
//                startAutoScroll(proxy: proxy)
            }
            .onDisappear {
                stopAutoScroll()
            }
        }
    }
    
    @ViewBuilder
    private func mediaView(for item: MediaItem) -> some View {
        switch item.type {
        case .image(let image):
            ZoomableImageView(image: image)
        case .video(let url):
            VideoPlayer(player: AVPlayer(url: url))
                .onDisappear {
                    AVPlayer(url: url).pause()
                }
        }
    }
    
    private func startAutoScroll(proxy: ScrollViewProxy) {
        // Prevent multiple timers
        stopAutoScroll()
        
        timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                currentIndex = (currentIndex + 1) % items.count
                withAnimation {
                    proxy.scrollTo(currentIndex, anchor: .center)
                }
            }
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }

}

// MARK: - Sample Data for Testing

struct MediaViewer: View {
    
    var body: some View {
        MediaListView(mediaItems: sampleMediaItems)
    }
    
    var sampleMediaItems: [MediaItem] {
        let image1 = UIImage(named: "cell_background_job_card")!
        let image2 = UIImage(named: "cell_background_job_card")!
        let videoURL = Bundle.main.url(forResource: "Watch product video for Easycase", withExtension: "mp4")!
        
        return [
            MediaItem(type: .image(image1)),
            MediaItem(type: .video(videoURL)),
            MediaItem(type: .image(image2)),
            MediaItem(type: .video(videoURL))
        ]
    }
}

// MARK: - Preview

#Preview {
    MediaViewer()
}

struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.frame = scrollView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView
        
        // Enable zoom bouncing
        scrollView.bouncesZoom = true
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // If you want to reset zoom when image changes, add logic here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var imageView: UIImageView?
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let imageView = imageView else { return }
            
            let boundsSize = scrollView.bounds.size
            var frameToCenter = imageView.frame
            
            // Center horizontally
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }
            
            // Center vertically
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }
            
            imageView.frame = frameToCenter
        }
    }

}
