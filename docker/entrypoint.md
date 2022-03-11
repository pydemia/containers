# Tips: Entrypoint Script

## Forward `SIGTERM` to the child process

In Kubernetes, Pod is terminated by sending `SIGTERM` to each containers(`docker kill --signal TERM`),
and a container is terminated by sending `SIGTERM` to its PID 1, which is the entrypoint
But the container may not be terminated gracefully when you use a shell script as an entrypoint.

An entrypoint bash script works as PID 1 so `SIGTERM` is sent to `bash -c entrypoint.sh` process but
if it has an child process, the child process cannot be terminated and the whole termination is stuck.

Add `trap`, `wait` and `kill` to the entrypoint to receive `SIGTERM` and run the child process as background.

---

Kubernetes에서 Pod 종료 신호는 각 Container에 SIGTERM을 전달하는 방식으로 동작(`docker kill --signal TERM`)하고,
각 Container는 PID 1에 SIGTERM을 전달하여 종료.
그러나 entrypoint를 shell script로 사용하는 경우 SIGTERM으로 즉시 종료되지 않는 경우가 발생. 

bash에서 해당 스크립트를 PID1로 등록하여 동작하므로
종료 시에도 `bash -c entrypoint.sh` 프로세스에 SIGTERM을 전달하지만,
child process는 종료되지 않아 반응이 없는 현상을 보임.

shell script를 수정하여 기존 child process를 background로 실행하면서
sigterm 명령어를 받을 수 있도록 처리.

---

### Example

```bash
#!/bin/bash

prep_term()
{
    unset term_child_pid
    unset term_kill_needed
    trap 'handle_term' TERM INT
}

handle_term()
{
    if [ "${term_child_pid}" ]; then
        kill -TERM "${term_child_pid}" 2>/dev/null
    else
        term_kill_needed="yes"
    fi
}

wait_term()
{
    term_child_pid=$!
    if [ "${term_kill_needed}" ]; then
        printf "Receive TERM signal. Server is shutdown..."
        kill -TERM "${term_child_pid}" 2>/dev/null 
    fi
    wait ${term_child_pid} 2>/dev/null
    trap - TERM INT
    wait ${term_child_pid} 2>/dev/null
}

prep_term

# cd "${0%/*}"

python3 -m your_module \
  $@ & wait_term

```

### Ref.

https://unix.stackexchange.com/questions/146756/forward-sigterm-to-child-in-bash
