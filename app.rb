#
# Tweet analyser
#

require 'dotenv'
require 'twitter'

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def cyan(text); colorize(text, 36); end
def green(text); colorize(text, 32); end
def blue(text); colorize(text, 34); end

TWEET_COUNT = 200
DAY_DIVIDER = 86400

Dotenv.load

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['CONSUMER_KEY']
  config.consumer_secret     = ENV['CONSUMER_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

if ARGV.count > 0
  screen_name = ARGV[0]
  tweets = client.user_timeline(screen_name, count: TWEET_COUNT)

  if tweets.count > 0
    start_date = tweets.first.created_at
    end_date = tweets.last.created_at
    tweets_per_day = tweets.count / ((start_date - end_date) / DAY_DIVIDER)
    days_since_last_tweet = (DateTime.now.to_time - start_date) / DAY_DIVIDER
    days_between_tweets = (start_date - end_date) / DAY_DIVIDER

    puts "\nTweets analyser for #{green(screen_name)}"
    puts cyan("==================================")
    puts "\n#{green(screen_name)} tweeted #{green(tweets_per_day.round(2))} times per day over a period of #{blue(days_between_tweets.round(0))} days."
    puts "\nIt has been #{green(days_since_last_tweet.round(0))} day(s) since their last tweet on #{blue(start_date.strftime("%A%e %B, %Y"))}."
    puts ""
  end
else
  file = open('twitter_stats.csv', 'w')

  file << "Account, Tweets per day, Start date, End date\n"

  client.friends.each do |friend|
    tweets = client.user_timeline(friend.screen_name, count: TWEET_COUNT)
    next if tweets.count == 0

    start_date = tweets.first.created_at
    end_date = tweets.last.created_at
    tweets_per_day = tweets.count / ((start_date - end_date) / DAY_DIVIDER)

    file << "#{friend.screen_name}, #{tweets_per_day.round(1)}, #{start_date.strftime("%Y-%m-%d %H:%M")}, #{end_date.strftime("%Y-%m-%d %H:%M")}\n"
  end

  file.close
end

