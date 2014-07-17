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

@property (strong, nonatomic) NSArray *parts;

@end

@implementation MultipartResponseParserTests

- (void)setUp
{
    [super setUp];

    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"response" ofType:@"data"]];

    self.parts = [MultipartResponseParser parseData:data];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPartsCount
{
    XCTAssertEqual(self.parts.count, 1, @"bad parts count");
}

- (void)testPartContent
{
    NSDictionary *part = [self.parts firstObject];
    XCTAssert(part[kMultipartBodyKey], @"no part body");
    XCTAssert(part[kMultipartHeadersKey], @"no part header");
}

- (void)testPartBody
{
    NSDictionary *part = [self.parts firstObject];
    NSData *body = part[kMultipartBodyKey];
    XCTAssert([body isKindOfClass:[NSData class]], @"bad body class");
    XCTAssertEqual(body.length, 1088, @"bad body length");  // correct length 1076 ?? (from headers)
}

- (void)testHeaders
{
    NSDictionary *headers = [self.parts firstObject][kMultipartHeadersKey];
    XCTAssertEqual(headers.count, 3, @"bad headers count");

    NSArray *headerNames = [headers allKeys];
    for (NSString *name in @[@"Content-Disposition", @"Content-Type", @"Content-Transfer-Encoding"]) {
        XCTAssert([headerNames containsObject:name], @"headers missing %@", name);
    }
}

- (void)testContentDisposition
{
    // Content-Disposition: form-data; name="2793dfd2-7f5a-4b13-931e-5a9aa6b5fdce;1076"; filename="eb691f45-20d5-4add-b787-9b2b9bae4b25"
    NSDictionary *cd = [self.parts firstObject][kMultipartHeadersKey][@"Content-Disposition"];
    XCTAssert(cd, @"Content-Disposition not found");

    NSArray *keys = [cd allKeys];
    XCTAssertEqual(keys.count, 3, @"bad keys count");
}

@end
