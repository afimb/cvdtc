require 'rails_helper'

RSpec.describe Job, type: :model do
  it 'has a valid factory' do
    expect(build(:job, :import)).to be_valid
    expect(build(:job, :import_with_url)).to be_valid
  end

  context '#import' do
    let(:job_import) { build(:job, :import) }
    let(:job_export) { build(:job, :export) }

    it 'has empty format_export' do
      expect(job_import.format_export).to be_nil
    end
    it 'has a format_export' do
      expect(job_export.format).to_not be_nil
      expect(job_export.format_export).to_not be_nil
      expect(job_export.format_export).to_not eq(job_export.format)
    end
    it 'has error on same format' do
      job = build(:job, :import_export)
      expect(job).to_not be_valid
      expect(job.errors).to have_key(:format_export)
    end
  end
end
