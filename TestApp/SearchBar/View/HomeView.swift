//
//  HomeView.swift
//  TestApp
//
//  Created by Ibrahim Gedami on 13/03/2025.
//

import SwiftUI

struct HomeView: View {
    
    @State var textField: String = ""
    @State var progress: CGFloat = 0
    @MainActor @FocusState var isFocused: Bool
     
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 15 ) {
                ForEach(Item.mockData) { item  in
                    cardView(item)
                }
            }
            .padding(15)
            .offset(y: isFocused ? 0 :  progress * 75)
            .padding(.bottom, 75)
            .safeAreaInset(edge: .top, spacing: 0) {
                resizableHeaderView()
            }
        }
        .animation(.snappy(duration: 0.3, extraBounce: 0), value: isFocused)
        .onScrollGeometryChange(for: CGFloat.self) {
            $0.contentOffset.y + $0.contentInsets.top
        } action: { _, newValue in
             progress = max(min(-newValue / 75, 1), 0)
        }

    }
    
    // MARK: Custom Header View
    @ViewBuilder
    func resizableHeaderView() -> some View {
        let progress = isFocused ? 1 : progress
        
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back!")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    Text("Ibrahim")
                        .font(.title.bold())
                }
                
                Spacer(minLength: 0)
                 
                /// Profile Button
                Button {
                     
                } label: {
                    let profileUrl = "https://randomuser.me/api/portraits/men/20.jpg"
                    if let url = URL(string: profileUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40 )
                                .clipShape(.circle)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
            .frame(height: 60 - (60 * progress), alignment: .bottom)
            .padding(.horizontal, 15)
            .padding(.top, 15)
            .padding(.bottom, 15 - (15 * progress))
            .opacity(1 - progress)
            .offset(y: -10 * progress)
            /// Floating Search Bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                
                TextField("Search ", text: $textField)
                    .focused($isFocused )
                
                /// Microphone  button
                Button {
                    
                } label: {
                    Image(systemName: "microphone.fill")
                        .foregroundStyle(.red)
                }

            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: isFocused ? 0 : 30)
                    .fill(.background
                        .shadow(.drop(color: .black.opacity(0.08), radius: 5, x: 5, y: 5))
                        .shadow(.drop(color: .black.opacity(0.05), radius: 5, x: -5, y: -5))
                    )
                    .padding(.top, isFocused ? -100 : 0)
                }
            .padding(.horizontal, isFocused ? 0 : 15)
            .padding(.bottom, 10)
            .padding(.top, 5)
         }
        .visualEffect { content, proxy in
            let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
            let offset = minY > 0 ? 0 : -minY
            return content.offset(y: offset)
        }
    }

    // MARK: Card View
    @ViewBuilder
    func cardView(_ item: Item) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader {
                let size = $0.size
                if let imageUrl = item.image,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(.rect(cornerRadius: 20))
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
            .frame(height: 220)
            
            Text("By: \(item.title)")
                .font(.callout)
                .foregroundStyle(.primary.secondary )
        }
    }
    
}

#Preview {
    
    HomeView()

}
