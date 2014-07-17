//
//  TestResponseHtml.m
//  MultipartResponseParser
//
//  Created by Alexander Vorobjov on 17/07/14.
//  Copyright (c) 2014 Alexander Vorobjov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MultipartResponseParser.h"

@interface TestResponseHtml : XCTestCase

@property (strong, nonatomic) NSArray *cssHeaders;
@property (strong, nonatomic) NSData *cssBody;

@property (strong, nonatomic) NSArray *htmlHeaders;
@property (strong, nonatomic) NSData *htmlBody;

@property (strong, nonatomic) NSArray *parts;

@end

@implementation TestResponseHtml

- (void)setUp
{
    [super setUp];

    self.cssBody = [@"body\r\n{\r\nbackground-color: yellow;\r\n}" dataUsingEncoding:NSUTF8StringEncoding];
    self.cssHeaders = @[
                       @"Content-Type: text/css; charset=utf-8",
                       @"Content-Location: http://localhost:2080/file.css",
                       ];

    self.htmlBody = [@"<html>\n    <head>\n        <link rel=\"stylesheet\" href=\"http://localhost:2080/file.css\">\n    </head>\n    </body>\n        Hello from a html\n        <script type=\"text/javascript\" src=\"http://localhost:2080/file.js\"></script>\n    </body>\n</html>\n\n;" dataUsingEncoding:NSUTF8StringEncoding];

    self.htmlHeaders = @[
                     @"Content-Type: text/html; charset=utf-8",
                     @"Content-Base: http://localhost:2080/",
                     ];

    NSData *boundary = [@"sample_boundary" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *crlf = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *boundaryStart = [@"--" dataUsingEncoding:NSUTF8StringEncoding];

    // css
    NSMutableData *data = [boundaryStart mutableCopy];
    [data appendData:boundary];
    [data appendData:crlf];
    for (NSString *header in self.cssHeaders) {
        [data appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:crlf];
    }

    [data appendData:crlf];
    [data appendData:self.cssBody];
    [data appendData:crlf];
    [data appendData:boundaryStart];
    [data appendData:boundary];

    // html
    [data appendData:crlf];

    for (NSString *header in self.htmlHeaders) {
        [data appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:crlf];
    }

    [data appendData:crlf];
    [data appendData:self.htmlBody];
    [data appendData:crlf];
    [data appendData:boundaryStart];
    [data appendData:boundary];

    // end
    [data appendData:boundaryStart];

    self.parts = [MultipartResponseParser parseData:data];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPartsCount
{
    XCTAssertEqual(self.parts.count, 2, @"bad parts count");
}

- (void)testBody
{
    NSData *cssBody = self.parts[0][kMultipartBodyKey];
    XCTAssertEqualObjects(cssBody, self.cssBody, @"bad css body");

    NSData *htmlBody = self.parts[1][kMultipartBodyKey];
    XCTAssertEqualObjects(htmlBody, self.htmlBody, @"bad html body");
}

@end
