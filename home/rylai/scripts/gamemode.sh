#!/usr/bin/env bash

if hyprctl getoption animations:enabled | grep -q "int: 1" ; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:blur:enabled 0;\
        keyword decoration:rounding 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0"
    notify-send -u low "Gamemode ACTIVADO" "Animaciones, blur y efectos visuales desactivados."
    exit
else
    hyprctl reload
    notify-send -u low "Gamemode DESACTIVADO" "Efectos visuales e interfaz restaurados."
    exit
fi
