#!/bin/bash
MODULE_NAME="react-native-webgl-arkit"

cp -rf example/node_modules/$MODULE_NAME/{ios,src} ./
cp -rf example/node_modules/$MODULE_NAME/android/{src,build.gradle} ./android
