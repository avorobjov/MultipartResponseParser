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

+ (NSArray *)parseHeaders:(NSData *)data
{
    NSUInteger len = data.length;
    NSData *lineSeparator = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *headerSeparator = [@":" dataUsingEncoding:NSUTF8StringEncoding];

//    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    NSMutableArray *headers = [[NSMutableArray alloc] init];

    NSUInteger pos = 0;
    while (pos < len) {
        NSRange lineSeparatorRange = [data rangeOfData:lineSeparator options:0 range:NSMakeRange(pos, len - pos)];
        NSData *lineData;
        if (lineSeparatorRange.location == NSNotFound) {
            lineData = [data subdataWithRange:NSMakeRange(pos, len - pos)];
            pos = len;
        } else {
            lineData = [data subdataWithRange:NSMakeRange(pos, lineSeparatorRange.location - pos)];
            pos = NSMaxRange(lineSeparatorRange);
        }

        [headers addObject:lineData];

//        NSUInteger lineLen = lineData.length;
//        NSRange headerSeparatorRange = [lineData rangeOfData:headerSeparator options:0 range:NSMakeRange(0, lineLen)];
//        if (headerSeparatorRange.location == NSNotFound) {
//            NSLog( @"%s warning: bad header line: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:lineData encoding:NSASCIIStringEncoding] );
//            continue;
//        }
//
//        NSData *headerNameData = [lineData subdataWithRange:NSMakeRange(0, headerSeparatorRange.location)];
//
//        NSUInteger valueStart = NSMaxRange(headerSeparatorRange);
//        NSData *headerValueData = [lineData subdataWithRange:NSMakeRange(valueStart, lineLen - valueStart)];
//
//        NSString *key = [[NSString alloc] initWithData:headerNameData encoding:NSUTF8StringEncoding];
//        NSString *values = [[NSString alloc] initWithData:headerValueData encoding:NSUTF8StringEncoding];
//        if (key && values) {
//            headers[key] = [self parseHeaderValuesFromString:values];
//        }
    }
    
    return [headers copy];
}

+ (NSDictionary *)parsePart:(NSData *)partData
{
    NSUInteger len = partData.length;
    NSData *separator = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];

    NSRange separatorRange = [partData rangeOfData:separator options:0 range:NSMakeRange(0, len)];
    if (separatorRange.location == NSNotFound) {
        return nil;
    }

    NSData *headers = [partData subdataWithRange:NSMakeRange(0, separatorRange.location)];

    NSUInteger bodyStart = NSMaxRange(separatorRange);
    NSData *body = [partData subdataWithRange:NSMakeRange(bodyStart, len - bodyStart)];

    return @{
             kMultipartHeadersKey: [self parseHeaders:headers],
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
        return nil;
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

        NSRange newLineRange = [partsData rangeOfData:lineEnd options:NSDataSearchAnchored range:NSMakeRange(pos, len - pos)];
        if (newLineRange.location != NSNotFound) {
            pos = NSMaxRange(newLineRange);
        }
    }

    return [parts copy];
}

+ (NSArray *)parseData:(NSData *)data
{
    return [self splitParts:data];
}

@end
