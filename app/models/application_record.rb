# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  after_commit :backup

  def self.to_csv
    require 'csv'

    base = "#{Dir.home}/Dropbox/Finances/Stocks/CSV/#{DateTime.now.to_date.to_s}"
    FileUtils.mkdir_p base

    csv_string = CSV.generate do |csv|
      csv << column_names
      all.each do |record|
        csv << column_names.collect do |column|
          record[column]
        end
      end
    end

    File.write("#{base}/#{table_name}.csv", csv_string)
  end

  def self.from_csv(date)
    require 'csv'

    file = "#{Dir.home}/Dropbox/Finances/Stocks/CSV/#{date.to_date.to_s}/#{table_name}.csv"

    CSV.foreach(file, headers: true) do |row|
      record = self.find_by(id: row["id"])

      attrs = row.to_h
      if !row["meta"].blank?
        attrs["meta"] = JSON.parse row["meta"].gsub("=>", ":")
      end

      if record.blank?
        create(attrs)
      else
        # update?
      end

      # If PK sequence is not set properly:
      # ActiveRecord::Base.connection.tables.each do |t|
      #   ActiveRecord::Base.connection.reset_pk_sequence!(t)
      # end
    end
  end

  def backup
    return true if Rails.env.production?
    return true if ENV.fetch('STOCKS_BACKUP', 'true') == 'false'

    base = "#{Dir.home}/Dropbox/Finances/Stocks/DB"
    return true unless File.directory?(base)

    adapter = Rails.configuration.database_configuration[Rails.env]["adapter"]
    db = Rails.configuration.database_configuration[Rails.env]["database"]

    timestamp = DateTime.now
    timestamp_seconds = timestamp.to_i

    last_backup_timestamp = begin
      File.read("#{Rails.root.join('tmp')}/last_backup_timestamp.txt")
    rescue Errno::ENOENT
      0
    end

    # only backup once every 30 minutes
    time_diff = timestamp_seconds - last_backup_timestamp.to_i
    if time_diff < 30.minutes.to_i
      puts "skipping backup for #{(30.minutes.to_i - time_diff) / 60} minutes"
      return true
    end

    File.write("#{Rails.root.join('tmp')}/last_backup_timestamp.txt", timestamp_seconds)

    dest = "#{base}/#{timestamp.year}/#{format('%02d', timestamp.month)}/#{format('%02d', timestamp.day)}"
    FileUtils.mkdir_p("#{dest}")

    filename = "#{timestamp.beginning_of_hour.to_formatted_s(:iso8601).parameterize}"

    if adapter.match? /sqlite/
      `cp #{Rails.root.join('db')}/development.sqlite3 #{dest}/#{filename}.sqlite3`
    elsif adapter.match? /postgresql/
      sqldump = "#{Rails.root.join('tmp')}/#{filename}.sql"
      `pg_dump #{db} > #{sqldump}; cp #{sqldump} #{dest}/#{filename}.sql && rm #{sqldump}`
    end

    ActiveRecord::Base.connection.tables.each do |t|
      t.classify.constantize.to_csv
    rescue NameError
      # there are tables that are not part of the app, I think
    end
  end
end
