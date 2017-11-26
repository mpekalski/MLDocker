#!/bin/bash
set -e
export TENSORBOARD_LOGDIR='/models'
exec ${CONDA_DIR}/bin/tensorboard --logdir=${TENSORBOARD_LOGDIR}
