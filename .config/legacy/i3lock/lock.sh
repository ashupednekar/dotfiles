#!/bin/bash

# Set lock screen options
i3lock \
    --blur 10 \                             # Blurs the current screen
    --clock \                               # Displays the clock
    --indicator \                           # Shows the unlock indicator
    --timestr="%H:%M:%S" \                  # Custom time format
    --datestr="%A, %d %B %Y" \              # Custom date format
    --inside-color=00000080 \               # Inside circle color
    --ring-color=ffffff80 \                 # Ring color
    --line-color=00000000 \                 # Line color
    --keyhl-color=88c0d0ff \                # Key press highlight color
    --bshl-color=bf616aff \                 # Backspace highlight color
    --separator-color=4c566aff \            # Separator color
    --verif-color=ffffff \                  # Verifying text color
    --wrong-color=bf616a \                  # Wrong password color
    --layout-color=d8dee9 \                 # Layout text color
    --time-color=ffffff \                   # Time text color
    --date-color=ffffff \                   # Date text color
    --greeter-text="Locked" \               # Custom greeter text
    --greeter-color=88c0d0 \                # Greeter text color
    --greeter-font="Hack" \                 # Greeter font
    --time-font="Hack" \                    # Time font
    --date-font="Hack" \                    # Date font
    --time-size=40 \                        # Time font size
    --date-size=20 \                        # Date font size
    --greeter-size=30 \                     # Greeter font size
    --image=/path/to/your/background.png    # Custom background image
