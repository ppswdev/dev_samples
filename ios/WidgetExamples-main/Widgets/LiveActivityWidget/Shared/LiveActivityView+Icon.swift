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

import SwiftUI

extension LiveActivityView {
    struct IconView: View {
        let state: DeliveryAttributes.ContentState
        let isStale: Bool

        var body: some View {
            Image(systemName: imageName)
                .symbolVariant(.fill)
                .padding(4)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )
        }
    }
}

// MARK: - Helpers

extension LiveActivityView.IconView {
    private var imageName: String {
        isStale ? "clock.badge.exclamationmark" : "shippingbox"
    }

    private var backgroundColor: Color {
        isStale ? .brown : deliveryColor
    }

    private var deliveryColor: Color {
        switch state.deliveryState {
        case .sent:
            .teal
        case .delayed:
            .orange
        case .arrived:
            .green
        }
    }
}

// MARK: - Preview

#Preview {
    HStack {
        ForEach(DeliveryAttributes.previewStates, id: \.self) {
            LiveActivityView.IconView(
                state: $0,
                isStale: false
            )
        }
        LiveActivityView.IconView(
            state: .sent,
            isStale: true
        )
    }
    .scaleEffect(2)
}
