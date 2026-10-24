package com.clevertyping.keyboard.ime

data class KeyboardPreferences(
    val autoCapitalizationEnabled: Boolean,
    val autoSpaceEnabled: Boolean,
    val hapticFeedbackEnabled: Boolean,
    val soundFeedbackEnabled: Boolean,
    val oneHandedModeEnabled: Boolean,
    val keyboardHeightScale: Float,
    val themePalette: ThemePalette,
    val primaryLanguage: String,
    val secondaryLanguage: String,
    val incognitoModeEnabled: Boolean,
)
