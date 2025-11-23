#!/bin/bash

partial="\e[33m\u25CB Skipped\e[0m"
success="\e[32m✓ Success\e[0m"
failure="\e[31m✗ Failure\e[0m"

ensure_block_in_file() {
	local path=$1
    local block_name=$2
	local content=$3
    local comment_marker="${4:-#}"

    local block_tag="$comment_marker $block_name: managed"
    local block_tag_closing="$comment_marker $block_name: end"

    # TODO: If there is already a block but it's wrong, we should deal with that.
    if ! grep -q "$block_tag" "$path"; then
        echo -n "Adding missing block '$block_name' to file '$path'... "
        cat <<EOF >>"$path"
$block_tag
$content
$block_tag_closing
EOF
        echo -e $success
    else
        echo -e "Block '$block_name' already found in '$path'...  $partial"
    fi
}

ensure_directory() {
	local path=$1
    echo -n "Ensuring path '$path' is present... "
    mkdir -p "$path"
    resp=$?
    if [[ resp -eq 0 ]]; then
        echo -e $success
    else
        echo -e $failure
    fi
}

ensure_symlink_dir() {
	local data_path=$1
	local link_path=$2

	if [[ ! -L "$link_path" && -d "$link_path" ]]; then
		local now=$(date +%s)
		echo -e "\e[34mNon-symlink directory exists at $link_path; backing up at $link_path$now\e[0m"
		mv "$link_path" "$link_path$now"
	fi
	echo -n "Ensuring path '$link_path' -> '$data_path'... "
	ln -snfv "$data_path" "$link_path"
    if [[ $? -eq 0 ]]; then
        echo -e $success
    else
        echo -e $failure
    fi
}

ensure_symlink_file() {
	local data_path=$1
	local link_path=$2

	if [[ ! -L "$link_path" && -f "$link_path" ]]; then
		local now=$(date +%s)
		echo "Non-symlink file exists at $link_path; backing up at $link_path$now"
		mv "$link_path" "$link_path$now"
	fi
	echo "Ensuring path $link_path -> $data_path"
	ln -sf "$data_path" "$link_path"
}
