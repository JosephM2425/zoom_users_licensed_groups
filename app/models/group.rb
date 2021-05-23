# == Schema Information
#
# Table name: groups
#
#  id         :bigint           not null, primary key
#  name       :string
#  schedule   :time
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Group < ApplicationRecord
    validates :name, :schedule, presence: true
    has_and_belongs_to_many :users
end
