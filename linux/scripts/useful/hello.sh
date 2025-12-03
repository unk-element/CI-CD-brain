#!/bin/bash

user=$(whoami)
whereami=$(pwd)
date=$(date)
direccionip=$(hostname -I)

# Ask name and say date & ip
echo "Hi, what is your name?"
read name
echo "OK $name, you user is $user  $date, $direccionip."
