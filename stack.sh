#!/bin/bash

STACK_NAME=web-app-stack
TEMPLATE_FILE=ubuntu.yml

aws cloudformation deploy --stack-name $STACK_NAME --template-file $TEMPLATE_FILE --capabilities CAPABILITY_IAM

# Obtener URL de la aplicacion
if [ $? -eq 0 ]; then
    aws cloudformation list-exports \
        --query "Exports[?Name=='IPaddress'].Value"
fi