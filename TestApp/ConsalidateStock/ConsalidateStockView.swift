//
//  ConsalidateStockView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 31/07/2025.
//

import SwiftUI

struct Product: Identifiable, Hashable {
    
    let id = UUID()
    let referenceNumber: String
    let classification: String
    let discount: Double
    let unitPrice: Double
    var imageURL: String?
    
    // Details that load when selected
    var name: String?
    var description: String?
    var stock: Int?
    var onTransit: Int?
    var reservation: Int?
    var balance: Int?
    var lastUpdated: Date?
    
}

class ProductViewModel: ObservableObject {
    // Sample data - replace with your actual data source
    @Published var brands: [String] = ["All Brands", "Nike", "Adidas", "Puma", "Under Armour"]
    @Published var groups: [String] = ["All Groups", "Footwear", "Apparel", "Accessories"]
    @Published var subgroups: [String: [String]] = [
        "Footwear": ["All Subgroups", "Running", "Basketball", "Soccer"],
        "Apparel": ["All Subgroups", "T-Shirts", "Shorts", "Jackets"],
        "Accessories": ["All Subgroups", "Bags", "Hats", "Socks"]
    ]
    
    @Published var selectedBrand: String = "All Brands"
    @Published var selectedGroup: String = "All Groups"
    @Published var selectedSubgroup: String = "All Subgroups"
    @Published var referenceText: String = ""
    
    @Published var searchResults: [Product] = []
    @Published var selectedProduct: Product?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // Search history
    @Published var searchHistory: [String] = []
    
    // Sorting options
    enum SortOption: String, CaseIterable {
        case reference = "Reference"
        case priceLowHigh = "Price (Low to High)"
        case priceHighLow = "Price (High to Low)"
        case discount = "Discount"
    }
    @Published var selectedSortOption: SortOption = .reference
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        selectedBrand = brands.first ?? ""
        selectedGroup = groups.first ?? ""
        selectedSubgroup = subgroups[selectedGroup]?.first ?? ""
    }
    
    func search() {
        guard !isLoading else { return }
        
        isLoading = true
        showError = false
        
        // Add to search history if not empty
        if !referenceText.isEmpty && !searchHistory.contains(referenceText) {
            searchHistory.insert(referenceText, at: 0)
            if searchHistory.count > 5 {
                searchHistory.removeLast()
            }
        }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            
            // Filter logic based on selections
            let allProducts = [
                Product(referenceNumber: "REF123", classification: "Running Shoes", discount: 15.0, unitPrice: 129.99, imageURL: "https://example.com/shoe1.jpg"),
                Product(referenceNumber: "REF456", classification: "Basketball Shorts", discount: 10.0, unitPrice: 49.99, imageURL: "https://example.com/shorts1.jpg"),
                Product(referenceNumber: "REF789", classification: "Training Jacket", discount: 20.0, unitPrice: 89.99, imageURL: "https://example.com/jacket1.jpg"),
                Product(referenceNumber: "REF101", classification: "Running Socks", discount: 5.0, unitPrice: 14.99, imageURL: "https://example.com/socks1.jpg"),
                Product(referenceNumber: "REF202", classification: "Gym Bag", discount: 25.0, unitPrice: 59.99, imageURL: "https://example.com/bag1.jpg")
            ]
            
            // Apply filters
            var filteredProducts = allProducts
            
            if self.selectedBrand != "All Brands" {
                filteredProducts = filteredProducts.filter { $0.classification.contains(self.selectedBrand) }
            }
            
            if self.selectedGroup != "All Groups" {
                filteredProducts = filteredProducts.filter { $0.classification.contains(self.selectedGroup) }
            }
            
            if self.selectedSubgroup != "All Subgroups" && self.selectedGroup != "All Groups" {
                filteredProducts = filteredProducts.filter { $0.classification.contains(self.selectedSubgroup) }
            }
            
            if !self.referenceText.isEmpty {
                filteredProducts = filteredProducts.filter { $0.referenceNumber.localizedCaseInsensitiveContains(self.referenceText) }
            }
            
            self.searchResults = filteredProducts.sorted(by: self.currentSortPredicate())
            
            // Select first item automatically if none selected
            if self.selectedProduct == nil, let first = self.searchResults.first {
                self.loadDetails(for: first)
            }
        }
    }
    
    func loadDetails(for product: Product) {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            
            var detailedProduct = product
            detailedProduct.name = "Premium \(product.classification)"
            detailedProduct.description = "High-quality \(product.classification.lowercased()) with advanced features for maximum performance."
            detailedProduct.stock = Int.random(in: 50...200)
            detailedProduct.onTransit = Int.random(in: 5...20)
            detailedProduct.reservation = Int.random(in: 2...15)
            detailedProduct.balance = (detailedProduct.stock ?? 0) - (detailedProduct.reservation ?? 0)
            detailedProduct.lastUpdated = Date()
            
            self.selectedProduct = detailedProduct
        }
    }
    
    func sortResults() {
        searchResults.sort(by: currentSortPredicate())
    }
    
    private func currentSortPredicate() -> (Product, Product) -> Bool {
        switch selectedSortOption {
        case .reference:
            return { $0.referenceNumber < $1.referenceNumber }
        case .priceLowHigh:
            return { $0.unitPrice < $1.unitPrice }
        case .priceHighLow:
            return { $0.unitPrice > $1.unitPrice }
        case .discount:
            return { $0.discount > $1.discount }
        }
    }
    
    func resetFilters() {
        selectedBrand = "All Brands"
        selectedGroup = "All Groups"
        selectedSubgroup = "All Subgroups"
        referenceText = ""
    }
}

