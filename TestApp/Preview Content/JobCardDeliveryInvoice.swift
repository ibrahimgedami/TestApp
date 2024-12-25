//
//  JobCardDeliveryInvoice.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 25/12/2024.
//

import SwiftUI

struct PaymentType: Codable, Hashable, Equatable {
    
    let cd: String?
    let name: String?
    let locationCd: String?
    let accountCode: String?
    let glCode: String?
    let txnCode: String?
    
}

enum PaymentMethod: String, CaseIterable, Identifiable {
    
    var id: String { self.rawValue }
    
    case cash
    case creditCard
    
}

struct Payment: Identifiable {
    
    let id = UUID()
    var method: PaymentMethod
    var amount: Double
    var foreignAmount: Double?
    var exchangeRate: Double?
    
    init(method: PaymentMethod, amount: Double, foreignAmount: Double? = nil, exchangeRate: Double? = nil) {
        self.method = method
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
    
    mutating func addPayment(method: PaymentMethod, amount: Double, foreignAmount: Double? = nil, exchangeRate: Double? = nil) {
        guard amount > 0 else { return }
        payments.append(Payment(method: method, amount: amount, foreignAmount: foreignAmount, exchangeRate: exchangeRate))
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
            Text("Add Payment")
                .font(.headline)
            
            Picker("Payment Method", selection: $newPaymentType) {
                ForEach(paymentTypes, id: \.cd) { paymentType in
                    Text(paymentType.name ?? "").tag(paymentType as PaymentType?)
                }
            }
            .pickerStyle(.wheel)
            .onChange(of: newPaymentType) { _, newValue in
                updateCurrency(for: newValue)
            }
//            Picker("Payment Method", selection: $newPaymentType) {
//                ForEach(paymentTypes, id: \.cd) { paymentType in
//                    Text(paymentType.name ?? "").tag(paymentType.cd)
//                }
//            }
//            .pickerStyle(.wheel)
            
            HStack {
                TextField(selectedCurrency == "AED" ? "Amount" : "Foreign Amount", text: $newForeignAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: newForeignAmount) { _, newValue in
                        updateAEDAmount(from: newValue)
                    }
            }
            
            Picker("Select Currency", selection: $selectedCurrency) {
                ForEach(foreignCurrencies.keys.sorted(), id: \.self) { currency in
                    Text(currency).tag(currency)
                }
            }
            
            Text("Conversion Rate: \(foreignCurrencies[selectedCurrency] ?? 1.0, specifier: "%.1f") AED")
            
            if !newForeignAmount.isEmpty {
                Text("Equivalent in AED: \(calculatedAEDAmount, specifier: "%.1f")")
                    .foregroundColor(.gray)
            }
            
            Button(action: addPayment) {
                Text("Add")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private var paymentsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Payments")
                .font(.headline)
            
            ForEach(invoice.payments, id: \.method) { payment in
                HStack {
                    Text(payment.method.rawValue.capitalized)
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
        guard let foreignAmountInSelectedCurrency = Double(newForeignAmount), foreignAmountInSelectedCurrency > 0,
              let newPaymentType = newPaymentType else { return }
        
        let selectedExchangeRate = foreignCurrencies[selectedCurrency] ?? 1.0
        let amountInAED = foreignAmountInSelectedCurrency * selectedExchangeRate
        if let value = newPaymentType.cd?.lowercased() {
            invoice.addPayment(method: PaymentMethod(rawValue: value) ?? .cash, amount: amountInAED, foreignAmount: foreignAmountInSelectedCurrency, exchangeRate: selectedExchangeRate)
        }
        
        newForeignAmount = ""
        calculatedAEDAmount = 0.0
    }
    
    private func updateAEDAmount(from foreignAmount: String) {
        guard let foreignAmountValue = Double(foreignAmount), foreignAmountValue > 0 else {
            calculatedAEDAmount = 0.0
            return
        }
        let selectedExchangeRate = foreignCurrencies[selectedCurrency] ?? 1.0
        calculatedAEDAmount = foreignAmountValue * selectedExchangeRate
    }
    
    private func updateCurrency(for paymentType: PaymentType?) {
        switch paymentType?.name {
        case "Cash", "Credit Card", "REFUND":
            selectedCurrency = "AED"
        case "FC (Euro)":
            selectedCurrency = "EUR"
        case "FC (GB Pound)":
            selectedCurrency = "GBP"
        case "FC (US$)":
            selectedCurrency = "USD"
        default:
            selectedCurrency = "AED"
        }
    }
    
    private func deletePayment(_ payment: Payment) {
        if let index = invoice.payments.firstIndex(where: { $0.id == payment.id }) {
            invoice.payments.remove(at: index)
        }
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

/*
 
 private var paymentSection: some View {
     VStack(spacing: 10) {
         Text("Add Payment")
             .font(.headline)
         
         Picker("Payment Method", selection: $newPaymentMethod) {
             ForEach(paymentTypes, id: \.cd) { paymentType in
                 Text(paymentType.name ?? "").tag(paymentType.cd)
             }
         }
         .pickerStyle(.wheel)
         
         HStack {
             TextField(selectedCurrency == "AED" ? "Amount" : "Foreign Amount", text: $newForeignAmount)
                 .keyboardType(.decimalPad)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .onChange(of: newForeignAmount) { _, newValue in
                     updateAEDAmount(from: newValue)
                 }
         }
         
         Picker("Select Currency", selection: $selectedCurrency) {
             ForEach(foreignCurrencies.keys.sorted(), id: \.self) { currency in
                 Text(currency).tag(currency)
             }
         }
         
         Text("Conversion Rate: \(foreignCurrencies[selectedCurrency]!, specifier: "%.1f") AED")
         
         if !newForeignAmount.isEmpty {
             Text("Equivalent in AED: \(calculatedAEDAmount, specifier: "%.1f")")
                 .foregroundColor(.gray)
         }
         
         Button(action: addPayment) {
             Text("Add")
                 .frame(maxWidth: .infinity)
                 .padding()
                 .background(Color.blue)
                 .foregroundColor(.white)
                 .cornerRadius(8)
         }
     }
     .padding()
     .background(Color(.systemGray6))
     .cornerRadius(10)
 }

 
 */
