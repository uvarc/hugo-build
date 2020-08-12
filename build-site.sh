#!/bin/sh

set -e

HUGO=${1:-hugo-0.69.0}

REPO=${1:-uvarc/rc-website}
REPODIR=${REPO##*/}

git clone --depth=50 --branch=$TRAVIS_BRANCH https://github.com/${REPO}.git
cd ${REPODIR}
mkdir public

if [ -f static/js/scripts.js ]; then
  yuicompressor --type js static/js/scripts.js > static/js/scripts.min.js
fi
if [ -f static/css/style.css ]; then
  yuicompressor --type css static/css/style.css > static/css/style.min.css
fi

echo "-------------"
echo $REPO
echo $TRAVIS_BRANCH
echo "-------------"

EXPIRES=`date '+%a, %d %b %Y %H:%M:%S GMT' -d "+1 day"`
echo "EXPIRES header set to: " $EXPIRES

if [ $TRAVIS_BRANCH = "master" ]; then
  # HUGO="hugo-v0.59.0";
  # HUGO="hugo-v0.69.0";
  echo "Publishing with: " $HUGO;
  # hugo -v --ignoreCache;
  $HUGO -v --ignoreCache;
  aws s3 sync public s3://$BUCKET_NAME --region=us-east-1 --cache-control public,max-age=$MAX_AGE --expires="$EXPIRES" --metadata generator=$HUGO --delete;
  aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*";
  sleep 10;
  aws lambda invoke --function-name web-crawl --invocation-type Event "outfile.txt"
elif [ $TRAVIS_BRANCH = "staging" ]; then
  # HUGO="hugo-v0.69.0";
  echo "Publishing with: " $HUGO;
  $HUGO -v --ignoreCache;
  aws s3 sync public s3://$BUCKET_NAME_STAGING --region=us-east-1 --cache-control public,max-age=$MAX_AGE --expires="$EXPIRES" --metadata generator=$HUGO --delete;
  aws cloudfront create-invalidation --distribution-id $STAGING_DISTRIBUTION_ID --paths "/*";
  sleep 15;
  aws lambda invoke --function-name web-crawl --invocation-type Event "outfile.txt"
fi
