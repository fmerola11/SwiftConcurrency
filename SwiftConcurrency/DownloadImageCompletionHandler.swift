//
//  ContentView.swift
//  SwiftConcurrency
//
//  Created by Francesco Merola on 27/03/23.
//

import SwiftUI

// MARK: COMPLETION HANDLER DATA LOADER

/*  In Swift, a completion handler is a closure that's used to handle the result of an asynchronous operation. Completion handlers are commonly used in functions that perform network requests or other time-consuming tasks, and they allow the calling code to be notified when the task is complete and to handle any errors that may have occurred. */

/* `weak self` is a way to avoid strong reference cycles when using closures or blocks. Strong reference cycles occur when two objects hold strong references to each other, creating a situation where they cannot be deallocated by the memory management system. This can cause memory leaks and other issues. By using `weak self` in a closure or block, you create a weak reference to the object that the closure or block is called on, allowing the object to be deallocated when it is no longer needed. */

class DownloadImageCompletionHandlerDataLoader {
    
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
    
    /* "escaping" refers to a closure or function parameter that "escapes" the current scope in which it is defined, meaning that it can be called or executed outside of that scope. */
    
    func downloadImageCompletionHandler (completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image,error)
            
        }
        .resume()
    }
}

// MARK: COMPLETION HANDLER VIEW MODEL

/*  The main thread is the thread that's responsible for updating the user interface. All user interface operations, such as creating views or updating labels, should be executed on the main thread. If you perform UI operations on a background thread, your app may become unresponsive or crash. We can switch to the main thread by writing DispatchQueue.main.async { code } */

class DownloadImageCompletionHandlerViewModel: ObservableObject {
    
    @Published var images: [UIImage?] = []
    @Published var showErrorAlert: Bool = false
    let loader = DownloadImageCompletionHandlerDataLoader()
    
    func fetchImage () async {
        
        loader.downloadImageCompletionHandler { image, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.showErrorAlert = true
                } else {
                    self.images.append(image)
                }
            }
        }
    }
}

// MARK: COMPLETION HANDLER VIEW

struct DownloadImageCompletionHandler: View {
    
    @StateObject private var viewModel = DownloadImageCompletionHandlerViewModel()
    
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
            .navigationTitle("Completion Handler")
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(title: Text("ALERT"), message: Text("HTTP Requests failed. Check your internet connection and retry"), dismissButton: .default(Text("OK")))
            }
        }
        
        /*  A task is a unit of work that can be executed asynchronously. Writing .task allows you to start a task before this view appears and to cancel the execution it when no longer needed. .task summarizes the sintax that uses .onAppear and .onDelete. */
        
        /*  The await keyword is used to suspend the execution of an async function until a certain asynchronous operation, such as a network call or a file I/O operation, has completed. */
        
        .task {
            await viewModel.fetchImage()
        }
        .task {
            await viewModel.fetchImage()
        }
    }
}

// MARK: COMPLETION HANDLER PREVIEWS

struct DownloadImageCompletionHandler_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageCompletionHandler()
    }
}
