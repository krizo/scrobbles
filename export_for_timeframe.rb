require 'last_fm_client'
require 'exporter'
require 'psych'

config = Psych.load_file('scrobbles.yml')

user = config['last_fm']['user']
api_key = config['last_fm']['api_key']

last_fm_client = LastfmClient.new(api_key, user)
# start_time = Time.parse("2009-01-01 21:00:00 UTC")
# end_time = Time.parse("2013-05-04 20:57:00 UTC")
start_time = Time.parse(ARGV[0])
end_time = Time.parse(ARGV[1])
output_file = ARGV[2] || "#{last_fm_client.user}_#{end_time.to_date}-#{start_time.to_date}.csv"
exporter = CsvExporter.new(last_fm_client, output_file)
exporter.export_for_timeframe(output_file, start_time, end_time)
