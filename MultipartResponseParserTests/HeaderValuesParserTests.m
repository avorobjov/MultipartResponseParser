//
//  HeaderValuesParserTests.m
//  MultipartResponseParser
//
//  Created by Alexander Vorobjov on 18/07/14.
//  Copyright (c) 2014 Alexander Vorobjov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MultipartResponseParser.h"

@interface MultipartResponseParser ()

+ (NSDictionary *)headerValuesFromString:(NSString *)values;

@end

@interface HeaderValuesParserTests : XCTestCase

@end

@implementation HeaderValuesParserTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1
{
    NSDictionary *values = [MultipartResponseParser headerValuesFromString:@"text/css; charset=utf-8"];

    XCTAssertEqual(values.count, 2, @"bad values count");
    XCTAssertEqualObjects(values[@"text/css"], @"");
    XCTAssertEqualObjects(values[@"charset"], @"utf-8");
}

- (void)test2
{
    NSDictionary *values = [MultipartResponseParser headerValuesFromString:@"form-data; name=\"2793dfd2-7f5a-4b13-931e-5a9aa6b5fdce;1076\"; filename=\"eb691f45-20d5-4add-b787-9b2b9bae4b25\""];

    XCTAssertEqual(values.count, 3, @"bad values count");
    XCTAssertEqualObjects(values[@"form-data"], @"");
    XCTAssertEqualObjects(values[@"name"], @"2793dfd2-7f5a-4b13-931e-5a9aa6b5fdce;1076");
    XCTAssertEqualObjects(values[@"filename"], @"eb691f45-20d5-4add-b787-9b2b9bae4b25");
}

- (void)test3 {
    NSDictionary *values = [MultipartResponseParser headerValuesFromString:@"http://localhost:2080/file.css"];

    XCTAssertEqual(values.count, 1, @"bad values count");
    XCTAssertEqualObjects(values[@"http://localhost:2080/file.css"], @"");
}

- (void)test4 {
    NSDictionary *values = [MultipartResponseParser headerValuesFromString:@"multipart/form-data; charset=ISO-8859-1"];

    XCTAssertEqual(values.count, 2, @"bad values count");
    XCTAssertEqualObjects(values[@"multipart/form-data"], @"");
    XCTAssertEqualObjects(values[@"charset"], @"ISO-8859-1");
}


@end
