#!/usr/bin/env bats

setup() {
	DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
	PATH="$DIR/../:$PATH"
	TMPDIR="$(mktemp -d)"

	echo "Hello, world" > "$TMPDIR/file.txt"
	echo "Another file" > "$TMPDIR/file2.txt"
	echo "Hello, world" > "$TMPDIR/.hidden.txt"
}

teardown() {
	rm -rf "$TMPDIR"
}

@test "List directory files, excluding hidden ones, matching regular expressions without modifying them during dry run" {
	output="$(sere -n "H\w+" "Goodbye" "$TMPDIR")"
	[ "$(echo "$output" | wc -l | tr -d ' ')" = "1" ]
	[ "$(echo "$output" | grep "$TMPDIR/file.txt")" = "$TMPDIR/file.txt" ]
	[ "$(cat "$TMPDIR/file.txt")" = "Hello, world" ]
}

@test "List directory files, including hidden ones, matching regular expressions without modifying them during dry run" {
	output="$(sere -H -n "H\w+" "Goodbye" "$TMPDIR")"
	[ "$(echo "$output" | wc -l | tr -d ' ')" = "2" ]
	[ "$(echo "$output" | grep "$TMPDIR/file.txt")" = "$TMPDIR/file.txt" ]
	[ "$(echo "$output" | grep "$TMPDIR/.hidden.txt")" = "$TMPDIR/.hidden.txt" ]
	[ "$(cat "$TMPDIR/.hidden.txt")" = "Hello, world" ]
	[ "$(cat "$TMPDIR/file.txt")" = "Hello, world" ]
}

@test "List directory files, excluding hidden ones, matching fixed strings without modifying them during dry run" {
	output="$(sere -n -F "Hello" "Goodbye" "$TMPDIR")"
	[ "$(echo "$output" | wc -l | tr -d ' ')" = "1" ]
	[ "$(echo "$output" | grep "$TMPDIR/file.txt")" = "$TMPDIR/file.txt" ]
	[ "$(cat "$TMPDIR/file.txt")" = "Hello, world" ]
}

@test "List directory files, including hidden ones, matching fixed strings without modifying them during dry run" {
	output="$(sere -n -H -F "Hello" "Goodbye" "$TMPDIR")"
	[ "$(echo "$output" | wc -l | tr -d ' ')" = "2" ]
	[ "$(echo "$output" | grep "$TMPDIR/file.txt")" = "$TMPDIR/file.txt" ]
	[ "$(echo "$output" | grep "$TMPDIR/.hidden.txt")" = "$TMPDIR/.hidden.txt" ]
	[ "$(cat "$TMPDIR/.hidden.txt")" = "Hello, world" ]
	[ "$(cat "$TMPDIR/file.txt")" = "Hello, world" ]
}

@test "Replaces text in directory files, excluding hidden ones, using regular expressions" {
	sere "H\w+" "Goodbye" "$TMPDIR"
	[ "$(cat "$TMPDIR/.hidden.txt")" = "Hello, world" ]
	[ "$(cat "$TMPDIR/file.txt")" = "Goodbye, world" ]
}

@test "Replaces text in directory files, including hidden ones, using regular expressions" {
	sere -H "H\w+" "Goodbye" "$TMPDIR"
	[ "$(cat "$TMPDIR/.hidden.txt")" = "Goodbye, world" ]
	[ "$(cat "$TMPDIR/file.txt")" = "Goodbye, world" ]
}

@test "Replaces text in directory files, excluding hidden ones, using fixed strings" {
	sere -F "Hello" "Goodbye" "$TMPDIR"
	[ "$(cat "$TMPDIR/.hidden.txt")" = "Hello, world" ]
	[ "$(cat "$TMPDIR/file.txt")" = "Goodbye, world" ]
}

@test "Replaces text in directory files, including hidden ones, using fixed strings" {
	sere -H -F "Hello" "Goodbye" "$TMPDIR"
	[ "$(cat "$TMPDIR/.hidden.txt")" = "Goodbye, world" ]
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
