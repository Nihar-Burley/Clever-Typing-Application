package com.clevertyping.keyboard.ime

class KeyboardLayoutFactory {
    fun buildRows(
        mode: KeyboardMode,
        shiftState: ShiftState,
    ): List<List<KeyboardKey>> {
        return when (mode) {
            KeyboardMode.LETTERS -> buildLetterRows(shiftState)
            KeyboardMode.NUMBERS -> buildNumberRows()
            KeyboardMode.SYMBOLS -> buildSymbolRows()
            KeyboardMode.EMOJI -> buildEmojiRows()
        }
    }

    private fun buildLetterRows(shiftState: ShiftState): List<List<KeyboardKey>> {
        val uppercase = shiftState != ShiftState.OFF
        fun key(letter: String): KeyboardKey {
            val label = if (uppercase) letter.uppercase() else letter
            return KeyboardKey(
                label = label,
                value = label,
                type = KeyType.CHARACTER,
            )
        }

        return listOf(
            listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p").map(::key),
            listOf("a", "s", "d", "f", "g", "h", "j", "k", "l").map(::key),
            listOf(
                KeyboardKey(
                    label = shiftLabel(shiftState),
                    value = "",
                    type = KeyType.SHIFT,
                    weight = 1.4f,
                    accent = shiftState != ShiftState.OFF,
                ),
            ) +
                listOf("z", "x", "c", "v", "b", "n", "m").map(::key) +
                listOf(
                    KeyboardKey(
                        label = "Del",
                        value = "",
                        type = KeyType.DELETE,
                        weight = 1.4f,
                    ),
                ),
            listOf(
                KeyboardKey("123", "", KeyType.MODE_SWITCH, weight = 1.2f, accent = true),
                KeyboardKey("Emoji", "", KeyType.EMOJI, weight = 1.2f),
                KeyboardKey("Clip", "", KeyType.CLIPBOARD, weight = 1.2f),
                KeyboardKey("Space", " ", KeyType.SPACE, weight = 3f),
                KeyboardKey("Left", "", KeyType.CURSOR_LEFT, weight = 1f),
                KeyboardKey("Right", "", KeyType.CURSOR_RIGHT, weight = 1f),
                KeyboardKey("Enter", "\n", KeyType.ENTER, weight = 1.4f, accent = true),
            ),
            listOf(
                KeyboardKey("Fix", "", KeyType.AI_GRAMMAR, weight = 1.1f, accent = true),
                KeyboardKey("Translate", "", KeyType.AI_TRANSLATE, weight = 1.3f, accent = true),
                KeyboardKey("Reply", "", KeyType.AI_SMART_REPLY, weight = 1.1f, accent = true),
                KeyboardKey("Assist", "", KeyType.AI_ASSIST, weight = 1.1f, accent = true),
            ),
            listOf(
                KeyboardKey("Rewrite", "", KeyType.AI_REWRITE, weight = 1.2f, accent = true),
                KeyboardKey("Para", "", KeyType.AI_PARAPHRASE, weight = 1.1f, accent = true),
                KeyboardKey("Summ", "", KeyType.AI_SUMMARIZE, weight = 1.1f, accent = true),
                KeyboardKey("Email", "", KeyType.AI_EMAIL, weight = 1.1f, accent = true),
                KeyboardKey("Caption", "", KeyType.AI_CAPTION, weight = 1.2f, accent = true),
            ),
        )
    }

    private fun buildNumberRows(): List<List<KeyboardKey>> {
        return listOf(
            "1 2 3 4 5 6 7 8 9 0".split(" ").map(::charKey),
            "- / : ; ( ) \$ & @ \"".split(" ").map(::charKey),
            listOf(
                KeyboardKey("ABC", "", KeyType.MODE_SWITCH, weight = 1.4f, accent = true),
            ) +
                " . , ? ! ' ".trim().split(" ").map(::charKey) +
                listOf(
                    KeyboardKey("Del", "", KeyType.DELETE, weight = 1.4f),
                ),
            listOf(
                KeyboardKey("#+=", "", KeyType.MODE_SWITCH, weight = 1.3f),
                KeyboardKey("Emoji", "", KeyType.EMOJI, weight = 1.1f),
                KeyboardKey("Space", " ", KeyType.SPACE, weight = 3f),
                KeyboardKey("Left", "", KeyType.CURSOR_LEFT, weight = 1f),
                KeyboardKey("Right", "", KeyType.CURSOR_RIGHT, weight = 1f),
                KeyboardKey("Enter", "\n", KeyType.ENTER, weight = 1.4f, accent = true),
            ),
        )
    }

