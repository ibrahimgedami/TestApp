//
//  ViewModel.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 05/03/2025.
//

import SwiftUI

// MARK: Brand ViewModel
@MainActor
class PaginatedViewModel: ObservableObject {
    
    @Published var items: [String] = []
    @Published var isLoading: Bool = false
    private var currentPage = 0
    private let itemsPerPage = 10
    private let totalItems = 100
    
    func loadNextPage() {
        guard !isLoading else { return }
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let start = self.currentPage * self.itemsPerPage
            let end = min(start + self.itemsPerPage, self.totalItems)
            
            if start < self.totalItems {
                let newItems = (start..<end).map { "Item \($0 + 1)" }
                self.items.append(contentsOf: newItems)
                self.currentPage += 1
            }
            self.isLoading = false
        }
    }
    
    func loadNextPageIfNeeded(currentItem item: String) {
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(of: item) == thresholdIndex {
            loadNextPage()
        }
    }
    
}
