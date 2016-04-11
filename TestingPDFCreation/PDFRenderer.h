//
//  PDFRenderer.h
//  TestingPDFCreation
//
//  Created by camacholaverde on 4/6/16.
//  Copyright © 2016 gibicgroup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFRenderer : NSObject


/// The name of the font used by default in the pdf generation
+(NSString*)defaultFontName;


/// The default size of the page used to generate the pdf
+(CGRect)defaultPageRect;

/// Indicates the horizontal space available for laying out text
+(CGFloat)defaultParagraphWidth;

/// Indicates the vertical space that must be discarted at the top or bottom of the page
+(CGFloat)defaultVerticalOffset;

/// Inicates the space that must be discarted horizontally
+(CGFloat)defaultHorizontalOffset;

///
+(CGFloat)yCoordinateForPointWithDistanceFromTop:(CGFloat)topDistance;

///
+(CGContextRef) newPDFContext:(CGRect)aCgRectinMediaBox
                         path:(CFStringRef) aCfStrPath;
///
+(void)layoutTitleInPDFContext:(CGContextRef)aCgPDFContextRef
                          text:(NSString*)string
                atTopLeftPoint:(CGPoint)origin;
///
+(void)layouHeaderInPDFContext:(CGContextRef)aCgPDFContextRef
                          text:(NSString*)string
                atTopLeftPoint:(CGPoint)origin;
///
+(void)layoutBodyInPDFContext:(CGContextRef)aCgPDFContextRef
                         text:(NSString*)string
               atTopLeftPoint:(CGPoint)origin;

///
+(void)layoutColumnarContentInPDFContext:(CGContextRef)aCgPDFContextRef
                                withText:(NSString*)string
                                  inRect:(CGRect)rowRect
                        inNumberOfColums:(int)numberOfColumns
                       withSplitedColums:(NSArray<NSNumber*>*)splitedColumsArray;
///
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
