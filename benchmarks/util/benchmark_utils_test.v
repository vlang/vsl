module util

import time

fn test_benchmark_timer_reports_nanoseconds() {
	mut timer := BenchmarkTimer{}
	started_at := timer.start()
	time.sleep(2 * time.millisecond)
	timer.record(started_at)

	assert timer.mean_ns(1) >= 2_000_000
}
