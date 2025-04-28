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

import WidgetKit

extension SwiftDataWidget {
    struct Entry: TimelineEntry {
        var date: Date = .now
        var productInfo: ProductInfo?
    }
}

// MARK: - ProductInfo

extension SwiftDataWidget.Entry {
    struct ProductInfo {
        let count: Int
        let lastItem: Product?
    }
}

// MARK: - Data

extension SwiftDataWidget.Entry {
    static var empty: Self {
        .init()
    }

    static var placeholder: Self {
        .init(productInfo: .placeholder)
    }
}

extension SwiftDataWidget.Entry.ProductInfo {
    static var placeholder: Self {
        .init(count: 3, lastItem: .placeholder)
    }
}

extension Product {
    static let placeholder = Product(
        name: "Product #3",
        creationDate: .now
    )
}
