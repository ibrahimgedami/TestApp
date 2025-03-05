//
//  ArchitectureView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 03/03/2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = PaginatedViewModel()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.items, id: \.self) { item in
                        Text(item)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .onAppear {
                                // Trigger loading next page when near the end of the list
                                viewModel.loadNextPageIfNeeded(currentItem: item)
                            }
                    }
                    
                    // Loading indicator when reaching the bottom
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .onAppear {
                    // Initial load of the first page
                    if viewModel.items.isEmpty {
                        viewModel.loadNextPage()
                    }
                }
            }
            .padding(.top)
        }
    }
}
