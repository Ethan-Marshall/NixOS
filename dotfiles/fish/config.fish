# disable greeting
set fish_greeting

# fastfetch on first terminal of boot
if status is-interactive
  if not test -f /tmp/fastfetch_shown
      fastfetch
      touch /tmp/fastfetch_shown
  end
end
