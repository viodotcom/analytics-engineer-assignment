.DEFAULT_GOAL := run

create-empty-table:
	@echo "Creating empty table"
	@sqlite3 db/assignment.db  ".read sql/create-empty-table.sql"

# TODO: Add all the necessary steps to complete the assignment
run:
