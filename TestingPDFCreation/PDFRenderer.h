//
//  PDFRenderer.h
//  TestingPDFCreation
//
//  Created by camacholaverde on 4/6/16.
//  Copyright © 2016 gibicgroup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFRenderer : NSObject


+(CGContextRef) newPDFContext:(CGRect)aCgRectinMediaBox path:(CFStringRef) aCfStrPath;

+ (CFArrayRef)createColumnsWithColumnCount:(int)columnCount;

+(void)createColumnarContentInPDFContext:(CGContextRef)aCgPDFContextRef withText:(NSString*)string;

+(void)createCustomColumnarContentInPDFContext:(CGContextRef)aCgPDFContextRef withText:(NSString*)string inRect:(CGRect)rowRect;

@end
