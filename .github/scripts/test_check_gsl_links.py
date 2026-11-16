"""Tests for the GNU GSL manual link checker."""

from __future__ import annotations

import contextlib
import importlib.util
import io
import sys
import tempfile
import unittest
from pathlib import Path
from urllib.error import HTTPError
from unittest.mock import patch

SCRIPT = Path(__file__).with_name("check-gsl-links.py")
SPEC = importlib.util.spec_from_file_location("check_gsl_links", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
CHECKER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECKER)


def http_error(url: str, code: int) -> HTTPError:
    return HTTPError(url, code, "test error", None, io.BytesIO())


class Response:
    status = 200

    def __enter__(self) -> Response:
        return self

    def __exit__(self, *_: object) -> None:
        return None

    def read(self, size: int) -> bytes:
        return b"x"


class CheckUrlTests(unittest.TestCase):
    def test_retries_a_rate_limit_then_succeeds(self) -> None:
        url = "https://www.gnu.org/software/gsl/doc/html/a.html"
        with (
            patch.object(
                CHECKER,
                "urlopen",
                side_effect=[http_error(url, 429), Response()],
            ),
            patch.object(CHECKER.time, "sleep") as sleep,
        ):
            self.assertIs(CHECKER.check_url(url), True)
        sleep.assert_called_once_with(CHECKER.RETRY_DELAY_SECONDS)

    def test_persistent_rate_limit_is_unverified_not_success(self) -> None:
        url = "https://www.gnu.org/software/gsl/doc/html/a.html"
        with (
            patch.object(
                CHECKER,
                "urlopen",
                side_effect=[http_error(url, 429), http_error(url, 429)],
            ),
            patch.object(CHECKER.time, "sleep"),
            contextlib.redirect_stdout(io.StringIO()) as output,
        ):
            self.assertIsNone(CHECKER.check_url(url))
        self.assertIn("not verified after rate limiting", output.getvalue())

    def test_not_found_is_a_failure(self) -> None:
        url = "https://www.gnu.org/software/gsl/doc/html/missing.html"
        error = http_error(url, 404)
        with patch.object(
            CHECKER, "urlopen", side_effect=error
        ), contextlib.redirect_stderr(io.StringIO()):
            self.assertIs(CHECKER.check_url(url), False)
        self.assertTrue(error.fp.closed)

    def test_main_fails_when_a_link_is_broken_even_if_one_is_rate_limited(self) -> None:
        first = "https://www.gnu.org/software/gsl/doc/html/a.html"
        second = "https://www.gnu.org/software/gsl/doc/html/b.html"
        with tempfile.TemporaryDirectory() as directory:
            document = Path(directory) / "links.md"
            document.write_text(f"{first} {second}", encoding="utf-8")
            output = io.StringIO()
            error = io.StringIO()
            with (
                patch.object(sys, "argv", ["check-gsl-links.py", str(document)]),
                patch.object(
                    CHECKER,
                    "urlopen",
                    side_effect=[
                        http_error(first, 429),
                        http_error(first, 429),
                        http_error(second, 404),
                    ],
                ),
                patch.object(CHECKER.time, "sleep"),
                contextlib.redirect_stdout(output),
                contextlib.redirect_stderr(error),
            ):
                self.assertEqual(CHECKER.main(), 1)
            self.assertIn("1 unverified due to rate limiting", output.getvalue())
            self.assertIn("HTTP 404", error.getvalue())


if __name__ == "__main__":
    unittest.main()
