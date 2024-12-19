//
//  CurveSegement.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 02/12/2024.
//

import SwiftUI
import PDFKit
import AppBase

struct PDFUIViewWrapperContentView: View {
    
    @State private var pdfHeight: CGFloat = 0
    @State private var disableScroll = true
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    let urlString = "http://172.150.2.67/web_services/sws/jobcard/V1/jobcards/2024/12/2024-12-04/149001723/job_card_order_149001723.pdf"
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                PDFUIViewWrapper(pdfURL: URL(string: urlString)!)
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
    
    private func loadPDF() {
        if let url = URL(string: urlString),
           let document = PDFDocument(url: url) {
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
