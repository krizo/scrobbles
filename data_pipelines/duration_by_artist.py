from pyspark import SparkConf, SparkContext
import collections
import io
import sys
import operator

reload(sys)
sys.setdefaultencoding('utf-8')

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

durations = rdd.reduceByKey(lambda x, y: (x + y) )
for x in sorted(durations.collect(), key=operator.itemgetter(1)):
    artist = x[0]
    duration = x[1]
    m, s = divmod(duration, 60)
    h, m = divmod(m, 60)
    print "%s:  %dh:%02dm:%02ds" % (artist, h, m, s)
