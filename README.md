# README

Import:
  console run
    `rake to:stdout fetch_data:csv_file`
  cron run
    `RAILS ENV='production' BUNDLE EXEC rake fetch_data:csv_file file=/var/data/source.csv`
Clean DB:
  `rake fetch_data:clean_db`

Search for data with ransack filters:
  `curl -X GET http://localhost:3000/api/v1/products -d 'q[producer_cont]=Waters'`