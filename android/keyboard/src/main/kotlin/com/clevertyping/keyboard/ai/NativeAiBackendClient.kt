package com.clevertyping.keyboard.ai

import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

/**
 * Small native HTTP client used by the IME so keyboard actions can call
 * the same live AI backend as the Flutter host app.
 */
class NativeAiBackendClient(
    private val baseUrl: String,
    private val apiKey: String,
) {
    data class NativeTranslationResult(
        val translatedText: String,
        val detectedSourceLanguage: String?,
    )

    data class NativeWritingToolResult(
        val outputText: String,
        val summaryBullets: List<String>,
    )

    fun correctGrammar(text: String): String {
        val payload =
            JSONObject()
                .put("text", text)

        val response = postJson("/v1/keyboard/grammar-correct", payload)
        return response.optString("correctedText")
    }

    fun translate(
        text: String,
        sourceLanguage: String,
        targetLanguage: String,
        preserveTone: Boolean,
    ): NativeTranslationResult {
        val payload =
            JSONObject()
                .put("text", text)
                .put("sourceLanguage", sourceLanguage)
                .put("targetLanguage", targetLanguage)
                .put("preserveTone", preserveTone)

        val response = postJson("/v1/keyboard/translate", payload)
        return NativeTranslationResult(
            translatedText = response.optString("translatedText"),
            detectedSourceLanguage =
                response.optString("detectedSourceLanguage").ifBlank { null },
        )
    }

    fun generateReplies(
        conversationContext: String,
        variant: String,
    ): List<String> {
        val payload =
            JSONObject()
                .put("conversationContext", conversationContext)
                .put("variant", variant)

        val response = postJson("/v1/keyboard/smart-reply", payload)
        val replies = response.optJSONArray("replies") ?: JSONArray()
        return List(replies.length()) { index -> replies.optString(index) }
            .filter { it.isNotBlank() }
    }

    fun executeWritingTool(
        tool: String,
        text: String,
        tone: String? = null,
        preserveTone: Boolean = true,
    ): NativeWritingToolResult {
        val payload =
            JSONObject()
                .put("tool", tool)
                .put("text", text)
                .put("preserveTone", preserveTone)
                .apply {
                    if (!tone.isNullOrBlank()) {
                        put("tone", tone)
                    }
                }

        val response = postJson("/v1/keyboard/rewrite", payload)
        val summaryBullets = response.optJSONArray("summaryBullets") ?: JSONArray()
        return NativeWritingToolResult(
            outputText = response.optString("outputText"),
            summaryBullets =
                List(summaryBullets.length()) { index -> summaryBullets.optString(index) }
                    .filter { it.isNotBlank() },
        )
    }

    fun executeAssistant(
        assistantId: String,
        userText: String,
    ): String {
        val payload =
            JSONObject()
                .put("assistantId", assistantId)
                .put("userText", userText)

        val response = postJson("/v1/keyboard/assistant-execute", payload)
        return response.optString("outputText")
    }

    private fun postJson(path: String, payload: JSONObject): JSONObject {
        val connection = (URL("$baseUrl$path").openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            connectTimeout = 10000
            readTimeout = 10000
            doInput = true
            doOutput = true
            setRequestProperty("Content-Type", "application/json")
            setRequestProperty("Authorization", "Bearer $apiKey")
        }

        try {
            OutputStreamWriter(connection.outputStream).use { writer ->
                writer.write(payload.toString())
                writer.flush()
            }

            val stream =
                if (connection.responseCode in 200..299) {
                    connection.inputStream
                } else {
                    connection.errorStream ?: connection.inputStream
                }

            val responseText =
                BufferedReader(InputStreamReader(stream)).use { reader ->
                    buildString {
                        var line: String?
                        while (reader.readLine().also { line = it } != null) {
                            append(line)
                        }
                    }
                }

            if (connection.responseCode !in 200..299) {
                throw IllegalStateException(
                    if (responseText.isBlank()) {
                        "AI request failed with status ${connection.responseCode}"
                    } else {
                        responseText
                    },
                )
            }

            return JSONObject(responseText)
        } finally {
            connection.disconnect()
        }
    }
}
