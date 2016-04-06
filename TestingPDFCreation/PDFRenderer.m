//
//  PDFRenderer.m
//  TestingPDFCreation
//
//  Created by camacholaverde on 4/6/16.
//  Copyright © 2016 gibicgroup. All rights reserved.
//

#import "PDFRenderer.h"

@implementation PDFRenderer


-(void)createPDF{
    
}

+(CGContextRef) createPDFContext:(CGRect)aCgRectinMediaBox path:(CFStringRef) aCfStrPath
{
    CGContextRef aCgContextRefNewPDF = NULL;
    CFURLRef aCfurlRefPDF;
    aCfurlRefPDF = CFURLCreateWithFileSystemPath (NULL,aCfStrPath,kCFURLPOSIXPathStyle,false);
    if (aCfurlRefPDF != NULL) {
        aCgContextRefNewPDF = CGPDFContextCreateWithURL (aCfurlRefPDF,&aCgRectinMediaBox,NULL);
        CFRelease(aCfurlRefPDF);
    }
    return aCgContextRefNewPDF;
}


+ (CFArrayRef)createColumnsWithColumnCount:(int)columnCount
{
    int column;
    
    CGRect* columnRects = (CGRect*)calloc(columnCount, sizeof(*columnRects));
        // Set the first column to cover the entire view.
    CGRect pageRect = CGRectMake(0, 0, 612, 792);
    
    columnRects[0] = pageRect;
    
        // Divide the columns equally across the frame's width.
    CGFloat columnWidth = CGRectGetWidth(pageRect) / columnCount;
    for (column = 0; column < columnCount - 1; column++) {
        CGRectDivide(columnRects[column], &columnRects[column],
                     &columnRects[column + 1], columnWidth, CGRectMinXEdge);
    }
    
        // Inset all columns by a few pixels of margin.
    for (column = 0; column < columnCount; column++) {
        columnRects[column] = CGRectInset(columnRects[column], 8.0, 15.0);
    }
    
        // Create an array of layout paths, one for each column.
    CFMutableArrayRef array =
    CFArrayCreateMutable(kCFAllocatorDefault,
                         columnCount, &kCFTypeArrayCallBacks);
    
    for (column = 0; column < columnCount; column++) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, columnRects[column]);
        CFArrayInsertValueAtIndex(array, column, path);
        CFRelease(path);
    }
    free(columnRects);
    return array;
}



@end


