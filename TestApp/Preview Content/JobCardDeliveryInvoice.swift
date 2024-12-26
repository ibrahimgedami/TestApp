//
//  JobCardDeliveryInvoice.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 25/12/2024.
//

import SwiftUI
import AppBase

struct PaymentType: Codable, Hashable, Identifiable {
    
    var id: String { cd ?? UUID().uuidString }
    let cd: String?
    let name: String?
    let locationCd: String?
    let accountCode: String?
    let glCode: String?
    let txnCode: String?
    
}

struct Payment: Identifiable {
    
    let id = UUID()
    var type: PaymentType
    var amount: Double
    var foreignAmount: Double?
    var exchangeRate: Double?
    
    init(type: PaymentType, amount: Double, foreignAmount: Double? = nil, exchangeRate: Double? = nil) {
        self.type = type
        self.amount = amount
        self.foreignAmount = foreignAmount
        self.exchangeRate = exchangeRate
        if let foreignAmount = foreignAmount, let exchangeRate = exchangeRate {
            self.amount = foreignAmount * exchangeRate
        }
    }
    
}

struct Invoice {
    
    var amount: Double
    var payments: [Payment]
    var vatAmount: Double
    var currencyCode: String
    var exchangeRate: Double
    var discount: Double?
    var additionalDiscount: Double
    
    var netAmount: Double {
        let discountedAmount = amount - totalDiscount
        return max(discountedAmount, 0)
    }
    
    var totalDiscount: Double {
        let value = (discount ?? 0) + additionalDiscount
        return value
    }
    
    var netAmountIncludingVAT: Double {
        netAmount
    }
    
    var netAmountExcludingVAT: Double {
        netAmount - vatAmount
    }
    
    var totalPaid: Double {
        payments.reduce(0) { $0 + $1.amount }
    }
    
    var remainingAmount: Double {
        netAmountIncludingVAT - totalPaid
    }
    
    mutating func addPayment(type: PaymentType, amount: Double, foreignAmount: Double? = nil, exchangeRate: Double? = nil) {
        guard amount > 0 else { return }
        payments.append(Payment(type: type, amount: amount, foreignAmount: foreignAmount, exchangeRate: exchangeRate))
    }
    
}

struct InvoiceView: View {
    
    @State private var isShowingSignatureView = false
    @State private var signatureImage: UIImage? = nil
    
    @State private var invoice = Invoice(
        amount: 350,
        payments: [],
        vatAmount: 16.67,
        currencyCode: "AED",
        exchangeRate: 1.0,
        discount: nil,
        additionalDiscount: 0.0
    )
    @State private var isShowingPaymentList = false
    @State private var newPaymentType: PaymentType?
    @State private var newForeignAmount: String = ""
    @State private var selectedCurrency: String = "AED"
    @State private var calculatedAEDAmount: Double = 0.0
    
    let foreignCurrencies: [String: Double] = [
        "USD": 3.66,
        "EUR": 4.0,
        "GBP": 4.5,
        "AED": 1.0
    ]
    
    let paymentTypes = loadPaymentTypes()
    
