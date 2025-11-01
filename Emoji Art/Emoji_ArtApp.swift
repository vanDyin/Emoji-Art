//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Вячеслав Полянский on 07.10.2025.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    @State var defaultDocument = EmojiArtDocument()
    @State var paletteStore = PaletteStore(named: "Main")
    @State var store2 = PaletteStore(named: "Alternate")
    @State var store3 = PaletteStore(named: "Special")
    
    var body: some Scene {
        WindowGroup {
            PaletteManager(stores: [paletteStore, store2, store3])
            //EmojiArtDocumentView(document: defaultDocument)
                .environment(paletteStore)
        }
    }
}
