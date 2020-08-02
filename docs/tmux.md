In the virtual machines is tmux used to run background processes. See also here: https://wiki.ubuntuusers.de/tmux/

```bash
# tmux basics
## list open session
tmux ls

## create a new session 
tmux new -s new_session_name

## attach a session
tmux attach -s new_session_name

# detach a tmux session
CTRL-B d 
```
