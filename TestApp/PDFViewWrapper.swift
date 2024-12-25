//
//  PDFViewWrapper.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 10/12/2024.
//

import SwiftUI
import PDFKit

let mainColor = Color(hex: "#73B61")

//public struct PDFViewerView: View {
//    
//    @State private var shareButtonFrame: CGRect = .zero
//    @Binding private var contentHeight: CGFloat
//    let pdfURL: URL
//
//    public init(pdfURL: URL, contentHeight: Binding<CGFloat>) {
//        self.pdfURL = pdfURL
//        self._contentHeight = contentHeight
//    }
//
//    public var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .bottomTrailing) {
//                // PDFViewWrapper is placed inside the ScrollView
//                PDFViewWrapper(url: pdfURL, contentHeight: $contentHeight)
//                    .frame(width: geometry.size.width, height: contentHeight) // Ensure correct height is passed
//                    .onAppear {
//                        calculatePDFHeight()
//                    }
//                    .background(Color.white)
//                    .ignoresSafeArea(.all)
//                
//                VStack {
//                    Spacer()
//                    HStack(spacing: 6) {
//                        ShareButtonRepresentable {
//                            self.sharePDF()
//                        }
//                        .padding()
//                        .frame(width: 35, height: 35)
//                        .foregroundStyle(.white)
//                        .background(GeometryReader { geometry in
//                            Circle()
//                                .fill(mainColor)
//                                .onAppear {
//                                    self.shareButtonFrame = geometry.frame(in: .global)
//                                }
//                        })
//                        
//                        Button(action: {
//                            self.printPDF()
//                        }) {
//                            Image(systemName: "printer")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .padding()
//                                .frame(width: 50, height: 50)
//                                .background(
//                                    Circle()
//                                        .fill(mainColor)
//                                        .frame(width: 35, height: 35)
//                                )
//                                .foregroundStyle(.white)
//                        }
//                    }
//                }
//                .padding(.bottom, 0)
//                .frame(height: 50)
//            }
//        }
//        .frame(height: contentHeight)
//        .ignoresSafeArea(.all)
//    }
//
//    private func calculatePDFHeight() {
//        if let document = PDFDocument(url: pdfURL) {
//            let totalHeight = (0..<document.pageCount).compactMap { index in
//                document.page(at: index)?.bounds(for: .mediaBox).height
//            }.reduce(0, +)
//            contentHeight = totalHeight
//        }
//    }
//    
//    private func sharePDF() {
//        let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
//        
//        if !shareButtonFrame.isEmpty {
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
//                activityVC.popoverPresentationController?.sourceView = topController.view
//                activityVC.popoverPresentationController?.sourceRect = shareButtonFrame
//            }
//        } else {
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
//                activityVC.popoverPresentationController?.sourceView = topController.view
//                activityVC.popoverPresentationController?.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
//            }
//        }
//        
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
//            topController.present(activityVC, animated: true, completion: nil)
//        }
//    }
//    
//    private func printPDF() {
//        let printController = UIPrintInteractionController.shared
//        if let document = PDFDocument(url: pdfURL) {
//            let printInfo = UIPrintInfo.printInfo()
//            printInfo.outputType = .general
//            printController.printInfo = printInfo
//            printController.printingItem = document.dataRepresentation()
//            printController.present(animated: true, completionHandler: nil)
//        }
//    }
//}
//
//struct PDFViewWrapper: UIViewRepresentable {
//    
//    let url: URL
//    @Binding var contentHeight: CGFloat
//    
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.autoScales = true
//        pdfView.backgroundColor = .white
//        pdfView.displayMode = .singlePageContinuous
//        pdfView.displaysAsBook = false
//        pdfView.displayDirection = .vertical
//        pdfView.isUserInteractionEnabled = false // Disable internal scrolling
//        return pdfView
//    }
//    
//    func updateUIView(_ uiView: PDFView, context: Context) {
//        if let document = PDFDocument(url: url) {
//            uiView.document = document
//            // Update the contentHeight based on the PDF document's total height
//            updatePDFHeight(for: document)
//        }
//    }
//    
//    private func updatePDFHeight(for document: PDFDocument) {
//        let totalHeight = (0..<document.pageCount).compactMap { index in
//            document.page(at: index)?.bounds(for: .mediaBox).height
//        }.reduce(0, +)
//        contentHeight = totalHeight
//    }
//}
//
////public struct PDFViewerView: View {
////    
////    @State private var shareButtonFrame: CGRect = .zero
////    @Binding private var contentHeight: CGFloat
////    let pdfURL: URL
////
////    public init(pdfURL: URL, contentHeight: Binding<CGFloat>) {
////        self.pdfURL = pdfURL
////        self._contentHeight = contentHeight
////    }
////
////    public var body: some View {
////        GeometryReader { geometry in
////            ZStack(alignment: .bottomTrailing) {
////                PDFViewWrapper(url: pdfURL)
////                    .frame(width: geometry.size.width, height: contentHeight) // Use calculated height
////                    .onAppear {
////                        calculatePDFHeight()
////                    }
////                    .background(Color.white)
////                    .ignoresSafeArea(.all)
////                
////                VStack {
////                    Spacer()
////                    HStack(spacing: 6) {
////                        ShareButtonRepresentable {
////                            self.sharePDF()
////                        }
////                        .padding()
////                        .frame(width: 35, height: 35)
////                        .foregroundStyle(.white)
////                        .background(GeometryReader { geometry in
////                            Circle()
////                                .fill(mainColor)
////                                .onAppear {
////                                    self.shareButtonFrame = geometry.frame(in: .global)
////                                }
////                        })
////                        
////                        Button(action: {
////                            self.printPDF()
////                        }) {
////                            Image(systemName: "printer")
////                                .resizable()
////                                .aspectRatio(contentMode: .fit)
////                                .padding()
////                                .frame(width: 50, height: 50)
////                                .background(
////                                    Circle()
////                                        .fill(mainColor)
////                                        .frame(width: 35, height: 35)
////                                )
////                                .foregroundStyle(.white)
////                        }
////                    }
////                }
////                .padding(.bottom, 0)
////                .frame(height: 50)
////            }
////        }
////        .frame(height: contentHeight)
////        .ignoresSafeArea(.all)
////    }
////
////    private func calculatePDFHeight() {
////        if let document = PDFDocument(url: pdfURL) {
////            let totalHeight = (0..<document.pageCount).compactMap { index in
////                document.page(at: index)?.bounds(for: .mediaBox).height
////            }.reduce(0, +)
////            contentHeight = totalHeight
////        }
////    }
////    
////    private func sharePDF() {
////        let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
////        
////        if !shareButtonFrame.isEmpty {
////            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
////               let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
////                activityVC.popoverPresentationController?.sourceView = topController.view
////                activityVC.popoverPresentationController?.sourceRect = shareButtonFrame
////            }
////        } else {
////            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
////               let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
////                activityVC.popoverPresentationController?.sourceView = topController.view
////                activityVC.popoverPresentationController?.sourceRect = CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
////            }
////        }
////        
////        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
////           let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
////            topController.present(activityVC, animated: true, completion: nil)
////        }
////    }
////    
////    private func printPDF() {
////        let printController = UIPrintInteractionController.shared
////        if let document = PDFDocument(url: pdfURL) {
////            let printInfo = UIPrintInfo.printInfo()
////            printInfo.outputType = .general
////            printController.printInfo = printInfo
////            printController.printingItem = document.dataRepresentation()
////            printController.present(animated: true, completionHandler: nil)
////        }
////    }
////}
////
////struct PDFViewWrapper: UIViewRepresentable {
////    
////    let url: URL
////    
////    func makeUIView(context: Context) -> PDFView {
////        let pdfView = PDFView()
////        pdfView.autoScales = true
////        pdfView.backgroundColor = .white
////        pdfView.displayMode = .singlePageContinuous
////        pdfView.displaysAsBook = false
////        pdfView.displayDirection = .vertical
////        pdfView.isUserInteractionEnabled = false
////        return pdfView
////    }
////    
////    func updateUIView(_ uiView: PDFView, context: Context) {
////        if let document = PDFDocument(url: url) {
////            uiView.document = document
////        }
////    }
////    
////}
//
//struct ShareButtonRepresentable: UIViewRepresentable {
//    
//    var action: () -> Void
//    
//    func makeUIView(context: Context) -> UIButton {
//        let button = UIButton(type: .system)
//        button.tintColor = .white
//        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
//        button.imageView?.contentMode = .scaleAspectFit
//        button.addTarget(context.coordinator, action: #selector(Coordinator.didTap), for: .touchUpInside)
//        return button
//    }
//    
//    func updateUIView(_ uiView: UIButton, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(action: action)
//    }
//    
//    class Coordinator: NSObject {
//        var action: () -> Void
//        
//        init(action: @escaping () -> Void) {
//            self.action = action
//        }
//        
//        @objc func didTap() {
//            action()
//        }
//    }
//    
//}
