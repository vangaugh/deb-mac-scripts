#!/usr/bin/env bash

# DELETE LOCAL TRASH SECURELY ON DEBIAN BASED SYSTEM

# DELETE LOCAL FILES
echo "...TAKING OUT THE GARBAGE"

find ~/.local/share/Trash/files ~/.local/share/Trash/info -type f -print0 | xargs -0 -I{} /usr/bin/scrub -Sfp random {}

find ~/.local/share/Trash/files/* ~/.local/share/Trash/info/* -depth | while read i
    do
        cleant=$(head -c17 /dev/urandom | tr -d [[:space:]] | tr -d [[:punct:]])
        mv "$i" ~/.local/share/Trash/files/"$cleant" 2> /dev/null
    done

rm -rf ~/.local/share/Trash/files/*

echo "ALL GARBAGE EMPTIED"
