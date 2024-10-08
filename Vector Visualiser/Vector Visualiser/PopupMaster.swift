//
//  PopupMaster.swift
//  Vector Visualiser
//
//  Created by Will Lucas on 25/06/2024.
//

import SwiftUI

struct PopupMaster: View {
    enum Popup: Codable {
        case new2DVector
        case new3DVector
        case none
    }
    
    @Binding var currentPopup: Popup
    @Binding var vectors2d: [Vector2D]
    @Binding var vectors3d: [Vector3D]
    
    var body: some View {
        GeometryReader { metrics in
            ZStack {
                Rectangle()
                    .frame(width: metrics.size.width, height: metrics.size.height)
                    .foregroundColor(.black)
                    .opacity(currentPopup == .none ? 0 : 0.3)
                switch currentPopup {
                case .new2DVector:
                    New2DVectorPopup(currentPopup: $currentPopup, vectors: $vectors2d)
                case .new3DVector:
                    New3DVectorPopup(currentPopup: $currentPopup, vectors: $vectors3d)
                case .none:
                    EmptyView()
                }
            }
        }
    }
}
