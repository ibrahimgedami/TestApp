//
//  ConsalidateStockView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 31/07/2025.
//

import SwiftUI

struct Product: Identifiable {
    let id = UUID()
    let referenceNumber: String
    let classification: String
    let discount: Double
    let unitPrice: Double
    
    // Details that load when selected
    var name: String?
    var stock: Int?
    var onTransit: Int?
    var reservation: Int?
    var balance: Int?
}

class ProductViewModel: ObservableObject {
    @Published var brands: [String] = ["Brand A", "Brand B", "Brand C", "Brand D"]
    @Published var groups: [String] = ["Group 1", "Group 2", "Group 3"]
    @Published var subgroups: [String] = ["Subgroup A", "Subgroup B", "Subgroup C"]
    
    @Published var selectedBrand: String = ""
    @Published var selectedGroup: String = ""
    @Published var selectedSubgroup: String = ""
    @Published var referenceText: String = ""
    
    @Published var searchResults: [Product] = []
    @Published var selectedProduct: Product?
    
    init() {
        // Initialize with first item selected or leave empty
        selectedBrand = brands.first ?? ""
        selectedGroup = groups.first ?? ""
        selectedSubgroup = subgroups.first ?? ""
    }
    
    func search() {
        // Simulate search - replace with your actual data fetching logic
        searchResults = [
            Product(referenceNumber: "REF123", classification: "Class A", discount: 5.0, unitPrice: 99.99),
            Product(referenceNumber: "REF456", classification: "Class B", discount: 10.0, unitPrice: 149.99),
            Product(referenceNumber: "REF789", classification: "Class C", discount: 15.0, unitPrice: 199.99)
        ]
    }
    
    func loadDetails(for product: Product) {
        // Simulate loading details - replace with your actual data fetching
        var detailedProduct = product
        detailedProduct.name = "Detailed Product Name"
        detailedProduct.stock = 100
        detailedProduct.onTransit = 20
        detailedProduct.reservation = 15
        detailedProduct.balance = 65
        
        selectedProduct = detailedProduct
    }
}

struct ProductSearchView: View {
    
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search Criteria Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Search Criteria")
                        .font(.headline)
                    
                    Picker("Brand", selection: $viewModel.selectedBrand) {
                        ForEach(viewModel.brands, id: \.self) { brand in
                            Text(brand).tag(brand)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Group", selection: $viewModel.selectedGroup) {
                        ForEach(viewModel.groups, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Subgroup", selection: $viewModel.selectedSubgroup) {
                        ForEach(viewModel.subgroups, id: \.self) { subgroup in
                            Text(subgroup).tag(subgroup)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Reference Number", text: $viewModel.referenceText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        viewModel.search()
                    }) {
                        Text("Search")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Search Results Section
                if !viewModel.searchResults.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Search Results")
                            .font(.headline)
                        
                        List(viewModel.searchResults) { product in
                            ProductRow(product: product)
                                .onTapGesture {
                                    viewModel.loadDetails(for: product)
                                }
                                .listRowBackground(viewModel.selectedProduct?.id == product.id ? Color.blue.opacity(0.1) : Color.clear)
                        }
                        .listStyle(PlainListStyle())
                        .frame(height: 200)
                    }
                }
                
                // Product Details Section
                if let selectedProduct = viewModel.selectedProduct {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Product Details")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            if let name = selectedProduct.name {
                                DetailRow(title: "Name:", value: name)
                            }
                            DetailRow(title: "Reference:", value: selectedProduct.referenceNumber)
                            DetailRow(title: "Classification:", value: selectedProduct.classification)
                            DetailRow(title: "Discount:", value: "\(selectedProduct.discount)%")
                            DetailRow(title: "Unit Price:", value: String(format: "$%.2f", selectedProduct.unitPrice))
                            
                            Divider()
                            
                            if let stock = selectedProduct.stock {
                                DetailRow(title: "Stock:", value: "\(stock)")
                            }
                            if let onTransit = selectedProduct.onTransit {
                                DetailRow(title: "On Transit:", value: "\(onTransit)")
                            }
                            if let reservation = selectedProduct.reservation {
                                DetailRow(title: "Reservation:", value: "\(reservation)")
                            }
                            if let balance = selectedProduct.balance {
                                DetailRow(title: "Balance:", value: "\(balance)")
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Product Search")
        }
    }
    
}

struct ProductRow: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(product.referenceNumber)
                .font(.headline)
            HStack {
                Text(product.classification)
                Spacer()
                Text("\(product.discount)%")
                Spacer()
                Text(String(format: "$%.2f", product.unitPrice))
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
        }
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
