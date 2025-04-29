//
//  SegmentedControlView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 29/04/2025.
//

import SwiftUI

extension View {
    
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
}

struct SizePreferenceKey: PreferenceKey {
    
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
    
}

struct BackgroundGeometryReader: View {
    
    var body: some View {
        GeometryReader { geometry in
            return Color
                .clear
                .preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }
    
}

struct SizeAwareViewModifier: ViewModifier {
    
    @Binding private var viewSize: CGSize
    
    init(viewSize: Binding<CGSize>) {
        self._viewSize = viewSize
    }
    
    func body(content: Content) -> some View {
        content
            .background(BackgroundGeometryReader())
            .onPreferenceChange(SizePreferenceKey.self, perform: { if self.viewSize != $0 { self.viewSize = $0 }})
    }
    
}

//struct SegmentedPicker: View {
//    
//    private static let ActiveSegmentColor: Color = Color(.tertiarySystemBackground)
//    private static let BackgroundColor: Color = Color(.secondarySystemBackground)
//    private static let ShadowColor: Color = Color.black.opacity(0.2)
//    private static let TextColor: Color = Color(.secondaryLabel)
//    private static let SelectedTextColor: Color = Color(.label)
//    
//    private static let TextFont: Font = .system(size: 12)
//    
//    private static let SegmentCornerRadius: CGFloat = 12
//    private static let ShadowRadius: CGFloat = 4
//    private static let SegmentXPadding: CGFloat = 16
//    private static let SegmentYPadding: CGFloat = 8
//    private static let PickerPadding: CGFloat = 4
//    
//    private static let AnimationDuration: Double = 0.1
//    
//    // Stores the size of a segment, used to create the active segment rect
//    @State private var segmentSize: CGSize = .zero
//    // Rounded rectangle to denote active segment
//    private var activeSegmentView: AnyView {
//        // Don't show the active segment until we have initialized the view
//        // This is required for `.animation()` to display properly, otherwise the animation will fire on init
//        let isInitialized: Bool = segmentSize != .zero
//        if !isInitialized { return EmptyView().eraseToAnyView() }
//        return RoundedRectangle(cornerRadius: SegmentedPicker.SegmentCornerRadius)
//            .foregroundColor(SegmentedPicker.ActiveSegmentColor)
//            .shadow(color: SegmentedPicker.ShadowColor, radius: SegmentedPicker.ShadowRadius)
//            .frame(width: self.segmentSize.width, height: self.segmentSize.height)
//            .offset(x: self.computeActiveSegmentHorizontalOffset(), y: 0)
//            .animation(Animation.easeInOut(duration: SegmentedPicker.AnimationDuration), value: selection)
//            .eraseToAnyView()
//    }
//    
//    @Binding private var selection: Int
//    private let items: [String]
//    
//    init(items: [String], selection: Binding<Int>) {
//        self._selection = selection
//        self.items = items
//    }
//    
//    var body: some View {
//        // Align the ZStack to the leading edge to make calculating offset on activeSegmentView easier
//        ZStack(alignment: .leading) {
//            // activeSegmentView indicates the current selection
//            self.activeSegmentView
//            HStack {
//                ForEach(0..<self.items.count, id: \.self) { index in
//                    self.getSegmentView(for: index)
//                }
//            }
//        }
//        .padding(SegmentedPicker.PickerPadding)
//        .background(SegmentedPicker.BackgroundColor)
//        .clipShape(RoundedRectangle(cornerRadius: SegmentedPicker.SegmentCornerRadius))
//    }
//    
//    // Helper method to compute the offset based on the selected index
//    private func computeActiveSegmentHorizontalOffset() -> CGFloat {
//        CGFloat(self.selection) * (self.segmentSize.width + SegmentedPicker.SegmentXPadding / 2)
//    }
//    
//    // Gets text view for the segment
//    private func getSegmentView(for index: Int) -> some View {
//        guard index < self.items.count else {
//            return EmptyView().eraseToAnyView()
//        }
//        let isSelected = self.selection == index
//        return Text(self.items[index])
//        // Dark test for selected segment
//            .foregroundColor(isSelected ? SegmentedPicker.SelectedTextColor: SegmentedPicker.TextColor)
//            .lineLimit(1)
//            .padding(.vertical, SegmentedPicker.SegmentYPadding)
//            .padding(.horizontal, SegmentedPicker.SegmentXPadding)
//            .frame(minWidth: 0, maxWidth: .infinity)
//        // Watch for the size of the
//            .modifier(SizeAwareViewModifier(viewSize: self.$segmentSize))
//            .onTapGesture { self.onItemTap(index: index) }
//            .eraseToAnyView()
//    }
//    
//    // On tap to change the selection
//    private func onItemTap(index: Int) {
//        guard index < self.items.count else {
//            return
//        }
//        self.selection = index
//    }
//    
//}

struct SegmentedPicker<T: Hashable>: View {
    
