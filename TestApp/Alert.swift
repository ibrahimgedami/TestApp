//
//  Alert.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 10/12/2024.
//

import SwiftUI

struct RoundedButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color(uiColor: .systemGray6)
    var foregroundColor: Color = .blue
    var font: Font = .proximaMedium(size: 18) // Replace with your custom font modifier
    var width: CGFloat = 200 // Default width
    var height: CGFloat = 50 // Default height
    var cornerRadius: CGFloat = 25
    var shadowColor: Color = Color.black.opacity(0.2)
    var shadowRadius: CGFloat = 10
    var shadowOffset: CGSize = CGSize(width: 0, height: 5)

    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .frame(width: width, height: height)
            .overlay(
                configuration.label
                    .font(font)
                    .foregroundColor(foregroundColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil) // Allow unlimited lines
                    .padding([.leading, .trailing], 10)
            )
            .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffset.width, y: shadowOffset.height)
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct ContentAlertView: View {

    @State private var showAlert = false

    var body: some View {
        
        Button(action: {
            showAlert.toggle()
        }) {
            Text("Show Alert")
        }
        .buttonStyle(RoundedButtonStyle(
            backgroundColor: Color(uiColor: .systemGray6),
            foregroundColor: .blue,
            font: .proximaMedium(size: 14),
            width: 100,
            height: 35,
            cornerRadius: 12
        ))
        .customAlertWithButtons(
            isPresented: $showAlert,
            title: "Alert Title",
            message: applyFontAndColorStylesString(to: "Sample message", boldText: "Sample", boldFont: .title, boldTextColor: .blue),
            isAttributedMessage: true,
            primaryButtonTitle: "OK",
            primaryAction: {
                print("Primary action")
            }
        )
        
    }
    
    func applyFontAndColorStylesString(to message: String, boldText: String, boldFont: Font, boldTextColor: Color) -> AttributedString {
        var attributedMessage = AttributedString(message)
        
        if let range = attributedMessage.range(of: boldText) {
            attributedMessage[range].font = boldFont
            attributedMessage[range].foregroundColor = boldTextColor
        }
        
//        if let range = attributedMessage.range(of: colordText) {
//            attributedMessage[range].foregroundColor = color
//        }
        return attributedMessage
    }
}
//
//
//struct AlertModifier: ViewModifier {
//    
//    @Binding var isPresented: Bool
//    var title: String
//    var message: AttributedString
//    var primaryButtonTitle: String
//    var primaryAction: () -> Void
//    var secondaryButtonTitle: String?
//    var secondaryAction: (() -> Void)?
//    
//    func body(content: Content) -> some View {
//        ZStack {
//            content
//            if isPresented {
//                Color.gray.opacity(0.5)
//                    .ignoresSafeArea(.all)
//                
//                CustomAlertView(
//                    title: title,
//                    message: message,
//                    primaryButtonTitle: primaryButtonTitle,
//                    primaryAction: primaryAction,
//                    secondaryButtonTitle: secondaryButtonTitle,
//                    secondaryAction: secondaryAction,
//                    isPresented: $isPresented
//                )
//            }
//        }
//    }
//    
//}
//
//struct CustomAlertView: View {
//    
//    var title: String
//    var message: String
//    var attributedMessage: AttributedString
//    var isAttributedMesage: Bool
//    var primaryButtonTitle: String
//    var primaryAction: () -> Void
//    var secondaryButtonTitle: String?
//    var secondaryAction: (() -> Void)?
//    
//    @Binding var isPresented: Bool
//    
//    var body: some View {
//        VStack {
//            VStack(spacing: 12) {
//                Text(title)
//                    .font(.headline)
//                    .padding(.top)
//                    .foregroundColor(.primary)
//                
//                // Scrollable message if it's too long, otherwise just a normal Text view
//                if message.characters.count > 200 {
//                    ScrollView {
//                        Text(message)
//                            .font(.body)
//                            .padding()
//                            .foregroundColor(.primary)
//                            .frame(maxWidth: .infinity, alignment: .leading) // Ensures the text doesn't overflow
//                    }
//                    .frame(maxHeight: 200) // Allow ScrollView to have a maximum height
//                } else {
//                    Text(message)
//                        .font(.body)
//                        .padding()
//                        .foregroundColor(.primary)
//                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure message stays within bounds
//                }
//                
//                HStack {
//                    if let secondaryButtonTitle = secondaryButtonTitle {
//                        Button(secondaryButtonTitle) {
//                            secondaryAction?()
//                            isPresented.toggle()
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .frame(width: 70)
//                        .foregroundStyle(.red)
//                        .padding()
//                        .background(Color.secondary.opacity(0.3))
//                        .cornerRadius(8)
//                    }
//                    
////                    Spacer()
//                    
//                    Button(primaryButtonTitle) {
//                        primaryAction()
//                        isPresented.toggle()
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    .frame(width: 70)
//                    .padding()
//                    .background(Color.secondary.opacity(0.3))
//                    .cornerRadius(8)
//                    .foregroundStyle(.blue)
//                }
//                .padding()
//                .frame(maxWidth: secondaryButtonTitle == nil ? .infinity : nil)
//            }
//            .frame(maxWidth: 300)
//            .background(Color.white)
//            .cornerRadius(10)
//            .shadow(radius: 20)
//            .padding(.horizontal, 40)
//            .padding(.vertical, 100)
//        }
//        .frame(maxHeight: .infinity)
//    }
//    
//}
//
//extension View {
//    
//    func customAlertWithButtons(
//        isPresented: Binding<Bool>,
//        title: String = "Caution",
//        message: AttributedString,
//        primaryButtonTitle: String = "Ok",
//        primaryAction: @escaping () -> Void = {},
//        secondaryButtonTitle: String? = nil,
//        secondaryAction: (() -> Void)? = nil
//    ) -> some View {
//        self.modifier(AlertModifier(
//            isPresented: isPresented,
//            title: title,
//            message: message,
//            primaryButtonTitle: primaryButtonTitle,
//            primaryAction: primaryAction,
//            secondaryButtonTitle: secondaryButtonTitle,
//            secondaryAction: secondaryAction
//        ))
//    }
//    
//}

