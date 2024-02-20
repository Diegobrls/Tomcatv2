#!/bin/bash

STACK_NAME="Tomcat-stack"

aws cloudformation delete-stack --stack-name "$STACK_NAME"
