//
//  CardVerificationView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 07/08/2025.
//

import SwiftUI


extension Color {
    
    static let darkBlue = Color(red: 0.1, green: 0.2, blue: 0.4)
    static let vibrantBlue = Color(red: 0.2, green: 0.5, blue: 1.0)
    static let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warningYellow = Color(red: 1.0, green: 0.8, blue: 0.2)
    static let errorRed = Color(red: 1.0, green: 0.3, blue: 0.3)
    
}

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
    @Published var fieldFocus: FieldFocus? = .lastFourDigits
    
    enum FieldFocus {
        case lastFourDigits, cvc
    }
    
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
    
    func save(completion: @escaping (Bool, String, String) -> Void) {
        if validateFields() {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoading = false
                self.isSuccess = true
                completion(true, self.lastFourDigits, self.cvc)
            }
        } else {
            completion(false, "", "")
        }
    }
}

struct CardVerificationView: View {
    
    @StateObject private var viewModel = CardVerificationViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var shakeInvalidField: Bool = false
    @State private var pulseButton = false
    @State private var cardTilt = CGSize.zero
    @Namespace private var animation
    var onVerificationComplete: ((Bool, String, String) -> Void)?
    
    init(onVerificationComplete: ((Bool, String, String) -> Void)? = nil) {
        self.onVerificationComplete = onVerificationComplete
    }
    
    var body: some View {
        ZStack {
            Color.lightBlue
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Image(systemName: "square.stack.3d.up.fill")
                        .foregroundStyle(.white.opacity(0.1))
                        .font(.system(size: 300))
                        .offset(x: 100, y: -100)
                )
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                            )
                    }
                    
                    Spacer()
                    
                    Text("Card Verification")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.blue)
                        .matchedGeometryEffect(id: "title", in: animation)
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                CardIllustrationView(lastFourDigits: viewModel.lastFourDigits,
                                     cvc: viewModel.cvc,
                                     isFocused: viewModel.fieldFocus == .cvc)
                .rotation3DEffect(
                    Angle(degrees: Double(cardTilt.width / 10)),
                    axis: (x: 0, y: 1, z: 0)
                )
                .rotation3DEffect(
                    Angle(degrees: Double(cardTilt.height / 10)),
                    axis: (x: 1, y: 0, z: 0)
                )
                .offset(cardTilt)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.interactiveSpring()) {
                                cardTilt = value.translation
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                cardTilt = .zero
                            }
                        }
                )
                .padding(.vertical, 30)
                .scaleEffect(viewModel.showValidationErrors && !viewModel.allFieldsValid ? 1.02 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.showValidationErrors)
                
                VStack(spacing: 20) {
                    // Last 4 digits field
                    FloatingLabelTextField(
                        label: "Last 4 Digits",
                        placeholder: "••••",
                        text: $viewModel.lastFourDigits,
                        isValid: viewModel.lastFourDigitsValid || !viewModel.showValidationErrors,
                        onCommit: { viewModel.fieldFocus = .cvc }
                    )
                    .keyboardType(.numberPad)
                    .modifier(ShakeEffect(animatableData: CGFloat(shakeInvalidField && !viewModel.lastFourDigitsValid ? 1 : 0)))
                    .overlay(
                        Group {
                            if viewModel.showValidationErrors && !viewModel.lastFourDigitsValid {
                                ValidationErrorView(message: "Enter exactly 4 digits")
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                            .animation(.easeInOut(duration: 0.3), value: viewModel.showValidationErrors)
                    )
                    .onTapGesture {
                        withAnimation {
                            viewModel.fieldFocus = .lastFourDigits
                        }
                    }
                    
                    // CVC field
                    FloatingLabelTextField(
                        label: "CVC Code",
                        placeholder: "•••",
                        text: $viewModel.cvc,
                        isValid: viewModel.cvcValid || !viewModel.showValidationErrors,
                        isSecure: true,
                        onCommit: { viewModel.save { success, last4, cvc in
                            onVerificationComplete?(success, last4, cvc)
                        } }
                    )
                    .keyboardType(.numberPad)
                    .modifier(ShakeEffect(animatableData: CGFloat(shakeInvalidField && !viewModel.cvcValid ? 1 : 0)))
                    .overlay(
                        Group {
                            if viewModel.showValidationErrors && !viewModel.cvcValid {
                                ValidationErrorView(message: "Enter exactly 3 digits")
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                            .animation(.easeInOut(duration: 0.3), value: viewModel.showValidationErrors)
                    )
                    .onTapGesture {
                        withAnimation {
                            viewModel.fieldFocus = .cvc
                        }
                    }
                    
                    Spacer()
                    
                    // Animated save button
                    Button(action: {
                        if viewModel.validateFields() {
                            withAnimation(.easeInOut(duration: 0.2).repeatCount(2)) {
                                pulseButton.toggle()
                            }
                            viewModel.save { success, last4, cvc in
                                if success {
                                    onVerificationComplete?(success, last4, cvc)
                                } else {
                                    withAnimation(.default) {
                                        shakeInvalidField.toggle()
                                    }
                                }
                            }
                        } else {
                            withAnimation(.interactiveSpring()) {
                                shakeInvalidField.toggle()
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                LoadingDotsView()
                            } else {
                                Text("VERIFY CARD")
                                    .font(.system(size: 17, weight: .bold))
                                    .scaleEffect(pulseButton ? 1.05 : 1.0)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    viewModel.allFieldsValid ? .vibrantBlue : .vibrantBlue.opacity(0.6),
                                    viewModel.allFieldsValid ? .darkBlue : .darkBlue.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                        )
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                        .shadow(color: .vibrantBlue.opacity(viewModel.allFieldsValid ? 0.4 : 0.1),
                                radius: 10, x: 0, y: 5)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .disabled(!viewModel.allFieldsValid || viewModel.isLoading)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}


struct CardIllustrationView: View {
    let lastFourDigits: String
    let cvc: String
    let isFocused: Bool
    
    var body: some View {
        ZStack {
            // Card background with embossed effect
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.darkBlue, Color.vibrantBlue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
                .frame(width: .infinity, height: 200)
                .padding(.horizontal)
            
            VStack(alignment: .leading) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.warningYellow, Color.orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 36)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .frame(width: 50, height: 36)
                        
                        // Chip lines
                        VStack(spacing: 4) {
                            ForEach(0..<4, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 30, height: 2)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Card network logo with shine
                    Text("VISA")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .italic()
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.8), .clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .mask(
                                Text("VISA")
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                    .italic()
                            )
                            .offset(y: -10)
                            .opacity(0.6)
                        )
                }
                
                Spacer()
                
                // Card number with focus animation
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Text(lastFourDigits.isEmpty ? "••••" : "•••• \(lastFourDigits)")
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white)
                }
                .opacity(isFocused ? 0.6 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isFocused)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CVC")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                        Text(cvc.isEmpty ? "•••" : cvc)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 24)
                            .background(
                                isFocused ? Color.white.opacity(0.2) : Color.clear
                            )
                            .cornerRadius(4)
                            .animation(.easeInOut(duration: 0.3), value: isFocused)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("EXPIRES")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                        Text("••/••")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                    .opacity(isFocused ? 0.6 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isFocused)
                }
                .padding(.top, 12)
            }
            .padding(25)
            .frame(width: 320, height: 200)
        }
    }
}

