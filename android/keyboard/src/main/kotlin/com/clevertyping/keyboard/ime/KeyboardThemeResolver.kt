package com.clevertyping.keyboard.ime

import android.graphics.Color
import android.content.SharedPreferences

class KeyboardThemeResolver {
    fun resolve(preferences: SharedPreferences): KeyboardTheme {
        return when (readPalette(preferences)) {
            ThemePalette.FOREST ->
                KeyboardTheme(
                    backgroundColor = Color.parseColor("#EEF6ED"),
                    panelColor = Color.parseColor("#D9EAD7"),
                    keyColor = Color.WHITE,
                    accentColor = Color.parseColor("#3A7D44"),
                    accentTextColor = Color.WHITE,
                    keyTextColor = Color.parseColor("#183A1D"),
                    subtleTextColor = Color.parseColor("#426348"),
                )

            ThemePalette.NIGHT ->
                KeyboardTheme(
                    backgroundColor = Color.parseColor("#15202B"),
                    panelColor = Color.parseColor("#243447"),
                    keyColor = Color.parseColor("#33485C"),
                    accentColor = Color.parseColor("#1DA1F2"),
                    accentTextColor = Color.WHITE,
                    keyTextColor = Color.WHITE,
                    subtleTextColor = Color.parseColor("#D9E1E8"),
                )

            ThemePalette.SUNRISE ->
                KeyboardTheme(
                    backgroundColor = Color.parseColor("#FFF7EB"),
                    panelColor = Color.parseColor("#FDEBD2"),
                    keyColor = Color.WHITE,
                    accentColor = Color.parseColor("#0D5C63"),
                    accentTextColor = Color.WHITE,
                    keyTextColor = Color.parseColor("#243447"),
                    subtleTextColor = Color.parseColor("#5F6B77"),
                )
        }
    }

    private fun readPalette(preferences: SharedPreferences): ThemePalette {
        return when (preferences.getString("themePalette", "sunrise")) {
            "forest" -> ThemePalette.FOREST
            "night" -> ThemePalette.NIGHT
            else -> ThemePalette.SUNRISE
        }
    }
}
