//
//  New2DVectorPopup.swift
//  Vector Visualiser
//
//  Created by Will Lucas on 25/06/2024.
//

import SwiftUI

struct New2DVectorPopup: View {
    @State private var scale: CGFloat = 0
    @State private var iScalar: String = ""
    @State private var jScalar: String = ""
    @State private var errorOccurred: String? = nil
    
    @Binding var currentPopup: PopupMaster.Popup
    @Binding var vectors: [Vector2D]
    
    var body: some View {
        GeometryReader { metrics in
            if scale == CGFloat(1) {
                VStack {
                    Spacer()
                    HStack {
                        Spacer ()
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(.white)
                                .frame(width: metrics.size.width * 0.4, height: metrics.size.height * 0.3)
                            VStack {
                                // Main popup body
                                Spacer().frame(height: metrics.size.height * 0.01)
                                ZStack {
                                    Text("New Vector")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            currentPopup = .none
                                        }) {
                                            Image(systemName: "xmark")
                                        }
                                    }.padding(.trailing, 8)
                                }
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    if let error = errorOccurred {
                                        Text(error)
                                            .foregroundStyle(Color.red)
                                    }
                                    
                                    Text("Enter scalar quantities for each basis vector:")
                                    
                                    TextField("Basis vector i", text: $iScalar)
                                        .frame(width: metrics.size.width * 0.2)
                                    TextField("Basis vector j", text: $jScalar)
                                        .frame(width: metrics.size.width * 0.2)
                                    
                                    Button("Add") {
                                        addNewVector()
                                    }
                                }.padding(.all, 5)
                                Spacer()
                            }
                            .frame(width: metrics.size.width * 0.4, height: metrics.size.height * 0.3)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .scaleEffect(scale)
            }
        }.onAppear() {
            withAnimation(Animation.snappy(duration: 0.1)) {
                scale = 1
            }
        }
    }
    
    private func addNewVector() {
        errorOccurred = nil
        if let i = Int(iScalar), let j = Int(jScalar) {
            vectors.append(Vector2D(id: UUID(), i: CGFloat(i), j: CGFloat(j), isUnitVector: false))
            currentPopup = .none
        } else {
            errorOccurred = "Invalid values entered"
        }
    }
}
