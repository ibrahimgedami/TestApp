//
//  CurveSegement.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 02/12/2024.
//

import SwiftUI
import PDFKit
import AppBase

extension String {
    /// Checks if the string matches the "number/number" format.
    func isValidNumberFormat() -> Bool {
        let regex = #"^\d+/\d+$"#
        return self.range(of: regex, options: .regularExpression) != nil
    }

}

struct PDFUIViewWrapperContentView: View {
    
    @State private var pdfHeight: CGFloat = 0
    @State private var disableScroll = true
    @State private var shareButtonFrame: CGRect = .zero
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    let pdfURL: URL
    
    public init(pdfURL: URL) {
        self.pdfURL = pdfURL
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                buttons
            }
            .frame(height: 60)
            ScrollView(showsIndicators: false) {
                VStack {
                    PDFUIViewWrapper(pdfURL: pdfURL)
                        .frame(height: pdfHeight)
                        .disabled(disableScroll)
                        .gesture(
                            DragGesture().onChanged { _ in }
                        )
                }
            }
            .onAppear {
                loadPDF()
                startOrientationObserver()
            }
            .onDisappear {
                removeOrientationObserver()
            }
            .onChange(of: orientation) { _, _ in
                loadPDF()
            }
        }
    }
    
    private func loadPDF() {
        if let document = PDFDocument(url: pdfURL) {
            var totalHeight: CGFloat = 0
            for pageIndex in 0..<document.pageCount {
                if let page = document.page(at: pageIndex) {
                    totalHeight += page.bounds(for: .mediaBox).height
                }
            }
            pdfHeight = totalHeight + addHeightValue
        }
    }
    
    var addHeightValue: CGFloat {
        if Device.isiPadDevice && isPortraitOrientation {
            return 330
        } else if Device.isiPadDevice && !isPortraitOrientation {
            return 800
        } else if !Device.isiPadDevice && !isPortraitOrientation {
            return 200
        }
        return 0
    }
    
    var isPortraitOrientation: Bool {
        if UIDevice.current.orientation.isPortrait {
            return true
        } else if UIDevice.current.orientation.isLandscape {
            return false
        } else {
            return false
        }
    }
    
    private func startOrientationObserver() {
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
            orientation = UIDevice.current.orientation
        }
    }
    
    private func removeOrientationObserver() {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func sharePDF() {
        let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
        
        if !shareButtonFrame.isEmpty {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                activityVC.popoverPresentationController?.sourceView = topController.view
                activityVC.popoverPresentationController?.sourceRect = shareButtonFrame
            }
        } else {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                activityVC.popoverPresentationController?.sourceView = topController.view
                activityVC.popoverPresentationController?.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
            }
        }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            topController.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func printPDF() {
        let printController = UIPrintInteractionController.shared
        if let document = PDFDocument(url: pdfURL) {
            let printInfo = UIPrintInfo.printInfo()
            printInfo.outputType = .general
            printController.printInfo = printInfo
            printController.printingItem = document.dataRepresentation()
            printController.present(animated: true, completionHandler: nil)
        }
    }
    
    @ViewBuilder
    private var buttons: some View {
        VStack {
            HStack(spacing: 12) {
                ShareButtonRepresentable {
                    sharePDF()
                }
                .padding()
                .frame(width: 35, height: 35)
                .foregroundStyle(.white)
                .background(GeometryReader { geometry in
                    Circle()
                        .fill(mainColor)
                        .onAppear {
                            self.shareButtonFrame = geometry.frame(in: .global)
                        }
                })
                
                Button(action: {
                    self.printPDF()
                }) {
                    Image(systemName: "printer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(mainColor)
                                .frame(width: 35, height: 35)
                        )
                        .foregroundStyle(.white)
                }
            }
            .padding()
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, alignment: .topTrailing)
    }
    
}

struct PDFUIViewWrapper: View {
    
    var pdfURL: URL
    @State private var pdfView = PDFView()
    
    init(pdfURL: URL) {
        self.pdfURL = pdfURL
    }
    
    var body: some View {
        PDFUIView(pdfView: $pdfView, url: pdfURL)
            .onAppear {
                loadPDF()
            }
    }
    
    private func loadPDF() {
        if let document = PDFDocument(url: pdfURL) {
            pdfView.document = document
            pdfView.autoScales = true
        }
    }
    
}

struct PDFUIView: UIViewRepresentable {
    
    @Binding var pdfView: PDFView
    var url: URL
    
    func makeUIView(context: Context) -> PDFView {
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil {
            if let document = PDFDocument(url: url) {
                uiView.document = document
            }
        }
    }
    
}

struct ShareButtonRepresentable: UIViewRepresentable {
    
    var action: () -> Void
    
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTap), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(action: action)
    }
    
    class Coordinator: NSObject {
        var action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func didTap() {
            action()
        }
    }
    
}
