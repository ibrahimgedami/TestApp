//
//  PDFViewerView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 14/03/2025.
//

import SwiftUI
import PDFKit

struct PDFContentView: View {
    @State private var showPDFViewer = false
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    showPDFViewer = true
                }) {
                    Text("Open PDF")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
                .fullScreenCover(isPresented: $showPDFViewer) {
                    PDFViewerView(
                        pdfURL: URL(string: "https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf")!,
                        title: "Sample PDF"
                    )
                }
            }
        }
    }
}

// 🔹 PDF Viewer with Header
struct PDFViewerView: View {
    
    let pdfURL: URL
    let title: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Spacer().frame(width: 44)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            
            // 🔹 PDF View
            PDFKitView(url: pdfURL)
                .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarHidden(true) // Hide default navigation bar
    }

}

struct PDFKitView: UIViewRepresentable {
    
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
    
}

// 🔹 Preview
struct PDFContentView_Previews: PreviewProvider {
    static var previews: some View {
        PDFContentView()
    }
}