struct ProductSearchView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var showFilters = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Search Bar
                    quickSearchBar
                    
                    // Search Results Section
                    if !viewModel.searchResults.isEmpty {
                        searchResultsSection
                    } else {
                        emptyStateView
                    }
                    
                    // Product Details Section
                    if let selectedProduct = viewModel.selectedProduct {
                        productDetailsSection(selectedProduct)
                    }
                }
                .padding()
            }
            .navigationTitle("Product Search")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolRenderingMode(.multicolor)
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView(viewModel: viewModel, onSearch: {
                    showFilters = false
                    viewModel.search()
                })
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                // Perform initial search
                viewModel.search()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var quickSearchBar: some View {
        HStack {
            TextField("Quick search...", text: $viewModel.referenceText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.search)
                .onSubmit {
                    viewModel.search()
                }
            
            Button(action: {
                viewModel.search()
            }) {
                Image(systemName: "magnifyingglass")
                    .padding(8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Search Results (\(viewModel.searchResults.count))")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    ForEach(ProductViewModel.SortOption.allCases, id: \.self) { option in
                        Button(action: {
                            viewModel.selectedSortOption = option
                            viewModel.sortResults()
                        }) {
                            Label(option.rawValue, systemImage: viewModel.selectedSortOption == option ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .font(.subheadline)
                }
            }
            
            LazyVStack(spacing: 0) {
                ForEach(viewModel.searchResults) { product in
                    ProductRow(product: product, isSelected: viewModel.selectedProduct?.id == product.id)
                        .onTapGesture {
                            viewModel.loadDetails(for: product)
                        }
                        .animation(.default, value: viewModel.selectedProduct)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No products found")
                .font(.headline)
            Text("Try adjusting your search criteria")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
    
    private func productDetailsSection(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Product Details")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Product Image and Basic Info
                HStack(alignment: .top, spacing: 15) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let name = product.name {
                            Text(name)
                                .font(.headline)
                        }
                        
                        Text(product.referenceNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Price")
                                    .font(.caption)
                                Text(String(format: "$%.2f", product.unitPrice))
                                    .font(.subheadline.bold())
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Discount")
                                    .font(.caption)
                                Text("\(product.discount)%")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Description
                if let description = product.description {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.subheadline.bold())
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Stock Information
                VStack(alignment: .leading, spacing: 8) {
                    Text("Inventory")
                        .font(.subheadline.bold())
                    
                    Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                        GridRow {
                            Text("Stock:")
                            Text("\(product.stock ?? 0)")
                                .gridColumnAlignment(.trailing)
                            
                            Text("On Transit:")
                            Text("\(product.onTransit ?? 0)")
                                .gridColumnAlignment(.trailing)
                        }
                        
                        GridRow {
                            Text("Reserved:")
                            Text("\(product.reservation ?? 0)")
                                .gridColumnAlignment(.trailing)
                            
                            Text("Available:")
                            Text("\(product.balance ?? 0)")
                                .gridColumnAlignment(.trailing)
                                .foregroundColor((product.balance ?? 0) <= 0 ? .red : .primary)
                        }
                    }
                    .font(.subheadline)
                }
                
                // Last updated
                if let lastUpdated = product.lastUpdated {
                    Divider()
                    
                    HStack {
                        Text("Last updated:")
                            .font(.caption)
                        Text(lastUpdated.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct FilterView: View {
    
    @ObservedObject var viewModel: ProductViewModel
    var onSearch: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Brand") {
                    Picker("Select Brand", selection: $viewModel.selectedBrand) {
                        ForEach(viewModel.brands, id: \.self) { brand in
                            Text(brand).tag(brand)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Group") {
                    Picker("Select Group", selection: $viewModel.selectedGroup) {
                        ForEach(viewModel.groups, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: viewModel.selectedGroup) { _, _ in
                        viewModel.selectedSubgroup = viewModel.subgroups[viewModel.selectedGroup]?.first ?? ""
                    }
                }
                
                if viewModel.selectedGroup != "All Groups" {
                    Section("Subgroup") {
                        Picker("Select Subgroup", selection: $viewModel.selectedSubgroup) {
                            ForEach(viewModel.subgroups[viewModel.selectedGroup] ?? [], id: \.self) { subgroup in
                                Text(subgroup).tag(subgroup)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Reference Number") {
                    TextField("Enter reference", text: $viewModel.referenceText)
                    
                    if !viewModel.searchHistory.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recent Searches")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.searchHistory, id: \.self) { history in
                                        Button(action: {
                                            viewModel.referenceText = history
                                        }) {
                                            Text(history)
                                                .font(.caption)
                                                .padding(6)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(5)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.resetFilters()
                    }) {
                        Text("Reset All Filters")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onSearch()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Search") {
                        onSearch()
                    }
                    .bold()
                }
            }
        }
    }
}

struct ProductRow: View {
    
    let product: Product
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.referenceNumber)
                        .font(.headline)
                    
                    Text(product.classification)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "$%.2f", product.unitPrice))
                        .font(.subheadline.bold())
                    
                    Text("\(product.discount)% off")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 1)
    }
}

// Preview
struct ProductSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ProductSearchView()
    }
}

// MARK: ----------------
//struct StockItem: Identifiable {
//    let id = UUID()
//    let referenceNo: String
//    let classification: String
//    let discount: String
//    let unitPrice: Double
//    let posName: String
//    let stock: Int
//    let onTransit: Int
//    let approvedReserved: Int
//    let balance: Int
//    
//    var hasReferenceInfo: Bool {
//        !referenceNo.isEmpty && !classification.isEmpty
//    }
//}
//
//struct ConsolidatedStockView: View {
//    let brand = "TUDOR"
//    let subGroup = "WATCHES"
//    let group = "WATCHES & CLOCKS"
//    let refFrom = "79030B"
//    let refTo = "79030BZ"
//    let descriptionText = "TUDOR 39MM STEEL SPORT BLACK BAY 58 BLUE INDEX DIAL STRAP"
//    let serialNumber = "7073562"
//    
//    @State private var expandedSections = Set<String>()
//    
//    let stockItems = [
//        StockItem(referenceNo: "79030B/72040 100020", classification: "CORE", discount: "***", unitPrice: 15880.00, posName: "Multi-New (Waff)", stock: 1, onTransit: 0, approvedReserved: 0, balance: 1),
//        StockItem(referenceNo: "79030B/SOFT TOUCH 100020", classification: "CORE", discount: "***", unitPrice: 14610.00, posName: "Multi @Atlantis", stock: 1, onTransit: 0, approvedReserved: 0, balance: 1),
//        StockItem(referenceNo: "79030B/TISSUE 100020", classification: "CORE", discount: "***", unitPrice: 14610.00, posName: "Multi H.End@MCC", stock: 1, onTransit: 0, approvedReserved: 0, balance: 1),
//        StockItem(referenceNo: "", classification: "", discount: "", unitPrice: 0, posName: "Tudor @MOE", stock: 3, onTransit: 0, approvedReserved: 0, balance: 3),
//        StockItem(referenceNo: "", classification: "", discount: "", unitPrice: 0, posName: "Multi H.End (DFC)", stock: 1, onTransit: 0, approvedReserved: 0, balance: 1),
//        StockItem(referenceNo: "", classification: "", discount: "", unitPrice: 0, posName: "Tudor @Dubai-Mall", stock: 2, onTransit: 0, approvedReserved: 0, balance: 2),
//        StockItem(referenceNo: "", classification: "", discount: "", unitPrice: 0, posName: "AS&S Multi @Al-Zahla", stock: 1, onTransit: 0, approvedReserved: 0, balance: 1)
//    ]
//    
//    var totalStock: Int {
//        stockItems.reduce(0) { $0 + $1.stock }
//    }
//    
//    var totalBalance: Int {
//        stockItems.reduce(0) { $0 + $1.balance }
//    }
//    
//    private func toggleSection(_ section: String) {
//        if expandedSections.contains(section) {
//            expandedSections.remove(section)
//        } else {
//            expandedSections.insert(section)
//        }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                    // Header
//                    headerSection
//                    
//                    // Product Info
//                    productInfoSection
//                    
//                    // Stock Table
//                    stockTableSection
//                    
//                    // Summary
//                    summarySection
//                }
//                .padding(.horizontal)
//            }
//            .navigationTitle("Stock Summary")
//            .navigationBarTitleDisplayMode(.inline)
//            .background(Color(.systemGroupedBackground))
//        }
//    }
//    
//    private var headerSection: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(descriptionText)
//                .font(.headline)
//                .padding(.bottom, 4)
//            
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Brand: \(brand)")
//                    Text("Group: \(group)")
//                }
//                
//                Spacer()
//                
//                VStack(alignment: .trailing, spacing: 4) {
//                    Text("Ref: \(refFrom)-\(refTo)")
//                    Text("Serial: \(serialNumber)")
//                }
//            }
//            .font(.subheadline)
//            .foregroundColor(.secondary)
//        }
//        .padding()
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(10)
//    }
//    
//    private var productInfoSection: some View {
//        DisclosureGroup(
//            isExpanded: Binding(
//                get: { expandedSections.contains("productInfo") },
//                set: { _ in toggleSection("productInfo") }
//            ),
//            content: {
//                VStack(alignment: .leading, spacing: 12) {
//                    infoRow(title: "Sub-Group", value: subGroup)
//                    Divider()
//                    infoRow(title: "Classification", value: "CORE")
//                    Divider()
//                    infoRow(title: "Discount", value: "***")
//                    Divider()
//                    infoRow(title: "Unit Price", value: "15,880.00 - 14,610.00 AED")
//                }
//                .padding(.top, 8)
//            },
//            label: {
//                Text("Product Details")
//                    .font(.headline)
//            }
//        )
//        .padding()
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(10)
//    }
//    
//    private var stockTableSection: some View {
//        VStack(spacing: 0) {
//            DisclosureGroup(
//                isExpanded: Binding(
//                    get: { expandedSections.contains("stockItems") },
//                    set: { _ in toggleSection("stockItems") }
//                ),
//                content: {
//                    ForEach(stockItems) { item in
//                        VStack(spacing: 0) {
//                            Divider()
//                            
//                            HStack(alignment: .top) {
//                                VStack(alignment: .leading, spacing: 6) {
//                                    if item.hasReferenceInfo {
//                                        Text(item.referenceNo)
//                                            .font(.subheadline)
//                                        Text("\(item.classification) | \(item.discount)")
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
//                                        Text(formatCurrency(item.unitPrice))
//                                            .font(.subheadline)
//                                    }
//                                    
//                                    Text(item.posName)
//                                        .font(.subheadline.bold())
//                                        .padding(.top, item.hasReferenceInfo ? 4 : 0)
//                                }
//                                
//                                Spacer()
//                                
//                                HStack(spacing: 16) {
//                                    stockInfoColumn(value: item.stock, label: "Stock")
//                                    stockInfoColumn(value: item.onTransit, label: "Transit")
//                                    stockInfoColumn(value: item.balance, label: "Balance")
//                                }
//                            }
//                            .padding(.vertical, 12)
//                        }
//                    }
//                },
//                label: {
//                    HStack {
//                        Text("Stock Items")
//                            .font(.headline)
//                        Spacer()
//                        Text("\(totalStock) items")
//                            .foregroundColor(.secondary)
//                    }
//                }
//            )
//        }
//        .padding()
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(10)
//    }
//    
//    private var summarySection: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("Total Summary")
//                    .font(.headline)
//                    .padding(.bottom, 4)
//                
//                summaryRow(label: "Total Stock", value: totalStock)
//                summaryRow(label: "In Transit", value: 0)
//                summaryRow(label: "Available", value: totalBalance)
//            }
//            
//            Spacer()
//        }
//        .padding()
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(10)
//    }
//    
//    private func infoRow(title: String, value: String) -> some View {
//        HStack {
//            Text(title)
//                .foregroundColor(.secondary)
//            Spacer()
//            Text(value)
//                .bold()
//        }
//    }
//    
//    private func stockInfoColumn(value: Int, label: String) -> some View {
//        VStack {
//            Text("\(value)")
//                .font(.subheadline.bold())
//            Text(label)
//                .font(.caption2)
//                .foregroundColor(.secondary)
//        }
//        .frame(width: 60)
//    }
//    
//    private func summaryRow(label: String, value: Int) -> some View {
//        HStack {
//            Text(label)
//                .foregroundColor(.secondary)
//            Spacer()
//            Text("\(value)")
//                .bold()
//        }
//        .padding(.vertical, 2)
//    }
//    
//    private func formatCurrency(_ value: Double) -> String {
//        guard value > 0 else { return "" }
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencySymbol = "AED"
//        formatter.maximumFractionDigits = 2
//        formatter.minimumFractionDigits = 2
//        return formatter.string(from: NSNumber(value: value)) ?? ""
//    }
//}
//
//struct ConsolidatedStockView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConsolidatedStockView()
//    }
//}
