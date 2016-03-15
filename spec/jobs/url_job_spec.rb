require 'rails_helper'

RSpec.describe UrlJob, type: :job do
  context '#validate_or_convert' do
    let(:job_with_url) { create(:job, :import_with_url) }

    it 'can download file from url' do
      # UrlJob.perform_now(job_with_url.id)
      # expect(File.file?(Rails.root.join(job_with_url.path_file))).to be_truthy
    end
  end
end
