#!/usr/bin/env python3
"""驗證 Harness Codex 版的結構、清單與平台殘留。"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # Python 3.10 的相容提示
    tomllib = None


ROOT = Path(__file__).resolve().parents[1]
ERRORS: list[str] = []


def fail(message: str) -> None:
    ERRORS.append(message)


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        fail(f"缺少必要檔案：{path.relative_to(ROOT)}")
    except json.JSONDecodeError as exc:
        fail(f"JSON 格式錯誤：{path.relative_to(ROOT)}：{exc}")
    return {}


def validate_plugin() -> None:
    path = ROOT / ".codex-plugin" / "plugin.json"
    data = load_json(path)
    if not data:
        return

    for key in ("name", "version", "description", "skills", "interface"):
        if not data.get(key):
            fail(f"plugin.json 缺少欄位：{key}")

    if data.get("name") != "harness":
        fail("plugin.json 的 name 必須是 harness")

    if not re.fullmatch(r"\d+\.\d+\.\d+", str(data.get("version", ""))):
        fail("plugin.json 的 version 必須使用完整 semver")

    for key in ("skills", "apps", "mcpServers"):
        value = data.get(key)
        if isinstance(value, str):
            target = ROOT / value
            if not target.exists():
                fail(f"plugin.json 的 {key} 路徑不存在：{value}")

    interface = data.get("interface", {})
    for key in (
        "displayName",
        "shortDescription",
        "longDescription",
        "developerName",
        "category",
        "capabilities",
        "defaultPrompt",
    ):
        if key not in interface:
            fail(f"plugin.json 的 interface 缺少欄位：{key}")

    for key in ("composerIcon", "logo", "logoDark"):
        value = interface.get(key)
        if value and not (ROOT / value).is_file():
            fail(f"plugin.json 的 {key} 檔案不存在：{value}")


def validate_marketplace() -> None:
    path = ROOT / ".agents" / "plugins" / "marketplace.json"
    data = load_json(path)
    if not data:
        return

    if not data.get("name"):
        fail("marketplace.json 缺少 name")

    plugins = data.get("plugins")
    if not isinstance(plugins, list) or not plugins:
        fail("marketplace.json 必須包含至少一個 plugin")
        return

    harness = next((item for item in plugins if item.get("name") == "harness"), None)
    if not harness:
        fail("marketplace.json 沒有 harness 項目")
        return

    policy = harness.get("policy", {})
    if policy.get("installation") not in {
        "AVAILABLE",
        "INSTALLED_BY_DEFAULT",
        "NOT_AVAILABLE",
    }:
        fail("marketplace harness 缺少有效的 policy.installation")
    if policy.get("authentication") not in {"ON_INSTALL", "ON_USE"}:
        fail("marketplace harness 缺少有效的 policy.authentication")
    if not harness.get("category"):
        fail("marketplace harness 缺少 category")

    source = harness.get("source")
    if isinstance(source, dict) and source.get("source") == "local":
        relative = source.get("path")
        if not relative or not (ROOT / relative).exists():
            fail(f"marketplace 的本機來源不存在：{relative}")


def parse_frontmatter(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if len(lines) < 3 or lines[0].strip() != "---":
        fail(f"Skill 缺少 YAML frontmatter：{path.relative_to(ROOT)}")
        return {}
    try:
        end = lines.index("---", 1)
    except ValueError:
        fail(f"Skill frontmatter 未結束：{path.relative_to(ROOT)}")
        return {}

    result: dict[str, str] = {}
    for line in lines[1:end]:
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        result[key.strip()] = value.strip().strip('"\'')
    return result


def validate_skills() -> None:
    skill_files = sorted((ROOT / "skills").glob("*/SKILL.md"))
    if not skill_files:
        fail("skills/ 中沒有任何 SKILL.md")
        return

    names: set[str] = set()
    for path in skill_files:
        metadata = parse_frontmatter(path)
        name = metadata.get("name", "")
        description = metadata.get("description", "")
        if not name:
            fail(f"Skill 缺少 name：{path.relative_to(ROOT)}")
        elif name in names:
            fail(f"Skill name 重複：{name}")
        else:
            names.add(name)
        if not description:
            fail(f"Skill 缺少 description：{path.relative_to(ROOT)}")

        text = path.read_text(encoding="utf-8")
        for ref in re.findall(r"`(references/[^`]+\.md)`", text):
            if not (path.parent / ref).is_file():
                fail(f"Skill 引用不存在：{path.relative_to(ROOT)} → {ref}")


def validate_harness_packager() -> None:
    root = ROOT / "skills" / "harness-packager"
    required = (
        root / "SKILL.md",
        root / "agents" / "openai.yaml",
        root / "references" / "package-format.md",
        root / "scripts" / "harness_packager.ps1",
        ROOT / "tests" / "test_harness_packager.ps1",
    )
    for path in required:
        if not path.is_file():
            fail(f"Harness Packager 缺少必要檔案：{path.relative_to(ROOT)}")

    if not (root / "SKILL.md").is_file():
        return
    text = (root / "SKILL.md").read_text(encoding="utf-8")
    for token in ("Pack", "Install", "Verify", ".harness", "harness_packager.ps1"):
        if token not in text:
            fail(f"Harness Packager SKILL.md 缺少必要內容：{token}")
    if re.search(r"\b(TODO|TBD|PLACEHOLDER)\b", text):
        fail("Harness Packager SKILL.md 仍有 placeholder")


def validate_toml() -> None:
    toml_files = sorted((ROOT / ".codex").rglob("*.toml")) if (ROOT / ".codex").exists() else []
    if toml_files and tomllib is None:
        fail("目前 Python 不支援 tomllib，無法驗證 TOML；請使用 Python 3.11 以上")
        return

    for path in toml_files:
        try:
            data = tomllib.loads(path.read_text(encoding="utf-8"))
        except Exception as exc:  # tomllib 的例外型別僅在匯入成功後存在
            fail(f"TOML 格式錯誤：{path.relative_to(ROOT)}：{exc}")
            continue

        if path.parent.name == "agents":
            for key in ("name", "description", "developer_instructions"):
                if not data.get(key):
                    fail(f"代理人缺少 {key}：{path.relative_to(ROOT)}")


def validate_platform_cleanup() -> None:
    for stale_path in (
        ROOT / ".claude-plugin",
        ROOT / ".claude",
        ROOT / "CLAUDE.md",
    ):
        has_artifacts = stale_path.is_file() or (
            stale_path.is_dir() and any(item.is_file() for item in stale_path.rglob("*"))
        )
        if has_artifacts:
            fail(f"仍存在 Claude 專用產物：{stale_path.relative_to(ROOT)}")

    forbidden = (
        "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS",
        "claude plugin install",
        "claude plugin marketplace",
        "claude -p",
    )
    ignored_roots = {".git", "_workspace"}
    ignored_files = {"CHANGELOG.md"}
    suffixes = {".md", ".json", ".toml", ".yml", ".yaml", ".html"}

    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in suffixes:
            continue
        relative = path.relative_to(ROOT)
        if relative.parts[0] in ignored_roots or relative.name in ignored_files:
            continue
        text = path.read_text(encoding="utf-8", errors="replace").lower()
        for token in forbidden:
            if token.lower() in text:
                fail(f"仍有 Claude 執行設定：{relative} → {token}")


def main() -> int:
    validate_plugin()
    validate_marketplace()
    validate_skills()
    validate_harness_packager()
    validate_toml()
    validate_platform_cleanup()

    if ERRORS:
        print("Harness Codex 驗證失敗：")
        for item in ERRORS:
            print(f"- {item}")
        return 1

    print("Harness Codex 驗證通過：外掛、Marketplace、Skill、TOML 與平台清理皆符合要求。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
