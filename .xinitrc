# background
feh --bg-scale ~/dotfiles/wallpaper/mowing_the_lawn.png

# cursor
xsetroot -cursor_name left_ptr

# status bar
bar | lemonbar &

# launch bspwm
sxhkd &
exec bspwm
