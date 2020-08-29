#!/bin/sh

set -e

if [ -z "$AWS_PROFILE" ]; then
  echo "AWS_PROFILE is not set."
  exit 1
fi

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set."
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  echo "AWS_REGION is not set."
  exit 1
fi

if [ -z "$BUILD_DIR" ]; then
  echo "BUILD_DIR is not set."
  exit 1
fi

if [ -z "$DISTRIBUTION_ID" ]; then
  echo "DISTRIBUTION_ID is not set."
  exit 1
fi

# Do not cache index.htmls
aws s3 sync --content-encoding='gzip' --content-type='text/html' --exclude='*' --include='*index.html.gz' --delete --cache-control max-age=0,no-store,no-cache,must-revalidate ${BUILD_DIR} s3://${AWS_S3_BUCKET}
aws s3 sync --content-encoding='br' --content-type='text/html' --exclude='*' --include='*index.html.br' --delete --cache-control max-age=0,no-store,no-cache,must-revalidate ${BUILD_DIR} s3://${AWS_S3_BUCKET}
aws s3 sync --content-type='text/html' --exclude='*' --include='*index.html' --delete --cache-control max-age=0,no-store,no-cache,must-revalidate ${BUILD_DIR} s3://${AWS_S3_BUCKET}

# We have eight cases of metadata to set specifically: html, css, js, and ttf with brotli and gzip encoding for each
aws s3 sync --content-encoding='gzip' --content-type='text/html' --exclude='*' --include='*.html.gz' --delete --cache-control max-age=31536000 ${BUILD_DIR} s3://${AWS_S3_BUCKET}
aws s3 sync --content-encoding='gzip' --content-type='text/css' --exclude='*' --include='*.css.gz' --delete --cache-control max-age=31536000 ${BUILD_DIR} s3://${AWS_S3_BUCKET}
aws s3 sync --content-encoding='gzip' --content-type='application/javascript' --exclude='*' --include='*.js.gz' --delete --cache-control max-age=31536000 ${BUILD_DIR} s3://${AWS_S3_BUCKET}
aws s3 sync --content-encoding='gzip' --content-type='font/ttf' --exclude='*' --include='*.ttf.gz' --delete --cache-control max-age=31536000 ${BUILD_DIR} s3://${AWS_S3_BUCKET}

aws s3 sync --content-encoding='br' --content-type='text/html' --exclude='*' --include='*.html.br' --delete --cache-control max-age=31536000 ${BUILD_DIR} s3://${AWS_S3_BUCKET}
aws s3 sync --content-encoding='br' --content-type='text/css' --exclude='*' --include='*.css.br' --delete --cache-control max-age=31536000 ${BUILD_DIR} s3://${AWS_S3_BUCKET}
aws s3 sync --content-encoding='br' --content-type='application/javascript' --exclude='*' --include='*.js.br' --delete --cache-control max-age=31536000 ${BUILD_DIR} s3://${AWS_S3_BUCKET}
aws s3 sync --content-encoding='br' --content-type='font/ttf' --exclude='*' --include='*.ttf.br' --delete --cache-control max-age=31536000 ${BUILD_DIR} s3://${AWS_S3_BUCKET}

# .ttf fonts were not detecting content-type properly
aws s3 sync --content-type='font/ttf' --exclude='*' --include='*.ttf' --delete --cache-control max-age=31536000 ${BUILD_DIR} s3://${AWS_S3_BUCKET}

# Everything else can use default metadata
aws s3 sync --delete --cache-control max-age=31536000 ${BUILD_DIR} s3://${AWS_S3_BUCKET}

aws cloudfront create-invalidation --distribution-id ${DISTRIBUTION_ID} --paths '/*'