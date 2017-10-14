#!/bin/bash
set -e
export TENSORBOARD_LOGDIR='/tmp'
exec ${CONDA_DIR}/bin/tensorboard --logdir=${TENSORBOARD_LOGDIR}
