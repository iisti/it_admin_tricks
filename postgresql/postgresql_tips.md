# PostgreSQL tips

## Backup database
~~~
pg_dump -h db01.example.com -U "user-name" "database-name" > "database-name"_database_dump_20231127.sql
~~~

## Check size
~~~
SELECT pg_size_pretty(pg_database_size('database_name'))
~~~
