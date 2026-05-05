# Hatsune Miku greeting - shown once per new terminal session
if [[ -o interactive ]]; then
  local hour=$(date +%H)
  local greeting
  if   (( hour < 6  )); then greeting="Good late night"
  elif (( hour < 12 )); then greeting="Good morning"
  elif (( hour < 17 )); then greeting="Good afternoon"
  elif (( hour < 21 )); then greeting="Good evening"
  else                        greeting="Good night"
  fi

  # Time at company (started 2026-01-05) — BSD vs GNU date differ
  local start_epoch
  if [[ "$OSTYPE" == "darwin"* ]]; then
    start_epoch=$(date -j -f '%Y-%m-%d' '2026-01-05' '+%s' 2>/dev/null)
  else
    start_epoch=$(date -d '2026-01-05' '+%s' 2>/dev/null)
  fi
  local now_epoch=$(date '+%s')
  local diff=$((now_epoch - start_epoch))
  local tenure=""
  if (( diff >= 0 )); then
    local days=$((diff / 86400))
    local months=$((days / 30))
    local remaining_days=$((days % 30))
    if (( months > 0 )); then
      tenure="${months}m ${remaining_days}d"
    else
      tenure="${days}d"
    fi
    tenure="🏢 Day $((days + 1)) at work (${tenure})"
  else
    local days=$(( (-diff) / 86400 ))
    tenure="🏢 Starting in ${days} days!"
  fi

  print -P "
%F{cyan}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣀⣀⠀⠀⣀⡠⠴⠒⠚⠉⠉⠓⠒⠦⣄⣶⠒⣷⡀%f
%F{cyan}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡷⢬⣉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠠⡌⠻⣧⢻⣧⣤%f
%F{cyan}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣖⠗⡋⢹⠀⠀⢰⡄⠀⠀⢸⣷⡀⠀⣠⠽⣆⢼⣇⢻⣸⡄%f
%F{cyan}⠀⠀⠀⠀⠀⠀⠀⠀⢀⡜⣡⣶⢋⡏⠙⢢⣏⣇⠀⠀⠈⣇⡵⡏⠀⠀⢹⡏⢾⣿⠃⢿⡆%f
%F{cyan}⠀⠀⠀⠀⠀⠀⠀⠀⣾⢿⢻⣏⣿⡇⡄⣾⠀⠹⡄⠄⠀⡇⠀⠹⣤⠈⠹⣿⣾⢸⠀⢘⣷⣄⣀%f    %F{green}${greeting}, %n!%f
%F{cyan}⠀⠀⠀⠀⠀⠀⠀⢠⣴⣯⣿⣽⣿⣷⢸⡗⠦⣄⡹⣼⣄⣿⣴⠛⠹⡄⡇⣿⣿⠾⠚⢹⢿⢽⣽⡇%f    %F{yellow}$(date +'%A, %B %d %Y')%f
%F{cyan}⠀⠀⠀⠀⠀⠀⠀⣸⣿⣞⣾⣿⢿⣯⢻⢻⡴⠞⠁⠈⠻⣿⣌⡉⠓⣿⣰⡿⠀⠀⠀⠸⡜⡾⣿⡇%f    %F{magenta}♪ Let's make something amazing~ ♪%f
%F{cyan}⠀⠀⠀⠀⠀⢀⡴⣡⠊⢸⣹⠁⠈⠙⣾⡄⠁⠀⢰⠛⠉⠉⠉⢳⣀⣿⣿⠃⠀⠀⣀⣀⣧⣿⡞⣷⡀%f    %F{38}${tenure}%f
%F{cyan}⠀⠀⠀⠀⣠⠋⡴⠁⠀⠸⢿⣤⣤⣤⣹⣿⣷⣶⣾⣷⣶⣶⣺⣋⣽⣿⣷⠶⠟⠛⠋⢧⠀⠀⠸⡜⣷%f
%F{cyan}⠀⠀⠀⢀⡜⠁⡰⠁⠀⠀⢠⡿⠀⠀⠀⠉⠉⠉⠙⢻⡟⣹⣿⠃⣿⠋⠁⠀⠀⠀⠀⠸⡄⠀⠀⢣⠹⣧%f
%F{cyan}⠀⠀⢠⠏⡀⢠⠇⠀⠀⢠⡿⠁⠀⠀⠀⠀⣤⣶⡴⠚⢻⠡⣸⠀⢹⣆⠀⠀⠀⠀⠀⠀⡇⠀⠀⠸⡄⢻⣇%f
%F{cyan}⠀⢀⡏⣼⠁⢸⠀⠀⠀⣾⠃⠀⠀⠀⠀⠀⢻⣿⣧⣀⣬⠋⠁⠀⣠⣿⣶⣆⠀⠀⠀⠀⡇⠀⠀⠀⡇⠈⣿⡀%f
%F{cyan}⠀⣸⣸⣿⠀⡇⠀⢰⣸⡟⠀⠀⠀⣀⣠⠴⠚⣟⣻⣧⣯⣗⣤⣾⣿⣿⡿⠋⠀⠀⠀⣸⣤⠀⠀⠀⡇⡆⢻⠃%f
%F{cyan}⠀⣿⡿⢸⡀⣇⠀⣸⣿⡁⠀⣾⣻⡁⣀⣤⣶⠟⠋⠉⠛⢿⣋⣻⡏⠉⠀⠀⠀⠀⢰⣿⡇⠀⠀⠀⣷⡇⣸⡄%f
%F{cyan}⠀⠿⠇⠀⢧⢸⠀⣿⡿⠇⠀⠈⠛⠛⠋⠉⠀⠀⠀⠀⠀⡟⠀⣿⠇⠀⠀⠀⠀⢠⣿⣿⡇⠀⠀⣰⡿⣧⣿⠃%f
%F{cyan}⠀⠀⠀⠀⠀⢿⣄⣹⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡇⠀⣿⠀⠀⠀⠀⠀⣸⡿⢸⠁⢠⣾⠋⢰⣿⡏%f
%F{cyan}⠀⠀⠀⠀⠀⠀⠉⠛⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣶⣶⡿⠀⠀⠀⠀⠀⠉⠁⢸⣶⡟⠁⠀⠾⠟%f
%F{cyan}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉%f   %F{39}♪ H A T S U N E  M I K U ♪%f
"
fi
