//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Вячеслав Полянский on 07.10.2025.
//

import SwiftUI

@Observable
class EmojiArtDocument {
    typealias Emoji = EmojiArt.Emoji

    private var emojiArt = EmojiArt()
    
    init(emojiArt: EmojiArt = EmojiArt()) {
        self.emojiArt = emojiArt
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }
    
    //MARK: Intents
    
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
}
