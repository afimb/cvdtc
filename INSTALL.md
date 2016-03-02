Getting started
===============

Requirements
------------

- [Ruby](http://www.ruby-lang.org) 2.3.x
- [Rails](http://rubyonrails.org) 4.2.x
- [Redis](http://redis.io)
- [Sidekiq](http://sidekiq.org)
- [CVDTC_CV](https://github.com/afimb/cvdtc_cv)

Clone the repository
--------------------

`git clone https://github.com/afimb/cvdtc.git`

Create and fill the file database.yml
-------------------------------------

`cp config/database.example.yml config/database.yml`

Create and fill the file application.yml
----------------------------------------

`cp config/application.example.yml config/application.yml`

Create database
---------------

`bin/rake db:create`

Create tables
-------------

`bin/rake db:migrate`

Run the application
-------------------

`bin/rails s`

or

`foreman start`

Do not forget to start Sidekiq
------------------------------

`bundle exec sidekiq -C config/sidekiq.yml`
