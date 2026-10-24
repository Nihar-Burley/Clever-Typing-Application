# Backend API Contract

This project currently uses a concrete backend contract for live AI execution. Both Flutter screens and the native Android keyboard are expected to target the same endpoints.

## Authentication

- Header: `Authorization: Bearer <AI_API_KEY>`
- Header: `Content-Type: application/json`

## Base URL

Provided at runtime with:

- `AI_BASE_URL`
- `AI_API_KEY`

## Endpoints

### `POST /v1/keyboard/grammar-correct`

Request:

```json
{
  "text": "i dont know what happened"
}
```

Response:

```json
{
  "correctedText": "I don't know what happened."
}
```

### `POST /v1/keyboard/translate`

Request:

```json
{
  "text": "Hello world",
  "sourceLanguage": "Auto Detect",
  "targetLanguage": "Spanish",
  "preserveTone": true
}
```

Response:

```json
{
  "translatedText": "Hola mundo",
  "detectedSourceLanguage": "English"
}
```

### `POST /v1/keyboard/smart-reply`

Request:

```json
{
  "conversationContext": "Can you send the update by evening?",
  "variant": "friendly"
}
```

Response:

```json
{
  "replies": [
    "Yes, I will send it this evening.",
    "Sure, I can have that ready by evening.",
    "Understood. I will share the update later today."
  ]
}
```

### `POST /v1/keyboard/rewrite`

Request:

```json
{
  "tool": "tone_rewrite",
  "text": "send me the file asap",
  "tone": "professional",
  "preserveTone": true
}
```

Response:

```json
{
  "outputText": "Please send me the file as soon as possible.",
  "detectedLanguage": "English",
  "summaryBullets": [
    "Polished wording",
    "Professional tone retained"
  ]
}
```

### `POST /v1/keyboard/assistant-execute`

Request:

```json
{
  "assistantId": "professional-rewrite",
  "userText": "Need a concise professional reply for this customer update."
}
```

Response:

```json
{
  "outputText": "Hello, thank you for the update. We are reviewing the details and will follow up shortly with the next steps."
}
```

## Notes

- Responses must be JSON objects.
- Empty response fields are treated as failures by the client.
- Flutter screens and the native IME now target the same endpoint set.
- Native keyboard actions prefer selected text, then fall back to nearby cursor context for insert flows.
- Smart reply can also use accessibility-captured conversation context stored on device after explicit opt-in.
