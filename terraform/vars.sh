#!/usr/bin/env bash

echo "Decrypting ansible variable with ansible vault"
for i in `ansible-vault view secrets.env`
do
  unset TF_VAR_$i
done
echo "Environment variables set"