    private let ActiveSegmentColor: Color = Color(.tertiarySystemBackground)
    private let BackgroundColor: Color = Color(.secondarySystemBackground)
    private let TextColor: Color = Color(.secondaryLabel)
    private let SelectedTextColor: Color = Color(.label)
    
    private let TextFont: Font = .system(size: 12)
    private let ShadowColor: Color = Color.black.opacity(0.2)

    private let SegmentCornerRadius: CGFloat = 12
    private let ShadowRadius: CGFloat = 4
    private let SegmentXPadding: CGFloat = 16
    private let SegmentYPadding: CGFloat = 8
    private let PickerPadding: CGFloat = 4
    
    private let AnimationDuration: Double = 0.1
    
    // MARK: - Properties
    
    @Binding private var selection: T
    private let items: [T]
    private let titleForItem: (T) -> String
    
    @State private var segmentSize: CGSize = .zero
    
    init(items: [T],
         selection: Binding<T>,
         titleForItem: @escaping (T) -> String,
         ActiveSegmentColor: Color = Color(.tertiarySystemBackground),
         BackgroundColor: Color = Color(.secondarySystemBackground),
         TextColor: Color = Color(.secondaryLabel),
         SelectedTextColor: Color = Color(.label)) {
        self._selection = selection
        self.items = items
        self.titleForItem = titleForItem
    }
    
    // MARK: - Views
    
    var body: some View {
        ZStack(alignment: .leading) {
            self.activeSegmentView
            HStack(spacing: SegmentXPadding / 2) {
                ForEach(items, id: \.self) { item in
                    self.getSegmentView(for: item)
                }
            }
        }
        .padding(PickerPadding)
        .background(BackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: SegmentCornerRadius))
    }
    
    private var activeSegmentView: some View {
        let isInitialized = segmentSize != .zero
        return Group {
            if isInitialized {
                RoundedRectangle(cornerRadius: SegmentCornerRadius)
                    .foregroundColor(ActiveSegmentColor)
                    .shadow(color: ShadowColor, radius: ShadowRadius)
                    .frame(width: segmentSize.width, height: segmentSize.height)
                    .offset(x: self.computeActiveSegmentHorizontalOffset(), y: 0)
                    .animation(.easeInOut(duration: AnimationDuration), value: selection)
            }
        }
    }
    
    private func getSegmentView(for item: T) -> some View {
        let isSelected = self.selection == item
        return Text(titleForItem(item))
            .foregroundColor(isSelected ? SelectedTextColor : TextColor)
            .lineLimit(1)
            .padding(.vertical, SegmentYPadding)
            .padding(.horizontal, SegmentXPadding)
            .frame(minWidth: 0, maxWidth: .infinity)
            .contentShape(Rectangle()) // 👈 Expands the tappable are
            .modifier(SizeAwareViewModifier(viewSize: self.$segmentSize))
            .onTapGesture { self.selection = item }
    }
    
    private func computeActiveSegmentHorizontalOffset() -> CGFloat {
        guard let index = items.firstIndex(of: selection) else { return 0 }
        return CGFloat(index) * (self.segmentSize.width + SegmentXPadding / 2)
    }
    
}

//struct PreviewView: View {
//    
//    @State var selection: Int = 0
//    private let items: [String] = ["M", "T", "W", "T", "F"]
//    
//    var body: some View {
//        SegmentedPicker(items: self.items, selection: self.$selection)
//            .padding()
//    }
//    
//}

enum Day: String, CaseIterable {
    
    case monday = "M"
    case tuesday = "T"
    case wednesday = "W"
    case satureday = "S"
    case friday = "F"
}

struct PreviewView: View {
    
    @State private var selectedDay: Day = .monday
    
    var body: some View {
        SegmentedPicker(
            items: Day.allCases,
            selection: $selectedDay,
            titleForItem: { $0.rawValue }
        )
        .padding()
    }
    
}
