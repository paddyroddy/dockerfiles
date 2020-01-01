#!/bin/bash
docker build --build-arg SSH_PRIVATE="$(cat ~/.ssh/id_rsa)" -t cosmoinformatics .
docker run -it --rm cosmoinformatics bash
