//
//  SelectionView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 12/02/2025.
//

import SwiftUI

struct ParentView: View {
    @State private var selectedItem: String? = nil
    @State private var showSelectionView = false  // State to control overlay visibility
    
    var body: some View {
        ZStack {
            VStack {
                Text("Selected Item: \(selectedItem ?? "None")")
                
                Button("Select Item") {
                    // Show the SelectionView overlay
                    showSelectionView.toggle()
                }
                .padding()
            }
            
            // Overlay view for SelectionView
            if showSelectionView {
                Color.black.opacity(0.5)  // Dimmed background
                    .edgesIgnoringSafeArea(.all)
                
                SelectionView(onItemSelected: { selectedItem in
                    self.selectedItem = selectedItem
                    self.showSelectionView = false  // Dismiss the overlay
                })
                .transition(.move(edge: .bottom))  // Add a smooth transition
                .zIndex(1)  // Ensure it's on top of the content
            }
        }
    }
}

struct SelectionView: View {

    let allItems = ["Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grape"]
    
    @State private var searchTerm: String = ""
    @State private var filteredItems: [String] = []
    
    var onItemSelected: (String) -> Void
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search...", text: $searchTerm)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: searchTerm) { _, newValue in
                        filterItems(searchTerm: newValue)
                    }
                
                Button(action: {
                    onItemSelected("")
                }) {
                    Text("Cancel")
                        .padding()
                }
            }
            .padding()
            
            List(filteredItems, id: \.self) { item in
                Text(item)
                    .onTapGesture {
                        onItemSelected(item)  // Return selected item
                    }
            }
            .onAppear {
                filteredItems = allItems
            }
            .frame(maxHeight: 300) // Set a maximum height for the list
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .frame(width: 300, height: 400) // Customize the overlay's size
    }
    
    private func filterItems(searchTerm: String) {
        if searchTerm.isEmpty {
            filteredItems = allItems
        } else {
            filteredItems = allItems.filter { $0.lowercased().contains(searchTerm.lowercased()) }
        }
    }
}

struct ParentView_Previews: PreviewProvider {
    static var previews: some View {
        ParentView()
    }
}
