module PostgresMigrationHelpers

  def add_pg_check_constraint table, expression
    cns_name = ck_constraint_name(table, expression)
    execute %{
      alter table #{table}
      add constraint #{cns_name}
      check (#{expression});
    }
  end

  def add_pg_foreign_key(from_table, from_columns, to_table, to_columns, on_delete="cascade", matchtype="full")
    cns_name = fk_constraint_name(from_table, from_columns)

    execute %{alter table #{from_table}
      add constraint #{cns_name}
      foreign key (#{from_columns.join(', ')})
      references #{to_table} (#{to_columns.join(', ')}) match #{matchtype}
      on delete #{on_delete} on update cascade
      not deferrable;}
  end

  def remove_pg_check_constraint table, expression
    cns_name = ck_constraint_name(table, expression)
    drop_constraint(from_table, cns_name)
  end

  def remove_pg_foreign_key(from_table, columns)
    cns_name = fk_constraint_name(from_table, columns)
    drop_constraint(from_table, cns_name)
  end

  private

  # To preserve compatability with postgres 8.3, `drop_constraint`
  # does not use the 'if exists' clause.
  def drop_constraint table, cns_name
    execute %{alter table #{table}
      drop constraint #{cns_name} restrict}
  end

  def ck_constraint_name table, expression
    expression_identifier = expression.gsub(/[^a-z_0-9]/, '')
    cns_name = "ck_#{table}_#{expression_identifier}"
    raise "Invalid identifier" unless is_valid_identifier(cns_name)
    cns_name
  end

  def fk_constraint_name table, columns
    "fk_#{table}_#{columns.join('_')}"
  end

  # A valid postgres identifier must start with a letter.  Subsequent
  # characters can be letters, underscores, or digits. The entire
  # identifier must be fewer than 63 bytes long.
  # http://bit.ly/FUNSCI
  def is_valid_identifier id
    /\A[a-z][a-z_0-9]*\z/.match(id).present? && id.length <= 63
  end
end
