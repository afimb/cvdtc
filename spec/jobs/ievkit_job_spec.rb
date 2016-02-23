require 'rails_helper'

RSpec.describe IevkitJob, type: :job do
  context '#validate' do
    let(:job_with_url) { create(:job, :import_with_url) }

    it 'can download file from url' do
      IevkitJob.perform_now(id: job_with_url.id, job_url: 'http://cvdtc.lvh.me/job/1')
      job_with_url.reload
      expect(job_with_url.scheduled?).to be_truthy
      expect(job_with_url.short_url).to be
      expect(job_with_url.list_links).to have_key(:forwarding_url)
    end
  end
end
