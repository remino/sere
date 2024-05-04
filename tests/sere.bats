#!/usr/bin/env bats

setup() {
	DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
	PATH="$DIR/../:$PATH"
	# Create a temporary directory
	TMPDIR="$(mktemp -d)"
	echo "$TMPDIR"
	echo "Hello, world" > "$TMPDIR/file.txt"
	echo "Another file" > "$TMPDIR/file2.txt"
}

# teardown() {
# 	# Clean up
# 	#rm -rf "$TMPDIR"
# }

@test "List files matching regular expressions without modifying them during dry run" {
	(
		[ "$(sere -n "H\w+" "Goodbye" "$TMPDIR")" = "$TMPDIR/file.txt" ]
		[ "$(cat "$TMPDIR/file.txt")" = "Hello, world" ]
	)
}

@test "List files matching fixed strings without modifying them during dry run" {
	(
		[ "$(sere -n -F "Hello" "Goodbye" "$TMPDIR")" = "$TMPDIR/file.txt" ]
		[ "$(cat "$TMPDIR/file.txt")" = "Hello, world" ]
	)
}

@test "Replaces text in files using regular expressions" {
	sere "H\w+" "Goodbye" "$TMPDIR"
	[ "$(cat "$TMPDIR/file.txt")" = "Goodbye, world" ]
}

@test "Replaces text in files using fixed strings" {
	sere -F "Hello" "Goodbye" "$TMPDIR"
	[ "$(cat "$TMPDIR/file.txt")" = "Goodbye, world" ]
}
