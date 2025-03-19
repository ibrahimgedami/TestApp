//
//  TestAppApp.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 14/05/2024.
//

import SwiftUI
import AppBase

@main
struct MyApp: App {
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
    }
}

import SwiftUI

struct JobCardPrintView: View {
    @State private var selectedJobCardType: String? = nil
    let jobCardTypes = ["Order", "Delivery"]
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            HStack {
                // Job Card Type Picker
                Picker("Select Job Card Type", selection: $selectedJobCardType) {
                    ForEach(jobCardTypes, id: \.self) { type in
                        Text(type).tag(type as String?)
                    }
                }
                .pickerStyle(.segmented) // Compact dropdown style
                
                Spacer()
                
                // Print Button with Validation
                Button(action: {
                    if selectedJobCardType == nil {
                        showAlert = true
                    } else {
                        printJobCard()
                    }
                }) {
                    HStack {
                        Image(systemName: "printer.fill")
                        Text("Print")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            // Printable Job Card View
            if let selectedType = selectedJobCardType {
                ScrollView {
                    PrintPreviewView(selectedType: selectedType)
                }
                .padding()
            } else {
                Text("Please select a job card type to preview.")
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation Error"), message: Text("Please select a job card type before printing."), dismissButton: .default(Text("OK")))
        }
    }
}

// MARK: - Print Preview UI
struct PrintPreviewView: View {
    let selectedType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📝 Job Card Preview")
                .font(.headline)
                .padding(.bottom, 5)
            
            if selectedType == "Order" {
                OrderJobCardView()
            } else {
                DeliveryJobCardView()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// MARK: - Order Job Card UI
struct OrderJobCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📌 Order Job Card")
                .font(.title2)
                .bold()
            
            Divider()
            
            Text("👤 Customer Name: John Doe")
            Text("📅 Order Date: 15 March 2025")
            Text("📦 Items: Watch Repair, Battery Change")
            Text("💳 Payment: Paid")
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Delivery Job Card UI
struct DeliveryJobCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📌 Delivery Job Card")
                .font(.title2)
                .bold()
            
            Divider()
            
            Text("👤 Customer Name: Jane Smith")
            Text("📍 Delivery Address: XYZ Street, Dubai")
            Text("📅 Delivery Date: 16 March 2025")
            Text("✍ Signature: ___________")
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Print Function (Placeholder)
func printJobCard() {
    print("🖨️ Printing Job Card...")
}

// MARK: - Preview
struct JobCardPrintView_Previews: PreviewProvider {
    static var previews: some View {
        JobCardPrintView()
    }
}
