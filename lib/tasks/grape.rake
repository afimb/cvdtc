namespace :grape do
  desc "API routes"
  task :routes => :environment do
    API::Root.routes.map { |route| puts "#{route} \n" }
  end
end
