#!/usr/bin/env bash

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    docker pull keyiz/manylinux-coreir
    docker run -d --name manylinux --rm -i -t keyiz/manylinux-coreir bash
    docker exec manylinux git clone https://github.com/leonardt/pycoreir
    docker exec manylinux bash -c "cd pycoreir && python setup.py bdist_wheel"
    docker exec manylinux bash -c "auditwheel show /pycoreir/dist/*.whl"
    # we should have any external linked libraries at this point
    docker exec manylinux bash -c "cd pycoreir && auditwheel repair dist/*.whl"
    # install the wheel for testing
    docker exec manylinux bash -c "cd pycoreir && pip install wheelhouse/*.whl"
    docker exec manylinux pip install pytest
else
     export PYTHON=3.7.0
     brew install pyenv-virtualenv
     pyenv install ${PYTHON}
     export PYENV_VERSION=$PYTHON
     export PATH="/Users/travis/.pyenv/shims:${PATH}"
     pyenv virtualenv venv
     source /Users/travis/.pyenv/versions/${PYTHON}/envs/venv/bin/activate
     python --version

     python -m pip install cmake twine wheel pytest
     python setup.py bdist_wheel
     pip install dist/*.whl
fi