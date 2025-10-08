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
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
        }
    }
}
