//
//  MultipartResponseParserTests.m
//  MultipartResponseParserTests
//
//  Created by Alexander Vorobjov on 17/07/14.
//  Copyright (c) 2014 Alexander Vorobjov. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MultipartResponseParser.h"

@interface MultipartResponseParserTests : XCTestCase

@end

@implementation MultipartResponseParserTests

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

- (void)testResponseData
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"response" ofType:@"data"]];

    NSArray *items = [MultipartResponseParser parseData:data];
    XCTAssertEqual(items.count, 1, @"bad parts count");
}

@end