    private fun buildSymbolRows(): List<List<KeyboardKey>> {
        return listOf(
            "[ ] { } # % ^ * + =".split(" ").map(::charKey),
            "_ \\ | ~ < > EUR GBP YEN *".split(" ").map(::charKey),
            listOf(
                KeyboardKey("ABC", "", KeyType.MODE_SWITCH, weight = 1.4f, accent = true),
            ) +
                " . , ? ! ' ".trim().split(" ").map(::charKey) +
                listOf(
                    KeyboardKey("Del", "", KeyType.DELETE, weight = 1.4f),
                ),
            listOf(
                KeyboardKey("123", "", KeyType.MODE_SWITCH, weight = 1.3f),
                KeyboardKey("Emoji", "", KeyType.EMOJI, weight = 1.1f),
                KeyboardKey("Space", " ", KeyType.SPACE, weight = 3f),
                KeyboardKey("Left", "", KeyType.CURSOR_LEFT, weight = 1f),
                KeyboardKey("Right", "", KeyType.CURSOR_RIGHT, weight = 1f),
                KeyboardKey("Enter", "\n", KeyType.ENTER, weight = 1.4f, accent = true),
            ),
        )
    }

    private fun buildEmojiRows(): List<List<KeyboardKey>> {
        return listOf(
            listOf("\uD83D\uDE00", "\uD83D\uDE02", "\uD83D\uDE0D", "\uD83D\uDE4F", "\uD83D\uDD25", "\uD83D\uDC4D", "\uD83C\uDF89", "\uD83E\uDD14", "\uD83D\uDE2D", "\u2764\uFE0F").map(::emojiKey),
            listOf("\uD83D\uDE0A", "\uD83D\uDE01", "\uD83D\uDE0E", "\uD83D\uDC4F", "\uD83D\uDE4C", "\uD83D\uDCAF", "\u2728", "\uD83D\uDE05", "\uD83D\uDE34", "\uD83E\uDD73").map(::emojiKey),
            listOf(
                KeyboardKey("ABC", "", KeyType.CLOSE_PANEL, weight = 1.4f, accent = true),
            ) +
                listOf("\uD83D\uDE42", "\uD83D\uDE07", "\uD83D\uDE2C", "\uD83D\uDE24", "\uD83E\uDD1D", "\uD83E\uDD29", "\uD83D\uDE0C").map(::emojiKey) +
                listOf(
                    KeyboardKey("Del", "", KeyType.DELETE, weight = 1.4f),
                ),
            listOf(
                KeyboardKey("123", "", KeyType.MODE_SWITCH, weight = 1.3f),
                KeyboardKey("Clip", "", KeyType.CLIPBOARD, weight = 1.1f),
                KeyboardKey("Space", " ", KeyType.SPACE, weight = 3f),
                KeyboardKey("Left", "", KeyType.CURSOR_LEFT, weight = 1f),
                KeyboardKey("Right", "", KeyType.CURSOR_RIGHT, weight = 1f),
                KeyboardKey("Enter", "\n", KeyType.ENTER, weight = 1.4f, accent = true),
            ),
        )
    }

    private fun charKey(value: String): KeyboardKey {
        return KeyboardKey(
            label = value,
            value = value,
            type = KeyType.CHARACTER,
        )
    }

    private fun emojiKey(value: String): KeyboardKey {
        return KeyboardKey(
            label = value,
            value = value,
            type = KeyType.CHARACTER,
        )
    }

    private fun shiftLabel(shiftState: ShiftState): String {
        return when (shiftState) {
            ShiftState.OFF -> "Shift"
            ShiftState.SINGLE -> "Shift*"
            ShiftState.CAPS_LOCK -> "Caps"
        }
    }
}
