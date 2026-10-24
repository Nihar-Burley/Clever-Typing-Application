package com.clevertyping.keyboard.ime

enum class KeyboardMode {
    LETTERS,
    NUMBERS,
    SYMBOLS,
    EMOJI,
}

enum class ShiftState {
    OFF,
    SINGLE,
    CAPS_LOCK,
}

enum class ThemePalette {
    SUNRISE,
    FOREST,
    NIGHT,
}

enum class KeyType {
    CHARACTER,
    SPACE,
    DELETE,
    ENTER,
    SHIFT,
    MODE_SWITCH,
    CURSOR_LEFT,
    CURSOR_RIGHT,
    CLIPBOARD,
    AI_GRAMMAR,
    AI_TRANSLATE,
    AI_SMART_REPLY,
    AI_REWRITE,
    AI_PARAPHRASE,
    AI_SUMMARIZE,
    AI_EMAIL,
    AI_CAPTION,
    AI_ASSIST,
    EMOJI,
    CLOSE_PANEL,
}

data class KeyboardKey(
    val label: String,
    val value: String,
    val type: KeyType,
    val weight: Float = 1f,
    val accent: Boolean = false,
)
