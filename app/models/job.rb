class JobFormatValidator < ActiveModel::Validator
  def validate(record)
    if record.format_export
      if record.format_export.end_with?(record.format)
        record.errors[:format_export] << I18n.t('activerecord.errors.messages.invalid_format_export')
      end
    end
  end
end

class Job < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true
  validates :format, presence: true
  validates :file, presence: true
  validates :file_md5, presence: true
  validates_with JobFormatValidator

  enum format: [ :gtfs, :neptune, :netex ]
  enum format_export: [ :export_gtfs, :export_neptune, :export_netex ] # TODO - Upgrade to Rails5 and add suffix http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html
  enum status: [ :scheduled, :terminated, :canceled ]
end
