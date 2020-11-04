#!/usr/bin/env bash

export BP_MODE="DEVELOPMENT"

if [ "$GITHUB_EVENT_NAME" = "create" ]; then
  if [[ "${GITHUB_REF}" =~ "tags" ]]; then
    BP_MODE="PRODUCTION"
  fi
fi

echo "BP_MODE=${BP_MODE}" >>$GITHUB_ENV

echo "the BP_MODE is '${BP_MODE}'"