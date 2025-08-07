//
//  CardVerificationView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 07/08/2025.
//

import SwiftUI

// Custom color palette
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
    
    func save(completion: @escaping (Bool) -> Void) {
        if validateFields() {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoading = false
                self.isSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
    @Environment(\.dismiss) var dismiss
    @State private var shakeInvalidField: Bool = false
    @State private var pulseButton = false
    @State private var cardTilt = CGSize.zero
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // Background with subtle texture
            Color.lightBlue
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Image(systemName: "square.stack.3d.up.fill")
                        .foregroundColor(.white.opacity(0.1))
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
                            .foregroundColor(.darkBlue)
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
                        .foregroundColor(.darkBlue)
                        .matchedGeometryEffect(id: "title", in: animation)
                    
                    Spacer()
                    
                    // Invisible spacer to balance the HStack
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Card illustration with 3D tilt effect
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
                        onCommit: { viewModel.save { _ in } }
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
                            viewModel.save { success in
                                if !success {
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
                        .foregroundColor(.white)
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
            
            // Success overlay with confetti
            if viewModel.isSuccess {
                SuccessOverlayView()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.9)),
                        removal: .opacity.combined(with: .scale(scale: 1.1))
                    ))
            }
        }
    }
}

// MARK: - Custom Views

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
                        .foregroundColor(.white)
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
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text(lastFourDigits.isEmpty ? "••••" : "•••• \(lastFourDigits)")
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                }
                .opacity(isFocused ? 0.6 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isFocused)
                
                // CVC and expiration with focus highlight
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CVC")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                        Text(cvc.isEmpty ? "•••" : cvc)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
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
                            .foregroundColor(.white.opacity(0.7))
                        Text("••/••")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
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
                .foregroundColor(isFocused ? .darkBlue : .gray)
                .scaleEffect(isFocused || !text.isEmpty ? 1.0 : 1.2)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused || !text.isEmpty)
            
            ZStack(alignment: .leading) {
                if text.isEmpty && !isFocused {
                    Text(placeholder)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.7))
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
                .foregroundColor(.errorRed)
                .font(.system(size: 14))
            
            Text(message)
                .foregroundColor(.errorRed)
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
                    .foregroundColor(.white)
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

struct SuccessOverlayView: View {
    @State private var confetti = false
    
    var body: some View {
        ZStack {
            // Background dim
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            // Confetti particles
            if confetti {
                ForEach(0..<30, id: \.self) { _ in
                    ConfettiParticle()
                }
            }
            
            // Success card
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.successGreen)
                        .scaleEffect(confetti ? 1.0 : 0.5)
                        .opacity(confetti ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.2), value: confetti)
                }
                
                Text("Card Verified!")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(confetti ? 1.0 : 0.0)
                    .offset(y: confetti ? 0 : 20)
                    .animation(.easeOut(duration: 0.3).delay(0.3), value: confetti)
                
                Text("Your card has been successfully verified")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .opacity(confetti ? 1.0 : 0.0)
                    .offset(y: confetti ? 0 : 20)
                    .animation(.easeOut(duration: 0.3).delay(0.4), value: confetti)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.darkBlue)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(40)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    confetti = true
                }
            }
        }
    }
}

struct ConfettiParticle: View {
    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0
    
    let colors: [Color] = [.vibrantBlue, .successGreen, .warningYellow, .errorRed, .white]
    let shapes: [AnyView] = [
        AnyView(Circle()),
        AnyView(Rectangle()),
        AnyView(Triangle()),
        AnyView(Diamond())
    ]
    
    var body: some View {
        let randomColor = colors.randomElement()!
        let randomShape = shapes.randomElement()!
        let duration = Double.random(in: 1.5...3.0)
        
        randomShape
            .foregroundColor(randomColor)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .position(position)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    position = CGPoint(
                        x: CGFloat.random(in: -UIScreen.main.bounds.width/2...UIScreen.main.bounds.width/2),
                        y: UIScreen.main.bounds.height
                    )
                    opacity = 1
                    rotation = Double.random(in: 0...360)
                    scale = CGFloat.random(in: 0.5...1.5)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    opacity = 0
                }
            }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

// MARK: - Animations

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = CGFloat(sin(animatableData * .pi * 6)) * 8
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

// MARK: - Preview

struct CardVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardVerificationView()
            
            CardVerificationView()
                .preferredColorScheme(.dark)
        }
    }
}
