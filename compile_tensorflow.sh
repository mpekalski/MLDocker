export VER_PYTHON=python3.5
cd /tmp/tensorflow && \
export PYTHON_BIN_PATH=$(which python3)
/usr/bin/python3 configure.py  && \
bazel build --config=opt --config=cuda --verbose_failures //tensorflow/tools/pip_package:build_pip_package  && \
bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg && \
cd ../tensorflow_pkg/  && \
pip3 install *.whl 