struct CustomAlertView: View {
    
    var title: String
    var message: String
    var attributedMessage: AttributedString
    var isAttributedMessage: Bool
    var primaryButtonTitle: String
    var primaryAction: () -> Void
    var secondaryButtonTitle: String?
    var secondaryAction: (() -> Void)?
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            VStack(spacing: 12) {
                Text(title)
                    .font(.headline)
                    .padding(.top)
                    .foregroundColor(.primary)
                
                // Display either attributedMessage or message based on isAttributedMessage
                if isAttributedMessage {
                    Text(attributedMessage)
                        .padding()
//                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    if message.count > 200 {
                        ScrollView {
                            Text(message)
                                .font(.body)
                                .padding()
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 200)
                    } else {
                        Text(message)
                            .font(.body)
                            .padding()
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                HStack {
                    if let secondaryButtonTitle = secondaryButtonTitle {
                        Button(secondaryButtonTitle) {
                            secondaryAction?()
                            isPresented.toggle()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 70)
                        .foregroundStyle(.red)
                        .padding()
                        .background(Color.secondary.opacity(0.3))
                        .cornerRadius(8)
                    }
                    
                    Button(primaryButtonTitle) {
                        primaryAction()
                        isPresented.toggle()
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 70)
                    .padding()
                    .background(Color.secondary.opacity(0.3))
                    .cornerRadius(8)
                    .foregroundStyle(.blue)
                }
                .padding()
                .frame(maxWidth: secondaryButtonTitle == nil ? .infinity : nil)
            }
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
            .padding(.vertical, 100)
        }
        .frame(maxHeight: .infinity)
    }
}

struct AlertModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    var title: String
    var message: AttributedString
    var primaryButtonTitle: String
    var primaryAction: () -> Void
    var secondaryButtonTitle: String?
    var secondaryAction: (() -> Void)?
    var isAttributedMessage: Bool // Add this property
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                Color.gray.opacity(0.5)
                    .ignoresSafeArea(.all)
                
                CustomAlertView(
                    title: title,
                    message: message.description,
                    attributedMessage: message,
                    isAttributedMessage: isAttributedMessage, // Pass it here
                    primaryButtonTitle: primaryButtonTitle,
                    primaryAction: primaryAction,
                    secondaryButtonTitle: secondaryButtonTitle,
                    secondaryAction: secondaryAction,
                    isPresented: $isPresented
                )
            }
        }
    }
}


extension View {
    
    func customAlertWithButtons(
        isPresented: Binding<Bool>,
        title: String = "Caution",
        message: AttributedString,
        isAttributedMessage: Bool = false, // Add this parameter
        primaryButtonTitle: String = "Ok",
        primaryAction: @escaping () -> Void = {},
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        self.modifier(AlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: primaryAction,
            secondaryButtonTitle: secondaryButtonTitle,
            secondaryAction: secondaryAction,
            isAttributedMessage: isAttributedMessage // Pass it here
        ))
    }
}

