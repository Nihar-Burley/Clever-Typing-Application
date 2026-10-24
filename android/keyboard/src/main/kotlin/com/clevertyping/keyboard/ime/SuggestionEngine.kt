package com.clevertyping.keyboard.ime

class SuggestionEngine {
    private val dictionary = listOf(
        "hello", "thanks", "thank", "there", "their", "tomorrow", "today",
        "please", "meeting", "message", "translate", "grammar", "keyboard",
        "application", "android", "feature", "update", "project", "great",
        "awesome", "polish", "professional", "friend", "friendly", "schedule",
        "because", "before", "after", "receive", "received", "available",
        "support", "compete", "clever", "typing", "application", "service",
        "reply", "response", "settings", "design", "launch", "premium",
    )

    private val nextWordMap = mapOf(
        "hello" to listOf("there", "team", "everyone"),
        "thank" to listOf("you", "them", "everyone"),
        "thanks" to listOf("for", "again", "team"),
        "see" to listOf("you", "the", "this"),
        "good" to listOf("morning", "luck", "work"),
        "looking" to listOf("forward", "into", "good"),
        "let" to listOf("me", "us", "them"),
        "please" to listOf("review", "share", "confirm"),
    )

    fun suggestionsFor(composingWord: String, previousWord: String?): List<String> {
        if (composingWord.isNotBlank()) {
            val normalized = composingWord.lowercase()
            val corrections = dictionary
                .filter { it.startsWith(normalized.take(1)) }
                .sortedBy { levenshtein(normalized, it) }
                .take(3)
            return corrections.ifEmpty { listOf(normalized) }
        }

        val fromPrevious = previousWord
            ?.lowercase()
            ?.let { nextWordMap[it] }
            ?.take(3)
            .orEmpty()
        return if (fromPrevious.isNotEmpty()) {
            fromPrevious
        } else {
            listOf("the", "and", "to")
        }
    }

    fun autocorrect(word: String): String {
        if (word.isBlank()) {
            return word
        }
        val normalized = word.lowercase()
        val best = dictionary.minByOrNull { levenshtein(normalized, it) } ?: return word
        val distance = levenshtein(normalized, best)
        if (distance > 2) {
            return word
        }
        return if (word.firstOrNull()?.isUpperCase() == true) {
            best.replaceFirstChar { it.uppercase() }
        } else {
            best
        }
    }

    fun swipeSuggestion(trace: List<String>): String? {
        if (trace.size < 2) {
            return null
        }
        val condensed = trace.fold(StringBuilder()) { acc, value ->
            if (acc.isEmpty() || acc.last().toString() != value.lowercase()) {
                acc.append(value.lowercase())
            }
            acc
        }.toString()
        return dictionary
            .filter { it.firstOrNull() == condensed.firstOrNull() }
            .minByOrNull { levenshtein(condensed, it) }
    }

    private fun levenshtein(left: String, right: String): Int {
        val matrix = Array(left.length + 1) { IntArray(right.length + 1) }
        for (i in 0..left.length) {
            matrix[i][0] = i
        }
        for (j in 0..right.length) {
            matrix[0][j] = j
        }
        for (i in 1..left.length) {
            for (j in 1..right.length) {
                val cost = if (left[i - 1] == right[j - 1]) 0 else 1
                matrix[i][j] = minOf(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost,
                )
            }
        }
        return matrix[left.length][right.length]
    }
}
