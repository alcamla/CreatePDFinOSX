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


    //MARK:- Table Row Creation

+ (CFArrayRef)createColumnsWithColumnCount:(int)columnCount
{
    return [PDFRenderer createTableRowWithColumnCount:columnCount inRect:CGRectNull withSubColumnsAtColumnNumbers:nil];
}

+(CFArrayRef)createTableRowWithColumnCount:(int)columnCount  inRect:(CGRect)rowRect{
    return [PDFRenderer createTableRowWithColumnCount:columnCount inRect:rowRect withSubColumnsAtColumnNumbers:nil];
}

+(CFArrayRef)createTableRowWithColumnCount:(int)columnCount inRect:(CGRect)rowRect withSubColumnsAtColumnNumbers:(NSArray<NSNumber*>*)columsWithSubcolumns{
    
    int column;
    
    int finalNumberOfColumns = columnCount + (int)columsWithSubcolumns.count;
    
        // Create a pointer to hold the array of column rectangles
    CGRect* columnRects = (CGRect*)calloc(finalNumberOfColumns, sizeof(*columnRects));
    
    if (CGRectIsEmpty(rowRect)){
            // Set the first column to cover the entire view.
        rowRect = CGRectMake(0, 0, 612, 792);
    }
    
    columnRects[0] = rowRect;
    
        // Divide the columns equally across the frame's width.
    CGFloat columnWidth = CGRectGetWidth(rowRect) / columnCount;
    for (column = 0; column < columnCount - 1; column++) {
        CGRectDivide(columnRects[column], &columnRects[column],
                     &columnRects[column + 1], columnWidth, CGRectMinXEdge);
    }
    
    
    if (columsWithSubcolumns != nil){
        for (NSNumber* columnNumber  in columsWithSubcolumns){
            assert(columnNumber <= [NSNumber numberWithInt:columnCount]);
        }
        
       
            // Sort the array
        columsWithSubcolumns = [columsWithSubcolumns sortedArrayUsingComparator:^NSComparisonResult(NSNumber *a, NSNumber *b){
            return [a compare: b];
        }];
        NSMutableArray *sortedColumnsWithSubcolumnsIndexArray = [NSMutableArray arrayWithArray:columsWithSubcolumns];
        
            //Change from column number to column index , i.e., rest 1 from each element in the array
        [sortedColumnsWithSubcolumnsIndexArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            NSInteger columnIndex = [(NSNumber*)obj integerValue];
            columnIndex --;
            sortedColumnsWithSubcolumnsIndexArray[idx] = [NSNumber numberWithInteger:columnIndex];
            
        }];
        
            // Apply the subdivision on the indicated columns
        for (int index = 0; index<sortedColumnsWithSubcolumnsIndexArray.count;index++){
            int columnIndex = [sortedColumnsWithSubcolumnsIndexArray[index] intValue];
                //Increment the size of the array
            for (int i = columnCount-1; i>= columnIndex; i--){
                columnRects[i+1] = columnRects[i];
            }
                //Divide the rectangle at the given column index
            CGFloat cellWidth =CGRectGetWidth(columnRects[columnIndex])/2;
            CGRectDivide(columnRects[columnIndex], &columnRects[columnIndex], &columnRects[columnIndex+1], cellWidth, CGRectMinXEdge);
                //The number of cell was incresed
            columnCount++;
            [sortedColumnsWithSubcolumnsIndexArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                NSInteger columnIndex = [(NSNumber*)obj integerValue];
                columnIndex ++;
                sortedColumnsWithSubcolumnsIndexArray[idx] = [NSNumber numberWithInteger:columnIndex];
            }];
        }
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

    //MARK: - Layout content

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



+(void)createCustomColumnarContentInPDFContext:(CGContextRef)aCgPDFContextRef withText:(NSString*)string inRect:(CGRect)rowRect{
    
    
    CFStringRef cfString = (__bridge CFStringRef)string;
    
    CFMutableAttributedStringRef attString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString(attString, CFRangeMake(0, 0), cfString);
    
        // Create the frameSetter
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(attString);
    
        // Create the paths corresponding to a three column layout
        //CFArrayRef columnPaths = [PDFRenderer createTableRowWithColumnCount:3 inRect:rowRect];
        CFArrayRef columnPaths = [PDFRenderer createTableRowWithColumnCount:5 inRect:rowRect withSubColumnsAtColumnNumbers:@[@(1), @(5)]];
    
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

+(void)createPathsForTableWithColumnCount:(int)numberOfColums rowCount:(int)rowCount subColumsForColumns:(NSArray<NSNumber*>*)columnsWithSubcolumns includeHeder:(BOOL)includeHeader contentForHeader:(NSArray*)headerContentArray contentForTable:(NSArray*)tableContentArray{
    
    
    
}









@end


