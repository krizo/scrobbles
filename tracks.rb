require 'last_fm_client'
require 'exporter'
require 'psych'

config = Psych.load_file('scrobbles.yml')

user = config['last_fm']['user']
api_key = config['last_fm']['api_key']

last_fm_client = LastfmClient.new(api_key, user)
csv_file = "#{last_fm_client.user}.csv"
exporter = CsvExporter.new(last_fm_client, csv_file)
exporter.export_recent_tracks(csv_file, { start_page: 3, end_page: 3 })
