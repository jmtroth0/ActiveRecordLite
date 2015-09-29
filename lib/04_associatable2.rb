require_relative '03_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      source_table = source_options.model_class.table_name
      own_table = through_options.model_class.table_name
      result = DBConnection.execute(<<-SQL, self.send(through_options.primary_key))
        SELECT  #{source_table}.*
        FROM    #{own_table}
        JOIN    #{source_table}
        ON      #{own_table}.#{source_options.foreign_key} =
                #{source_table}.#{through_options.primary_key}
        WHERE
                #{own_table}.#{source_options.primary_key} = ?

      SQL
      source_options.model_class.new(result.first)
    end
  end
end
