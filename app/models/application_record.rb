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
    dest = "#{Dir.home}/Dropbox/Finances/Stocks/DB"
    return unless File.directory?(dest)

    `cp #{Rails.root.join('db')}/development.sqlite3 #{dest}/backup-#{DateTime.now.to_formatted_s(:iso8601).parameterize}.sqlite3`
  end
end
