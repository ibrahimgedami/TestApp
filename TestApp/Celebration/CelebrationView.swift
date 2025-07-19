//
//  CelebrationView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 18/07/2025.
//

import SwiftUI
import SwipeCellSUI

struct CelebrationView: View {
    
    // Data
    @State private var personalCelebrations = ["Day One", "Anniversary"]
    @State private var seasonalCelebrations = ["Eid", "Birthday", "New Year"]
    @State private var otherCelebrations = ["Graduation", "Promotion"]
    
    // Swipe state
    @State private var currentUserInteractionCellID: String? = nil
    
    // UI Constants
    private let buttonColumns = [GridItem(.adaptive(minimum: 150), spacing: 16)]
    private let rowHeight: CGFloat = 50
    private let rowCornerRadius: CGFloat = 12
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Action Buttons
                    actionButtonsSection
                    
                    // MARK: - Celebration Lists
                    celebrationListSection(title: "Personal", items: $personalCelebrations)
                    celebrationListSection(title: "Seasonal", items: $seasonalCelebrations)
                    celebrationListSection(title: "Other", items: $otherCelebrations)
                }
                .padding(.bottom)
            }
            .navigationTitle("Celebrations")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Subviews
    
    private var actionButtonsSection: some View {
        LazyVGrid(columns: buttonColumns, spacing: 16) {
            celebrationButton(title: "Add Personal", action: { addItem(to: &personalCelebrations) })
            celebrationButton(title: "Add Seasonal", action: { addItem(to: &seasonalCelebrations) })
            celebrationButton(title: "Add Other", action: { addItem(to: &otherCelebrations) })
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private func celebrationListSection(title: String, items: Binding<[String]>) -> some View {
        Group {
            if !items.wrappedValue.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: title)
                    
                    ForEach(items.wrappedValue, id: \.self) { item in
                        SwipeableRow(
                            title: item,
                            onDelete: { deleteItem(item, from: items) },
                            onFavorite: { favoriteItem(item) },
                            onEdit: { editItem(item, in: items) }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Row Actions
    
    private func deleteItem(_ item: String, from items: Binding<[String]>) {
        withAnimation {
            items.wrappedValue.removeAll { $0 == item }
        }
    }
    
    private func favoriteItem(_ item: String) {
        print("Favorite action for \(item)")
        // Add your favorite logic here
    }
    
    private func editItem(_ item: String, in items: Binding<[String]>) {
        print("Edit action for \(item)")
        // Add your edit logic here
    }
    
    private func addItem(to items: inout [String]) {
        let newItem = "New Event \(items.count + 1)"
        withAnimation {
            items.append(newItem)
        }
    }
    
    // MARK: - UI Components
    
    private func celebrationButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.callout)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brown)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    private struct SectionHeader: View {
        let title: String
        
        var body: some View {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }
    
    private struct SwipeableRow: View {
        let title: String
        let onDelete: () -> Void
        let onFavorite: () -> Void
        let onEdit: () -> Void
        
        var body: some View {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    HStack {
                        Text(title)
                            .foregroundStyle(.primary)
                            .padding(.leading)
                        Spacer()
                    }
                )
                .padding(.horizontal)
                .frame(height: 50)
                .swipeCell(
                    id: title,
                    cellWidth: UIScreen.main.bounds.width - 32,
                    leadingSideGroup: leadingActions,
                    trailingSideGroup: trailingActions,
                    currentUserInteractionCellID: .constant(nil),
                    settings: SwipeCellSettings()
                )
        }
        
        private var leadingActions: [SwipeCellActionItem] {
            [
                SwipeCellActionItem(
                    buttonView: {
                        AnyView(
                            Image(systemName: "star.fill")
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                        )
                    },
                    backgroundColor: .orange,
                    actionCallback: onFavorite
                ),
                SwipeCellActionItem(
                    buttonView: {
                        AnyView(
                            Image(systemName: "pencil")
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                        )
                    },
                    backgroundColor: .blue,
                    actionCallback: onEdit
                )
            ]
        }
        
        private var trailingActions: [SwipeCellActionItem] {
            [
                SwipeCellActionItem(
                    buttonView: {
                        AnyView(
                            Image(systemName: "trash")
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                        )
                    },
                    backgroundColor: .red,
                    swipeOutAction: true,
                    swipeOutHapticFeedbackType: .warning,
                    swipeOutIsDestructive: true,
                    actionCallback: onDelete
                )
            ]
        }
    }
}

#Preview {
    CelebrationView()
}
