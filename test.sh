#!/bin/sh

set -e

IMAGE="bowling-api"
RAILS_ENV="RAILS_ENV=test"

function print_error {
  echo "TESTS FAILED!!"
  echo "Exiting.."
  exit 1
}

trap "print_error" ERR

if [[ -z "$(docker images -q $IMAGE)" ]]; then
  echo "Docker image not found!"
  exit 1
fi

docker run --rm -v ${pwd}:/app -e $RAILS_ENV $IMAGE \
  /bin/sh -c "rubocop && brakeman -Az5 -i .brakeman.ignore && rspec"

echo "Tests were executed successfully!"
echo "Exiting.."

exit 0
