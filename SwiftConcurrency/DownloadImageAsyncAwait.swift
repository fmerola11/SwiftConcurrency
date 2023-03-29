//
//  DownloadImageAsyncAwait.swift
//  SwiftConcurrency
//
//  Created by Francesco Merola on 28/03/23.
//

import SwiftUI

// MARK: ASYNC/AWAIT DATA LOADER

class DownloadImageAsyncAwaitDataLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse (data: Data?, response: URLResponse?) -> UIImage? {
        
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300
        else
        {
            return nil
        }
        
        return image
        
    }
    
    func downloadImageAsyncAwait () async throws -> UIImage? {
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return handleResponse(data: data, response: response)
        } catch  {
            throw error
        }
    }
    
}

// MARK: ASYNC/AWAIT VIEW MODEL

class DownloadImageAsyncAwaitViewModel: ObservableObject {
    
    @Published var images: [UIImage?] = []
    let loader = DownloadImageAsyncAwaitDataLoader()
    @Published var showErrorAlert: Bool = false
    
    /*  Actors in Swift are a type of object that encapsulates state and behavior that can be accessed and modified by asynchronous messages. They are designed to provide a safe and isolated way to manage shared mutable state in concurrent programming. Actors can be used to prevent race conditions, deadlocks, and other common concurrency issues. In particular, the MainActor is a special type of actor that represents the main thread of execution in an application. It is used to ensure that certain operations, such as UI updates, are always performed on the main thread, which is necessary for the proper functioning of many user interfaces.*/
    
    func fetchImage() async {
        
        do {
            let image = try await loader.downloadImageAsyncAwait()
            await MainActor.run {
                images.append(image)
            }
        } catch  {
            print("Error: \(error.localizedDescription)")
            showErrorAlert = true
        }
    }
}

// MARK: ASYNC/AWAIT VIEW

struct DownloadImageAsyncAwait: View {
    
    @StateObject var viewModel = DownloadImageAsyncAwaitViewModel()
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 40) {
                ForEach (viewModel.images, id: \.self) { image in
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    }
                }
            }
            .navigationTitle("Async/await")
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(title: Text("ALERT"), message: Text("HTTP Requests failed. Check your internet connection and retry"), dismissButton: .default(Text("OK")))
            }
            .task {
                await viewModel.fetchImage()
            }
            .task {
                await viewModel.fetchImage()
            }
        }
    }
}

// MARK: ASYNC/AWAIT PREVIEWS

struct DownloadImageAsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsyncAwait()
    }
}
