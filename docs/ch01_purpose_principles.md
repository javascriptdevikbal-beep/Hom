
# Homeonix — Ch-01: Purpose & Principles

## Overview (EN)
Homeonix is an offline Android application that provides a local, privacy-preserving homeopathy reference and on-device search over imported books and images.

## Overview (BN)
Homeonix হল একটি অফলাইন অ্যান্ড্রয়েড অ্যাপ যা লোকালভাবে হোমিওপ্যাথি রেফারেন্স ও অন-ডিভাইস সার্চ প্রদর্শন করে এবং ব্যবহারকারীর ডেটা ফোনেই রাখে।

## Goals
- Enable remedy search (EN/BN) across imported texts with explainability (evidence: matching text chunk + source page).  
- Provide an offline ingestion pipeline: PDF/image → OCR → text chunking → embedding → local index.  
- Deliver fast, practical search: target p95 latency for Top-5 results ≲ 500 ms on mid-range devices (where feasible).  
- Preserve user privacy: all processing and data remain on-device; exports are under user control.  
- Offer clear explanations for suggestions (source text, book, page) to support user review.

## Non-Goals
- Not intended to provide clinical or medical advice; outputs are reference-only.  
- No online accounts, synchronization, or mandatory cloud backend.  
- Not a cloud-hosted AI service; no server-side model inference designed.  
- Not a substitute for professional medical consultation.

## Principles
**Privacy-first**  
All data processing, indexing, and model inference occur on the device; user data does not leave the device unless the user explicitly exports a local backup.

**Explainability**  
Every suggested remedy is accompanied by the evidence (matched text chunk and source reference) so users can trace why a suggestion was made.

**Minimal-permissions**  
The app requests only the permissions strictly required for local functionality (file access for user-imported content and local storage); design favors least-privilege operation.

**Offline-only**  
Core functionality (ingestion, search, explanation, backup/restore) is designed to operate without external services; exports/imports are user-initiated.

## Scope boundaries
**Includes**
- Local import of PDFs and images, on-device OCR (EN/BN), text chunking, local embedding and vector search, reader-like evidence navigation, and local backup/export of indices and settings.

**Excludes**
- Cloud synchronization, remote backups, online account management, server-side inference or cloud-hosted search services.

## Glossary
**SAF** — Storage Access Framework: Android mechanism for user-authorized file access (used for selecting/importing PDFs and images).  
**Room/SQLite** — Local relational storage used to store metadata, chunks, bookmarks, and indexes on the device.  
**tess-two (Tesseract)** — An on-device OCR library (Tesseract bindings for Android) used to extract text from images and PDF pages.  
**TFLite/ONNX** — On-device runtime formats for compact ML models (used for sentence embeddings or light rerankers).  
**PdfRenderer** — Android API or equivalent library component used to render PDF pages for display and page-level evidence navigation.
