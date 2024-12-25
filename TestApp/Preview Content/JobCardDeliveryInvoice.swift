//
//  JobCardDeliveryInvoice.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 25/12/2024.
//

import SwiftUI

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
    var vatPercentage: Double
    var currencyCode: String
    var exchangeRate: Double
    var discount: Double?
    var additionalDiscount: Double
    
    var netAmount: Double {
        let discountedAmount = amount - (discount ?? 0) - additionalDiscount
        return max(discountedAmount, 0)
    }
    
    var vatAmount: Double {
        netAmount * (vatPercentage / 100)
    }
    
    var netAmountIncludingVAT: Double {
        netAmount + vatAmount
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

    @State private var invoice = Invoice(
        amount: 1000.0,
        payments: [],
        vatPercentage: 5.0,
        currencyCode: "AED",
        exchangeRate: 1.0,
        discount: nil,
        additionalDiscount: 0.0
    )
    
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
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Summary")
                .font(.headline)
            Text("Currency: \(invoice.currencyCode)")
            Text("Exchange Rate: \(invoice.exchangeRate, specifier: "%.1f")")
            Text("Original Amount: \(invoice.amount, specifier: "%.1f")")
            Text("Net Amount: \(invoice.netAmount, specifier: "%.1f")")
            Text("VAT (\(invoice.vatPercentage)%): \(invoice.vatAmount, specifier: "%.1f")")
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
        VStack(spacing: 10) {
            Text("Add Payment").font(.headline)
            
            Picker("Payment Type", selection: $newPaymentType) {
                ForEach(paymentTypes) { type in
                    Text(type.name ?? "")
                        .tag(type as PaymentType?)
                }
            }
            .frame(height: 100)
            .pickerStyle(WheelPickerStyle())
            .onChange(of: newPaymentType) { _, newValue in
                updateCurrency(for: newValue)
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
        guard let type = newPaymentType,
              let foreignAmount = Double(newForeignAmount),
              foreignAmount > 0 else { return }
        
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
