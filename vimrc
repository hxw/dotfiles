
# 'sudow" command to runs the 'w' under sudo in order to edit R/O or root owned files
cnoremap sudow w !sudo tee % >/dev/null
