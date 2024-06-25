//
//  ContentView.swift
//  Vector Visualiser
//
//  Created by Will Lucas on 16/06/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var currentDimension: Int?
    @State private var currentPopup: PopupMaster.Popup = .none

    var body: some View {
        ZStack {
            NavigationSplitView {
                List {
                    NavigationLink {
                        _2DPlaneVisualiser(currentDimension: $currentDimension)
                    } label: {
                        HStack {
                            Image(systemName: "square")
                            Text("2D Plane")
                        }
                    }
                    
                    NavigationLink {
                        Text("Hello, world!")
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
                            }
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
            } detail: {
                Text("Please select a plane to visualise")
            }
            PopupMaster(currentPopup: $currentPopup)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
