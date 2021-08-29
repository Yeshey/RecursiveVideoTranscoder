#!/bin/bash

read rsp
echo $rsp

read -p "do you wish to append _f to transcoded videos?, videos that end with _f won't be transcoded y/n: " yn

while true; do
    read -p "do you wish to append _f to transcoded videos?, videos that end with _f won't be transcoded y/n: " yn
    case $yn in
        [Yy]* ) name_f="_f"; break;;
        [Nn]* ) name_f=""; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
