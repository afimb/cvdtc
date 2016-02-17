class Link < ActiveRecord::Base
  belongs_to :job
  validates :name, presence: true, uniqueness: { scope: :job_id }
  validates :url, presence: true, format: URI.regexp(%w(http https))
  validates :job, presence: true
end
