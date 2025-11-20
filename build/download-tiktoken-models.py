#!/usr/bin/env python3
"""
Download all common tiktoken model encodings for offline use.
This ensures tiktoken can work in offline environments.
"""
import tiktoken

# Common encodings used by various OpenAI models
ENCODINGS = [
    "cl100k_base",  # GPT-4, GPT-3.5-turbo
    "p50k_base",    # Codex models
    "r50k_base",    # GPT-3 models (davinci, etc.)
    "o200k_base",   # GPT-4o models
]

def download_encodings():
    """Download all tiktoken encodings."""
    print("Downloading tiktoken encodings for offline use...")

    for encoding_name in ENCODINGS:
        try:
            print(f"  Downloading {encoding_name}...", end=" ")
            enc = tiktoken.get_encoding(encoding_name)
            # Test that it works
            enc.encode("test")
            print("✓")
        except Exception as e:
            print(f"✗ Failed: {e}")

    print("\nAll encodings downloaded successfully!")
    print("tiktoken is now ready for offline use.")

if __name__ == "__main__":
    download_encodings()
