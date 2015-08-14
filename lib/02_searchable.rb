require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.map { |column, value| "#{column} = ?"}.join(" AND ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    results.map { |result| self.new(result)}
  end

  def lazy_where(params)
    Relation.new(self, self.table_name, params)
  end
end

class SQLObject
  extend Searchable
end

class Relation
  attr_reader :klass, :table_name, :loaded
  attr_accessor :values

  def initialize(klass, table_name, values = {})
    @klass = klass
    @table_name = table_name
    @values = values
    @loaded = false
  end

  def run_relation
    results = DBConnection.execute(<<-SQL, values[:where].values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL
  end

  def add_where_values(values)
    if values[:where]
      values[:where] += values
    else
      values[:where] = [values]
    end
  end

  def get_where_line
    values[:where].map { |column, value| "#{column} = ?"}.join(" AND ")
  end
end
