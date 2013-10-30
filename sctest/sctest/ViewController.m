//
//  ViewController.m
//  sctest
//
//  Created by croath on 10/30/13.
//  Copyright (c) 2013 Croath. All rights reserved.
//

#import "ViewController.h"
#import "FMDatabase.h"

@interface ViewController (){
    FMDatabase *_ncdb;
    FMDatabase *_cdb;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initDatabase];
}

- (void)initDatabase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath1 = [documentsDirectory stringByAppendingPathComponent:@"testdb_normal.db"];
    
    _ncdb = [FMDatabase databaseWithPath:dbPath1];
    
//    if (_ncdb != nil) {
//        if (![_ncdb open]) {
//            [_ncdb open];
//        }
//    }
    
    NSString *dbPath2 = [documentsDirectory stringByAppendingPathComponent:@"testdb_sc.db"];
    _cdb = [FMDatabase databaseWithPath:dbPath2];
    
//    if (_cdb != nil) {
//        if (![_cdb openWithFlags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_SHAREDCACHE]) {
//            [_cdb openWithFlags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_SHAREDCACHE];
//        }
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectInDBCached:(BOOL)cached{
    __block NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
    
    __block int n = 0;
    int max = 1000;
    dispatch_queue_t queue = dispatch_queue_create("com.croath.selectQ", NULL);
    for (int i = 0; i < max; i ++) {
        __block FMDatabase *db;
        if (cached) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *dbPath2 = [documentsDirectory stringByAppendingPathComponent:@"testdb_sc.db"];
            db = [FMDatabase databaseWithPath:dbPath2];
            [db openWithFlags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_SHAREDCACHE];
        }
        dispatch_async(queue, ^{
            if (!cached) {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *dbPath1 = [documentsDirectory stringByAppendingPathComponent:@"testdb_normal.db"];
                db = [FMDatabase databaseWithPath:dbPath1];
                [db open];
            }
            for (int j = 0; j < 10; j ++) {
                
                [db executeQueryWithFormat:@"select * from t1 where id = %d", j];
            }
            [db close];
            @synchronized (self){
                n++;
                if (n == max) {
                    NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
                    __block NSTimeInterval result = end - start;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (cached) {
                            [_c2Result setText:[NSString stringWithFormat:@"%f", result]];
                        } else {
                            [_nc2Result setText:[NSString stringWithFormat:@"%f", result]];
                        }
                    });
                }
            }
        });
    }
}


- (IBAction)nc2:(id)sender {
     [self selectInDBCached:NO];
}

- (IBAction)c2:(id)sender {
    [self selectInDBCached:YES];
}
@end
