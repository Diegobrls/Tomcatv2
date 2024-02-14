#!/bin/bash

STACK_NAME="web-app-stack"

aws cloudformation delete-stack --stack-name "$STACK_NAME"
