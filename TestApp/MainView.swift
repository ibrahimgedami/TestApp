//
//  MainView.swift
//  TestApp
// 
//  Created by Ibrahim Gedami on 21/10/2024.
//

import SwiftUI
import AppBase

struct JobCardModule: Identifiable {
    
    let id = UUID()
    let title: String
    let imageName: String
    
}

//struct JobCardGridView: View {
//    
//    let modules: [JobCardModule] = [
//        JobCardModule(title: "Tracking", imageName: "location.viewfinder"),
//        JobCardModule(title: "Creation", imageName: "plus.square.on.square"),
//        JobCardModule(title: "Delivery", imageName: "shippingbox")
//    ]
//    
//    let columns = [
//        GridItem(.flexible(), spacing: 15)]
//    
//    var body: some View {
//        ScrollView {
//            LazyVGrid(columns: columns, spacing: 20) {
//                ForEach(modules) { module in
//                    Button {
//                        
//                    } label: {
//                        VStack(spacing: 20){
//                            Image(systemName: module.imageName)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: .infinity)
//                                .frame(maxHeight: 150)
//                                .foregroundColor(.blue)
//                            
//                            Text(module.title)
//                                .font(.headline)
//                                .foregroundStyle(.primary)
//                                .padding()
//                                .frame(width: .infinity)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
//                                        .foregroundStyle(.white)
//                                )
//                        }
//                        .padding()
//                        .frame(maxWidth: .infinity, minHeight: 150)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(16)
//                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//    
//}

struct JobCardGridView: View {
    
    let modules: [JobCardModule] = [
        JobCardModule(title: "Tracking", imageName: "location.viewfinder"),
        JobCardModule(title: "Creation", imageName: "plus.square.on.square"),
        JobCardModule(title: "Delivery", imageName: "shippingbox")
    ]
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    private var gridItemMinWidth: CGFloat {
        horizontalSizeClass == .compact ? 160 : 220
    }
    
    private var gridItemHeight: CGFloat {
        dynamicTypeSize > .large ? 180 : 160
    }
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: gridItemMinWidth), spacing: 10)]
    }
    
    private let cornerRadius: CGFloat = 12
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(modules) { module in
                    ZStack(alignment: .bottom) {
                        Image("cell_background_job_card")
                            .resizable()
                            .scaledToFill()
                            .frame(height: gridItemHeight)
                            .frame(maxWidth: .infinity)
                            .clipped()
                        
                        VStack {
                            Spacer()
                            Text(module.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        }
                        .padding()
                    }
                    .frame(height: gridItemHeight)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .onTapGesture {
                        debugPrint("\(module.title)")
                    }
                }
            }
            .padding()
        }
    }
}

//#Preview {
//    JobCardGridView()
//}

import SwiftUI
import Combine

class DeviceOrientationObserver: ObservableObject {
    
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    
    private var cancellable: AnyCancellable?
    
    init() {
        isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        
        cancellable = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let screen = UIScreen.main.bounds
                self.isLandscape = screen.width > screen.height
            }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

import SwiftUI
import AppBase
import SSSwiftUISpinnerButton

struct SaveButtonView: View {
    
    @Binding var isAnimating: Bool
    let action: () -> Void
    
    @StateObject private var orientationObserver = DeviceOrientationObserver()
    
    var body: some View {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let screenWidth = UIScreen.main.bounds.width
        
        let width: CGFloat = {
            if isIpad {
                return orientationObserver.isLandscape ? screenWidth - 20 : 300
            } else {
                return screenWidth - 20
            }
        }()
        
        VStack {
            SpinnerButton(
                buttonAction: action,
                isAnimating: $isAnimating,
                buttonStyle: customSpinnerButtonStyle(width: width),
                animationType: SpinnerButtonAnimationStyle.arcsRotateChase(count: 3, width: 2, spacing: 2)
            ) {
                HStack {
                    Text("Save")
                        .font(.proximaBold(size: 22))
                }
                .foregroundStyle(Color.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .frame(height: 60)
    }
}

struct SaveButtonViewer: View {
    
    @State var isAnimate = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Form")
                Spacer()
                
                SaveButtonView(isAnimating: $isAnimate) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isAnimate = false
                    }
                }
            }
        }
    }
    
}

public extension View {
 
    func customSpinnerButtonStyle(width: CGFloat? = 120) -> SpinnerButtonViewStyle {
        var buttonStyle = SpinnerButtonViewStyle()
        if let width {
            buttonStyle.width = width
        } else {
            buttonStyle.width = .infinity
        }
        buttonStyle.cornerRadius = buttonStyle.height / 2
        buttonStyle.backgroundColor = Color(.blue)
        buttonStyle.spinningButtonBackgroundColor = .blue
        buttonStyle.spinningStrokeColor = .green
        buttonStyle.borderWidth = 1
        buttonStyle.borderColor = .blue
        buttonStyle.shadowColor = .blue
        buttonStyle.shadowRadius = 1
        buttonStyle.shadowOffset = CGPoint(x: 0, y: 2)
        return buttonStyle
    }
    
}

#Preview {
    SaveButtonViewer()
}
