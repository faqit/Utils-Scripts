#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Use root or SUDO" >&2
  exit 1
fi

