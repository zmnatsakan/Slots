//
//  ContentView.swift
//  slots
//
//  Created by mnats on 25.12.2023.
//

import SwiftUI

struct ContentView: View {
    var viewModels = [
        SlotColumnViewModel(size: 50),
        SlotColumnViewModel(size: 50),
        SlotColumnViewModel(size: 50),
        SlotColumnViewModel(size: 50),
        SlotColumnViewModel(size: 50),
        SlotColumnViewModel(size: 50),
        SlotColumnViewModel(size: 50),
        SlotColumnViewModel(size: 50),
    ]
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(viewModels, id: \.id) { viewModel in
                    SlotColumnView(viewModel: viewModel)
                }
            }
            .frame(width: 400, height: 200, alignment: .top)
            .clipShape(.rect)
            
            Button("SPIN") {
                Task {
                    for viewModel in viewModels {
    //                    viewModel.slots = [1, 2, 3, 4, 5, 6, 7]
                        viewModel.spin(count: 70, initialTimeInterval: 0.02)
                        try? await Task.sleep(nanoseconds: 100_000_000)
                    }
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ContentView()
}
