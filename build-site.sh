#!/bin/sh

set -e

git clone --depth=50 --branch=$TRAVIS_BRANCH https://github.com/uvasomrc/rc-website.git
cd rc-website
mkdir public

yuicompressor --type js static/js/scripts.js > static/js/scripts.min.js
yuicompressor --type css static/css/style.css > static/css/style.min.css

hugo -v --ignoreCache

echo "-------------"
echo $TRAVIS_BRANCH
echo "-------------"

EXPIRES=`date '+%a, %d %b %Y %H:%M:%S GMT' -d "+1 day"`
echo "EXPIRES header set to: " $EXPIRES

if [ $TRAVIS_BRANCH = "master" ]; then
  aws s3 sync public s3://$BUCKET_NAME --region=us-east-1 --cache-control public,max-age=$MAX_AGE --expires="$EXPIRES" --delete;
  aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*";
  sleep 15;
  aws lambda invoke --function-name web-crawl --invocation-type RequestResponse "outfile.txt"
elif [ $TRAVIS_BRANCH = "staging" ]; then 
  aws s3 sync public s3://$BUCKET_NAME_STAGING --region=us-east-1 --cache-control public,max-age=$MAX_AGE --expires="$EXPIRES" --delete;
  aws cloudfront create-invalidation --distribution-id $STAGING_DISTRIBUTION_ID --paths "/*";
elif [ $TRAVIS_BRANCH = "somrc" ]; then
  aws s3 sync public s3://$BUCKET_NAME_SOMRC --region=us-east-1 --cache-control public,max-age=$MAX_AGE --expires="$EXPIRES" --delete;  
  aws cloudfront create-invalidation --distribution-id $SOMRC_DISTRIBUTION_ID --paths "/*";  
fi
