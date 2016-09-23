require 'CSV'
require 'pry'
require 'httparty'
require 'psych'


config = Psych.load_file('scrobbles.yml')

user = config['last_fm']['user']
KEY = config['last_fm']['api_key']
page = 0
total = 1485 # total no of pages

def get_track_info(artist, track_name)
  artist.gsub!(" ", '+')
  track_name.gsub!(" ", '+')
  url = "http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=#{KEY}&format=json&artist=#{artist}&track=#{track_name}"
  track_info = HTTParty.get(URI.escape(url))
  if track_info['message'] == "Track not found"
    nil
  else
    track_info
  end
end

CSV.open("#{user}.csv", "wb") do |csv|
  while page < total
    url = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{user}&api_key=#{KEY}&format=json&extended=1"
    response = HTTParty.get(url)
    response['recenttracks']['track'].each do |track|
      track_name = track['name']
      artist = track['artist']['name']
      album = track['album']['#text']
      date = track['date']
      timestamp = date ? date['uts'] : nil
      datestamp = date ? date['#text'] : nil
      track_info = get_track_info(artist, track_name)
      if track_info
        duration = track_info['track']['duration']
        image = if track_info['track']['album'].nil?
          nil
        else
          track_info['track']['album']['image'].first['#text']
        end
        taggings = []
        track_info['track']['toptags']['tag'].each do |tag|
          taggings << tag['name'] unless tag.empty?
        end
        tags = taggings.join(";") if taggings
      else
        duration, image, tags = nil
      end
      csv << [
        user,
        timestamp,
        datestamp,
        artist,
        track_name,
        album,
        duration,
        image,
        tags
      ]
    end
  end
end
