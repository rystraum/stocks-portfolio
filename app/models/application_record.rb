# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  after_commit :backup

  def backup
    dest = "#{Dir.home}/Dropbox/Finances/Stocks/DB"
    return unless File.directory?(dest)

    `cp #{Rails.root.join('db')}/development.sqlite3 #{dest}/backup-#{DateTime.now.to_formatted_s(:iso8601).parameterize}.sqlite3`
  end
end
