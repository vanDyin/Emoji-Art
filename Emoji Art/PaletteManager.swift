//
//  PaletteManager.swift
//  Emoji Art
//
//  Created by Вячеслав Полянский on 31.10.2025.
//

import SwiftUI

struct PaletteManager: View {
    let stores: [PaletteStore]
    @Environment(PaletteStore.self) private var store
    
    @State var selectedStore: PaletteStore?
    var body: some View {
        NavigationSplitView {
            List(stores, selection: $selectedStore) { store in
                Text(store.name)
                    .tag(store)
            }
        } content: {
            if let selectedStore {
                EditablePaletteList(store: selectedStore)
            }
        } detail: {
            Text("Choose a store")
        }
    }
}

//#Preview {
//    PaletteManager()
//}
