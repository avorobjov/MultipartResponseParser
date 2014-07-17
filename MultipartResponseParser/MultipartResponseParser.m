//
//  MultipartResponseParser.m
//  MultipartResponseParser
//
//  Created by Alexander Vorobjov on 17/07/14.
//  Copyright (c) 2014 Alexander Vorobjov. All rights reserved.
//

#import "MultipartResponseParser.h"

@interface MultipartResponseParser ()
@end

@implementation MultipartResponseParser

+ (NSArray *)splitParts:(NSData *)partsData
{
    NSUInteger len = partsData.length;

    NSRange boundaryRange = ({
        NSData *boundaryEnd = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];
        [partsData rangeOfData:boundaryEnd options:0 range:NSMakeRange(0, len)];
    });

    if (boundaryRange.location == NSNotFound) {
        return nil; // TODO: no boundary found — wrong separator?
    }

    NSData *boundary = [partsData subdataWithRange:NSMakeRange(0, boundaryRange.location)];

    NSMutableArray *parts = [[NSMutableArray alloc] init];

    NSUInteger pos = NSMaxRange(boundaryRange);
    while (pos < len) {
        NSRange range = [partsData rangeOfData:boundary options:0 range:NSMakeRange(pos, len - pos)];
        if (range.location == NSNotFound) {
            break;
        }

        NSData *part = [partsData subdataWithRange:NSMakeRange(pos, range.location)];
        [parts addObject:part];

        pos = NSMaxRange(range);
    }

    return [parts copy];
}

+ (NSArray *)parseData:(NSData *)data
{
    return [self splitParts:data];
}

@end
