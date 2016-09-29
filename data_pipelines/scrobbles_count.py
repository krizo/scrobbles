from pyspark import SparkConf, SparkContext
import collections
import io
import sys
import operator

reload(sys)
sys.setdefaultencoding('utf-8')
input_file = sys.argv[1]

conf = SparkConf().setMaster("local").setAppName("Scrobbles")
sc = SparkContext(conf = conf)

lines = sc.textFile(input_file)
ratings = lines.map(lambda x: x.split(',')[4])
result = ratings.countByValue()

sortedResults = collections.OrderedDict(sorted(result.items(), key=operator.itemgetter(1)))
for key, value in sortedResults.items():
    print("%s %i" % (key, value))
