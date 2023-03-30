# SwiftConcurrency
[SwiftConcurrency.pdf](https://github.com/fmerola11/SwiftConcurrency/files/11113561/SwiftConcurrency.pdf)

This project is an example of how to use concurrency in Swift. The app uses the URLSession API to fetch data from a remote API and display it in the user interface. Concurrency is the ability of a programming language to execute multiple tasks or processes concurrently. Swift, being a modern programming language, has built-in support for concurrency, which allows developers to write more efficient and responsive code. Concurrency in Swift is important for several reasons:
+ Performance: by allowing multiple tasks to execute concurrently, Swift can take advantage of modern multi-core processors, which can significantly improve the performance of your application.
+ Responsiveness: concurrency can improve the responsiveness of your application by allowing it to perform multiple tasks at the same time, such as responding to user input while performing background tasks.
+ Resource utilization: concurrency allows you to make better use of system resources such as CPU, memory, and I/O. By executing tasks concurrently, you can avoid wasting resources and ensure that your application runs smoothly.
+ Simplified code: concurrency can simplify the code by removing the need for complex and error-prone synchronization techniques. Swift provides built-in concurrency features such as async/await and actors that simplify the process of writing concurrent code.

Overall, concurrency in Swift is essential for building efficient and responsive applications that can take advantage of modern hardware and provide a better user experience.

## Installation
+ Clone the repository: git clone https://github.com/fmerola11/SwiftConcurrency.git
+ Open SwiftConcurrency.xcodeproj in Xcode.
+ Build and run the app on a simulator or device. 📱

## Features
+ Uses URLSession to perform network requests, in order to fetch data from the web.
+ Utilizes DispatchQueue to intentionally switch between main and background thread.
+ Shows different ways to write concurrent code: Completion Handler, async/await, Combine Framework. The app also illustrates how a task works.
+ Error Handling.
+ Implements a simple user interface to display the fetched data, that consists of images.
+ Uses a `while` cycle to perform a task that loads images in an infinite ScrollView.

## Usage
+ Launch the app on your device or simulator.
+ The app will fetch data from a remote API and display it in a view. 🌁

## How to learn from the app
Each file in the app is related to a specific mode to write concurrent code and fetch data from the network. I recommend to read the files in this order: DownloadImageCompletionHandler, DownloadImageCombine, DownloadImageAsyncAwait, DownloadImageAsyncTaskGroup, InfiniteScrollView. The code is documented 🗂️

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
This project was inspired by the Swift concurrency documentation and various online resources on using concurrency in Swift.
