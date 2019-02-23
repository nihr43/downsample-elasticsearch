#!/bin/sh
#
## gradually expires time series metrics in elasticsearch

INDEX="$1"
RND="`dd if=/dev/random bs=16 count=1 | md5`"
HOST="10.0.0.32"
WEEK_AGO="`date -v-7d "+%F"`"
NOW="`date "+%F"`"

new_docs_count () {
  curl -s -X GET 'http://'${HOST}':9200/'${INDEX}'/_search' -H 'Content-Type: application/json' -d '
  {
    "query": {
      "range": {
        "@timestamp": {
          "lt": "'${NOW}'T00:00:00-06:00",
          "gt": "'${WEEK_AGO}'T00:00:00-06:00"
        }
      }
    }
  }' | jq '.hits.total'
}


####


DEL_COUNT=$(expr $(new_docs_count) / 2)
echo ${DEL_COUNT}

exit

curl -s -X POST 'http://'${HOST}':9200/'${INDEX}'/_delete_by_query?size='${DEL_COUNT}'&wait_for_completion=false' -H 'Content-Type: application/json' -d '
{
  "conflicts": "proceed",
  "query": {
    "function_score": {
      "query": {
        "range": {
          "@timestamp": { "lt": "'${WEEK_AGO}'T00:00:00-06:00" }
        }
      },
      "random_score": {
        "seed": "'${RND}'"
      }
    }
  }
}'


curl -s -X GET "${HOST}:9200/_tasks?detailed=true&actions=*/delete/byquery" | jq
