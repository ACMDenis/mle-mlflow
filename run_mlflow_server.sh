#!/bin/bash

# Загружаем переменные из .env (если файл существует)
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Файл .env не найден!"
  exit 1
fi

# Проверка обязательных переменных
if [ -z "$DB_DESTINATION_PORT" ] || [ -z "$DB_DESTINATION_HOST" ] || [ -z "$DB_DESTINATION_USER" ] || [ -z "$DB_DESTINATION_PASSWORD" ] || [ -z "$DB_DESTINATION_NAME" ]; then
  echo "Ошибка: Не заданы переменные для подключения к PostgreSQL!"
  exit 1
fi

# Экспорт переменных для S3
export MLFLOW_S3_ENDPOINT_URL="https://storage.yandexcloud.net"
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"  # Из .env
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"  # Из .env
export AWS_BUCKET_NAME="$S3_BUCKET_NAME"  # Из .env

# Запуск MLflow-сервера
mlflow server \
  --backend-store-uri "postgresql://$DB_DESTINATION_USER:$DB_DESTINATION_PASSWORD@$DB_DESTINATION_HOST:$DB_DESTINATION_PORT/$DB_DESTINATION_NAME" \
  --default-artifact-root "s3://$AWS_BUCKET_NAME" \
  --no-serve-artifacts \
  --host 0.0.0.0 \
  --port 5000