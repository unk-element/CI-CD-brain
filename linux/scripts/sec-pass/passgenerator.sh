#!/bin/bash
length=${1:-16}
openssl rand -base64 32 | cut -c1-$length
