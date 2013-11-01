# Start numbering at 1
set -g base-index 1

# Allows for faster key repetition
set -s escape-time 0

# random options
setw -g automatic-rename
set-option -g default-terminal "screen-256color"
set-option -g allow-rename off

# # status bar
set-option -g status-utf8 on
set-option -g status-justify left
set-option -g status-bg black
set-option -g status-fg cyan
set-option -g status-interval 5
set-option -g status-left-length 20
set-option -g status-left '#[fg=green]Â» #[fg=black,bold]#T#[fg=green] /#[default]'
set-option -g status-right '#[fg=green] ###S  #[fg=black,bold]%R %m-%d#[default]'
set-window-option -g window-status-current-fg white

# # clock
set-window-option -g clock-mode-colour cyan
set-window-option -g clock-mode-style 12

# # pane borders
set-option -g pane-border-fg white
set-option -g pane-active-border-fg green


# Rather than constraining window size to the maximum size of any client 
# connected to the *session*, constrain window size to the maximum size of any 
# client connected to *that window*. Much more reasonable.
setw -g aggressive-resize on

bind-key -r k select-pane -U
bind-key -r j select-pane -D
bind-key -r h select-pane -L
bind-key -r l select-pane -R

bind-key -r C-k resize-pane -U
bind-key -r C-j resize-pane -D
bind-key -r C-h resize-pane -L
bind-key -r C-l resize-pane -R

setw -g mode-keys vi
bind-key -t vi-copy 'v' begin-selection
bind-key -t vi-copy 'y' copy-selection
