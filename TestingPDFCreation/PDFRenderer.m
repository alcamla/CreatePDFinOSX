//
//  PDFRenderer.m
//  TestingPDFCreation
//
//  Created by camacholaverde on 4/6/16.
//  Copyright © 2016 gibicgroup. All rights reserved.
//

#import "PDFRenderer.h"
@import AppKit;

@implementation PDFRenderer



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
    
    // Determine the total number of columns in the row by including those columns that have subcolumns.
    int finalNumberOfColumns = columnCount + (int)columsWithSubcolumns.count;
    
    // Convert the columns numbers to column indexes
    
    
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
            assert([columnNumber isLessThanOrEqualTo:[NSNumber numberWithInt:columnCount] ]);
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
        columnRects[column] = CGRectInset(columnRects[column], 4.0, 0.0);
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

//MARK: - Layout Tables

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
    /**
    //Get the first path, in order to test a function
    CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(columnPaths, 0);
    [PDFRenderer layoutText:string inPath:path usingContext:aCgPDFContextRef];
    **/
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

//MARK: - Layout Content

+(void)layoutText:(NSString*)string withAttributes:(NSDictionary*)attributes inPath:(CGPathRef)path usingContext:(CGContextRef)aCgPDFContextRef{
    
    CFStringRef cfString = (__bridge CFStringRef)string;
    
    CFMutableAttributedStringRef attString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString(attString, CFRangeMake(0, 0), cfString);
    if (attributes != nil){
        CFDictionaryRef cfAttributes = (__bridge CFDictionaryRef)attributes;
        CFIndex leght = CFAttributedStringGetLength(attString);
        CFAttributedStringSetAttributes(attString, CFRangeMake(0, leght), cfAttributes, true);
    }
    
    
    // Create the frameSetter
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(attString);
    
    // Create a frame for this column and draw it.
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, aCgPDFContextRef);
    
    //Release those elements created in this function
    CFRelease(frameSetter);
    CFRelease(frame);
    CFRelease(attString);
    
}

+(void)createPathsForTableWithColumnCount:(int)numberOfColums
                                 rowCount:(int)rowCount
                      subColumsForColumns:(NSArray<NSNumber*>*)columnsWithSubcolumns
                         contentForHeader:(NSArray<NSString*>*)headerContentArray
                          contentForTable:(NSArray<NSString*>*)tableContentArray
                              withRowSize:(CGSize)rowsSize
                                   inPage:(CGRect)page
                        withOffsetFromTop:(CGFloat)verticalOffset
                                 centered:(BOOL)isCentered
                                inContext:(CGContextRef)aCgPDFContextRef
{
    
    NSMutableArray<NSNumber*>*subcolumns = [NSMutableArray new];
    for (NSNumber *subcolumn in columnsWithSubcolumns){
        [subcolumns addObject:subcolumn];
    }
    if (subcolumns != nil){
        if([subcolumns count] > 0 ){
            NSLog(@"Non nil, non empty array");
        }
    }
    // Get the total number of rows that the table will have, excluding the header
    int totalRows = ([subcolumns count]>0)? (rowCount*(numberOfColums + (int)[subcolumns count])): rowCount*numberOfColums;
    
    //Verify that the elements in the text array are enough to fill the table
    assert(totalRows == tableContentArray.count);
    
    //Indicates if the table includes a header
    BOOL hasHeader = (headerContentArray != nil && headerContentArray.count > 0);
    // Stores the size corresponding to a header row
    CGSize headerRowSize = rowsSize;
    headerRowSize.height = headerRowSize.height+2.0;
    
    //Indicates the horizontal offset for the tables that are not centered on the page
    CGFloat horizontalOffset = 40.0;
    
    
    // Stores the initialization point for the table view. consider the offset and if the table is centered, and if the table includes a header row
    CGFloat currentRowHeight = hasHeader? headerRowSize.height : rowsSize.height;
    
    
    CGPoint currentRowOrigin;
    if (isCentered){
        
        currentRowOrigin = CGPointMake((page.size.width/2) - (rowsSize.width/2), page.size.height - currentRowHeight - verticalOffset);
        
    } else {
        
        if (page.size.width - rowsSize.width > horizontalOffset){
            currentRowOrigin = CGPointMake(horizontalOffset, page.size.height - currentRowHeight - verticalOffset);
        } else{
            // Assume that no horizontal offset can be applied
            currentRowOrigin =CGPointMake(0, page.size.height-currentRowHeight - verticalOffset);
        }
    }
    
    
    // Create the array of paths corresponding to the header. Set the row height of the header a bit bigger than the rest of the table
    if (hasHeader){
        
        //Verify if the header content and the number of columns in the header correspond
        assert(headerContentArray.count == numberOfColums);
        
        CFArrayRef headerRowPaths = [PDFRenderer createTableRowWithColumnCount:numberOfColums inRect:CGRectMake(currentRowOrigin.x, currentRowOrigin.y, headerRowSize.width, headerRowSize.height)];
        
        // Isert the content of the header.
        
        NSDictionary *headerAttributes = [PDFRenderer attributesDictionaryForTableHeader];
        
        // Iterate over all the columns of the header
        for (int i=0; i<headerContentArray.count; i++){
            
            // Get the string corresponding to the current column
            NSString *string = [headerContentArray objectAtIndex:i];
            // Get the path corresponding to the current column of the header
            CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(headerRowPaths, i);
            //Layout the text in the path corresponding to the current column of the header
            [PDFRenderer layoutText:string withAttributes:headerAttributes inPath:path usingContext:aCgPDFContextRef];
        }
    }
    
    
    // Create an array of layout paths, one for each column.
    int textCellIndex = 0;
    NSDictionary *cellAttributes = [PDFRenderer attributesDictionaryForTableCellContent];
    for (int rowIndex = 0; rowIndex<rowCount; rowIndex++){
        currentRowOrigin.y -= rowsSize.height;
        CFArrayRef currentRowPaths = [PDFRenderer createTableRowWithColumnCount:numberOfColums inRect:CGRectMake(currentRowOrigin.x, currentRowOrigin.y, rowsSize.width, rowsSize.height) withSubColumnsAtColumnNumbers:columnsWithSubcolumns];
        // Insert the text in the current row. Verify if the number of elements in the text is correct.
        CFIndex pathCount = CFArrayGetCount(currentRowPaths);
        for (int cell = 0; cell < pathCount; cell++){
            CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(currentRowPaths, cell);
            [PDFRenderer layoutText:[tableContentArray objectAtIndex:textCellIndex] withAttributes:cellAttributes inPath:path usingContext:aCgPDFContextRef];
            textCellIndex++;
        }
    }
}

//MARK: Common paragraph attributes

+(NSDictionary*)attributesDictionaryForTableHeader{
    // The color of the font
    NSColor *color = [NSColor blueColor];
    // The paragraph Stile of the header
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    // The font for the Header
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *font = [fontManager fontWithFamily:@"Helvetica Neue" traits:NSBoldFontMask weight:0 size:15];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:font forKey:NSFontAttributeName];
    return attributes;
}


+(NSDictionary*)attributesDictionaryForTableCellContent{
    // The color of the font
    NSColor *color = [NSColor blackColor];
    // The paragraph Stile of the header
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    // The font for the Header
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *font = [fontManager fontWithFamily:@"Helvetica Neue" traits:NSUnboldFontMask weight:0 size:13];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:font forKey:NSFontAttributeName];
    return attributes;
}


@end


