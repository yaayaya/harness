"""Translate repository documents into Traditional and Simplified Chinese.

The script intentionally has no third-party dependency. It reads source files
from upstream/main, calls an OpenAI-compatible chat endpoint, and writes only
translation files to the current branch. Pushing is deliberately outside this
script.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path


DEFAULT_MODEL = "gpt-4.1-mini"
EXTENSIONS = {".md", ".mdx", ".txt", ".html"}
SKIP_NAMES = {"LICENSE", "README_EN.md", "README_JA.md", "README_KO.md"}


def git_source(path: str) -> str:
    result = subprocess.run(
        ["git", "show", f"upstream/main:{path}"],
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    return result.stdout


def target_path(source: Path, language: str) -> Path:
    if language == "zh-tw" and source.suffix.lower() in {".md", ".mdx", ".txt"}:
        return source
    if source.suffix.lower() == ".html":
        suffix = "_zh_TW" if language == "zh-tw" else "_zh_CN"
    else:
        suffix = "_ZH_TW" if language == "zh-tw" else "_ZH_CN"
    return source.with_name(f"{source.stem}{suffix}{source.suffix}")


def is_translatable(path: Path) -> bool:
    return (
        path.suffix.lower() in EXTENSIONS
        and path.name not in SKIP_NAMES
        and "_ZH_" not in path.stem
        and "_zh_" not in path.stem
    )


def translate(text: str, language: str, model: str, endpoint: str, api_key: str) -> str:
    language_name = "繁體中文（台灣用語）" if language == "zh-tw" else "簡體中文（中國大陸用語）"
    prompt = (
        f"請將以下 repository 文件完整翻譯成{language_name}。保留 Markdown/HTML 結構、"
        "標題層級、連結 URL、命令、檔案路徑、環境變數、程式碼區塊與表格欄位；"
        "不要摘要、不要新增資訊、不要翻譯程式碼區塊內容。只輸出翻譯後的完整文件。\n\n"
        f"原文：\n{text}"
    )
    body = {
        "model": model,
        "messages": [
            {"role": "system", "content": "你是嚴謹的技術文件翻譯器。"},
            {"role": "user", "content": prompt},
        ],
        "temperature": 0.1,
    }
    request = urllib.request.Request(
        endpoint,
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            payload = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"翻譯 API 回應 {error.code}: {detail}") from error
    except urllib.error.URLError as error:
        raise RuntimeError(f"無法連線翻譯 API：{error.reason}") from error
    try:
        return payload["choices"][0]["message"]["content"].strip() + "\n"
    except (KeyError, IndexError, TypeError) as error:
        raise RuntimeError("翻譯 API 回應缺少 choices[0].message.content") from error


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--path", action="append", help="只翻譯指定的 upstream 相對路徑，可重複指定")
    parser.add_argument("--language", choices=["zh-tw", "zh-cn", "both"], default="both")
    parser.add_argument("--model", default=os.getenv("TRANSLATION_MODEL", DEFAULT_MODEL))
    parser.add_argument("--endpoint", default=os.getenv("TRANSLATION_ENDPOINT", "https://api.openai.com/v1/chat/completions"))
    parser.add_argument("--dry-run", action="store_true", help="只列出預計處理的檔案，不呼叫 API")
    args = parser.parse_args()

    paths = [Path(item) for item in args.path] if args.path else [
        Path(line) for line in subprocess.check_output(
            ["git", "ls-tree", "-r", "--name-only", "upstream/main"], text=True
        ).splitlines()
    ]
    paths = [path for path in paths if is_translatable(path)]
    languages = ["zh-tw", "zh-cn"] if args.language == "both" else [args.language]

    if Path("README.md") in paths:
        english_snapshot = Path("README_EN.md")
        print(f"en: README.md -> {english_snapshot}")
        if not args.dry_run:
            english_snapshot.write_text(git_source("README.md"), encoding="utf-8", newline="\n")

    for source in paths:
        for language in languages:
            destination = target_path(source, language)
            print(f"{language}: {source} -> {destination}")
            if args.dry_run:
                continue
            api_key = os.getenv("OPENAI_API_KEY")
            if not api_key:
                print("缺少 OPENAI_API_KEY；請設定環境變數後重試。", file=sys.stderr)
                return 2
            translated = translate(git_source(source.as_posix()), language, args.model, args.endpoint, api_key)
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text(translated, encoding="utf-8", newline="\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
