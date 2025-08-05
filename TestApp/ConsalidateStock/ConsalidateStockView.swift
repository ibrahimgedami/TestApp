//
//  ConsalidateStockView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 31/07/2025.
//

import SwiftUI

// MARK: - Protocol Definitions
public protocol SearchableDropDown {
    var searchText: String? { get }
    var object: Self? { get }
}

public protocol DisplayableDropDown {
    var displayedText: String? { get }
}

public protocol IdentifiableWithID: Identifiable, SearchableDropDown, DisplayableDropDown {}

// MARK: - Searchable Selection View
struct SearchableSelectionView<Item: IdentifiableWithID>: View {
    let items: [Item]
    @Binding var isPresented: Bool
    let title: String
    let closeButtonText: String
    let detents: [PresentationDetent]
    let showDragIndicator: Bool
    var closure: ((Item) -> Void)?
    
    @State private var searchQuery = ""
    
    init(items: [Item],
         isPresented: Binding<Bool>,
         title: String,
         closeButtonText: String = "Close",
         detents: [PresentationDetent] = [.medium, .large],
         showDragIndicator: Bool = true,
         closure: ((Item) -> Void)? = nil) {
        self.items = items
        self._isPresented = isPresented
        self.title = title
        self.closeButtonText = closeButtonText
        self.detents = detents
        self.showDragIndicator = showDragIndicator
        self.closure = closure
    }
    
    private var filteredItems: [Item] {
        if searchQuery.isEmpty {
            return items
        } else {
            return items.filter {
                $0.searchText?.localizedCaseInsensitiveContains(searchQuery) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredItems) { item in
                Button(action: {
                    closure?(item)
                    isPresented = false
                }) {
                    Text(item.displayedText ?? "")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchQuery, prompt: "Search")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(closeButtonText) {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents(Set(detents))
        .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
        .presentationBackgroundInteraction(.enabled)
    }
}

// MARK: - Data Models
struct FilterItem: IdentifiableWithID {
    let id = UUID()
    let value: String
    var searchText: String? { value }
    var object: FilterItem? { self }
    var displayedText: String? { value }
}

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

struct ProductSearchView: View {
    
    @StateObject private var viewModel = ProductViewModel()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                        ProductDetailsSectionView(products: [selectedProduct])
                    }
                }
                .padding()
            }
            .navigationTitle("Product Search")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        navigationPath.append("FilterView")
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolRenderingMode(.multicolor)
                    }
                }
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "FilterView" {
                    FilterView(viewModel: viewModel, navigationPath: $navigationPath)
                }
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
                viewModel.search()
            }
            // Dropdown sheets
            .sheet(isPresented: $viewModel.showBrandDropdown) {
                SearchableSelectionView(
                    items: viewModel.brands,
                    isPresented: $viewModel.showBrandDropdown,
                    title: "Select Brand",
                    closure: { item in
                        viewModel.selectedBrand = item
                    }
                )
            }
            .sheet(isPresented: $viewModel.showGroupDropdown) {
                SearchableSelectionView(
                    items: viewModel.groups,
                    isPresented: $viewModel.showGroupDropdown,
                    title: "Select Group",
                    closure: { item in
                        viewModel.selectedGroup = item
                        viewModel.selectedSubgroup = viewModel.subgroups[item.value]?.first ?? FilterItem(value: "All Subgroups")
                    }
                )
            }
            .sheet(isPresented: $viewModel.showSubgroupDropdown) {
                SearchableSelectionView(
                    items: viewModel.subgroups[viewModel.selectedGroup.value] ?? [],
                    isPresented: $viewModel.showSubgroupDropdown,
                    title: "Select Subgroup",
                    closure: { item in
                        viewModel.selectedSubgroup = item
                    }
                )
            }
        }
    }
    
    // MARK: - Subviews (same as before)
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
        
}

struct ProductDetailsSectionView: View {
    let products: [Product]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Product Details (\(products.count))")
                .font(.headline)
            
            ForEach(products) { product in
                ProductDetailCard(product: product)
            }
        }
    }
}

struct ProductDetailCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            productHeaderSection
            Divider()
            descriptionSection
            Divider()
            inventorySection
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var productHeaderSection: some View {
        HStack(alignment: .top, spacing: 15) {
            ProductImage(url: product.imageURL)
            productBasicInfo
            Spacer()
        }
    }
    
    private var productBasicInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let name = product.name {
                Text(name)
                    .font(.headline)
            }
            
            Text(product.referenceNumber)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            priceAndDiscountInfo
        }
    }
    
    private var priceAndDiscountInfo: some View {
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
    
    private var descriptionSection: some View {
        Group {
            if let description = product.description {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.subheadline.bold())
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var inventorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Inventory")
                .font(.subheadline.bold())
            
            inventoryGrid
        }
    }
    
    private var inventoryGrid: some View {
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
}

struct ProductImage: View {
    let url: String?
    
    var body: some View {
        Group {
            if let urlString = url, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    placeholderImage
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            } else {
                placeholderImage
            }
        }
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            )
    }
}

struct FilterView: View {
    
    @ObservedObject var viewModel: ProductViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Form {
            Section("Brand") {
                filterSelectionRow(
                    title: "Brand",
                    value: viewModel.selectedBrand.value,
                    action: { viewModel.showBrandDropdown = true }
                )
            }
            
            Section("Group") {
                filterSelectionRow(
                    title: "Group",
                    value: viewModel.selectedGroup.value,
                    action: { viewModel.showGroupDropdown = true }
                )
            }
            
            if viewModel.selectedGroup.value != "All Groups" {
                Section("Subgroup") {
                    filterSelectionRow(
                        title: "Subgroup",
                        value: viewModel.selectedSubgroup.value,
                        action: { viewModel.showSubgroupDropdown = true }
                    )
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
            
            Section {
                Button(action: {
                    viewModel.search()
                    navigationPath.removeLast()
                }) {
                    Text("Search")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func filterSelectionRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Text(value)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(.plain)
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

struct ProductSearchView_Previews: PreviewProvider {
    
    static var previews: some View {
        ProductSearchView()
    }
    
}
