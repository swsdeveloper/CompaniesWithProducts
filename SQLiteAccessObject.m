//
//  SQLiteAccessObject.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 12/1/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import "SQLiteAccessObject.h"
#import "Constants.h"


@interface SQLiteAccessObject () {
    
    int sqlRetCode;
}
@end


@implementation SQLiteAccessObject

// *******************
// * Private Methods *
// *******************

- (id)initWithDatabase:(NSString *)dbName {
    self = [super init];
    if (self) {
        _dbIsOpen = NO;
        _sqlDbName = dbName;
        _database = nil;
    }
    return self;
}

// This method should never be called
- (void)createDatabase {
    NSLog(@"Program failed - there is no code here to create a database");
}

- (int)openDatabase {
    
    if (MYDEBUG) { NSLog(@"\nOPEN database"); }
    
    if (self.dbIsOpen == YES) {
        NSLog(@"database is Already Open");
        return SQLITE_OK;   // = database is already open
    }
    
    NSLog(@"** %@\n dbIsOpen = %@ **", self.sqlDbName, self.dbIsOpen ? @"YES" : @"NO");
    
    sqlRetCode = sqlite3_open([self.sqlDbName UTF8String], &_database); // Open the database (OK if already open) -- sets |_database| handle)
    
    /*
     SQLITE_API int sqlite3_open(
     const char *filename,   // Database filename (UTF-8)
     sqlite3 **ppDb          // OUT: SQLite db handle
     );
     
     SQLITE_API int sqlite3_open_v2(
     const char *filename,   //Database filename (UTF-8)
     sqlite3 **ppDb,         // OUT: SQLite db handle
     int flags,              // Flags
     const char *zVfs        // Name of VFS module to use
     );
     */
    
    if (sqlRetCode != SQLITE_OK) {
        NSLog(@"*** ERROR: sqlite OPEN failed with error:%d = %s", sqlRetCode, sqlite3_errmsg(self.database));
    } else {
        self.dbIsOpen = YES;
    }
    
    return sqlRetCode;
}

- (int)sqlPrepareStmt:(const char *)sql_stmt {            // Prepare (compile) a stmt for use in Step
    if (!self.dbIsOpen) {
        NSLog(@"*** ERROR: could not PREPARE - database NOT open!");
        return SQLITE_CANTOPEN;
    }
    
    sqlRetCode = sqlite3_prepare(self.database, sql_stmt, -1, &_preparedStmt, NULL);
    
    // DB Handle, UTF8 sql stmt, parm2 len (-1 means ignore len), prepared sql stmt Handle, ptr to unused portion of parm2 (irrelevant in this case)
    
    if (MYDEBUG) { NSLog(@" PREPARE Statement: %s", sql_stmt); }
    
    /*
     SQLITE_API int sqlite3_prepare(
     sqlite3 *db,            // Database handle
     const char *zSql,       // SQL statement, UTF-8 encoded
     int nByte,              // Maximum length of zSql in bytes.
     sqlite3_stmt **ppStmt,  // OUT: Statement handle
     const char **pzTail     // OUT: Pointer to unused portion of zSql
     );
     */
    
    if (sqlRetCode != SQLITE_OK) {
        NSLog(@"*** ERROR: sqlite PREPARE failed with error:%d = %s", sqlRetCode, sqlite3_errmsg(self.database));
    }
    
    return sqlRetCode;
}

- (int)sqlStep {               // Step through (i.e., invoke) a prepared statement
    if (!self.dbIsOpen) {
        NSLog(@"*** ERROR: could not STEP - database NOT open!");
        return SQLITE_CANTOPEN;
    }
    
    sqlRetCode = sqlite3_step(self.preparedStmt);
    
    NSString *sqlRetCodeString = nil;
    
    if (sqlRetCode == 100) { sqlRetCodeString = @"(There is another Row)"; }
    if (sqlRetCode == 101) { sqlRetCodeString = @"(Done!)"; }
    
    if (MYDEBUG) { NSLog(@" STEP thru Prepared Statement returned code: %d = %@", sqlRetCode, sqlRetCodeString); }
    
    /*
     SQLITE_API int sqlite3_step(
     sqlite3*,                                   // An open database
     const char *sql,                            // SQL stmt to be evaluated
     int (*callback)(void*,int,char**,char**),   // Callback function
     void *,                                     // 1st argument to callback
     char **errmsg                               // Error msg written here
     );
     */
    
    return sqlRetCode;
}

- (int)sqlFinalizePreparedStmt {           // Clean up/delete a Prepared stmt
    if (!self.dbIsOpen) {
        NSLog(@"*** ERROR: could not FINALIZE - database NOT open!");
        return SQLITE_CANTOPEN;
    }
    
    sqlRetCode = sqlite3_finalize(self.preparedStmt);
    
    if (MYDEBUG) { NSLog(@" FINALIZE Prepared Statement"); }
    
    if (sqlRetCode != SQLITE_OK) {
        NSLog(@"*** ERROR: sqlite FINALIZE failed with error:%d = %s", sqlRetCode, sqlite3_errmsg(self.database));
    }
    
    return sqlRetCode;
}

- (int)sqlExecStmt:(const char *)stmt {               // Exec is a wrapper for Prepare, Step, and Finalize
    if (!self.dbIsOpen) {
        NSLog(@"*** ERROR: could not EXEC - database NOT open!");
        return SQLITE_CANTOPEN;
    }
    
    char *error;
    sqlRetCode = sqlite3_exec(self.database, stmt, NULL, NULL, &error);
    
    if (MYDEBUG) { NSLog(@" EXEC Statement: %s", stmt); }
    
    /*
     SQLITE_API int sqlite3_exec(
     sqlite3*,                                   // An open database
     const char *sql,                            // SQL stmt to be evaluated
     int (*callback)(void*,int,char**,char**),   // Callback function
     void *,                                     // 1st argument to callback
     char **errmsg                               // Error msg written here
     );
     */
    
    if (sqlRetCode != SQLITE_OK) {
        NSLog(@"*** ERROR: sqlite EXEC failed with error:%d = %s", sqlRetCode, sqlite3_errmsg(self.database));
    }
    
    return sqlRetCode;
}

- (int)closeDatabase {
    if (!self.dbIsOpen) {
        NSLog(@"*** WARNING: No need to CLOSE - database NOT open!");
        return SQLITE_OK;
    }
    
    sqlRetCode = sqlite3_close(self.database);
    
    if (MYDEBUG) { NSLog(@"CLOSE database\n"); }
    
    if (sqlRetCode != SQLITE_OK) {      // eg: SQLITE_BUSY
        NSLog(@"*** ERROR: sqlite CLOSE failed with error:%d = %s", sqlRetCode, sqlite3_errmsg(self.database));
    } else {
        self.dbIsOpen = NO;
    }
    
    return sqlRetCode;
}

@end

