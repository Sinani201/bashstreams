#!/bin/bash

# Config file: ~/.streams
# Files should be stored in format: <stream url> <stream name>
# Supported streams are anything that works in livestreamer

playstream() {
	# Loop through the configuration file to find the url that
	# corresponds to the alias
	while read streamurl; do
		if [ $(cut -d ' ' -f 2- <<< $streamurl) == "$1" ]; then
			livestreamer $(cut -d ' ' -f 1 <<< $streamurl) best
		fi
	done < ~/.streams
}

tostream=false

for arg in "$@"
do
	if $tostream ; then
		playstream "$arg"	
		tostream=false
	elif [ "$arg" == "reload" ]; then
		# Loop through each line in the config file
		while read streamurl; do
			# Use livestreamer -j to output information about the stream in json format.
			# Then use json to see if the "live" parameter is true.
			if [ $(livestreamer -j $(cut -d ' ' -f 1 <<< $streamurl) best | jshon -e params -e live) == "true" ]; then
				# If it's streaming, get the stream alias from the file and echo it to the live file
				echo $(cut -d ' ' -f 2- <<< $streamurl)
			fi
		done < ~/.streams > ~/.live
	elif [ "$arg" == "dmenu" ]; then
		playstream $(dmenu -p "Stream" < ~/.live)
	elif [ "$arg" == "stream" ]; then
		tostream=true
	elif [ "$arg" == "help" ] || [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
		echo "Usage: $(basename $0) [commands...]

Commands available:
reload - reload the list of streams currently live (stored in ~/.live)
dmenu - Run dmenu with a list of currently live streams
stream - Run a stream by name

You can also do \"$(basename $0) reload dmenu\" to check for livestreams and
then immediately run dmenu. However if you have a large amount of streams in
your config file this may be slow.

Configuration file is in ~/.streams . Each line in the file is a stream
to track. The format is <stream url> <stream alias>

This script requires livestreamer ( https://github.com/chrippa/livestreamer ),
jshon, and dmenu."
	fi
done
