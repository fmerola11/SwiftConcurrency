//
//  DownloadImageAsyncTaskGroup.swift
//  SwiftConcurrency
//
//  Created by Francesco Merola on 28/03/23.
//

import SwiftUI

class DownloadImageAsyncTaskGroupDataLoader {
    
    func fetchImagesWithAsyncTaskGroup () async throws -> [UIImage] {
        
        let urlString: String = "https://picsum.photos/300"
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            
            var images: [UIImage] = []
            
            for _ in 0..<10 {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        
        guard let url = URL (string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            }
            else {
                throw URLError(.badURL)
            }
        } catch  {
            throw error
        }
    }
}

class DownloadImageAsyncTaskGroupViewModel: ObservableObject {
    
    @Published var images: [UIImage?] = []
    @Published var showErrorAlert: Bool = false
    let loader = DownloadImageAsyncTaskGroupDataLoader()
    
    func getImages () async {
        
        if let images = try? await loader.fetchImagesWithAsyncTaskGroup() {
            self.images.append(contentsOf: images)
        } else {
            showErrorAlert = true
        }
    }
    
}

struct DownloadImageAsyncTaskGroup: View {
    
    @StateObject var viewModel = DownloadImageAsyncTaskGroupViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack (spacing: 40) {
                    ForEach(viewModel.images, id: \.self) { image in
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        }
                    }
                }
            }
            .navigationTitle("Task Group")
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(title: Text("ALERT"), message: Text("HTTP Requests failed. Check your internet connection and retry"), dismissButton: .default(Text("OK")))
            }
            .task {
                await viewModel.getImages()
            }
            
        }
    }
}

struct DownloadImageAsyncTaskGroup_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsyncTaskGroup()
    }
}
