// The MIT License (MIT)
//
// Copyright (c) 2020-Present Paweł Wiszenko
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import OSLog
import SwiftData
import WidgetKit

extension SwiftDataWidget {
    struct Provider: TimelineProvider {
        private let modelContext = ModelContext(Self.container)

        func placeholder(in context: Context) -> Entry {
            .placeholder
        }

        func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
            completion(.placeholder)
        }

        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            guard let products = fetchProducts() else {
                completion(.init(entries: [.empty], policy: .never))
                return
            }
            let productInfo = Entry.ProductInfo(
                count: products.count,
                lastItem: products.last
            )
            let entry = Entry(productInfo: productInfo)
            completion(.init(entries: [entry], policy: .never))
        }
    }
}

// MARK: - ModelContainer

extension SwiftDataWidget.Provider {
    private static let container: ModelContainer = {
        do {
            return try ModelContainer(for: Product.self)
        } catch {
            fatalError("\(error)")
        }
    }()
}

// MARK: - Helpers

extension SwiftDataWidget.Provider {
    private func fetchProducts() -> [Product]? {
        do {
            let products = try modelContext.fetch(FetchDescriptor<Product>())
            return products.sorted {
                $0.creationDate < $1.creationDate
            }
        } catch {
            Logger.widgets.error("Error fetching products: \(error)")
            return nil
        }
    }
}
