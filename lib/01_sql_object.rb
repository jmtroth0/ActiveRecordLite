require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject

  def self.columns
    table = DBConnection.execute2("SELECT * FROM #{self.table_name}")

    table[0].map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) { attributes[column] }

      define_method("#{column}=") do |column_name|
        attributes[column] = column_name
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    parse_all DBConnection.execute(<<-SQL)
      SELECT #{table_name}.*
      FROM #{self.table_name}
    SQL
  end

  def self.parse_all(results)
    results.map { |row| self.new(row) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{self.table_name}
      WHERE id = ?
      LIMIT 1
    SQL

    return nil unless result[0]
    self.new(result[0])
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym unless attr_name.is_a?(Symbol)
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end

      send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |column| send(column) }
  end

  def insert
    col_names = self.class.columns
    question_marks = "(#{(["?"] * col_names.length).join(", ")})"
    col_names = col_names.join(", ")
    DBConnection.execute(<<-SQL, *(self.attribute_values))
      INSERT INTO
        #{self.class.table_name}
      VALUES
        #{question_marks}
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    # table_name = self.class.table_name
    columns_with_values = self.class.columns.map do |column|
      "#{column} = ?"
    end.join(", ")
    DBConnection.execute(<<-SQL, *(self.attribute_values), self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{columns_with_values}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
