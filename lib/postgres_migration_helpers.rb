module PostgresMigrationHelpers

  def add_pg_foreign_key(from_table, from_columns, to_table, to_columns, on_delete="cascade", matchtype="full")
    constraint_name = gocongress_constraint_name(from_table, from_columns)

    execute %{alter table #{from_table}
      add constraint #{constraint_name}
      foreign key (#{from_columns.join(', ')}) 
      references #{to_table} (#{to_columns.join(', ')}) match #{matchtype}
      on delete #{on_delete} on update cascade
      not deferrable;}
  end

  def remove_pg_foreign_key(from_table, columns)
    constraint_name = gocongress_constraint_name(from_table, columns)
    execute %{alter table #{from_table} 
      drop constraint if exists #{constraint_name} restrict}
  end

  def gocongress_constraint_name(from_table, columns)
    "fk_#{from_table}_#{columns.join('_')}"
  end
end

    
# ALTER TABLE name
#     ADD
#   [ CONSTRAINT constraint_name ]
#   FOREIGN KEY ( column_name [, ... ] ) REFERENCES reftable [ ( refcolumn [, ... ] ) ]
#       [ MATCH FULL | MATCH PARTIAL | MATCH SIMPLE ] [ ON DELETE action ] [ ON UPDATE action ]
#   [ DEFERRABLE | NOT DEFERRABLE ] [ INITIALLY DEFERRED | INITIALLY IMMEDIATE ]
