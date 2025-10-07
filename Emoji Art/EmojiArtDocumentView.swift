//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Вячеслав Полянский on 07.10.2025.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    private let emojis = "👻🍎😃🤪☹️🤯🐶🐭🦁🐵🦆🐝🐢🐄🐖🌲🌴🌵🍄🌞🌎🔥🌈🌧️🌨️☁️⛄️⛳️🚗🚙🚓🚲🛺🏍️🚘✈️🛩️🚀🚁🏰🏠❤️💤⛵️"
    var body: some View {
        VStack {
            Color.yellow
            ScrollingEmojis(emojis: emojis)
        }
    }
}

struct ScrollingEmojis: View {
    let emojis: [String]
    
    init(emojis: [String]) {
        self.emojis = emojis
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            ForEach(emojis, id: \.self) {emoji in
                    
            }
        }
    }
}

#Preview {
    EmojiArtDocumentView()
}
