#!/bin/bash

# dependencies
# brew install wget cmake protobuf bazelisk opencv@3
# brew uninstall --ignore-dependencies glog

pip install wheel
pip install six

mediapipe_tag="v0.8.9"
mediapipe_dir="mediapipe"

# cleanup
rm -rf $mediapipe_dir

# download
git clone --recurse-submodules --shallow-submodules --depth 1 --branch $mediapipe_tag https://github.com/google/mediapipe.git $mediapipe_dir

# prepare
root_dir=$(pwd)
patches_dir="$root_dir/patches"
dist_dir="$root_dir/dist"
mkdir -p "$dist_dir"

# build
export GLOG_logtostderr=1
pushd $mediapipe_dir || exit

pip install -r requirements.txt

# apply patches
git apply "$patches_dir/fix-arm.patch"
git apply "$patches_dir/setup.patch"
git apply "$patches_dir/workspace.patch"

# build
python setup.py gen_protos
python setup.py bdist_wheel

pushd dist || exit

# delocate
pip install delocate
delocate-wheel -v ./*.whl

# copy to release
cp -a ./*.whl "$dist_dir"

popd || exit
popd || exit

echo "done."
