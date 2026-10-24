package com.clevertyping.app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * Captures the latest visible conversation text after explicit user opt-in so
 * smart reply can seed context from supported messaging surfaces.
 */
class NativeConversationCaptureService : AccessibilityService() {
    override fun onServiceConnected() {
        super.onServiceConnected()
        setLatestContext("")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val safeEvent = event ?: return
        if (safeEvent.packageName == packageName) {
            return
        }

        val eventText =
            safeEvent.text
                ?.map { it?.toString().orEmpty().trim() }
                ?.filter { it.isNotBlank() }
                .orEmpty()

        val sourceText = buildContextPayload(eventText, safeEvent.source) ?: return
        if (sourceText.length < MIN_CONTEXT_LENGTH) {
            return
        }

        setLatestContext(sourceText.takeLast(MAX_CONTEXT_LENGTH))
    }

    override fun onInterrupt() = Unit

    private fun buildContextPayload(
        eventText: List<String>,
        source: AccessibilityNodeInfo?,
    ): String? {
        if (eventText.isNotEmpty()) {
            return eventText.joinToString(separator = "\n")
        }

        val root = rootInActiveWindow ?: source ?: return null
        val collected = mutableListOf<String>()
        collectNodeText(root, collected)
        return collected
            .distinct()
            .joinToString(separator = "\n")
            .trim()
            .ifBlank { null }
    }

    private fun collectNodeText(
        node: AccessibilityNodeInfo,
        output: MutableList<String>,
    ) {
        val text = node.text?.toString()?.trim().orEmpty()
        if (text.isNotBlank()) {
            output += text
        }

        val contentDescription = node.contentDescription?.toString()?.trim().orEmpty()
        if (contentDescription.isNotBlank()) {
            output += contentDescription
        }

        for (index in 0 until node.childCount) {
            node.getChild(index)?.let { child ->
                collectNodeText(child, output)
            }
        }
    }

    private fun setLatestContext(value: String) {
        getSharedPreferences(PREFERENCES_NAME, MODE_PRIVATE)
            .edit()
            .putString(LATEST_CONVERSATION_CONTEXT_KEY, value)
            .apply()
    }

    companion object {
        private const val PREFERENCES_NAME = "clever_keyboard_preferences"
        private const val LATEST_CONVERSATION_CONTEXT_KEY = "latestConversationContext"
        private const val MIN_CONTEXT_LENGTH = 12
        private const val MAX_CONTEXT_LENGTH = 1200
    }
}
