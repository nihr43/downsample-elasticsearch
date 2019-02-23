## expire-elasticsearch

A method of gradually expiring time-series metrics data in elasticsearch.

Usage:

Edit the global vars, and run it on an index.

```sh
./expire.sh telegraf
```

#### Rational

This tool uses elasticsearch's random_score function to randomly delete a given number of documents from an index.  By querying the number of 'hits' within a range ( read: the number of new metrics "this week" ), and deleting this number of documents from the entire index, we are able to maintain a constant database size and a gradual resolution "trail-off" with time.  Because we are deleting an even, random spread of documents, new data will naturally be of higher resolution, and old data will surely but slowly expire, as it has been exposed to more random delete cycles.  The quality of this "slope" will depend on the quality of randomness used as the "seed" in the delete query.

To allow an index to grow, the expression determining the number of documents to be deleted should be tuned.  Currently, half the number of new documentws per week are deleted.

In theory, this method could be used to create a nice, even time-series metrics database in elasticsearch with no hard cutoff, allowing one to retain long-term "climate" data, and short-term detail.
