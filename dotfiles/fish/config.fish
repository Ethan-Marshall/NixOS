# disable greeting
set fish_greeting

# fastfetch on first terminal of boot
if not test -f /tmp/fastfetch-shown
    fastfetch
    touch /tmp/fastfetch_shown
end
