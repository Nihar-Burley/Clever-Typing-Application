package com.clevertyping.keyboard.ime

data class KeyboardState(
    val mode: KeyboardMode = KeyboardMode.LETTERS,
    val shiftState: ShiftState = ShiftState.SINGLE,
    val clipboardVisible: Boolean = false,
    val smartRepliesVisible: Boolean = false,
    val suggestions: List<String> = emptyList(),
    val smartReplies: List<String> = emptyList(),
    val composingWord: String = "",
    val status: String = "Native IME connected",
)
