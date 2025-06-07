//
//  InteractionView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 02/06/2025.
//

import SwiftUI

struct Interaction: Identifiable, Codable {
    
    var id = UUID()
    var templateID: String?
    var actualTime: String?
    var staffID: String?
    var branchNo: String?
    var followUpTime: String?
    var followUpCompleted: String?
    var followUpRequested: String?
    
    enum CodingKeys: CodingKey {
        case templateID
        case actualTime
        case staffID
        case branchNo
        case followUpTime
        case followUpCompleted
        case followUpRequested
    }
    
}

struct InteractionView: View {
    
    let interactions: [Interaction]
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(interactions, id: \.id) { item in
                    interactionRow(item)
                }
            }
            .padding()
        }
        .navigationTitle("Interactions")
    }
    
    private func interactionRow(_ item: Interaction) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Template ID", systemImage: "doc.fill")
                    .foregroundStyle(.blue)
                Spacer()
                Text(item.templateID ?? "")
            }
            Divider()
            
            HStack {
                Label("Actual Time", systemImage: "calendar")
                    .foregroundStyle(.blue)
                Spacer()
                Text(item.actualTime ?? "")
            }
            Divider()
            
            HStack {
                Label("Follow-Up Time", systemImage: "calendar.badge.clock")
                    .foregroundStyle(.blue)
                Spacer()
                Text(item.followUpTime ?? "")
            }
            Divider()
            
            HStack {
                Label("Follow-Up Requested", systemImage: "questionmark.circle")
                    .foregroundStyle(.blue)
                Spacer()
                Text(item.followUpRequested ?? "")
                    .foregroundStyle(item.followUpRequested == "Y" ? .green : .red)
            }
            Divider()
            
            HStack {
                Label("Completed", systemImage: "checkmark.circle")
                    .foregroundStyle(.blue)
                Spacer()
                Text(item.followUpCompleted ?? "")
                    .foregroundStyle(item.followUpCompleted == "Y" ? .green : .red)
            }
        }
        .padding()
        .background(Color(.gray).opacity(0.05))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
}

//struct InteractionView: View {
//    let interactions: [Interaction]
//    
//    var body: some View {
//        List(interactions) { item in
//            VStack(alignment: .leading, spacing: 8) {
//                HStack {
//                    Label("Template ID", systemImage: "doc.fill")
//                    Spacer()
//                    Text(item.templateID ?? "")
//                }
//                
//                HStack {
//                    Label("Actual Time", systemImage: "calendar")
//                    Spacer()
//                    Text(item.actualTime ?? "")
//                }
//                
//                HStack {
//                    Label("Follow-Up Time", systemImage: "calendar.badge.clock")
//                    Spacer()
//                    Text(item.followUpTime ?? "")
//                }
//                
//                HStack {
//                    Label("Follow-Up Requested", systemImage: "questionmark.circle")
//                    Spacer()
//                    Text(item.followUpRequested ?? "")
//                        .foregroundStyle(item.followUpRequested == "Y" ? .green : .red)
//                }
//                
//                HStack {
//                    Label("Completed", systemImage: "checkmark.circle")
//                    Spacer()
//                    Text(item.followUpCompleted ?? "")
//                        .foregroundStyle(item.followUpCompleted == "Y" ? .green : .red)
//                }
//            }
//            .padding()
//            .background(Color(.systemGroupedBackground))
//            .cornerRadius(12)
//            .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
//        }
//        .navigationTitle("Interactions")
//    }
//}

#Preview {
    NavigationStack {
        CustomerInfoGridView()
    }
}
