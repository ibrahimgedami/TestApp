//
//  CelebrationView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 18/07/2025.
//

import SwiftUI

struct CelebrationView: View {
    
    @State private var personalCelebrations = ["day one"]
    @State private var seasonalCelebrations = ["day one", "day one", "Eid", "Birthday", "Eid"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Top Buttons
                    VStack(spacing: 16) {
                        celebrationButton(title: "Add Personal Celebration")
                        celebrationButton(title: "Add Other Celebration")
                        celebrationButton(title: "Add Seasonal Celebration")
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // MARK: - Personal Section
                    if !personalCelebrations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Personal")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            ForEach(personalCelebrations, id: \.self) { item in
                                celebrationRow(title: item) {
                                    deleteItem(item, from: &personalCelebrations)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Seasonal Section
                    if !seasonalCelebrations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Seasonal")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            ForEach(seasonalCelebrations, id: \.self) { item in
                                celebrationRow(title: item) {
                                    deleteItem(item, from: &seasonalCelebrations)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Celebrations")
        }
    }
    
    // MARK: - Celebration Button
    private func celebrationButton(title: String) -> some View {
        Button(action: {
            print("Tapped \(title)")
        }) {
            Text(title)
                .font(.callout)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brown)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Celebration Row with Swipe to Delete
    private func celebrationRow(title: String, onDelete: @escaping () -> Void) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            HStack {
                Text(title)
                    .padding(.leading, 16)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    withAnimation {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(.trailing, 16)
                }
            }
            .frame(height: 50)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Deletion Logic
    private func deleteItem(_ item: String, from list: inout [String]) {
        if let index = list.firstIndex(of: item) {
            list.remove(at: index)
        }
    }
}

#Preview {
    CelebrationView()
}
