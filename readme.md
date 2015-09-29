# Active Record Lite

ORM inspired by the functionality of Active Record written in Ruby

## Features
- SQL Object connects to SQLite3 database using DBConnection with heredocs. Table_info, all, find, insert, update, and save methods are all supported.
- Searchable module allows you to execute stackable WHERE queries, escaping input for you.
- Associatable module supports belongs_to, has_many, and has_one_through relations

## To do
- Implement has_many_through relation
- Includes method to pre-fetch
- Model Level Validations
- Joins

## To use this:
- Clone or extract a zip of this repo.
- In your project, `require-relative './ActiveRecordLite/arlite.rb'`
- Call 'DBConnection.open(YOUR_DB_FILE_PATH)' to load your SQLite3 Database.
- Have your model inherit the SQLObject as you would have and ActiveRecord object in Rails.
- Save records to the database with the usual pattern creating a new model and calling save on it.
- Search by one or more columns using `where`, or use `lazy_where` to stack methods.
- Retrieve rows by association.
