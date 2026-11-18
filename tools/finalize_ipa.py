#!/usr/bin/env python3
"""Готовит IPA для Sideloadly: убирает подпись, профиль и Team ID, ставит свой bundle id и имя.

Использование: finalize_ipa.py <папка Payload> <новый bundle id>
"""
import os
import plistlib
import shutil
import sys

OLD = "ph.telegra.Telegraph"


def main():
    payload, new = sys.argv[1], sys.argv[2]
    renamed = 0
    for root, dirs, files in os.walk(payload):
        # подпись и профили не нужны: Sideloadly подпишет заново своим сертификатом
        for d in list(dirs):
            if d == "_CodeSignature":
                shutil.rmtree(os.path.join(root, d), ignore_errors=True)
                dirs.remove(d)
        for f in files:
            if f in ("embedded.mobileprovision", "CodeResources"):
                os.remove(os.path.join(root, f))
        if "Info.plist" in files:
            path = os.path.join(root, "Info.plist")
            try:
                with open(path, "rb") as fh:
                    data = plistlib.load(fh)
            except Exception:
                continue
            changed = False
            for key in ("CFBundleIdentifier", "WKCompanionAppBundleIdentifier"):
                value = data.get(key)
                if isinstance(value, str) and value.startswith(OLD):
                    data[key] = new + value[len(OLD):]
                    changed = True
            if root.endswith(".app") and os.path.dirname(root).endswith("Payload"):
                data["CFBundleDisplayName"] = "MattGram"
                data["CFBundleName"] = "MattGram"
                changed = True
            if changed:
                with open(path, "wb") as fh:
                    plistlib.dump(data, fh, fmt=plistlib.FMT_BINARY)
                renamed += 1
    print("обновлено Info.plist:", renamed, "bundle id:", new)


if __name__ == "__main__":
    main()
