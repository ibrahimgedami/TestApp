//
//  ProductViewModel.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 03/08/2025.
//

import Foundation

class ProductViewModel: ObservableObject {
    
    // Sample data - replace with your actual data source
    @Published var brands: [FilterItem] = [
        FilterItem(value: "All Brands"),
        FilterItem(value: "Nike"),
        FilterItem(value: "Adidas"),
        FilterItem(value: "Puma"),
        FilterItem(value: "Under Armour")
    ]
    
    @Published var groups: [FilterItem] = [
        FilterItem(value: "All Groups"),
        FilterItem(value: "Footwear"),
        FilterItem(value: "Apparel"),
        FilterItem(value: "Accessories")
    ]
    
    @Published var subgroups: [String: [FilterItem]] = [
        "Footwear": [
            FilterItem(value: "All Subgroups"),
            FilterItem(value: "Running"),
            FilterItem(value: "Basketball"),
            FilterItem(value: "Soccer")
        ],
        "Apparel": [
            FilterItem(value: "All Subgroups"),
            FilterItem(value: "T-Shirts"),
            FilterItem(value: "Shorts"),
            FilterItem(value: "Jackets")
        ],
        "Accessories": [
            FilterItem(value: "All Subgroups"),
            FilterItem(value: "Bags"),
            FilterItem(value: "Hats"),
            FilterItem(value: "Socks")
        ]
    ]
    
    @Published var selectedBrand: FilterItem = FilterItem(value: "All Brands")
    @Published var selectedGroup: FilterItem = FilterItem(value: "All Groups")
    @Published var selectedSubgroup: FilterItem = FilterItem(value: "All Subgroups")
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
    
    // Dropdown visibility
    @Published var showBrandDropdown = false
    @Published var showGroupDropdown = false
    @Published var showSubgroupDropdown = false
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        selectedBrand = brands.first ?? FilterItem(value: "All Brands")
        selectedGroup = groups.first ?? FilterItem(value: "All Groups")
        selectedSubgroup = subgroups[selectedGroup.value]?.first ?? FilterItem(value: "All Subgroups")
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
            
            if self.selectedBrand.value != "All Brands" {
                filteredProducts = filteredProducts.filter { $0.classification.contains(self.selectedBrand.value) }
            }
            
            if self.selectedGroup.value != "All Groups" {
                filteredProducts = filteredProducts.filter { $0.classification.contains(self.selectedGroup.value) }
            }
            
            if self.selectedSubgroup.value != "All Subgroups" && self.selectedGroup.value != "All Groups" {
                filteredProducts = filteredProducts.filter { $0.classification.contains(self.selectedSubgroup.value) }
            }
            
            if !self.referenceText.isEmpty {
                filteredProducts = filteredProducts.filter { $0.referenceNumber.localizedCaseInsensitiveContains(self.referenceText) }
            }
            
            self.searchResults = filteredProducts.sorted(by: self.currentSortPredicate())
            
            // Select first item automatically if none selected
            if self.selectedProduct == nil,
               let first = self.searchResults.first {
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
        selectedBrand = FilterItem(value: "All Brands")
        selectedGroup = FilterItem(value: "All Groups")
        selectedSubgroup = FilterItem(value: "All Subgroups")
        referenceText = ""
    }
}
