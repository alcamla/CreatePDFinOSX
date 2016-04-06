//
//  PDFRenderer.h
//  TestingPDFCreation
//
//  Created by camacholaverde on 4/6/16.
//  Copyright © 2016 gibicgroup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFRenderer : NSObject


+(CGContextRef) createPDFContext:(CGRect)aCgRectinMediaBox path:(CFStringRef) aCfStrPath;

+ (CFArrayRef)createColumnsWithColumnCount:(int)columnCount;

@end
