//
//  JobCardInvoice.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 25/07/2025.
//

import Foundation
import PhotosUI
import SwiftUI

// MARK: - Main View
struct JobCardCreationView: View {
    
    enum CreationStep: Int, CaseIterable {
        case form, media, invoice
        
        var title: String {
            switch self {
            case .form: return "Details"
            case .media: return "Media"
            case .invoice: return "Invoice"
            }
        }
        
        var icon: String {
            switch self {
            case .form: return "doc.text.fill"
            case .media: return "photo.fill"
            case .invoice: return "dollarsign.circle.fill"
            }
        }
    }
    
    @State private var currentStep: CreationStep = .form
    @State private var formData = JobFormData()
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideoURL: URL?
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                EnhancedStepIndicator(currentStep: $currentStep)
                    .padding(.vertical, 20)
                    .background(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                
                // Content for current step
                Group {
                    switch currentStep {
                    case .form:
                        JobFormView(formData: $formData)
                    case .media:
                        MediaUploadView(selectedImages: $selectedImages, selectedVideoURL: $selectedVideoURL)
                    case .invoice:
                        InvoiceView(formData: formData, selectedImages: $selectedImages, selectedVideoURL: $selectedVideoURL)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
                
                Spacer()
                
                // Next/Submit button
                Button(action: nextStep) {
                    HStack {
                        if isSubmitting && currentStep == .invoice {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(currentStep == .invoice ? "Submit Job Card" : "Continue")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(canProceedToNextStep ? Color.blue : Color.gray)
                    .cornerRadius(10)
                }
                .disabled(!canProceedToNextStep || (isSubmitting && currentStep == .invoice))
                .padding()
            }
            .navigationTitle("Create Job Card")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    resetForm()
                }
            } message: {
                Text("Your job card has been created successfully!")
            }
        }
    }
    
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case .form:
            return !formData.clientName.isEmpty && !formData.jobDescription.isEmpty
        case .media:
            return !selectedImages.isEmpty || selectedVideoURL != nil
        case .invoice:
            return true
        }
    }
    
    private func nextStep() {
        if currentStep == .invoice {
            submitJobCard()
        } else {
            withAnimation {
                currentStep = CreationStep(rawValue: currentStep.rawValue + 1) ?? .form
            }
        }
    }
    
    private func submitJobCard() {
        isSubmitting = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showSuccess = true
        }
    }
    
    private func resetForm() {
        withAnimation {
            currentStep = .form
            formData = JobFormData()
            selectedImages = []
            selectedVideoURL = nil
        }
    }
}

// MARK: - Enhanced Step Indicator
struct EnhancedStepIndicator: View {
    @Binding var currentStep: JobCardCreationView.CreationStep
    let steps = JobCardCreationView.CreationStep.allCases
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(steps, id: \.self) { step in
                StepView(step: step, currentStep: $currentStep)
                    .frame(maxWidth: .infinity)
                
                if step != steps.last {
                    Spacer()
                        .frame(height: 1)
                        .background(currentStep.rawValue > step.rawValue ? Color.blue : Color.gray.opacity(0.3))
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct StepView: View {
    let step: JobCardCreationView.CreationStep
    @Binding var currentStep: JobCardCreationView.CreationStep
    
    var isCompleted: Bool {
        currentStep.rawValue > step.rawValue
    }
    
    var isCurrent: Bool {
        currentStep == step
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isCompleted || isCurrent ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: step.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isCurrent ? .white : Color.gray)
                }
            }
            
            Text(step.title)
                .font(.system(size: 12, weight: isCurrent ? .semibold : .regular))
                .foregroundColor(isCompleted || isCurrent ? .blue : .gray)
        }
    }
}

// MARK: - Form Step
struct JobFormData {
    var clientName: String = ""
    var jobDescription: String = ""
    var jobDate: Date = Date()
    var estimatedHours: Double = 1
    var hourlyRate: Double = 50
}

struct JobFormView: View {
    @Binding var formData: JobFormData
    
