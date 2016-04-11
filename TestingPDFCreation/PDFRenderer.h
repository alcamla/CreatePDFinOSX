//
//  PDFRenderer.h
//  TestingPDFCreation
//
//  Created by camacholaverde on 4/6/16.
//  Copyright © 2016 gibicgroup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFRenderer : NSObject


+(NSString*)defaultFontName;

+(CGRect)defaultPageRect;

+(CGFloat)defaultParagraphWidth;

+(CGFloat)defaultVerticalOffset;

+(CGFloat)defaultHorizontalOffset;

+(CGFloat)yCoordinateForPointWithDistanceFromTop:(CGFloat)topDistance;

+(CGContextRef) newPDFContext:(CGRect)aCgRectinMediaBox
                         path:(CFStringRef) aCfStrPath;
+(CGPoint)layoutTitleInPDFContext:(CGContextRef)aCgPDFContextRef
                          text:(NSString*)string
                atTopLeftCorner:(CGPoint)origin;

+(CGPoint)layouHeaderInPDFContext:(CGContextRef)aCgPDFContextRef
                          text:(NSString*)string
                atTopLeftCorner:(CGPoint)origin;

+(CGPoint)layoutBodyInPDFContext:(CGContextRef)aCgPDFContextRef
                         text:(NSString*)string
               atTopLeftCorner:(CGPoint)origin;

+(void)layoutColumnarContentInPDFContext:(CGContextRef)aCgPDFContextRef
                                withText:(NSString*)string
                                  inRect:(CGRect)rowRect
                        inNumberOfColums:(int)numberOfColumns
                       withSplitedColums:(NSArray<NSNumber*>*)splitedColumsArray;

+(void)layoutTableWithColumnCount:(int)numberOfColums
                                 rowCount:(int)rowCount
                      subColumsForColumns:(NSArray<NSNumber*>*)columnsWithSubcolumns
                         contentForHeader:(NSArray<NSString*>*)headerContentArray
                          contentForTable:(NSArray<NSString*>*)tableContentArray
                              withRowSize:(CGSize)rowsSize
                                   inPage:(CGRect)page
                        withOffsetFromTop:(CGFloat)verticalOffset
                                 centered:(BOOL)isCentered
                                inContext:(CGContextRef)aCgPDFContextRef;

@end
