class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  DISPLAY_DATETIME = "%Y/%m/%d %T".freeze
end
