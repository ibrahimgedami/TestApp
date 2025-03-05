//
//  ArchitectureView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 03/03/2025.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {

    class Coordinator: NSObject, @preconcurrency MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(parent: MailView) {
            self.parent = parent
        }
        
        @MainActor
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) {
                self.parent.didSendMail(result)
            }
        }
    }
    
    var subject: String
    var recipients: [String]
    var body: String
    var didSendMail: (MFMailComposeResult) -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.setSubject(subject)
        mailComposeVC.setToRecipients(recipients)
        mailComposeVC.setMessageBody(body, isHTML: false)
        mailComposeVC.mailComposeDelegate = context.coordinator
        return mailComposeVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
    }

}

struct ContentView: View {
    
    @State private var isShowingMailView = false
    @State private var mailResult: MFMailComposeResult? = nil
    
    var body: some View {
        VStack {
            Text("Send Email App")
                .font(.largeTitle)
                .padding()
            
            Button("Send Email") {
                isShowingMailView.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            // Handle the result
            if let result = mailResult {
                switch result {
                case .sent:
                    Text("Email sent successfully!")
                        .foregroundColor(.green)
                case .failed:
                    Text("Failed to send email.")
                        .foregroundColor(.red)
                default:
                    Text("")
                }
            }
        }
        .sheet(isPresented: $isShowingMailView) {
            MailView(subject: "Test Subject", recipients: ["ibrahim.abdelgani@seddiqiholding.com"], body: "This is a test email") { result in
                self.mailResult = result
            }
        }
    }

}
