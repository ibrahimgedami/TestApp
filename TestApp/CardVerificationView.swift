//
//  CardVerificationView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 07/08/2025.
//

import SwiftUI

class CardVerificationViewModel: ObservableObject {
    @Published var lastFourDigits = "" {
        didSet {
            if lastFourDigits.count > 4 {
                lastFourDigits = String(lastFourDigits.prefix(4))
            }
            validateLastFourDigits()
        }
    }
    
    @Published var cvc = "" {
        didSet {
            if cvc.count > 3 {
                cvc = String(cvc.prefix(3))
            }
            validateCVC()
        }
    }
    
    @Published var lastFourDigitsValid = false
    @Published var cvcValid = false
    @Published var showValidationErrors = false
    @Published var isLoading = false
    @Published var isSuccess = false
    
    var allFieldsValid: Bool {
        lastFourDigitsValid && cvcValid
    }
    
    private func validateLastFourDigits() {
        lastFourDigitsValid = lastFourDigits.count == 4 && lastFourDigits.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    private func validateCVC() {
        cvcValid = cvc.count == 3 && cvc.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func validateFields() -> Bool {
        validateLastFourDigits()
        validateCVC()
        showValidationErrors = !allFieldsValid
        return allFieldsValid
    }
    
    func save(completion: @escaping (Bool) -> Void) {
        if validateFields() {
            isLoading = true
            // Simulate network request
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoading = false
                self.isSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    completion(true)
                }
            }
        } else {
            completion(false)
        }
    }
}

struct CardVerificationView: View {
    @StateObject private var viewModel = CardVerificationViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var shakeInvalidField: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.9803921569, alpha: 1)), Color.white]),
                           startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Verify Card")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible spacer to balance the HStack
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Card illustration
                CreditCardIllustration(lastFourDigits: viewModel.lastFourDigits, cvc: viewModel.cvc)
                    .padding(.vertical, 30)
                    .scaleEffect(viewModel.showValidationErrors && !viewModel.allFieldsValid ? 1.02 : 1)
                    .animation(.interactiveSpring(), value: viewModel.showValidationErrors)
                
                // Form fields
                VStack(spacing: 24) {
                    // Last 4 digits field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LAST 4 DIGITS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.systemGray))
                        
                        HStack {
                            TextField("••••", text: $viewModel.lastFourDigits)
                                .font(.system(size: 18, weight: .medium, design: .monospaced))
                                .keyboardType(.numberPad)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            viewModel.showValidationErrors && !viewModel.lastFourDigitsValid ?
                                            Color.red : Color(.systemGray4),
                                            lineWidth: 1.5
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                        )
                                )
                                .modifier(ShakeEffect(animatableData: CGFloat(shakeInvalidField && !viewModel.lastFourDigitsValid ? 1 : 0)))
                                .onChange(of: viewModel.lastFourDigits) { _ in
                                    if viewModel.showValidationErrors {
                                        _ = viewModel.validateFields()
                                    }
                                }
                        }
                        
                        if viewModel.showValidationErrors && !viewModel.lastFourDigitsValid {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Please enter exactly 4 digits")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                Spacer()
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    // CVC field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CVC CODE")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(.systemGray))
                        
                        HStack {
                            SecureField("•••", text: $viewModel.cvc)
                                .font(.system(size: 18, weight: .medium, design: .monospaced))
                                .keyboardType(.numberPad)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            viewModel.showValidationErrors && !viewModel.cvcValid ?
                                            Color.red : Color(.systemGray4),
                                            lineWidth: 1.5
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                        )
                                )
                                .modifier(ShakeEffect(animatableData: CGFloat(shakeInvalidField && !viewModel.cvcValid ? 1 : 0)))
                                .onChange(of: viewModel.cvc) { _ in
                                    if viewModel.showValidationErrors {
                                        _ = viewModel.validateFields()
                                    }
                                }
                        }
                        
                        if viewModel.showValidationErrors && !viewModel.cvcValid {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Please enter exactly 3 digits")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                Spacer()
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        if viewModel.validateFields() {
                            viewModel.save { success in
                                if !success {
                                    withAnimation(.default) {
                                        shakeInvalidField.toggle()
                                    }
                                }
                            }
                        } else {
                            withAnimation(.default) {
                                shakeInvalidField.toggle()
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Verify Card")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            
            if viewModel.isSuccess {
                SuccessOverlay()
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

// MARK: - Custom Views

struct CreditCardIllustration: View {
    let lastFourDigits: String
    let cvc: String
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color(#colorLiteral(red: 0.3254901961, green: 0.4196078431, blue: 0.7764705882, alpha: 1)), Color(#colorLiteral(red: 0.4274509804, green: 0.3176470588, blue: 0.7607843137, alpha: 1))]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 320, height: 200)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "simcard.fill")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 24))
                    
                    Spacer()
                    
                    Text("VISA")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                HStack {
                    ForEach(0..<3) { _ in
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text("••••")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.leading, 8)
                    
                    if !lastFourDigits.isEmpty {
                        Text(lastFourDigits)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CVC")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        Text(cvc.isEmpty ? "•••" : "•".repeating(cvc.count) + cvc.suffix(3 - cvc.count))
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding(25)
            .frame(width: 320, height: 200)
        }
    }
}

struct SuccessOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Verified Successfully!")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)
            )
            .padding(40)
        }
        .zIndex(1)
    }
}

// MARK: - Animations

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = CGFloat(sin(animatableData * .pi * 4)) * 10
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

extension String {
    func repeating(_ count: Int) -> String {
        return String(repeating: self, count: count)
    }
}

// MARK: - Preview

struct CardVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        CardVerificationView()
    }
}