struct FloatingLabelTextField: View {
    
    let label: String
    let placeholder: String
    @Binding var text: String
    var isValid: Bool = true
    var isSecure: Bool = false
    var onCommit: () -> Void = {}
    
    @State private var isFocused: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isFocused ? .blue : .gray)
                .scaleEffect(isFocused || !text.isEmpty ? 1.0 : 1.2)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused || !text.isEmpty)
            
            ZStack(alignment: .leading) {
                if text.isEmpty && !isFocused {
                    Text(placeholder)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundStyle(.gray.opacity(0.7))
                        .offset(y: 1)
                }
                
                if isSecure {
                    SecureField("", text: $text, onCommit: onCommit)
                } else {
                    TextField("", text: $text, onCommit: onCommit)
                }
            }
            .font(.system(size: 18, weight: .medium, design: .monospaced))
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isFocused ? Color.vibrantBlue :
                                    isValid ? Color(.systemGray4) : Color.errorRed,
                                lineWidth: isFocused ? 2 : 1.5
                            )
                    )
                    .shadow(color: isFocused ? Color.vibrantBlue.opacity(0.2) : .clear,
                            radius: isFocused ? 4 : 0, x: 0, y: 0)
            )
            .onTapGesture {
                isFocused = true
            }
        }
        .onAppear {
            // Handle keyboard show/hide notifications to update focus state
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    isFocused = true
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    isFocused = false
                }
            }
        }
    }
    
}

struct ValidationErrorView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.system(size: 14))
            
            Text(message)
                .foregroundStyle(.red)
                .font(.system(size: 13, weight: .medium))
            
            Spacer()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.errorRed.opacity(0.1))
        )
        .offset(y: 8)
    }
}

struct LoadingDotsView: View {
    
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(.white)
                    .opacity(animating ? 0.3 : 1)
                    .offset(y: animating ? 5 : -5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2)
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
    
}

struct ShakeEffect: GeometryEffect {
    
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = CGFloat(sin(animatableData * .pi * 6)) * 8
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
    
}

#Preview {
    CardVerificationView { isSuccess, last4, cvc in
        
    }
}
