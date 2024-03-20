#!/bin/bash

# Define the path to the .gitignore file
GITIGNORE_FILE=".gitignore"

# Check if .gitignore file already exists, if not create one
if [ ! -f "$GITIGNORE_FILE" ]; then
    touch "$GITIGNORE_FILE"
fi

# Check if the 'node_modules' entry already exists in .gitignore
if grep -q "node_modules/" "$GITIGNORE_FILE"; then
    echo "'node_modules' entry already exists in $GITIGNORE_FILE"
else
    # Add 'node_modules' entry to .gitignore
    echo "node_modules/" >> "$GITIGNORE_FILE"
    echo "Added 'node_modules' entry to $GITIGNORE_FILE"
fi

