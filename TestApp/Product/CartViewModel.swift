//
//  CartViewModel.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 15/03/2025.
//

import SwiftUI
import Combine

struct Product: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let price: Double
    var quantity: Int
    var discount: Double
    var netAmountExclVat: Double
    var vatAmount: Double
    var vatPercentage: Double
    var netAmountInclVat: Double
    var skywardsPoint: Int
}

@MainActor
class CartViewModel: ObservableObject {
    
    static let shared = CartViewModel()
    
    @Published private(set) var cartItems: [Product] = [] {
        didSet {
            cartCount = cartItems.count
        }
    }
    
    @Published var cartCount: Int = 0
    
    func addToCart(_ product: Product) {
        cartItems.append(product)
    }
    
    func removeFromCart(_ product: Product) {
        if let index = cartItems.firstIndex(where: { $0.id == product.id }) {
            cartItems.remove(at: index)
        }
    }
    func getCartItems() -> [Product] {
        cartItems
    }
    
}

struct ProductCatalogueView: View {
    
    @ObservedObject private var cartViewModel = CartViewModel.shared  // Use @ObservedObject
    @State private var selectedProduct: Product?
    
    let products = [
        Product(name: "Watch", price: 99.99, quantity: 1, discount: 5.0, netAmountExclVat: 94.99, vatAmount: 5.0, vatPercentage: 5.0, netAmountInclVat: 99.99, skywardsPoint: 10),
        Product(name: "Phone", price: 599.99, quantity: 1, discount: 20.0, netAmountExclVat: 579.99, vatAmount: 20.0, vatPercentage: 5.0, netAmountInclVat: 599.99, skywardsPoint: 50),
        Product(name: "Laptop", price: 1299.99, quantity: 1, discount: 50.0, netAmountExclVat: 1249.99, vatAmount: 50.0, vatPercentage: 5.0, netAmountInclVat: 1299.99, skywardsPoint: 100)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ForEach(products) { product in
                        Button(action: {
                            selectedProduct = product
                        }) {
                            HStack {
                                Text(product.name)
                                Text("$\(product.price, specifier: "%.2f")")
                            }
                        }
                        .padding()
                    }
                    
                    if cartViewModel.cartCount > 0 {
                        NavigationLink(destination: CartView()) {
                            CartButton(cartCount: $cartViewModel.cartCount)
                        }
                        .padding()
                    }
                }
                
                if let product = selectedProduct {
                    ProductDetailsView(product: product, isPresented: $selectedProduct)
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle("Products")
        }
    }
}

struct ProductDetailsView: View {
    
    let product: Product
    @Binding var isPresented: Product?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(product.name)
                .font(.title)
            
            Text("$\(product.price, specifier: "%.2f")")
                .font(.title2)
            
            Button(action: {
                CartViewModel.shared.addToCart(product)  // No async needed anymore
                isPresented = nil
            }) {
                Text("Add to Cart")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            Button("Close") {
                isPresented = nil
            }
        }
        .frame(maxWidth: 300, maxHeight: 200)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
}

struct CartButton: View {
    
    @Binding var cartCount: Int
    
    var body: some View {
        ZStack {
            Image(systemName: "cart.fill")
                .font(.title)
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 4)
            
            if cartCount > 0 {
                Text("\(cartCount)")  // Show cart count if greater than 0
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 12, y: -12)
            }

        }
    }
}

struct EmptyCartView: View {
    var body: some View {
        VStack {
            Image(systemName: "cart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.bottom, 10)
            
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Browse and add items to your cart.")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
                .padding(.top, 2)
        }
        .padding()
        .opacity(0.9)
    }
}


struct CartView: View {
    @StateObject private var cartViewModel = CartViewModel.shared
    @State private var cartItems: [Product] = []
    @State private var currentSwipedRow: UUID?
    
    var body: some View {
        NavigationStack {
            VStack {
                if cartItems.isEmpty {
                    EmptyCartView()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(cartItems) { product in
                                ProductCartCard(product: product, currentSwipedRow: $currentSwipedRow)
                                    .transition(.scale)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Cart")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            cartItems.removeAll()
                        }
                    } label: {
                        Label("Clear Cart", systemImage: "trash")
                    }
                }
            }
            .onAppear {
                Task {
                    await updateCartItems()
                }
            }
            .onChange(of: cartViewModel.cartItems) { _, _ in
                cartItems = cartViewModel.cartItems
            }
        }
    }
    
    private func updateCartItems() async {
        // Fetch the latest cart items
        cartItems = cartViewModel.getCartItems()
    }
}


struct ProductCartCard: View {
    var product: Product
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @State private var dragOffset = CGSize.zero
    @State private var showDeleteButton = false // Track showing the delete button
    @State private var isSwiped = false // Track if the card is swiped
    @Binding var currentSwipedRow: UUID? // Track the current swiped row
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(product.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                    Text("Qty: \(product.quantity)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(6)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(8)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                    RowView(label: "💲 Price", value: product.price)
                        .padding(.trailing, 10)
                    RowView(label: "🏷 Discount", value: product.discount)
                        .padding(.leading, 10)
                    RowView(label: "💵 Net Amount (Excl. VAT)", value: product.netAmountExclVat)
                        .padding(.trailing, 10)
                    RowView(label: "💰 VAT Amount", value: product.vatAmount)
                        .padding(.leading, 10)
                    RowView(label: "📊 VAT %", value: product.vatPercentage, suffix: "%")
                        .padding(.trailing, 10)
                    RowView(label: "💳 Net Amount (Incl. VAT)", value: product.netAmountInclVat)
                        .padding(.leading, 10)
                }
            }
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.9))
                        .blur(radius: 5)
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                }
            )
            .cornerRadius(15)
            .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
            .padding(.horizontal, 5)
            .offset(x: dragOffset.width)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 { // Only allow left swipes
                            dragOffset = value.translation
                            if dragOffset.width < -50 {
                                showDeleteButton = true // Show delete button when swiped left
                                isSwiped = true
                                currentSwipedRow = product.id // Set the current swiped row to this product's ID
                            }
                        }
                    }
                    .onEnded { value in
                        if dragOffset.width < -100 {
                        } else {
                            resetSwipe()
                        }
                    }
            )
            .animation(.easeOut, value: dragOffset)
            
            // Delete button only appears when swiped left
            if showDeleteButton {
                Button(action: {
                    withAnimation {
                        CartViewModel.shared.removeFromCart(product)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    resetSwipe()
                }) {
                    Text("Delete")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.trailing, 15)
                }
                .frame(width: 100) // Fixed width for delete button
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Make sure the HStack fills available space
        .onTapGesture {
            if isSwiped {
                resetSwipe()
            }
        }
        .onAppear {
            // If this row is the one that's swiped, reset its state when another row is swiped
            if currentSwipedRow != product.id {
                resetSwipe()
            }
        }
    }
    
    private func resetSwipe() {
        // Reset the swipe offset and the state
        withAnimation {
            dragOffset = .zero
            showDeleteButton = false
            isSwiped = false
            currentSwipedRow = nil // Reset the current swiped row
        }
    }
}

struct RowView: View {
    let label: String
    let value: Double
    let suffix: String?
    
    init(label: String, value: Double, suffix: String? = nil) {
        self.label = label
        self.value = value
        self.suffix = suffix
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 200, alignment: .leading)  // Fixed width for labels
            
            Text("\(value, specifier: "%.2f")\(suffix ?? "")")
                .font(.subheadline)
                .foregroundColor(.black)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .trailing)  // Align values to right
        }
    }
}
