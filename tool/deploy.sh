#!/usr/bin/env bash
set -eo pipefail

DISTRIBUTION_ID=$(jq -r .Coffee.DistributionId backend/outputs.json)
PROXY_URL=$(jq -r .Coffee.ProxyUrl backend/outputs.json)

flutter pub get
flutter build web --release --dart-define=PROXY_URL=$PROXY_URL

aws s3 sync build/web s3://coffee.dillonnys.com --delete
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*" >/dev/null
