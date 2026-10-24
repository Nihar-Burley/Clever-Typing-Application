package com.clevertyping.keyboard.bridge

/**
 * Bridge contract for native keyboard and Flutter host app coordination.
 */
interface KeyboardBridge {
    fun refreshPreferences()
    fun requestAiAction(action: String, sourceText: String)
    fun requestGrammarCorrection(sourceText: String)
    fun requestTranslation(sourceText: String, targetLanguage: String)
    fun getKeyboardStatus(): Map<String, Boolean>
}
