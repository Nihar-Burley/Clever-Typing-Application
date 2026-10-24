package com.clevertyping.keyboard.ime

import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.inputmethodservice.InputMethodService
import android.media.AudioManager
import android.os.Handler
import android.os.Looper
import android.os.Vibrator
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.text.InputType
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.ExtractedTextRequest
import android.widget.Button
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.TextView
import com.clevertyping.keyboard.R
import com.clevertyping.keyboard.ai.NativeAiBackendClient

class CleverKeyboardService : InputMethodService() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val layoutFactory = KeyboardLayoutFactory()
    private val suggestionEngine = SuggestionEngine()
    private val themeResolver = KeyboardThemeResolver()
    private lateinit var clipboardHistoryManager: ClipboardHistoryManager

    private lateinit var rootView: LinearLayout
    private lateinit var headerPanel: LinearLayout
    private lateinit var titleView: TextView
    private lateinit var statusView: TextView
    private lateinit var suggestionRow: LinearLayout
    private lateinit var clipboardScroll: HorizontalScrollView
    private lateinit var clipboardRow: LinearLayout
    private lateinit var replyScroll: HorizontalScrollView
    private lateinit var replyRow: LinearLayout
    private lateinit var composingPreview: TextView
    private lateinit var keyRowsContainer: LinearLayout

    private var keyboardState = KeyboardState()
    private var keyboardPreferences = KeyboardPreferences(
        autoCapitalizationEnabled = true,
        autoSpaceEnabled = true,
        hapticFeedbackEnabled = true,
        soundFeedbackEnabled = false,
        oneHandedModeEnabled = false,
        keyboardHeightScale = 1.0f,
        themePalette = ThemePalette.SUNRISE,
        primaryLanguage = "English",
        secondaryLanguage = "Hindi",
        incognitoModeEnabled = false,
    )
    private var activeTheme = KeyboardTheme(
        backgroundColor = 0,
        panelColor = 0,
        keyColor = 0,
        accentColor = 0,
        accentTextColor = 0,
        keyTextColor = 0,
        subtleTextColor = 0,
    )

    private var lastShiftTapAt = 0L
    private val swipeTrace = mutableListOf<String>()
    private var lastSwipeLabel: String? = null

    override fun onCreate() {
        super.onCreate()
        clipboardHistoryManager = ClipboardHistoryManager(this)
        clipboardHistoryManager.start()
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        loadPreferences()
        if (keyboardPreferences.autoCapitalizationEnabled) {
            keyboardState = keyboardState.copy(shiftState = ShiftState.SINGLE)
        }
        updateSuggestions()
        if (::rootView.isInitialized) {
            renderAll()
        }
    }

    override fun onCreateInputView(): View {
        rootView = LayoutInflater.from(this).inflate(R.layout.keyboard_view, null) as LinearLayout
        headerPanel = rootView.findViewById(R.id.header_panel)
        titleView = rootView.findViewById(R.id.keyboard_title)
        statusView = rootView.findViewById(R.id.keyboard_status)
        suggestionRow = rootView.findViewById(R.id.suggestion_row)
        clipboardScroll = rootView.findViewById(R.id.clipboard_scroll)
        clipboardRow = rootView.findViewById(R.id.clipboard_row)
        replyScroll = rootView.findViewById(R.id.reply_scroll)
        replyRow = rootView.findViewById(R.id.reply_row)
        composingPreview = rootView.findViewById(R.id.composing_preview)
        keyRowsContainer = rootView.findViewById(R.id.key_rows_container)

        loadPreferences()
        updateSuggestions()
        renderAll()
        return rootView
    }

    private fun loadPreferences() {
        val preferences = getSharedPreferences(PREFERENCES_NAME, MODE_PRIVATE)
        keyboardPreferences = KeyboardPreferences(
            autoCapitalizationEnabled = preferences.getBoolean("autoCapitalizationEnabled", true),
            autoSpaceEnabled = preferences.getBoolean("autoSpaceEnabled", true),
            hapticFeedbackEnabled = preferences.getBoolean("hapticFeedbackEnabled", true),
            soundFeedbackEnabled = preferences.getBoolean("soundFeedbackEnabled", false),
            oneHandedModeEnabled = preferences.getBoolean("oneHandedModeEnabled", false),
            keyboardHeightScale = preferences.getFloat("keyboardHeight", 1.0f),
            themePalette = when (preferences.getString("themePalette", "sunrise")) {
                "forest" -> ThemePalette.FOREST
                "night" -> ThemePalette.NIGHT
                else -> ThemePalette.SUNRISE
            },
            primaryLanguage = preferences.getString("primaryLanguage", "English").orEmpty(),
            secondaryLanguage = preferences.getString("secondaryLanguage", "Hindi").orEmpty(),
            incognitoModeEnabled = preferences.getBoolean("incognitoModeEnabled", false),
        )
        activeTheme = themeResolver.resolve(preferences)
        if (::rootView.isInitialized) {
            rootView.layoutParams =
                ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    (resources.displayMetrics.density * 360 * keyboardPreferences.keyboardHeightScale)
                        .toInt(),
                )
        }
    }

    private fun renderAll() {
        applyTheme()
        renderHeader()
        renderSuggestions()
        renderClipboard()
        renderReplies()
        renderKeys()
    }

    private fun applyTheme() {
        rootView.setBackgroundColor(activeTheme.backgroundColor)
        headerPanel.background = roundedDrawable(activeTheme.panelColor)
        titleView.setTextColor(activeTheme.accentColor)
        statusView.setTextColor(activeTheme.subtleTextColor)
        composingPreview.setTextColor(activeTheme.subtleTextColor)
    }

    private fun renderHeader() {
        val baseStatus = if (keyboardPreferences.oneHandedModeEnabled) {
            "One-handed layout active"
        } else {
            "Native IME connected"
        }
        statusView.text =
            if (keyboardState.status == "Native IME connected") {
                baseStatus
            } else {
                keyboardState.status
            }
        composingPreview.text =
            when {
                keyboardState.smartRepliesVisible && keyboardState.smartReplies.isNotEmpty() ->
                    "Reply suggestions ready - tap a chip to insert"
                keyboardPreferences.incognitoModeEnabled ->
                    "Incognito mode active - local history and capture are minimized"
                keyboardState.composingWord.isBlank() ->
                    "Languages: ${keyboardPreferences.primaryLanguage} / ${keyboardPreferences.secondaryLanguage}"
                else -> "Composing: ${keyboardState.composingWord}"
            }
    }

    private fun renderSuggestions() {
        suggestionRow.removeAllViews()
        keyboardState.suggestions.forEach { suggestion ->
            suggestionRow.addView(
                buildChip(
                    label = suggestion,
                    accent = false,
                ) {
                    applySuggestion(suggestion)
                },
            )
        }
    }

    private fun renderClipboard() {
        clipboardRow.removeAllViews()
        if (!keyboardState.clipboardVisible) {
            clipboardScroll.visibility = View.GONE
            return
        }
        clipboardScroll.visibility = View.VISIBLE
        clipboardRow.addView(
            buildChip(
                label = "Close",
                accent = true,
            ) {
                keyboardState = keyboardState.copy(clipboardVisible = false)
                renderClipboard()
            },
        )
        clipboardHistoryManager.currentEntries().forEach { entry ->
            clipboardRow.addView(
                buildChip(
                    label = entry.take(20),
                    accent = false,
                ) {
                    commitText(entry, allowAutoSpace = true)
                    keyboardState = keyboardState.copy(clipboardVisible = false)
                    renderClipboard()
                },
            )
        }
    }

    private fun renderReplies() {
        replyRow.removeAllViews()
        if (!keyboardState.smartRepliesVisible || keyboardState.smartReplies.isEmpty()) {
            replyScroll.visibility = View.GONE
            return
        }

        replyScroll.visibility = View.VISIBLE
        replyRow.addView(
            buildChip(
                label = "Close",
                accent = true,
            ) {
                keyboardState = keyboardState.copy(
                    smartRepliesVisible = false,
                    smartReplies = emptyList(),
                )
                renderHeader()
                renderReplies()
            },
        )
        keyboardState.smartReplies.forEach { reply ->
            replyRow.addView(
                buildChip(
                    label = reply.take(42),
                    accent = false,
                ) {
                    currentInputConnection?.commitText(reply, 1)
                    keyboardState = keyboardState.copy(
                        smartRepliesVisible = false,
                        smartReplies = emptyList(),
                        status = "Reply inserted",
                    )
                    renderHeader()
                    renderReplies()
                },
            )
        }
    }

    private fun renderKeys() {
        keyRowsContainer.removeAllViews()
        val rows = layoutFactory.buildRows(keyboardState.mode, keyboardState.shiftState)
        rows.forEachIndexed { index, row ->
            val rowLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams =
                    LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.MATCH_PARENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                    ).apply {
                        topMargin = if (index == 0) 0 else dp(6)
                    }
                gravity =
                    if (keyboardPreferences.oneHandedModeEnabled) {
                        Gravity.END
                    } else {
                        Gravity.CENTER_HORIZONTAL
                    }
                if (keyboardPreferences.oneHandedModeEnabled) {
                    setPadding(dp(56), 0, 0, 0)
                }
            }
            row.forEach { key ->
                rowLayout.addView(buildKeyButton(key))
            }
            keyRowsContainer.addView(rowLayout)
        }
    }

    private fun buildKeyButton(key: KeyboardKey): Button {
        return Button(this).apply {
            text = key.label
            isAllCaps = false
            typeface = Typeface.DEFAULT_BOLD
            textSize = if (key.label.length > 6) 11f else 14f
            setTextColor(if (key.accent) activeTheme.accentTextColor else activeTheme.keyTextColor)
            background = roundedDrawable(if (key.accent) activeTheme.accentColor else activeTheme.keyColor)
            layoutParams =
                LinearLayout.LayoutParams(0, dp(44), key.weight).apply {
                    marginEnd = dp(4)
                }
            setPadding(dp(4), 0, dp(4), 0)
            if (key.type == KeyType.CHARACTER && key.value.length == 1 && key.value[0].isLetter()) {
                setOnTouchListener { _, event -> handleLetterTouch(key, event) }
            } else {
                setOnClickListener { handleKeyPress(key) }
            }
        }
    }

    private fun handleKeyPress(key: KeyboardKey) {
        when (key.type) {
            KeyType.CHARACTER -> {
                commitText(key.value, allowAutoSpace = false)
                updateComposingWordAfterCharacter(key.value)
                maybeResetShiftAfterCharacter()
            }
            KeyType.SPACE -> handleSpacePress()
            KeyType.DELETE -> handleDeletePress()
            KeyType.ENTER -> {
                currentInputConnection?.commitText(key.value, 1)
                keyboardState = keyboardState.copy(composingWord = "")
                updateSuggestions()
            }
            KeyType.SHIFT -> cycleShiftState()
            KeyType.MODE_SWITCH -> switchMode()
            KeyType.CURSOR_LEFT -> moveCursor(-1)
            KeyType.CURSOR_RIGHT -> moveCursor(1)
            KeyType.CLIPBOARD -> {
                keyboardState = keyboardState.copy(clipboardVisible = !keyboardState.clipboardVisible)
                renderClipboard()
            }
            KeyType.AI_GRAMMAR -> runGrammarCorrection()
            KeyType.AI_TRANSLATE -> runTranslation()
            KeyType.AI_SMART_REPLY -> runSmartReply()
            KeyType.AI_REWRITE -> runWritingTool(
                tool = "tone_rewrite",
                tone = "professional",
                startedStatus = "Running tone rewrite...",
                successStatus = "Tone rewrite applied",
                failureStatus = "Tone rewrite failed",
            )
            KeyType.AI_PARAPHRASE -> runWritingTool(
                tool = "paraphrase",
                startedStatus = "Running paraphrase...",
                successStatus = "Paraphrase applied",
                failureStatus = "Paraphrase failed",
            )
            KeyType.AI_SUMMARIZE -> runWritingTool(
                tool = "summarize",
                startedStatus = "Running summarization...",
                successStatus = "Summary inserted",
                failureStatus = "Summarization failed",
            )
            KeyType.AI_EMAIL -> runWritingTool(
                tool = "email_draft",
                tone = "professional",
                startedStatus = "Drafting email...",
                successStatus = "Email draft inserted",
                failureStatus = "Email draft failed",
            )
            KeyType.AI_CAPTION -> runWritingTool(
                tool = "caption_generation",
                startedStatus = "Generating caption...",
                successStatus = "Caption inserted",
                failureStatus = "Caption generation failed",
            )
            KeyType.AI_ASSIST -> runAssistant()
            KeyType.EMOJI -> {
                keyboardState = keyboardState.copy(mode = KeyboardMode.EMOJI)
                renderKeys()
            }
            KeyType.CLOSE_PANEL -> {
                keyboardState = keyboardState.copy(mode = KeyboardMode.LETTERS)
                renderKeys()
            }
        }
    }

    private fun handleSpacePress() {
        val originalWord = keyboardState.composingWord
        val correctedWord =
            if (originalWord.isNotBlank()) {
                suggestionEngine.autocorrect(originalWord)
            } else {
                ""
            }
        if (correctedWord.isNotBlank() && correctedWord != originalWord) {
            currentInputConnection?.deleteSurroundingText(originalWord.length, 0)
            currentInputConnection?.commitText(correctedWord, 1)
        }
        commitText(" ", allowAutoSpace = false)
        keyboardState = keyboardState.copy(composingWord = "")
        if (keyboardPreferences.autoCapitalizationEnabled) {
            keyboardState = keyboardState.copy(shiftState = ShiftState.SINGLE, mode = KeyboardMode.LETTERS)
        }
        updateSuggestions(previousWord = if (correctedWord.isNotBlank()) correctedWord else originalWord)
        renderKeys()
    }

    private fun handleDeletePress() {
        vibrateIfEnabled()
        currentInputConnection?.deleteSurroundingText(1, 0)
        if (keyboardState.composingWord.isNotBlank()) {
            keyboardState = keyboardState.copy(composingWord = keyboardState.composingWord.dropLast(1))
        }
        updateSuggestions()
    }

    private fun cycleShiftState() {
        val now = System.currentTimeMillis()
        val nextState =
            if (now - lastShiftTapAt < SHIFT_DOUBLE_TAP_MS) {
                ShiftState.CAPS_LOCK
            } else {
                when (keyboardState.shiftState) {
                    ShiftState.OFF -> ShiftState.SINGLE
                    ShiftState.SINGLE -> ShiftState.OFF
                    ShiftState.CAPS_LOCK -> ShiftState.OFF
                }
            }
        lastShiftTapAt = now
        keyboardState = keyboardState.copy(shiftState = nextState, mode = KeyboardMode.LETTERS)
        renderKeys()
    }

    private fun switchMode() {
        keyboardState =
            keyboardState.copy(
                mode = when (keyboardState.mode) {
                    KeyboardMode.LETTERS -> KeyboardMode.NUMBERS
                    KeyboardMode.NUMBERS -> KeyboardMode.SYMBOLS
                    KeyboardMode.SYMBOLS -> KeyboardMode.LETTERS
                    KeyboardMode.EMOJI -> KeyboardMode.LETTERS
                },
                clipboardVisible = false,
                smartRepliesVisible = false,
            )
        renderKeys()
        renderClipboard()
        renderReplies()
    }

    private fun handleLetterTouch(key: KeyboardKey, event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                swipeTrace.clear()
                swipeTrace.add(key.value.lowercase())
                lastSwipeLabel = key.value.lowercase()
                return true
            }
            MotionEvent.ACTION_MOVE -> {
                val current = key.value.lowercase()
                if (lastSwipeLabel != current) {
                    swipeTrace.add(current)
                    lastSwipeLabel = current
                }
                return true
            }
            MotionEvent.ACTION_UP -> {
                if (swipeTrace.size >= 3) {
                    val suggestion = suggestionEngine.swipeSuggestion(swipeTrace)
                    if (!suggestion.isNullOrBlank()) {
                        currentInputConnection?.commitText("$suggestion ", 1)
                        keyboardState = keyboardState.copy(composingWord = "")
                        updateSuggestions(previousWord = suggestion)
                    } else {
                        handleKeyPress(key)
                    }
                } else {
                    handleKeyPress(key)
                }
                swipeTrace.clear()
                lastSwipeLabel = null
                return true
            }
            MotionEvent.ACTION_CANCEL -> {
                swipeTrace.clear()
                lastSwipeLabel = null
                return true
            }
        }
        return false
    }

    private fun updateComposingWordAfterCharacter(value: String) {
        if (value.length != 1 || !value[0].isLetter()) {
            return
        }
        keyboardState = keyboardState.copy(composingWord = keyboardState.composingWord + value)
        updateSuggestions()
    }

    private fun maybeResetShiftAfterCharacter() {
        if (keyboardState.shiftState == ShiftState.SINGLE) {
            keyboardState = keyboardState.copy(shiftState = ShiftState.OFF, mode = KeyboardMode.LETTERS)
            renderKeys()
        }
    }

    private fun updateSuggestions(previousWord: String? = null) {
        val contextPreviousWord = previousWord ?: readPreviousWord()
        keyboardState =
            keyboardState.copy(
                suggestions = suggestionEngine.suggestionsFor(
                    keyboardState.composingWord,
                    contextPreviousWord,
                ),
            )
        if (::rootView.isInitialized) {
            renderHeader()
            renderSuggestions()
        }
    }

    private fun applySuggestion(suggestion: String) {
        if (keyboardState.composingWord.isNotBlank()) {
            currentInputConnection?.deleteSurroundingText(keyboardState.composingWord.length, 0)
        }
        commitText(suggestion, allowAutoSpace = keyboardPreferences.autoSpaceEnabled)
        keyboardState = keyboardState.copy(composingWord = "")
        if (keyboardPreferences.autoCapitalizationEnabled) {
            keyboardState = keyboardState.copy(shiftState = ShiftState.SINGLE, mode = KeyboardMode.LETTERS)
        }
        updateSuggestions(previousWord = suggestion)
        renderKeys()
    }

    private fun readPreviousWord(): String? {
        val beforeCursor = currentInputConnection?.getTextBeforeCursor(40, 0)?.toString().orEmpty()
        return beforeCursor.trim().split(" ").lastOrNull()?.lowercase()
    }

    private fun commitText(value: String, allowAutoSpace: Boolean) {
        vibrateIfEnabled()
        playClickIfEnabled()
        currentInputConnection?.commitText(value, 1)
        if (allowAutoSpace) {
            currentInputConnection?.commitText(" ", 1)
        }
    }

    private fun moveCursor(delta: Int) {
        val extractedText = currentInputConnection?.getExtractedText(ExtractedTextRequest(), 0) ?: return
        val selection = (extractedText.selectionStart + delta).coerceAtLeast(0)
        currentInputConnection?.setSelection(selection, selection)
    }

    private fun runGrammarCorrection() {
        if (!ensureAiAllowed()) {
            return
        }
        val selection = readTransformTarget() ?: run {
            setStatus("Select text or place the cursor near the text to correct")
            return
        }
        val client = createBackendClientOrNull() ?: return
        setStatus("Running grammar correction...")
        incrementCounter("nativeAiExecutions")
        Thread {
            try {
                val correctedText = client.correctGrammar(selection.text)
                mainHandler.post {
                    applyGeneratedText(correctedText, selection.replaceSelection)
                    setStatus("Grammar correction applied")
                }
            } catch (_: Exception) {
                incrementCounter("nativeAiFailures")
                mainHandler.post { setStatus("Grammar correction failed") }
            }
        }.start()
    }

    private fun runTranslation() {
        if (!ensureAiAllowed()) {
            return
        }
        val selection = readTransformTarget() ?: run {
            setStatus("Select text or place the cursor near the text to translate")
            return
        }
        val client = createBackendClientOrNull() ?: return
        setStatus("Running translation...")
        incrementCounter("nativeAiExecutions")
        Thread {
            try {
                val translated = client.translate(
                    text = selection.text,
                    sourceLanguage = AUTO_SOURCE_LANGUAGE,
                    targetLanguage = keyboardPreferences.secondaryLanguage,
                    preserveTone = true,
                )
                mainHandler.post {
                    applyGeneratedText(translated.translatedText, selection.replaceSelection)
                    setStatus(
                        translated.detectedSourceLanguage?.let {
                            "Translated from $it to ${keyboardPreferences.secondaryLanguage}"
                        } ?: "Translation applied",
                    )
                }
            } catch (_: Exception) {
                incrementCounter("nativeAiFailures")
                mainHandler.post { setStatus("Translation failed") }
            }
        }.start()
    }

    private fun runSmartReply() {
        if (!ensureAiAllowed()) {
            return
        }
        val client = createBackendClientOrNull() ?: return
        val context = readConversationContext()
        if (context.isBlank()) {
            setStatus("Enable capture or provide nearby conversation text first")
            return
        }
        setStatus("Generating smart replies...")
        incrementCounter("nativeAiExecutions")
        Thread {
            try {
                val replies = client.generateReplies(context, DEFAULT_REPLY_VARIANT)
                mainHandler.post {
                    keyboardState = keyboardState.copy(
                        smartRepliesVisible = replies.isNotEmpty(),
                        smartReplies = replies,
                        status =
                            if (replies.isNotEmpty()) {
                                "Smart replies ready"
                            } else {
                                "No reply variants returned"
                            },
                    )
                    renderHeader()
                    renderReplies()
                }
            } catch (_: Exception) {
                incrementCounter("nativeAiFailures")
                mainHandler.post { setStatus("Smart reply failed") }
            }
        }.start()
    }

    private fun runWritingTool(
        tool: String,
        tone: String? = null,
        startedStatus: String,
        successStatus: String,
        failureStatus: String,
    ) {
        if (!ensureAiAllowed()) {
            return
        }
        val selection = readTransformTarget() ?: run {
            setStatus("Select text or place the cursor near the text to transform")
            return
        }
        val client = createBackendClientOrNull() ?: return
        setStatus(startedStatus)
        incrementCounter("nativeAiExecutions")
        Thread {
            try {
                val result = client.executeWritingTool(
                    tool = tool,
                    text = selection.text,
                    tone = tone,
                )
                mainHandler.post {
                    applyGeneratedText(result.outputText, selection.replaceSelection)
                    setStatus(successStatus)
                }
            } catch (_: Exception) {
                incrementCounter("nativeAiFailures")
                mainHandler.post { setStatus(failureStatus) }
            }
        }.start()
    }

    private fun runAssistant() {
        if (!ensureAiAllowed()) {
            return
        }
        val selection = readTransformTarget() ?: run {
            setStatus("Select text or place the cursor near a message before running the assistant")
            return
        }
        val client = createBackendClientOrNull() ?: return
        setStatus("Running assistant...")
        incrementCounter("nativeAiExecutions")
        Thread {
            try {
                val output = client.executeAssistant(
                    assistantId = readPinnedAssistantId(),
                    userText = selection.text,
                )
                mainHandler.post {
                    applyGeneratedText(output, selection.replaceSelection)
                    setStatus("Assistant output inserted")
                }
            } catch (_: Exception) {
                incrementCounter("nativeAiFailures")
                mainHandler.post { setStatus("Assistant failed") }
            }
        }.start()
    }

    private fun readTransformTarget(): TransformTarget? {
        val selectedText = currentInputConnection?.getSelectedText(0)?.toString()?.trim().orEmpty()
        if (selectedText.isNotBlank()) {
            return TransformTarget(selectedText, replaceSelection = true)
        }

        val beforeCursor = currentInputConnection?.getTextBeforeCursor(180, 0)?.toString().orEmpty()
        val afterCursor = currentInputConnection?.getTextAfterCursor(60, 0)?.toString().orEmpty()
        val nearbyText = "$beforeCursor$afterCursor".trim()
        if (nearbyText.isBlank()) {
            return null
        }

        return TransformTarget(nearbyText.takeLast(180), replaceSelection = false)
    }

    private fun readConversationContext(): String {
        val preferences = getSharedPreferences(PREFERENCES_NAME, MODE_PRIVATE)
        val capturedContext = preferences.getString(LATEST_CONVERSATION_CONTEXT_KEY, "").orEmpty().trim()
        if (capturedContext.isNotBlank()) {
            return capturedContext
        }

        return readTransformTarget()?.text.orEmpty()
    }

    private fun applyGeneratedText(
        text: String,
        replaceSelection: Boolean,
    ) {
        if (text.isBlank()) {
            return
        }
        if (replaceSelection) {
            currentInputConnection?.commitText(text, 1)
        } else {
            currentInputConnection?.commitText(text, 1)
        }
        keyboardState = keyboardState.copy(
            composingWord = "",
            smartRepliesVisible = false,
            smartReplies = emptyList(),
        )
        updateSuggestions()
        renderReplies()
    }

    private fun createBackendClientOrNull(): NativeAiBackendClient? {
        val preferences = getSharedPreferences(PREFERENCES_NAME, MODE_PRIVATE)
        val baseUrl = preferences.getString("aiBaseUrl", "").orEmpty()
        val apiKey = preferences.getString("aiApiKey", "").orEmpty()
        if (baseUrl.isBlank() || apiKey.isBlank()) {
            setStatus("Backend not configured in host app")
            return null
        }
        return NativeAiBackendClient(baseUrl = baseUrl, apiKey = apiKey)
    }

    private fun readPinnedAssistantId(): String {
        return getSharedPreferences(PREFERENCES_NAME, MODE_PRIVATE)
            .getString("pinnedAssistantId", DEFAULT_ASSISTANT_ID)
            .orEmpty()
            .ifBlank { DEFAULT_ASSISTANT_ID }
    }

    private fun ensureAiAllowed(): Boolean {
        if (!isSensitiveField()) {
            return true
        }
        incrementCounter("blockedSensitiveActions")
        setStatus("AI actions are blocked in password, payment, and OTP fields")
        return false
    }

    private fun isSensitiveField(): Boolean {
        val info = currentInputEditorInfo ?: return false
        val variation = info.inputType and InputType.TYPE_MASK_VARIATION
        if (
            variation == InputType.TYPE_TEXT_VARIATION_PASSWORD ||
            variation == InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD ||
            variation == InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD ||
            variation == InputType.TYPE_NUMBER_VARIATION_PASSWORD
        ) {
            return true
        }

        val hintText = info.hintText?.toString()?.lowercase().orEmpty()
        return listOf("otp", "password", "passcode", "cvv", "card", "upi", "pin")
            .any(hintText::contains)
    }

    private fun incrementCounter(key: String) {
        getSharedPreferences(PREFERENCES_NAME, MODE_PRIVATE)
            .edit()
            .putInt(
                key,
                getSharedPreferences(PREFERENCES_NAME, MODE_PRIVATE).getInt(key, 0) + 1,
            )
            .apply()
    }

    private fun setStatus(message: String) {
        keyboardState = keyboardState.copy(status = message)
        if (::rootView.isInitialized) {
            renderHeader()
        }
    }

    private fun vibrateIfEnabled() {
        if (!keyboardPreferences.hapticFeedbackEnabled) {
            return
        }
        @Suppress("DEPRECATION")
        (getSystemService(VIBRATOR_SERVICE) as? Vibrator)?.vibrate(18)
    }

    private fun playClickIfEnabled() {
        if (!keyboardPreferences.soundFeedbackEnabled) {
            return
        }
        (getSystemService(AUDIO_SERVICE) as? AudioManager)?.playSoundEffect(AudioManager.FX_KEY_CLICK)
    }

    private fun buildChip(
        label: String,
        accent: Boolean,
        onTap: () -> Unit,
    ): TextView {
        return TextView(this).apply {
            text = label
            textSize = 13f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(if (accent) activeTheme.accentTextColor else activeTheme.keyTextColor)
            background = roundedDrawable(if (accent) activeTheme.accentColor else activeTheme.keyColor)
            setPadding(dp(14), dp(10), dp(14), dp(10))
            setOnClickListener { onTap() }
            layoutParams =
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                ).apply {
                    marginEnd = dp(6)
                }
        }
    }

    private fun roundedDrawable(color: Int): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(16).toFloat()
            setColor(color)
        }
    }

    private fun dp(value: Int): Int {
        return (value * resources.displayMetrics.density).toInt()
    }

    companion object {
        private const val PREFERENCES_NAME = "clever_keyboard_preferences"
        private const val LATEST_CONVERSATION_CONTEXT_KEY = "latestConversationContext"
        private const val AUTO_SOURCE_LANGUAGE = "Auto Detect"
        private const val DEFAULT_REPLY_VARIANT = "friendly"
        private const val DEFAULT_ASSISTANT_ID = "professional-rewrite"
        private const val SHIFT_DOUBLE_TAP_MS = 450L
    }

    private data class TransformTarget(
        val text: String,
        val replaceSelection: Boolean,
    )
}
