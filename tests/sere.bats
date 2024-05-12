#!/usr/bin/env bats

setup() {
	DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
	PATH="$DIR/../:$PATH"
	TMPDIR="$(mktemp -d)"

	echo "Hello, world" > "$TMPDIR/file.txt"
	echo "Another file" > "$TMPDIR/file2.txt"
}

teardown() {
	rm -rf "$TMPDIR"
}

@test "List directory files matching regular expressions without modifying them during dry run" {
	(
		[ "$(sere -n "H\w+" "Goodbye" "$TMPDIR")" = "$TMPDIR/file.txt" ]
		[ "$(cat "$TMPDIR/file.txt")" = "Hello, world" ]
	)
}

@test "List directory files matching fixed strings without modifying them during dry run" {
	(
		[ "$(sere -n -F "Hello" "Goodbye" "$TMPDIR")" = "$TMPDIR/file.txt" ]
		[ "$(cat "$TMPDIR/file.txt")" = "Hello, world" ]
	)
}

@test "List singular file matching regular expressions without modifying them during dry run" {
	(
		[ "$(sere -n "H\w+" "Goodbye" "$TMPDIR/file.txt")" = "$TMPDIR/file.txt" ]
		[ "$(cat "$TMPDIR/file.txt")" = "Hello, world" ]
	)
}

@test "List singular file matching fixed strings without modifying them during dry run" {
	(
		[ "$(sere -n -F "Hello" "Goodbye" "$TMPDIR/file.txt")" = "$TMPDIR/file.txt" ]
		[ "$(cat "$TMPDIR/file.txt")" = "Hello, world" ]
	)
}

@test "Replaces text in directory files using regular expressions" {
	sere "H\w+" "Goodbye" "$TMPDIR"
	[ "$(cat "$TMPDIR/file.txt")" = "Goodbye, world" ]
}

@test "Replaces text in directory files using fixed strings" {
	sere -F "Hello" "Goodbye" "$TMPDIR"
	[ "$(cat "$TMPDIR/file.txt")" = "Goodbye, world" ]
}

@test "Replaces text in singular file using regular expressions" {
	sere "H\w+" "Goodbye" "$TMPDIR/file.txt"
	[ "$(cat "$TMPDIR/file.txt")" = "Goodbye, world" ]
}

@test "Replaces text in singular file using fixed strings" {
	sere -F "Hello" "Goodbye" "$TMPDIR/file.txt"
	[ "$(cat "$TMPDIR/file.txt")" = "Goodbye, world" ]
}
