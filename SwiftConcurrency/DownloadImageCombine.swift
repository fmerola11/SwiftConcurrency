//
//  DownloadImageCombine.swift
//  SwiftConcurrency
//
//  Created by Francesco Merola on 28/03/23.
//

import SwiftUI
import Combine

// MARK: COMBINE DATA LOADER

class DownloadImageCombineDataLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse (data: Data?, response: URLResponse?) -> UIImage? {
        
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 // typical status code values
        else
        {
            return nil
        }
        
        return image
        
    }
    
    /*  A publisher is an object that emits a sequence of values over time. A Combine publisher can be thought of as a source of data that can be subscribed to by one or more subscribers. */
    
    /*  map is an operator that transforms the output of a publisher. It takes a closure as an argument that's called with each value emitted by the publisher and returns a new value that's emitted by the transformed publisher. */
    
    /*  In Swift, you can use the eraseToAnyPublisher() method to erase the type of a publisher to AnyPublisher. This can be useful when you want to return a publisher whose type is unknown or when you want to hide implementation details of a publisher. */
    
    func downloadWithCombine () -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> Error in
                return error
            }
            .map(handleResponse)
            .eraseToAnyPublisher()
    }
}


// MARK: - COMBINE VIEW MODEL

class DownloadImageCombineViewModel: ObservableObject {
    
    @Published var images: [UIImage?] = []
    
    @Published var showErrorAlert: Bool = false
    
    let loader = DownloadImageCombineDataLoader()
    
    /*  Cancellable allows you to cancel a task that you no longer need or want to continue, which can be useful for managing resources and preventing memory leaks. */
    
    var cancellables = Set<AnyCancellable>()
    
    /*  In this example, the receive(on:) method is used to specify that the subscriber should receive values on the main thread. */
    
    /*  you can use the sink method to subscribe to the resulting publisher and receive the combined values */
    
    func fetchImage() async {
        
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink (receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Request completed successfully")
                case .failure(let error):
                    print("Error: \(error)")
                    self.showErrorAlert = true
                }
                
            }, receiveValue: { [weak self] image in
                self?.images.append(image)
            })
            .store(in: &cancellables)
    }
}


// MARK: COMBINE VIEW

struct DownloadImageCombine: View {
    
    @StateObject private var viewModel = DownloadImageCombineViewModel()
    
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
            .navigationTitle("Combine")
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(title: Text("ALERT"), message: Text("HTTP Requests failed. Check your internet connection and retry"), dismissButton: .default(Text("OK")))
            }
        }
        .task {
            await viewModel.fetchImage()
        }
        .task {
            await viewModel.fetchImage()
        }
    }
}


// MARK: COMBINE PREVIEWS

struct DownloadImageCombine_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageCombine()
    }
}
