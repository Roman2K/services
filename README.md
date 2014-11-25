## Installation

```shell
$ npm install mongroup
```

## tmux-status-server

Why a long-running server instead of short-lived shell scripts?

I prefer Ruby over Bash. But since my status is refreshed often, interpreter
startup time is important. Bash is very fast. Ruby is very slow. Hence, a
long-running Ruby process that serves text on demand very fast to a simple
socket client. Another advantage that comes with this approach is the ability to
cache values once for several tmux instances.
