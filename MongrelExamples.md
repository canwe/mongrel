# Mongrel Tutorial #

Mongrel supports several options for creating, reading, updating or deleting documents. This wiki has examples of using Mongrel from the Erlang shell. To run the example code, it's necessary that:
  * You've started the `mongodb` and `mongrel` applications
  * You have compiled the `book_database` module and that the BEAM file is available on the shell's path
  * You've executed `book_database:add_mappings()` to allow the records specified in the `book_database` module to be mapped to documents
  * You've run `book_database:populate()` to write documents into MongoDB.
  * You've executed `rr(book_database)` to allow the records specified in the sample module to be available to the shell.

See ExamplePrerequisites for the details of the above steps.

## CRUD Examples ##
The following pages show how to perform the CRUD operations

  * CreateExamples
  * ReadExamples
  * UpdateExamples
  * DeleteExamples

## Additional Information ##
The following pages contain some material on "query operators" and "update modifiers" when used with Mongrel.

  * QueryConditional
  * UpdateModifier

A page describing some differences between Mongrel cursors and MongoDB cursors:
  * MongrelCursors