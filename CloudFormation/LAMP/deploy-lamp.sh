#!/bin/bash

# Configuración
STACK_NAME="LAMP-RDS"
TEMPLATE_FILE="lamp-rds.yml"

# Parámetros personalizables
DB_NAME="lampdb"
DB_USER="lampdbuser"
DB_PASSWORD="c0m0m0la"
DB_ROOT_USER="admin"
DB_ROOT_PASSWORD="c0m0m0la"

# Validación de la plantilla
echo "📦 Validando plantilla..."
aws cloudformation validate-template --template-body file://$TEMPLATE_FILE
if [ $? -ne 0 ]; then
  echo "❌ La plantilla no es válida. Abortando despliegue."
  exit 1
fi

# Verifica si el stack ya existe
STACK_EXISTS=$(aws cloudformation describe-stacks --stack-name $STACK_NAME 2>/dev/null)

# Definir parámetros
PARAMETERS="ParameterKey=DBName,ParameterValue=$DB_NAME \
ParameterKey=DBUser,ParameterValue=$DB_USER \
ParameterKey=DBPassword,ParameterValue=$DB_PASSWORD \
ParameterKey=DBRootUser,ParameterValue=$DB_ROOT_USER \
ParameterKey=DBRootPassword,ParameterValue=$DB_ROOT_PASSWORD"

# Crear o actualizar el stack
if [ -z "$STACK_EXISTS" ]; then
  echo "🚀 Creando stack $STACK_NAME..."
  aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --parameters $PARAMETERS \
    --capabilities CAPABILITY_IAM

  echo "⏳ Esperando a que se complete la creación..."
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME

  if [ $? -eq 0 ]; then
    echo "✅ Stack $STACK_NAME creado correctamente."
  else
    echo "❌ Error durante la creación del stack."
    exit 1
  fi
else
  echo "🔄 Stack $STACK_NAME ya existe. Intentando actualizar..."

  UPDATE_OUTPUT=$(aws cloudformation update-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --parameters $PARAMETERS \
    --capabilities CAPABILITY_IAM 2>&1)

  UPDATE_STATUS=$?

  if [ $UPDATE_STATUS -eq 0 ]; then
    echo "⏳ Esperando a que se complete la actualización..."
    aws cloudformation wait stack-update-complete --stack-name $STACK_NAME
    echo "✅ Stack $STACK_NAME actualizado correctamente."
  else
    if echo "$UPDATE_OUTPUT" | grep -q "No updates are to be performed"; then
      echo "ℹ️ No hay cambios en la plantilla. El stack ya está actualizado."
    else
      echo "❌ Error durante la actualización del stack:"
      echo "$UPDATE_OUTPUT"
      exit 1
    fi
  fi
fi

# Mostrar outputs del stack
aws cloudformation describe-stacks --stack-name $STACK_NAME \
  --query "Stacks[0].Outputs"
