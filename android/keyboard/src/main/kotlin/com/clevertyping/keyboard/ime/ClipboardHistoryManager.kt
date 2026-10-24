package com.clevertyping.keyboard.ime

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context

class ClipboardHistoryManager(context: Context) {
    private val clipboardManager =
        context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    private val history = ArrayDeque<String>()

    fun start() {
        clipboardManager.addPrimaryClipChangedListener {
            val clip = clipboardManager.primaryClip ?: return@addPrimaryClipChangedListener
            val text = clip.getItemAt(0).coerceToText(null)?.toString()?.trim().orEmpty()
            if (text.isBlank()) {
                return@addPrimaryClipChangedListener
            }
            history.remove(text)
            history.addFirst(text)
            while (history.size > 5) {
                history.removeLast()
            }
        }
    }

    fun currentEntries(): List<String> {
        val liveText = clipboardManager.primaryClip
            ?.getItemAt(0)
            ?.coerceToText(null)
            ?.toString()
            ?.trim()
            .orEmpty()
        if (liveText.isNotBlank() && !history.contains(liveText)) {
            history.addFirst(liveText)
        }
        while (history.size > 5) {
            history.removeLast()
        }
        return history.toList()
    }

    fun copyToClipboard(text: String) {
        clipboardManager.setPrimaryClip(ClipData.newPlainText("clever_typing", text))
    }
}
