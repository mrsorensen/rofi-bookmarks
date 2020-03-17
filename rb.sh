#!/bin/bash

# CONFIG
# ----------------------------

# Browser
firefox=1
chromium=0

# Location of bookmarks
dir=~/rofi-bookmarks/bookmarks

# Recognized top domains
domains="
.com
.no
.net
.org
"

# Max rofi lines
maxlines=10

# END OF CONFIG
# ----------------------------

# Create bookmarks file if needed
if [ ! -f $dir ]; then
	touch $dir
fi

# Read bookmarks
bookmarks="$(sort $dir)"

# Count lines in bookmarks file
lines="$(wc -l < $dir)"

# Make sure there are no more lines than maxlines
if (( lines > maxlines )); then
	lines="$maxlines"
fi

# Get user input
input=$(echo -e "$bookmarks" | rofi -dmenu -p "Web" -l $lines)


# Check if input is not empty
if [[ -n "$input" ]]; then

	# Check if input is URL or search query
	for d in $domains; do
		if [[ $input == *"${d}" ]] || [[ $input == *"${d}/"* ]]; then
			isLink=1
		fi
	done
	# If input is URL
	if [[ $isLink == 1 ]]; then

		# Get core URL (reddit.com/r/pics becomes reddit.com)
		shortURL=$(echo https://${input} | awk -F[/:] '{print $4}')

		# Check if shortened URL has been previously added to bookmarks
		searchShort="$(grep ${shortURL} $dir)"
		if [[ "$searchShort" == "" ]]; then
			echo "Adding URL to bookmarks..."
			echo "${shortURL}" >> $dir
		fi

		# Check if URL has been previously added to bookmarks
		searchInput="$(grep ${input} $dir)"
		if [[ "$searchInput" == "" ]]; then
			echo "Adding URL to bookmarks..."
			echo "${input}" >> $dir
		fi


		# Open input in chromium
		echo "Going to https://${input}"
		if [[ "$firefox" == 1 ]]; then
			firefox https://${input}
		elif [[ "$chromium" == 1 ]]; then
			chromium --app=https://${input}
		else
			echo "No browser selected"
		fi
	# If input is search query
	else
		# Check if user input is localhost*
		if [[ "$input" == "localhost"* ]]; then
			echo "$input"
			if [[ "$firefox" == 1 ]]; then
				firefox http://${input}
			elif [[ "$chromium" == 1 ]]; then
				chromium --app=http://${input}
			else
				echo "No browser selected"
			fi
		# Regular search
		else
			# Change spaces with URL friendly %20
			input=${input// /%20}
			# Goto duckduckgo and search
			echo "Going to https://duckduckgo.com/?q=${input}"
			if [[ "$firefox" == 1 ]]; then
				firefox https://duckduckgo.com/?q=${input}
			elif [[ "$chromium" == 1 ]]; then
				chromium --app=https://duckduckgo.com/?q=${input}
			else
				echo "No browser selected"
			fi
		fi
	fi


fi
