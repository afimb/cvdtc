FactoryGirl.define do
  factory :job do
    user
    name 'Metz GTFS'
    file 'gtfs_current.zip'
    file_md5 'bae9ad8e3a61808d8b2c4b758c10fa79'
    status :pending
  end

  trait :import do
    format :gtfs
  end

  trait :convert do
    format :gtfs
    format_convert :convert_neptune
  end

  trait :import_export do
    format :gtfs
    format_convert :convert_gtfs
  end

  trait :import_with_url do
    format :gtfs
    file nil
    url 'http://geo-ws.metzmetropole.fr/services/opendata/gtfs_current.zip'
  end

  trait :import_with_wrong_url do
    format :gtfs
    file nil
    url 'ftp://data.toulouse-metropole.fr/explore/dataset/tisseo-gtfs/files/bd1298f158bc39ed9065e0c17ebb773b/download/'
  end
end
