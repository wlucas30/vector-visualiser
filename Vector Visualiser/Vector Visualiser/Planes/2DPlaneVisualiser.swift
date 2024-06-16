//
//  2DPlaneVisualiser.swift
//  Vector Visualiser
//
//  Created by Will Lucas on 16/06/2024.
//

import SwiftUI

struct _2DPlaneVisualiser: View {
    
    @Binding var currentDimension: Int?
    
    var body: some View {
        VStack {
            Text("2D")
        }
        .onAppear() {
            currentDimension = 2
        }
    }
}
