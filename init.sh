#!/bin/bash

# Startup

# Commands: run start up stop prune down status up restart exec usage
COMMAND=$1

# Load and set env variables
set -a
source .env
set +a

# Add second compose config with activated persistence
if ${PERSISTENCE}; then
  COMPOSE_FILE+=":docker-persistence.yml"
fi

# Activate multicloud profile to deploy all services (AWS + Azure, GCP, OCI)
if [[ "$RUN_ALL" == "true" ]]; then
  COMPOSE_PROFILES=multicloud
fi

usage() {
  echo -e "usage: ./init.sh <command> [args]\n"
  echo -e "Currently supported commands:\n  run, start, up\tstart containers\n  stop\t\t\texit containters\n  prune, down\t\texit and clear containers\n  status, up\t\tshow compose status\n  restart\t\trestart containers\n  exec\t\t\texec terminal to container [args = service name]"
}

# Start containters
run() {
  # Copy temp files from floci-ui
  mkdir -p .tmp/init
  cp -rt .tmp/init \
    submodules/floci-ui/init/files \
    submodules/floci-ui/init/ready.d \
    submodules/floci-ui/init/seed-clouds.sh #/files submodules/floci-ui/init/seed-clouds.sh

  # Start main services
  docker compose up -d --wait # AWS only
}

# Exit containers
stop() {
  docker compose stop
}

# Exit and clear containers
prune() {
  docker compose down
}

# Status
status() {
  docker compose ps -a
}

# Restart
restart() {
  docker compose restart
}

# Exec
compose_exec() {
  docker compose exec -it "$@" /bin/sh
}

check_command() {
  # Safe command assign
  local command="${1:-}"

  # Safe shift (if only one argument was passed)
  shift || true

  case $command in

    run | start | up | stop | prune | down | status | ps | restart)
      if [[ "$#" -gt 0 ]]; then
        echo "Too many arguments for '$COMMAND'!"
        exit 1
      fi
      ;;

    exec)
      if [[ "$#" -gt 1 ]]; then
        echo -e "Too many arguments for '$COMMAND'!\nOnly allowed: 1 (container name)"
        exit 1
      fi
      ;;

    *)
      echo "Not existing command '$command'"
      usage
      exit 1
      ;;

  esac
}

main() {
  check_command "$@"

  case $COMMAND in

    run | start | up)
      run
      ;;

    stop)
      stop
      ;;

    prune | down)
      prune
      ;;

    status | ps)
      status
      ;;

    restart)
      restart
      ;;

    exec)
      shift 1
      compose_exec "$@"
      ;;

    *)
      usage
      exit 1
      ;;

  esac
}

main "$@"
