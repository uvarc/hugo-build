#!/bin/sh

set -e

HUGO=${2:-hugo-0.69.0}

REPO=${1:-uvarc/rc-website}
REPODIR=${REPO##*/}

git clone --depth=50 --branch=$BRANCH https://github.com/${REPO}.git
cd ${REPODIR}
mkdir public

if [ -f static/js/scripts.js ]; then
  yuicompressor --type js static/js/scripts.js > static/js/scripts.min.js
fi
if [ -f static/css/style.css ]; then
  yuicompressor --type css static/css/style.css > static/css/style.min.css
fi
if [ -f static/js/user-session.js ]; then
  yuicompressor --type js static/js/user-session.js > static/js/user-session.min.js
fi

echo "-------------"
echo $REPO
echo $BRANCH
echo "-------------"

EXPIRES=`date '+%a, %d %b %Y %H:%M:%S GMT' -d "+1 day"`
echo "EXPIRES header set to: " $EXPIRES

if [ $BRANCH = "master" ]; then
  # HUGO="hugo-v0.59.0";
  # HUGO="hugo-v0.69.0";
  echo "Publishing with: " $HUGO;
  # hugo -v --ignoreCache;
  $HUGO -v --ignoreCache;
  /usr/bin/html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype public/index.html -o public/index.html;
  aws s3 sync public s3://$BUCKET_NAME --region=us-east-1 --cache-control public,max-age=$MAX_AGE --expires="$EXPIRES" --metadata generator=$HUGO --delete;
  aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*";
  sleep 10;
  aws lambda invoke --function-name web-crawl --invocation-type Event "outfile.txt"
elif [ $BRANCH = "staging" ]; then
  # HUGO="hugo-v0.69.0";
  echo "Publishing with: " $HUGO;
  $HUGO -v --ignoreCache;
  /usr/bin/html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype public/index.html -o public/index.html;
  aws s3 sync public s3://$BUCKET_NAME_STAGING --region=us-east-1 --cache-control public,max-age=$MAX_AGE --expires="$EXPIRES" --metadata generator=$HUGO --delete;
  aws cloudfront create-invalidation --distribution-id $STAGING_DISTRIBUTION_ID --paths "/*";
  sleep 15;
  aws lambda invoke --function-name web-crawl --invocation-type Event "outfile.txt"
fi
