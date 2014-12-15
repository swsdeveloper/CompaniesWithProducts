//
//  DataAccessObject.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 12/1/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface SQLiteAccessObject : NSObject

@property (assign, nonatomic) BOOL dbIsOpen;

@property (retain, nonatomic) NSString *sqlDbName;        // Full path and database name

@property (assign, nonatomic) sqlite3 *database;          // pointer to a SQLite3 database file handle

// Each open SQLite database is represented by a pointer to an instance of
// the opaque structure named "sqlite3".  It is useful to think of an sqlite3
// pointer as an object.  The [sqlite3_open()], [sqlite3_open16()], and
// [sqlite3_open_v2()] interfaces are its constructors, and [sqlite3_close()]
// is its destructor.  There are many other interfaces (such as
// [sqlite3_prepare_v2()], [sqlite3_create_function()], and
// [sqlite3_busy_timeout()] to name but three) that are methods on an
// sqlite3 object.

@property (assign, nonatomic) const char *sql_stmt;

@property (assign, nonatomic) sqlite3_stmt *preparedStmt;

// This object is variously known as a "prepared statement", a "compiled SQL statement", or simply as a "statement".
//
//       The life of a statement object goes something like this:
//        - 1. Create the object using sqlite3_prepare_v2() or a related function
//        - 2. Bind values to [host parameters] using the sqlite3_bind_*() interfaces
//        - 3. Run the SQL by calling sqlite3_step() one or more times
//        - 4. Reset the statement using sqlite3_reset() then go back to step 2.  Do this zero or more times (optional)
//        - 5. Destroy the object using sqlite3_finalize()

- (id)initWithDatabase:(NSString *)dbName;

- (void)createDatabase;

- (int)openDatabase;

- (int)sqlPrepareStmt:(const char *)stmt;

- (int)sqlStep;

- (int)sqlFinalizePreparedStmt;

- (int)sqlExecStmt:(const char *)stmt;

- (int)closeDatabase;

@end
