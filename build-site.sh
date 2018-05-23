#!/bin/sh

set -e

git clone --depth=50 --branch=$TRAVIS_BRANCH https://github.com/uvasomrc/rc-website.git
cd rc-website
mkdir public

hugo -v --ignoreCache

echo "-------------"
echo $TRAVIS_BRANCH
echo "-------------"

if [ $TRAVIS_BRANCH = "master" ]; then
  aws s3 sync public s3://$BUCKET_NAME --region=us-east-1 --delete;
  aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*";
elif [ $TRAVIS_BRANCH = "staging" ]; then 
  aws s3 sync public s3://$BUCKET_NAME_STAGING --region=us-east-1 --delete
  aws cloudfront create-invalidation --distribution-id $STAGING_DISTRIBUTION_ID --paths "/*"
fi
