//
//  SearchableModifier.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 20/05/2025.
//

import SwiftUI
import AVFoundation
import Speech
import Combine

struct SearchView: View {
    // MARK: - States
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showResults = false
    @State private var isLoading = false
    @FocusState private var isFocused: Bool
    @State private var isListening = false
    @State private var hideNavBar = false
    
    // MARK: - Combine
    @State private var cancellable: AnyCancellable?
    
    // MARK: - Scroll Tracking
    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    // MARK: - Dummy Data
    let dummyData = [
        "Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grapes", "Honeydew",
        "Jackfruit", "Kiwi", "Lemon", "Mango", "Nectarine", "Orange", "Papaya", "Quince",
        "Raspberry", "Strawberry", "Tangerine", "Ugli Fruit", "Vanilla Bean", "Watermelon",
        "Xigua", "Yellow Passion Fruit", "Zucchini", "Apricot", "Blackberry", "Cantaloupe",
        "Dragon Fruit", "Eggfruit", "Feijoa", "Guava", "Hackberry", "Imbe", "Jujube",
        "Kumquat", "Lychee", "Mulberry", "Naranjilla", "Olive", "Peach", "Rambutan", "Salak",
        "Tamarind", "Yuzu", "Persimmon", "Longan"
    ]
    let columns = [GridItem(.flexible()), GridItem(.flexible())
    ]
    
    @State private var filteredData: [String] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isSearching {
                    searchBar
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut, value: isSearching)
                        .background(.ultraThinMaterial)
                        .padding(.top, hideNavBar ? -100 : 0)
                }
                
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("scroll")).minY)
                        }
                        .frame(height: 0)
                        
                        VStack(spacing: 10) {
                            if isLoading {
                                ProgressView("Searching...")
                                    .padding()
                            }
                            
                            ForEach(filteredData, id: \.self) { item in
                                Text(item)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 1)
                            }
                        }
                        .padding()
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { newOffset in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            hideNavBar = newOffset < lastScrollOffset
                        }
                        lastScrollOffset = newOffset
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            isSearching.toggle()
                        }
                        if isSearching {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isFocused = true
                            }
                        } else {
                            resetSearch()
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .onChange(of: searchText) { _, _ in debounceSearch() }
            .onAppear {
                filteredData = dummyData
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search...", text: $searchText)
                    .focused($isFocused)
                    .onSubmit {
                        showResults = true
                        isLoading = false
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        filteredData = dummyData
                        showResults = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: {
                    toggleVoiceRecognition()
                }) {
                    Image(systemName: isListening ? "mic.circle.fill" : "mic.circle")
                        .foregroundColor(.blue)
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if isSearching {
                Button("Cancel") {
                    withAnimation {
                        resetSearch()
                    }
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing))
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    private func resetSearch() {
        isSearching = false
        isFocused = false
        searchText = ""
        isLoading = false
        showResults = false
        filteredData = dummyData
    }
    
    private func debounceSearch() {
        isLoading = true
        cancellable?.cancel()
        cancellable = Just(searchText)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { text in
                if text.isEmpty {
                    filteredData = dummyData
                    isLoading = false
                } else {
                    filteredData = dummyData.filter {
                        $0.localizedCaseInsensitiveContains(text)
                    }
                    isLoading = false
                    showResults = true
                }
            }
    }
    
    private func toggleVoiceRecognition() {
        if isListening {
            SpeechRecognizer.shared.stopRecording()
            isListening = false
        } else {
            isListening = true
            SpeechRecognizer.shared.startRecording { result in
                DispatchQueue.main.async {
                    self.searchText = result
                    self.isListening = false
                }
            }
        }
    }
    
}

// MARK: - Offset PreferenceKey
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate {
    static let shared = SpeechRecognizer()
    
    private let recognizer = SFSpeechRecognizer()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func startRecording(onResult: @escaping (String) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else { return }
            
            let request = SFSpeechAudioBufferRecognitionRequest()
            let inputNode = self.audioEngine.inputNode
            
            self.recognitionTask?.cancel()
            self.recognitionTask = self.recognizer?.recognitionTask(with: request) { result, error in
                if let result = result {
                    onResult(result.bestTranscription.formattedString)
                }
            }
            
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            
            self.audioEngine.prepare()
            try? self.audioEngine.start()
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
    }
    
}

#Preview {
    SearchView()
}
