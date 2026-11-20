"""Tests for the GNU GSL manual link checker."""

from __future__ import annotations

import contextlib
import errno
import importlib.util
import io
import sys
import tempfile
import unittest
from pathlib import Path
from urllib.error import HTTPError, URLError
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
            self.assertEqual(CHECKER.check_url(url), "ok")
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
            self.assertEqual(CHECKER.check_url(url), "rate_limited")
        self.assertIn("not verified after rate limiting", output.getvalue())

    def test_not_found_is_a_failure(self) -> None:
        url = "https://www.gnu.org/software/gsl/doc/html/missing.html"
        error = http_error(url, 404)
        with patch.object(
            CHECKER, "urlopen", side_effect=error
        ), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(CHECKER.check_url(url), "broken")
        self.assertTrue(error.fp.closed)

    def test_runner_connectivity_is_unverified_after_retry(self) -> None:
        url = "https://www.gnu.org/software/gsl/doc/html/a.html"
        network_error = URLError(OSError(errno.ENETUNREACH, "Network is unreachable"))
        with (
            patch.object(CHECKER, "urlopen", side_effect=[network_error, network_error]),
            patch.object(CHECKER.time, "sleep"),
            contextlib.redirect_stdout(io.StringIO()) as output,
        ):
            self.assertEqual(CHECKER.check_url(url), "unverified_connectivity")
        self.assertIn("not verified because the CI runner", output.getvalue())

    def test_timeout_remains_a_failure(self) -> None:
        url = "https://www.gnu.org/software/gsl/doc/html/a.html"
        with (
            patch.object(CHECKER, "urlopen", side_effect=URLError("handshake timed out")),
            patch.object(CHECKER.time, "sleep"),
            contextlib.redirect_stderr(io.StringIO()),
        ):
            self.assertEqual(CHECKER.check_url(url), "broken")

    def test_main_fails_when_a_link_is_broken_even_if_one_is_unverified(self) -> None:
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
                        URLError(OSError(errno.ECONNRESET, "Connection reset by peer")),
                        URLError(OSError(errno.ECONNRESET, "Connection reset by peer")),
                        http_error(second, 404),
                    ],
                ),
                patch.object(CHECKER.time, "sleep"),
                contextlib.redirect_stdout(output),
                contextlib.redirect_stderr(error),
            ):
                self.assertEqual(CHECKER.main(), 1)
            self.assertIn("1 unverified due to runner connectivity", output.getvalue())
            self.assertIn("HTTP 404", error.getvalue())


if __name__ == "__main__":
    unittest.main()
