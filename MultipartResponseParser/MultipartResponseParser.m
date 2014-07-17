//
//  MultipartResponseParser.m
//  MultipartResponseParser
//
//  Created by Alexander Vorobjov on 17/07/14.
//  Copyright (c) 2014 Alexander Vorobjov. All rights reserved.
//

#import "MultipartResponseParser.h"

NSString *const kMultipartHeadersKey = @"headers";
NSString *const kMultipartBodyKey = @"body";

@interface MultipartResponseParser ()
@end

@implementation MultipartResponseParser

+ (NSDictionary *)parsePart:(NSData *)data
{
    NSUInteger len = data.length;
    NSData *separator = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];

    NSRange separatorRange = [data rangeOfData:separator options:0 range:NSMakeRange(0, len)];
    if (separatorRange.location == NSNotFound) {
        return nil;
    }

    NSData *headers = [data subdataWithRange:NSMakeRange(0, separatorRange.location)];

    NSUInteger bodyStart = NSMaxRange(separatorRange);
    NSData *body = [data subdataWithRange:NSMakeRange(bodyStart, len - bodyStart)];

    return @{
             kMultipartHeadersKey: headers,
             kMultipartBodyKey: body,
             };
}

+ (NSArray *)splitParts:(NSData *)partsData
{
    NSUInteger len = partsData.length;
    NSData *lineEnd = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];

    NSRange boundaryRange = ({
        [partsData rangeOfData:lineEnd options:0 range:NSMakeRange(0, len)];
    });

    if (boundaryRange.location == NSNotFound) {
        return nil; // TODO: no boundary found — wrong separator?
    }

    NSData *boundary = ({
        NSMutableData *data = [lineEnd mutableCopy];
        [data appendData:[partsData subdataWithRange:NSMakeRange(0, boundaryRange.location)]];
        [data copy];
    });

    NSMutableArray *parts = [[NSMutableArray alloc] init];

    NSUInteger pos = NSMaxRange(boundaryRange);
    while (pos < len) {
        NSRange range = [partsData rangeOfData:boundary options:0 range:NSMakeRange(pos, len - pos)];
        if (range.location == NSNotFound) {
            break;
        }

        NSData *partData = [partsData subdataWithRange:NSMakeRange(pos, range.location - pos)];
        id part = [self parsePart:partData];
        if (part) {
            [parts addObject:part];
        }

        pos = NSMaxRange(range);
    }

    return [parts copy];
}

+ (NSArray *)parseData:(NSData *)data
{
    return [self splitParts:data];
}

@end
