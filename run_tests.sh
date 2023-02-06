#!/bin/bash
set -e

MODEL_WITH_EXPANDABLE_FIELDS="model_document"
MODEL_REFERENCED="model_file"
VENV=".model_venv"
# export OPENSEARCH_PORT=9400
python3 -m venv $VENV
. $VENV/bin/activate
pip install -U setuptools pip wheel
for MODEL in $MODEL_WITH_EXPANDABLE_FIELDS $MODEL_REFERENCED
do
  if test -d ./tests/$MODEL; then
    rm -rf ./tests/$MODEL
  fi
  oarepo-compile-model ./tests/$MODEL.yaml --output-directory ./tests/$MODEL -vvv
  pip install "./tests/$MODEL[tests]"
done
pytest tests/test_models.py