#!/bin/bash

export CORNN_DIR=/CoRNN_DT1_tractography

source $CORNN_DIR/venv/bin/activate
python3 $CORNN_DIR/src/generate.py $@
deactivate
