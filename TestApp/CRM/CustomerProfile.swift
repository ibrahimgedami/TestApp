//
//  CustomerProfile.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 29/05/2025.
//

import SwiftUI
import AppBase

struct InfoItem: Identifiable {
    
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    
}

let infoItems: [InfoItem] = [

    .init(title: "Celebration", icon: "sparkles", color: .pink),
    .init(title: "Sales History", icon: "chart.bar", color: .blue),
    .init(title: "Service History", icon: "wrench.fill", color: .orange),
    .init(title: "Audit Trail", icon: "doc.text.magnifyingglass", color: .purple),
    .init(title: "Interaction", icon: "person.2.fill", color: .green),
    .init(title: "Complaints", icon: "exclamationmark.bubble.fill", color: .red)
]

struct CustomerInfoGridView: View {
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var interactions: [Interaction] = []
    @State private var showInteraction: Bool = false
    @State private var text: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("name", text: $text)
            }
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(infoItems) { item in
                    VStack(spacing: 10) {
                        Image(systemName: item.icon)
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .padding()
                            .background(item.color)
                            .clipShape(Circle())
                        
                        Text(item.title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .onTapGesture {
                        let title = item.title
                        print("Tapped on \(title)")
                        switch title {
                        case "Interaction":
                            showInteraction = true
                        default:
                            break
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                if let data = FileHelper.shared.decodeJSONFromFile(filename: "Interactions", as: [Interaction].self) {
                    self.interactions = data
                }
            }
        }
        .navigationDestination(isPresented: $showInteraction) {
            InteractionView(interactions: interactions)
        }
    }
    
}

#Preview {
    NavigationStack {
        CustomerInfoGridView()
    }
}