    var body: some View {
        if !Device.isiPadDevice {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        summarySection
                        paymentSection
                        paymentsList
                    }
                    .padding()
                }
                .navigationTitle("Invoice")
            }
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 50) {
                        summarySection
                        Spacer()
                        paymentSection
                    }
                    paymentsList
                    
                    Button(action: {
                        isShowingSignatureView.toggle()
                    }) {
                        if let image = signatureImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 100) // You can adjust the size as needed
                        } else {
                            // If no signature is captured, show the default button text
                            Text("Add Signature")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .sheet(isPresented: $isShowingSignatureView) {
                        // Present the signature view as a sheet
                        SignatureView(isOpened: $isShowingSignatureView, signatureImage: $signatureImage)
                    }

                }
                .padding()
            }
        }
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Summary")
                .font(.headline)
            Text("Currency: \(invoice.currencyCode)")
            Text("Exchange Rate: \(invoice.exchangeRate, specifier: "%.1f")")
            Text("Original Amount: \(invoice.netAmountExcludingVAT, specifier: "%.1f")")
            Text("VAT Amount: \(invoice.vatAmount, specifier: "%.1f")")
            Text("Net Amount: \(invoice.netAmount, specifier: "%.1f")")
            Text("Net Amount Including VAT: \(invoice.netAmountIncludingVAT, specifier: "%.1f")")
            Text("Total Paid: \(invoice.totalPaid, specifier: "%.1f")")
            Text("Remaining Amount: \(invoice.remainingAmount, specifier: "%.1f")")
                .foregroundStyle(invoice.remainingAmount > 0 ? .red : .green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var paymentSection: some View {
        VStack(spacing: 5) {
            Text("Add Payment").font(.headline)
            
            Button(action: {
                isShowingPaymentList.toggle()
            }) {
                HStack {
                    Text(newPaymentType?.name ?? "Select Payment Type")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .sheet(isPresented: $isShowingPaymentList) {
                VStack {
                    Text("Select Payment Type")
                        .font(.headline)
                        .padding()
                    
                    List(paymentTypes, id: \.cd) { type in
                        Button(action: {
                            newPaymentType = type
                            isShowingPaymentList = false
                            updateCurrency(for: type)
                        }) {
                            Text(type.name ?? "Unknown Type")
                        }
                    }
                }
                .frame(width: 300, height: 400)
            }

            HStack {
                TextField(selectedCurrency == "AED" ? "Amount" : "Foreign Amount", text: $newForeignAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: newForeignAmount) { _, newValue in
                        updateAEDAmount(from: newValue)
                    }
            }
            
            Picker("Currency", selection: $selectedCurrency) {
                ForEach(foreignCurrencies.keys.sorted(), id: \.self) { currency in
                    Text(currency).tag(currency)
                }
            }
            
            Text("Exchange Rate: \(foreignCurrencies[selectedCurrency] ?? 1.0, specifier: "%.2f")")
            
            if !newForeignAmount.isEmpty {
                Text("AED Equivalent: \(calculatedAEDAmount, specifier: "%.2f")").foregroundColor(.gray)
            }
            HStack {
                Button {
                    addPayment()
                } label: {
                    Text("Add Payment")
                        .frame(height: 10, alignment: .leading)
                        .padding()
                        .background(canAddPayment && !newForeignAmount.isEmpty ? Color.blue : .gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(!canAddPayment && !newForeignAmount.isEmpty)
                }
                
                Spacer()
            }
        }
    }
    
    private var paymentsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Payments")
                    .font(.headline)
                Spacer()
            }
            
            ForEach(invoice.payments, id: \.type) { payment in
                HStack {
                    Text(payment.type.cd?.capitalized ?? "--")
                    Spacer()
                    Text("\(payment.amount, specifier: "%.1f") AED")
                    if let foreignAmount = payment.foreignAmount,
                       let exchangeRate = payment.exchangeRate {
                        Text("(\(foreignAmount, specifier: "%.1f") \(selectedCurrency))")
                            .foregroundStyle(.gray)
                    }
                    
                    Button(action: {
                        deletePayment(payment)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(5)
                    }
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private func addPayment() {
        guard
            let type = newPaymentType,
            let foreignAmount = Double(newForeignAmount),
            foreignAmount > 0
        else {
            return
        }
        
        let exchangeRate = foreignCurrencies[selectedCurrency] ?? 1.0
        let amount = foreignAmount * exchangeRate
        
        invoice.addPayment(type: type, amount: amount, foreignAmount: foreignAmount, exchangeRate: exchangeRate)
        
        newForeignAmount = ""
        calculatedAEDAmount = 0.0
    }
    
    private func updateAEDAmount(from foreignAmount: String) {
        guard let value = Double(foreignAmount) else {
            calculatedAEDAmount = 0.0
            return
        }
        calculatedAEDAmount = value * (foreignCurrencies[selectedCurrency] ?? 1.0)
    }
    
    private func updateCurrency(for paymentType: PaymentType?) {
        selectedCurrency = {
            switch paymentType?.name {
            case "FC (Euro)": return "EUR"
            case "FC (GB Pound)": return "GBP"
            case "FC (US$)": return "USD"
            default: return "AED"
            }
        }()
    }
    
    private func deletePayment(_ payment: Payment) {
        if let index = invoice.payments.firstIndex(where: { $0.id == payment.id }) {
            invoice.payments.remove(at: index)
        }
    }
    
    private var canAddPayment: Bool {
        invoice.remainingAmount > 0
    }
    
}

//struct SignatureView: View {
//
//    @Binding var isOpened: Bool
//    @Binding var signatureImage: UIImage?
//    @State private var currentPath = Path()
//    @State private var drawnImage: UIImage? = nil
//        
//        var body: some View {
//            VStack {
//                Text("Draw your signature")
//                    .font(.headline)
//                
//                // Drawing canvas where user can sign
//                Canvas { context, size in
//                    context.stroke(currentPath, with: .color(.black), lineWidth: 3)
//                }
//                .gesture(DragGesture(minimumDistance: 0)
//                    .onChanged { value in
//                        let newPoint = value.location
//                        if currentPath.isEmpty {
//                            currentPath.move(to: newPoint)
//                        } else {
//                            currentPath.addLine(to: newPoint)
//                        }
//                    }
//                )
//                .frame(height: 200)
//                .background(Color.white)
//                .border(Color.black, width: 1)
//                .cornerRadius(10)
//                
//                HStack {
//                    Button("Clear") {
//                        currentPath = Path() // Reset the signature
//                    }
//                    .padding()
//                    
//                    Spacer()
//                    
//                    Button("Done") {
//                        signatureImage = captureSignatureImage()
//                        isOpened = false
//                    }
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                }
//            }
//            .padding()
//        }
//    
//    private func captureSignatureImage() -> UIImage? {
//        let controller = UIHostingController(rootView: self)
//        let view = controller.view!
//        let size = CGSize(width: view.frame.width - 50, height: 400)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        let image = renderer.image { context in
//            view.layer.render(in: context.cgContext)
//        }
//        return image
//    }
//
//}

func loadPaymentTypes() -> [PaymentType] {
    let jsonData = """
    [
            {
                "cd": "CRE-ADV",
                "name": "CREDIT ADVICE",
                "locationCd": "149",
                "accountCode": "ADV",
                "glCode": "600",
                "txnCode": "COU"
            },
            {
                "cd": "MV",
                "name": "MALL GIFT VOUCHER",
                "locationCd": "149",
                "accountCode": "C001",
                "glCode": "600",
                "txnCode": "COU"
            },
            {
                "cd": "CASH",
                "name": "CASH",
                "locationCd": "149",
                "accountCode": "1149",
                "glCode": "660",
                "txnCode": "COU"
            },
            {
                "cd": "CRE CARD",
                "name": "CREDIT CARD",
                "locationCd": "149",
                "accountCode": "VMAM",
                "glCode": "600",
                "txnCode": "COU"
            },
            {
                "cd": "FCE",
                "name": "FC (Euro)",
                "locationCd": "149",
                "accountCode": "EU149",
                "glCode": "660",
                "txnCode": "COU"
            },
            {
                "cd": "FCP",
                "name": "FC (GB Pound)",
                "locationCd": "149",
                "accountCode": "GB149",
                "glCode": "660",
                "txnCode": "COU"
            },
            {
                "cd": "FCU",
                "name": "FC (US$)",
                "locationCd": "149",
                "accountCode": "U149",
                "glCode": "660",
                "txnCode": "COU"
            },
            {
                "cd": "RFD",
                "name": "REFUND",
                "locationCd": "149",
                "accountCode": "1149",
                "glCode": "660",
                "txnCode": "COU"
            },
            {
                "cd": "CASH",
                "name": "CASH",
                "locationCd": "149",
                "accountCode": "1149",
                "glCode": "660",
                "txnCode": "JO"
            },
            {
                "cd": "CRE CARD",
                "name": "CREDIT CARD",
                "locationCd": "149",
                "accountCode": "VMAM",
                "glCode": "600",
                "txnCode": "JO"
            },
            {
                "cd": "FCE",
                "name": "FC (Euro)",
                "locationCd": "149",
                "accountCode": "EU149",
                "glCode": "660",
                "txnCode": "JO"
            },
            {
                "cd": "FCP",
                "name": "FC (GB Pound)",
                "locationCd": "149",
                "accountCode": "GB149",
                "glCode": "660",
                "txnCode": "JO"
            },
            {
                "cd": "FCU",
                "name": "FC (US$)",
                "locationCd": "149",
                "accountCode": "U149",
                "glCode": "660",
                "txnCode": "JO"
            },
            {
                "cd": "RFD",
                "name": "REFUND",
                "locationCd": "149",
                "accountCode": "1149",
                "glCode": "660",
                "txnCode": "JO"
            },
            {
                "cd": "DPAY",
                "name": "DIGITAL PAYMENT",
                "locationCd": "149",
                "accountCode": "DPAY",
                "glCode": "660",
                "txnCode": "COU"
            },
            {
                "cd": "DPAY",
                "name": "DIGITAL PAYMENT",
                "locationCd": "149",
                "accountCode": "DPAY",
                "glCode": "660",
                "txnCode": "JO"
            },
            {
                "cd": "G",
                "name": "GIFT VOUCHER",
                "locationCd": "149",
                "accountCode": "PPGV",
                "glCode": "600",
                "txnCode": "COU"
            },
            {
                "cd": "ADCBP",
                "name": "TOUCH POINT - ADCB",
                "locationCd": "149",
                "accountCode": "A402",
                "glCode": "600",
                "txnCode": "JO"
            },
            {
                "cd": "OCP",
                "name": "PAY BY LINK",
                "locationCd": "149",
                "accountCode": "OCP",
                "glCode": "600",
                "txnCode": "COU"
            },
            {
                "cd": "OCP",
                "name": "PAY BY LINK",
                "locationCd": "149",
                "accountCode": "OCP",
                "glCode": "600",
                "txnCode": "JO"
            },
            {
                "cd": "ADCBP",
                "name": "TOUCH POINT - ADCB",
                "locationCd": "149",
                "accountCode": "A402",
                "glCode": "600",
                "txnCode": "COU"
            },
            {
                "cd": "BANK TRF",
                "name": "BANK TRANSFER",
                "locationCd": "149",
                "accountCode": "A005",
                "glCode": "660",
                "txnCode": "COU"
            }
        ]
    """
    let data = jsonData.data(using: .utf8)!
    let decoder = JSONDecoder()
    
    do {
        let paymentTypes = try decoder.decode([PaymentType].self, from: data)
        return paymentTypes.filter { $0.txnCode == "JO" }
    } catch {
        print("Error decoding JSON: \(error)")
        return []
    }
    
}

struct SignatureView: View {
    
    @Binding var isOpened: Bool
    @Binding var signatureImage: UIImage?
    @State private var currentPath = Path()
    
    var body: some View {
        VStack {
            HStack {
                Button("Close") {
                    withAnimation {
                        isOpened = false
                        currentPath = Path()
                    }
                }
                .padding()
                
                Spacer()
                
                Text("Draw your signature:")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button("Save Signature") {
                    withAnimation {
                        signatureImage = captureSignatureImage() // Capture the drawn signature
                        isOpened = false
                    }
                }
                .padding()
            }
            .background(Color.gray)
            Canvas { context, size in
                context.stroke(currentPath, with: .color(.black), lineWidth: 3)
            }
            .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newPoint = value.location
                            if currentPath.isEmpty {
                                currentPath.move(to: newPoint)
                            } else {
                                currentPath.addLine(to: newPoint)
                            }
                        }
                        .onEnded { _ in })
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10) // Add rounded corners to the drawing area
            .padding(.top, 20) // Add spacing to top to align properly
            
            Button("Clear") {
                withAnimation {
                    currentPath = Path()
                }
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            if let signatureImage = signatureImage {
                currentPath = createPath(from: signatureImage)
            }
        }
        .padding()
        .background(Color.white) // Set the background color to white
        .cornerRadius(20) // Rounded corners for the entire signature view
        .shadow(radius: 20) // Add a shadow effect for elevation
        .padding(30)
        .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height / 2)
    }

    // Function to capture the drawn signature as UIImage
    private func captureSignatureImage() -> UIImage? {
        let size = CGSize(width: 500, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(3)
            context.cgContext.addPath(currentPath.cgPath)
            context.cgContext.strokePath()
        }
    }
    
    private func createPath(from image: UIImage) -> Path {
        guard let cgImage = image.cgImage else { return Path() }
        
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.none.rawValue)!
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelData = context.data else { return Path() }
        
        // Correctly interpret the data as a pointer to UInt8
        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height)
        
        var path = Path()
        for y in 0..<height {
            for x in 0..<width {
                let pixel = data[y * width + x]
                if pixel < 128 { // Threshold for detecting "drawn" pixels
                    let point = CGPoint(x: x, y: height - y) // Flip y-axis for SwiftUI
                    if path.isEmpty {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
            }
        }
        return path
    }


}

struct ContentView: View {
    
    @State private var signatureImage: UIImage? = nil
    @State private var isShowingSignatureView = false
    
    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    if signatureImage != nil {
                        isShowingSignatureView = true // Open signature view to display the existing signature
                    } else {
                        isShowingSignatureView.toggle() // Open signature view for capturing a signature
                    }
                }) {
                    VStack {
                        if let image = signatureImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        } else {
                            VStack {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                                Text("Add Signature")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                
                if let signature = signatureImage {
                    Image(uiImage: signature)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 100)
                        .padding()
                }
            }
            .padding()
            
            // Signature view overlay when isShowingSignatureView is true
            if isShowingSignatureView {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea() // Dimmed background
                    
                    SignatureView(isOpened: $isShowingSignatureView, signatureImage: $signatureImage)
                }
            }
        }
    }
}
