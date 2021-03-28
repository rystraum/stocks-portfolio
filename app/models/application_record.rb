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

  def backup
    dest = "#{Dir.home}/Dropbox/Finances/Stocks/DB"
    return unless File.directory?(dest)

    `cp #{Rails.root.join('db')}/development.sqlite3 #{dest}/backup-#{DateTime.now.to_formatted_s(:iso8601).parameterize}.sqlite3`
  end
end
