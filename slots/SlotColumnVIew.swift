//
//  SlotColumnVIew.swift
//  slots
//
//  Created by mnats on 26.12.2023.
//

import SwiftUI

struct SlotColumnView: View {
    @ObservedObject var viewModel = SlotColumnViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.slots, id: \.self) { slot in
                Image("slot\(slot)")
                    .resizable()
                    .frame(width: viewModel.size, height: viewModel.size)
            }
        }
        .offset(y: viewModel.offset)
    }
}
