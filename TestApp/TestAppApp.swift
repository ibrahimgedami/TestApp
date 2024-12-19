//
//  TestAppApp.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 14/05/2024.
//

import SwiftUI

@main
struct TestAppApp: App {
    
    var body: some Scene {
        WindowGroup {
            PDFUIViewWrapperContentView()
        }
    }
    
}


struct ContainerView: View {
    
    @State private var pdfContentHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                GeometryReader { metrics in
                    Text("PDF View")
                        .frame(width: metrics.size.width, height: 50)
                }
                .frame(height: 50)
                .padding(.bottom, 70)
                
                ScrollView {
                    VStack {
                        PDFViewerView(
                            pdfURL: URL(string: "http://172.150.2.67/web_services/sws/jobcard/V1/jobcards/2024/12/2024-12-04/149001723/job_card_order_149001723.pdf")!,
                            contentHeight: $pdfContentHeight
                        )
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
}