    var body: some View {
        Form {
            Section(header: Text("Client Information")) {
                TextField("Client Name", text: $formData.clientName)
            }
            
            Section(header: Text("Job Details")) {
                DatePicker("Job Date", selection: $formData.jobDate, displayedComponents: .date)
                TextField("Description", text: $formData.jobDescription, axis: .vertical)
                    .lineLimit(3...)
            }
            
            Section(header: Text("Pricing")) {
                Stepper(value: $formData.estimatedHours, in: 0.5...100, step: 0.5) {
                    HStack {
                        Text("Estimated Hours")
                        Spacer()
                        Text("\(formData.estimatedHours, specifier: "%.1f")")
                            .foregroundColor(.blue)
                    }
                }
                
                HStack {
                    Text("Hourly Rate")
                    Spacer()
                    TextField("", value: $formData.hourlyRate, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Media Upload Step
struct MediaUploadView: View {
    @Binding var selectedImages: [UIImage]
    @Binding var selectedVideoURL: URL?
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Images section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Images")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingImagePicker = true }) {
                            Label("Add", systemImage: "plus")
                                .font(.subheadline)
                        }
                    }
                    
                    if selectedImages.isEmpty {
                        EmptyStateView(
                            icon: "photo",
                            title: "No Images Added",
                            subtitle: "Add photos of the job"
                        )
                        .onTapGesture {
                            showingImagePicker = true
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(selectedImages, id: \.self) { image in
                                    ImageThumbnailView(image: image) {
                                        if let index = selectedImages.firstIndex(of: image) {
                                            selectedImages.remove(at: index)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // Video section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Video")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingVideoPicker = true }) {
                            Label("Add", systemImage: "plus")
                                .font(.subheadline)
                        }
                    }
                    
                    if selectedVideoURL == nil {
                        EmptyStateView(
                            icon: "video",
                            title: "No Video Added",
                            subtitle: "Add a video of the job"
                        )
                        .onTapGesture {
                            showingVideoPicker = true
                        }
                    } else {
                        if let url = selectedVideoURL {
                            VideoThumbnailView(videoURL: url) {
                                selectedVideoURL = nil
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(images: $selectedImages)
        }
        .sheet(isPresented: $showingVideoPicker) {
            VideoPicker(videoURL: $selectedVideoURL)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.gray.opacity(0.5))
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ImageThumbnailView: View {
    let image: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.red)
                    .font(.system(size: 20))
                    .offset(x: 8, y: -8)
            }
        }
    }
}

// MARK: - Invoice Step
struct InvoiceView: View {
    let formData: JobFormData
    @Binding var selectedImages: [UIImage]
    @Binding var selectedVideoURL: URL?
    
    var totalCost: Double {
        formData.estimatedHours * formData.hourlyRate
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary card
                VStack(spacing: 16) {
                    HStack {
                        Text("Summary")
                            .font(.title3.bold())
                        Spacer()
                    }
                    
                    Divider()
                    
                    SummaryRow(label: "Client", value: formData.clientName)
                    SummaryRow(label: "Job Date", value: formData.jobDate.formatted(date: .abbreviated, time: .omitted))
                    SummaryRow(label: "Description", value: formData.jobDescription)
                    
                    Divider()
                    
                    SummaryRow(label: "Media Attachments", value: "\(selectedImages.count) photos\(selectedVideoURL != nil ? ", 1 video" : "")")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Invoice card
                VStack(spacing: 16) {
                    HStack {
                        Text("Invoice")
                            .font(.title3.bold())
                        Spacer()
                    }
                    
                    Divider()
                    
                    SummaryRow(label: "Hourly Rate", value: "$\(formData.hourlyRate)")
                    SummaryRow(label: "Estimated Hours", value: "\(formData.estimatedHours)")
                    
                    Divider()
                    
                    HStack {
                        Text("Total Estimate")
                            .font(.headline)
                        Spacer()
                        Text("$\(totalCost, specifier: "%.2f")")
                            .font(.title3.bold())
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct SummaryRow: View {
    
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Media Pickers
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.images.append(image)
                        }
                    }
                }
            }
        }
    }
}

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: VideoPicker
        
        init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.dismiss()
            
            if let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            }
        }
    }
}

struct VideoThumbnailView: View {
    let videoURL: URL
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 180)
                .overlay(
                    VStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                        Text("Video")
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                )
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.red)
                    .font(.system(size: 20))
                    .offset(x: 8, y: -8)
            }
        }
    }
}

#Preview {
    NavigationView {
        JobCardCreationView()
    }
}
