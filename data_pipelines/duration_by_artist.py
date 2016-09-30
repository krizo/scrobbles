from pyspark import SparkConf, SparkContext
import collections
import io
import sys
import operator
from helpers import display_time

def parseLine(line):
    fields = line.split(',')
    artist = fields[4].encode('utf8')
    duration = 0 if fields[7] == '' else int(fields[7]) / 1000;
    if duration == 0:
        duration = 180
    return (artist, duration)

input_file = sys.argv[1]
conf = SparkConf().setMaster("local").setAppName("DurationByArtist")
sc = SparkContext(conf = conf)

lines = sc.textFile(input_file)
rdd = lines.map(parseLine)

durations = rdd.reduceByKey(lambda x, y: (x + y) ).collect()
total_durations = sum([duration[1] for duration in durations]) # this is ugly :(

for x in sorted(durations, key=operator.itemgetter(1)):
    artist = x[0]
    duration = x[1]
    print(artist + ": " + display_time(duration, 3))

print("Total duration: " + display_time(total_durations))
print("Number of artists: %d" % len(durations))
