#!/bin/bash

# Loop through each file in the bin directory and handle

	# Note: pixi 0.35.0 introduced breaking change to this script
	# "pixi global exposed binaries are not scripts anymore but actual executables, resulting in significant speedup and better compatibility with other tools."
	# Therefore added new logic for handling ELF 64-bit files, but kept the old logic for backwards compatibility.
	# Binary paths are still found in the trampoline_configuration directory, so this is used in these cases.

DIRECTORY="$HOME/.pixi/bin"

if [ -d "$DIRECTORY" ]; then

	cd "$DIRECTORY"

	for file in *
		do
			if [ "$file" = "cleanup-pixi-bin.sh" ]; then
				echo "Skipping cleanup-pixi-bin.sh script."
				continue
			fi
			# Leave pixi binary alone
			if [ "$file" = "pixi" ]; then
				echo "Skipping pixi binary."
				continue
			fi
			# Check file is regular and executable
			if [[ -f "$file" && -x "$file" ]]; then
				# Store the file type
				filetype=$(file "$file")
				# Handle binaries
				if [[ "$filetype" == *"ELF 64-bit"* ]]; then
					target_binary=$(grep -Eo '"/.*/bin/'"$file"'.*"' "./trampoline_configuration/$file.json" | tr -d '"')
					if [[ -e "$target_binary" ]]; then
						echo "Binary exists for binary: $file"
					else
						echo "Removing binary with non-existent binary: $file"
						rm "$file"
					fi
					continue
				# Handle scripts
				elif [[ "$filetype" == *"ASCII text executable"* ]]; then
					target_binary=$(grep -Eo '"/.*/bin/[^"]+"' "$file" | tr -d '"')
					if [[ -e "$target_binary" ]]; then
						echo "Binary exists for script: $file"
					else
						echo "Removing script with non-existent binary: $file"
						rm "$file"
					fi
				fi
			else
				echo "Non-regular or non-executable file: $file"
			fi

		done
else
	echo "Directory does not exist: $DIRECTORY"
	exit 1
fi
