 FactoryGirl.define do
  factory :job do
    user
    name 'Tisseo GTFS'
    file 'tisseo_gtfs.zip'
    file_md5 '6b464070117e27b80ab0b1c2826b3970'
    status :scheduled
  end

  trait :import do
    format :gtfs
  end

  trait :export do
    format :gtfs
    format_export :export_neptune
  end

  trait :import_export do
    format :gtfs
    format_export :export_gtfs
  end

  trait :import_with_url do
    format :gtfs
    file nil
    url 'https://data.toulouse-metropole.fr/explore/dataset/tisseo-gtfs/files/bd1298f158bc39ed9065e0c17ebb773b/download/'
  end

   trait :import_with_wrong_url do
     format :gtfs
     file nil
     url 'ftp://data.toulouse-metropole.fr/explore/dataset/tisseo-gtfs/files/bd1298f158bc39ed9065e0c17ebb773b/download/'
   end
end
