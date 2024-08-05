//
//  ContentView.swift
//  Vector Visualiser
//
//  Created by Will Lucas on 16/06/2024.
//

import SwiftUI
import SwiftData

struct Vector2D {
    var id: UUID
    var i: CGFloat
    var j: CGFloat
    var name: String?
    var isUnitVector: Bool
}

struct Vector3D {
    var id: UUID
    var i: CGFloat
    var j: CGFloat
    var k: CGFloat
    var name: String?
    var isUnitVector: Bool
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var currentDimension: Int?
    @State private var currentPopup: PopupMaster.Popup = .none
    
    @State private var vectors2d: [Vector2D] = [
        Vector2D(id: UUID(), i: 2, j: 3, isUnitVector: false),
        Vector2D(id: UUID(), i: 1, j: -4, isUnitVector: false),
        Vector2D(id: UUID(), i: 1, j: 0, name: "i", isUnitVector: true),
        Vector2D(id: UUID(), i: 0, j: 1, name: "j", isUnitVector: true)
    ]
    
    @State private var vectors3d: [Vector3D] = [
        Vector3D(id: UUID(), i: 1, j: 0, k: 0, name: "i", isUnitVector: true),
        Vector3D(id: UUID(), i: 0, j: 1, k: 0, name: "j", isUnitVector: true),
        Vector3D(id: UUID(), i: 0, j: 0, k: 1, name: "j", isUnitVector: true)
    ]

    var body: some View {
        ZStack {
            NavigationSplitView {
                List {
                    NavigationLink {
                        _2DPlaneVisualiser(currentDimension: $currentDimension, vectors: $vectors2d)
                    } label: {
                        HStack {
                            Image(systemName: "square")
                            Text("2D Plane")
                        }
                    }
                    
                    NavigationLink {
                        _3DPlaneVisualiser(currentDimension: $currentDimension, vectors: $vectors3d)
                    } label: {
                        HStack {
                            Image(systemName: "cube.transparent")
                            Text("3D Plane")
                        }
                    }
                }
                .navigationSplitViewColumnWidth(min: 150, ideal: 150, max: 150)
                .toolbar(removing: .sidebarToggle)
                .toolbar {
                    ToolbarItem {
                        Button {
                            if currentDimension == 2 {
                                currentPopup = .new2DVector
                            } else if currentDimension == 3 {
                               // currentPopup = .new3DVector
                            }
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
            } detail: {
                Text("Please select a plane to visualise")
            }
            PopupMaster(currentPopup: $currentPopup, vectors2d: $vectors2d)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
