#!/bin/bash

# Startup

# Commands: up run start stop down destroy remove status up restart exec usage
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
if ${RUN_ALL}; then
  COMPOSE_PROFILES=multicloud
fi

usage() {
  echo -e "usage: ./init.sh <command> [args]\n"
  echo -e "Currently supported commands:
    up, run, start           start containers
    stop                    exit containters
    down, destroy, remove   exit and clear containers
    status, up              show compose status
    restart                 restart containers
    exec                    exec terminal to container [args = service name]
    help, usage             show this menu"
}

# Start containters
up() {
  # Copy temp files from floci-ui
  mkdir -p .tmp/init
  cp -rt .tmp/init \
    ../submodules/floci-ui/init/files \
    ../submodules/floci-ui/init/ready.d \
    ../submodules/floci-ui/init/seed-clouds.sh

  # Start main services
  docker compose up -d --wait
}

# Stop containers
stop() {
  docker compose stop
}

# Stop and clear containers
down() {
  docker compose down
}

# Status
ps() {
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

    up | run | start | stop | down | destroy | delete | status | ps | restart| help | usage)
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

    up | run | start)
      up
      ;;

    stop)
      stop
      ;;

    down | destroy | remove)
      down
      ;;

    status | ps)
      ps
      ;;

    restart)
      restart
      ;;

    exec)
      shift 1
      compose_exec "$@"
      ;;

    help | usage)
      usage
      ;;

    *)
      usage
      exit 1
      ;;

  esac
}

main "$@"
