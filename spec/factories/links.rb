FactoryGirl.define do
  factory :link do
    name 'action_report'
    url 'http://localhost:8080/iev/1/action_report.json'
    association :job, factory: [:job, :import]
  end
end
