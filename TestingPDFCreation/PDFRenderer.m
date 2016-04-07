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

+(CGContextRef) newPDFContext:(CGRect)aCgRectinMediaBox path:(CFStringRef) aCfStrPath
{
        // Note: It is very important that the method names follow the "Create rule", when working with Core Foundation objects.  In objective C, the analogy to the "create" is “alloc”, “new”, “copy”, or “mutableCopy”, in order to give the compiler clarity that the responsability of memory management is given to the caller or the method.
    
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
    
        // Create a pointer to hold the array of column rectangles
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

-(CFArrayRef)createTableRowWithColumnCount:(int)columnCount  origin:(CGPoint)rowOrigin rowSize:(CGSize)rowSize{
    
    int column;
    
        // Create a pointer to hold the array of column rectangles
    CGRect* columnRects = (CGRect*)calloc(columnCount, sizeof(*columnRects));
    
        // Create a rectangle that corresponds to a cell covering the entire row area.
    CGRect rowRect = CGRectMake(rowOrigin.x, rowOrigin.y, rowSize.width, rowSize.height);
    
    columnRects[0] = rowRect;
    
        // Divide the columns equally across the frame's width.
    CGFloat columnWidth = CGRectGetWidth(rowRect) / columnCount;
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
    
    
        // Insert the rectangles paths into the created array
    for (column = 0; column < columnCount; column++) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, columnRects[column]);
        CFArrayInsertValueAtIndex(array, column, path);
        CFRelease(path);
    }
    free(columnRects);
    return array;
}



+(void)createColumnarContentInPDFContext:(CGContextRef)aCgPDFContextRef withText:(NSString*)string{
    
    
    CFStringRef cfString = (__bridge CFStringRef)string;
    
    CFMutableAttributedStringRef attString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString(attString, CFRangeMake(0, 0), cfString);
    
        // Create the frameSetter
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(attString);
    
        // Create the paths corresponding to a three column layout
    CFArrayRef columnPaths = [PDFRenderer createColumnsWithColumnCount:3];
    
    CFIndex pathCount = CFArrayGetCount(columnPaths);
    CFIndex startIndex = 0;
    int column;
    
        // Create a frame for each column (path).
    for (column = 0; column < pathCount; column++) {
            // Get the path for this column.
        CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(columnPaths, column);
        
            // Create a frame for this column and draw it.
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(startIndex, 0), path, NULL);
        CTFrameDraw(frame, aCgPDFContextRef);
        
            // Start the next frame at the first character not visible in this frame.
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        startIndex += frameRange.length;
        CFRelease(frame);
        
    }
    
    CFRelease(columnPaths);
    CFRelease(frameSetter);
    CFRelease(attString);
    
}






@end


