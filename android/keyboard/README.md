# Native Keyboard Module

This directory holds the native Android keyboard surface and related platform code.

## Purpose

- own the `InputMethodService`
- render keys and suggestion UI natively
- handle per-keystroke input without Flutter in the hot path
- bridge settings and AI actions to the Flutter host app

## Current Status

The module currently contains service and bridge stubs only. A full Android project shell and manifest wiring still need to be added or connected to an existing Android app module.
