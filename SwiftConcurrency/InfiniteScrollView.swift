//
//  InfiniteScrollView.swift
//  SwiftConcurrency
//
//  Created by Francesco Merola on 29/03/23.
//


import SwiftUI

struct InfiniteScrollView: View {
    
    @State private var images = [UIImage]()
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack (spacing: 40) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    }
                }
                if isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .navigationTitle("Infinite Scroll View")
            .task {
                await fetchImages()
            }
        }
    }
    
    func fetchImages() async {
        let urls = [
            
            URL(string: "https://picsum.photos/200")!,
            URL(string: "https://picsum.photos/200")!,
            URL(string: "https://picsum.photos/200")!,
            URL(string: "https://picsum.photos/200")!,
            URL(string: "https://picsum.photos/200")!,
            URL(string: "https://picsum.photos/200")!,
            URL(string: "https://picsum.photos/200")!,
            URL(string: "https://picsum.photos/200")!,
            URL(string: "https://picsum.photos/200")!,
            URL(string: "https://picsum.photos/200")!
        ]
        
        while true {
            isLoading = true
            
            do {
                let newImages = try await withThrowingTaskGroup(of: UIImage.self) { group -> [UIImage] in
                    for url in urls {
                        group.addTask {
                            let (data, _) = try await URLSession.shared.data(from: url)
                            let image = UIImage(data: data)
                            return image ?? UIImage()
                        }
                    }
                    
                    return try await group.reduce(into: [UIImage]()) { result, image in
                        result.append(image)
                    }
                }
                
                images.append(contentsOf: newImages)
                isLoading = false
            } catch {
                print("Error fetching images: \(error.localizedDescription)")
            }
            
        }
    }
}




struct InfiniteScrollView_Previews: PreviewProvider {
    static var previews: some View {
        InfiniteScrollView()
    }
}
