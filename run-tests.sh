#!/bin/bash
set -e

OAREPO_VERSION=${OAREPO_VERSION:-11}
OAREPO_VERSION_MAX=$((OAREPO_VERSION+1))
if [ -d .venv-builder ] ; then
    rm -rf .venv-builder
fi
rm -rf .venv-builder

MODEL_WITH_EXPANDABLE_FIELDS="model_document"
MODEL_REFERENCED="model_file"

# export OPENSEARCH_PORT=9400
python3 -m venv .venv-builder
.venv-builder/bin/pip install -U setuptools pip wheel
.venv-builder/bin/pip install -e .

BUILDER=.venv-builder/bin/oarepo-compile-model

for MODEL in $MODEL_WITH_EXPANDABLE_FIELDS $MODEL_REFERENCED
do
  if test -d ./tests/$MODEL; then
    rm -rf ./tests/$MODEL
  fi
  ${BUILDER} ./tests/$MODEL.yaml --output-directory ./tests/$MODEL -vvv
  rm -rf .venv-tests
  python3 -m venv .venv-tests
  source .venv-tests/bin/activate
  pip install -U setuptools pip wheel
  pip install "oarepo>=$OAREPO_VERSION,<$OAREPO_VERSION_MAX"
  pip install -e ./tests/$MODEL
  pip install pytest-invenio
done
pytest tests/test_models