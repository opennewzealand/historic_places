require "place.rb"
require "logger"

desc "download records from the site"
task :download_records do
  if ENV["start"] && ENV["end"]
    (ENV['start'].to_i..ENV['end'].to_i).each do |record_number|
      place = Place.new(record_number, false)
      if place.valid_record?
        p "Processing: #{record_number}"
        f = File.new("raw/#{record_number}.html", "w")
        f.puts place.raw
        f.close
      else
        p "Skipping: #{record_number}"
        f = File.new("raw/#{record_number}.skip", "w")
        f.puts place.raw
        f.close
      end    
    end
  else
    p "Example Usage: rake download_records start=1 end=100"
  end
end

desc "List all attributes that could match fields"
task :list_attributes do 
  fields = []
  (ENV['start'].to_i..ENV['end'].to_i).each do |record_number|
    p "Processing record #{record_number}"
    place = Place.new(record_number, false)  
    fields += place.possible_fields
  end
  p fields.uniq.sort
end

namespace :json do
  desc "Write out a single record from the cahce to a file"
  task :single_from_cache do
    if File.exists?("raw/#{ENV['id']}.html")
      place = Place.new(ENV['id'], false)

      #Write out a single record
      data = File.new("place_#{ENV['id']}.json", "w+")
      data.write(place.to_json)
      data.close
      
    elsif File.exists?("raw/#{ENV['id']}.skip")
      p "Record not found"
    else
      p "record not downloaded"
    end
  end

  desc "Write out all records from the cache to a file using start and end ID's"
  task :all_from_cache do
    if ENV["start"] && ENV["end"]
      all = {}
      (ENV['start'].to_i..ENV['end'].to_i).each do |record_number|
        p "Processing #{record_number}"
        if File.exists?("raw/#{record_number}.html")
          place = Place.new(record_number, false)
          all[record_number] = place.formatted_fields
        elsif File.exists?("raw/#{record_number}.skip")
          p "Record not found"
        else
          p "record not downloaded"
        end
      end
      data = File.new("all.json", "w+")
      data.write(all.to_json)
      data.close
    else
      p "Example Usage: rake json:all_from_cache start=1 end=100"
    end
  end
end