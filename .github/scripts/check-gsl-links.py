#!/usr/bin/env python3
"""Check GSL manual URLs while distinguishing rate limits from broken links."""

from __future__ import annotations

import os
import re
import sys
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[2]
GSL_URL = re.compile(r"https://www\.gnu\.org/software/gsl/doc/html/[^\s)>]*")
TEXT_EXTENSIONS = {
    ".htm",
    ".html",
    ".json",
    ".json5",
    ".jsonc",
    ".markdown",
    ".md",
    ".mdx",
    ".rst",
    ".txt",
    ".yaml",
    ".yml",
}
IGNORED_DIRECTORIES = {".git", ".validation", "node_modules"}
MAX_RETRIES = 1
RETRY_DELAY_SECONDS = 5
REQUEST_INTERVAL_SECONDS = 3
REQUEST_TIMEOUT_SECONDS = 10


def check_url(url: str) -> bool | None:
    for attempt in range(MAX_RETRIES + 1):
        try:
            request = Request(url, headers={"User-Agent": "VSL GSL manual link checker"})
            with urlopen(request, timeout=REQUEST_TIMEOUT_SECONDS) as response:
                response.read(1)
                print(f"Checked {url}: HTTP {response.status}")
                return True
        except HTTPError as error:
            status = error.code
            error.close()
            if status == 429:
                if attempt < MAX_RETRIES:
                    print(f"GNU rate limit for {url}; retrying once")
                    time.sleep(RETRY_DELAY_SECONDS)
                    continue
                print(
                    "::warning::GNU GSL manual link not verified after rate limiting: "
                    f"{url}"
                )
                return None
            print(f"ERROR: {url} returned HTTP {status}", file=sys.stderr)
            return False
        except (TimeoutError, URLError) as error:
            if attempt < MAX_RETRIES:
                print(f"Transient network error for {url}; retrying once")
                time.sleep(RETRY_DELAY_SECONDS)
                continue
            print(f"ERROR: could not check {url}: {error}", file=sys.stderr)
            return False

    return False


def repository_documents():
    for directory, subdirectories, filenames in os.walk(ROOT):
        subdirectories[:] = [
            name for name in subdirectories if name not in IGNORED_DIRECTORIES
        ]
        for filename in filenames:
            path = Path(directory) / filename
            if path.suffix.lower() in TEXT_EXTENSIONS:
                yield path


def main() -> int:
    documents = [Path(path) for path in sys.argv[1:]] or list(repository_documents())
    urls = []
    for document in documents:
        content = document.read_text(encoding="utf-8")
        urls.extend(GSL_URL.findall(content))
    urls = list(dict.fromkeys(urls))
    if not urls:
        print("ERROR: no GSL manual URLs found", file=sys.stderr)
        return 1

    failures = 0
    unverified = 0
    for index, url in enumerate(urls):
        if index:
            time.sleep(REQUEST_INTERVAL_SECONDS)
        result = check_url(url)
        if result is False:
            failures += 1
        elif result is None:
            unverified += 1

    print(
        f"Checked {len(urls)} GSL manual URL(s); {failures} broken/unreachable, "
        f"{unverified} unverified due to rate limiting."
    )
    return int(failures > 0)


if __name__ == "__main__":
    raise SystemExit(main())
