#!/bin/sh

set -e

HUGO=${2:-hugo-0.69.0}
# HUGO.0.81.0=${2:-hugo-0.81.0-ext}

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

if [ $BRANCH = "main" ]; then
  echo "Publishing with: " $HUGO;
  # $HUGO --minify -v --ignoreCache;
  $HUGO -v --ignoreCache;
  # /usr/bin/html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype public/index.html -o public/index.html;
  # if [ -f public/project/index.html ]; then
  #     /usr/bin/html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype public/project/index.html -o public/project/index.html;
  # fi;
  aws s3 sync public s3://$BUCKET_NAME --region=us-east-1 --cache-control public,max-age=$MAX_AGE,s-maxage=$MAX_AGE --expires="$EXPIRES" --metadata generator=$HUGO --delete;
  aws s3 cp public s3://$BUCKET_NAME --metadata-directive REPLACE --exclude "*" --include "*.jpg" --include "*.gif" --include "*.png" --recursive --cache-control max-age=604800,s-maxage=604800
  aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*";
  sleep 10;
  aws lambda invoke --function-name web-crawl --invocation-type Event "outfile.txt"
elif [ $BRANCH = "master" ]; then
  echo "This branch has been deprecated.";
  exit 0;
elif [ $BRANCH = "staging" ]; then
  echo "Publishing with: " $HUGO;
  $HUGO -v --ignoreCache;
  # hugo-0.81.0-ext -v --ignoreCache;
  # /usr/bin/html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype public/index.html -o public/index.html;
  # if [ -f public/project/index.html ]; then
  #     /usr/bin/html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype public/project/index.html -o public/project/index.html;
  # fi;
  aws s3 sync public s3://$BUCKET_NAME_STAGING --region=us-east-1 --cache-control public,max-age=$MAX_AGE,s-maxage=$MAX_AGE --expires="$EXPIRES" --metadata generator=$HUGO --delete;
  aws s3 cp public s3://$BUCKET_NAME_STAGING --metadata-directive REPLACE --exclude "*" --include "*.jpg" --include "*.gif" --include "*.png" --recursive --cache-control max-age=604800,s-maxage=604800
  aws cloudfront create-invalidation --distribution-id $STAGING_DISTRIBUTION_ID --paths "/*";
  sleep 10;
  aws lambda invoke --function-name web-crawl --invocation-type Event "outfile.txt"
elif [ $BRANCH = "feature" ]; then
  echo "Publishing with: " $HUGO;
  $HUGO --minify -v --ignoreCache;
  # hugo-0.81.0-ext -v --ignoreCache;
  # /usr/bin/html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype public/index.html -o public/index.html;
  # if [ -f public/project/index.html ]; then
  #     /usr/bin/html-minifier --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype public/project/index.html -o public/project/index.html;
  # fi;
  aws s3 sync public s3://$BUCKET_NAME_FEATURE --region=us-east-1 --cache-control public,max-age=$MAX_AGE,s-maxage=$MAX_AGE --expires="$EXPIRES" --metadata generator=$HUGO --delete;
  aws s3 cp public s3://$BUCKET_NAME_FEATURE --metadata-directive REPLACE --exclude "*" --include "*.jpg" --include "*.gif" --include "*.png" --recursive --cache-control max-age=604800,s-maxage=604800
  aws cloudfront create-invalidation --distribution-id $FEATURE_DISTRIBUTION_ID --paths "/*";
fi
