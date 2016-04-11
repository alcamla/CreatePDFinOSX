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

#pragma mark - Static variables

/// The name of the font used by default in the pdf generation
+(NSString*)defaultFontName{
    return @"Helvetica Neue";
}

/// The default size of the page used to generate the pdf
+(CGRect)defaultPageRect{
    return CGRectMake(0, 0, 612, 792);
}

/// Indicates the horizontal space available for laying out text
+(CGFloat)defaultParagraphWidth{
    return [PDFRenderer defaultPageRect].size.width * .92;
}

/// Indicates the vertical space that must be discarted at the top or bottom of the page
+(CGFloat)defaultVerticalOffset{
    return [PDFRenderer defaultPageRect].size.height *0.04;
}

/// Inicates the space that must be discarted horizontally
+(CGFloat)defaultHorizontalOffset{
    return [PDFRenderer defaultPageRect].size.width * 0.04;
}

/// The space added after a title
+(CGFloat)defaultSpacingAfterTitleParagraph{
    return 17.0;
}

/// The space added after a paragraph
+(CGFloat)defaultSpacingAfterBodyParagraph{
    return 13.0;
}

/// The space added after a header
+(CGFloat)defaultSpacingAfterHeaderParagraph{
    return 15.0;
}


/**
 @brief Utility method to convert a distance meassured from the top of the page into coordinate ready value.
 @discussion It is important to notice that Cocoa for OSX and Core Foundation have a coordinate system with origin at bottom left coorner.
 @param The distance to convert to a point ready coordinate, meassure from the top of the containing rectangle
*/
+(CGFloat)yCoordinateForPointWithDistanceFromTop:(CGFloat)topDistance{
    // A default page is assumed for this calculation
    return [PDFRenderer defaultPageRect].size.height - topDistance;
}

#pragma mark - PDF context creation


/**
 @brief Creates an returns a CGContextRef with the given rectangular area, at the given file path.
 @discussion This method increments the reference count in the caller. Release memory accordingly.
 
 @param aCgRectinMediaBox Rectangular area to be used by the created context
 @param aCfStrPath a path where the context will be saved to
 
*/
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


#pragma mark - Table Paths Creation

/**
 @brief Creates a single table row, with the specified requirements.
 @discussion This method creates an returns an array of @c CGPaths corresponding to cells in a row. The row is inscribed in a default size page rectangle.
 
 @param columnCount             The number of colums, or cells, that the row will have.
 */
+ (CFArrayRef)newColumnsWithColumnCount:(int)columnCount
{
    return [PDFRenderer newTableRowWithColumnCount:columnCount inRect:CGRectNull withSubColumnsAtColumnNumbers:nil];
}


/**
 @brief Creates a single table row, with the specified requirements.
 @discussion This method creates an returns an array of @c CGPaths corresponding to cells in a row.
 
 @param columnCount             The number of colums, or cells, that the row will have.
 @param rowRect                 The rectangular area in which the row will be inscribed.
 */
+(CFArrayRef)newTableRowWithColumnCount:(int)columnCount  inRect:(CGRect)rowRect{
    return [PDFRenderer newTableRowWithColumnCount:columnCount inRect:rowRect withSubColumnsAtColumnNumbers:nil];
}

/**
 @brief Creates a single table row, with the specified requirements.
 @discussion This method creates an returns an array of @c CGPaths corresponding to cells in a row. The user can select to split a given row, generating two equally sized subrows.
 
 @param columnCount             The number of colums, or cells, that the row will have.
 @param rowRect                 The rectangular area in which the row will be inscribed.
 @param columnsWithSubcolums    Indicates which cells are going to be splited, generating two equally sized sub-cells.
*/

+(CFArrayRef)newTableRowWithColumnCount:(int)columnCount inRect:(CGRect)rowRect withSubColumnsAtColumnNumbers:(NSArray<NSNumber*>*)columsWithSubcolumns{
    
    int column;
    
    // Determine the total number of columns in the row by including those columns that have subcolumns.
    int finalNumberOfColumns = columnCount + (int)columsWithSubcolumns.count;
    
    // Convert the columns numbers to column indexes
    
    
    // Create a pointer to hold the array of column rectangles
    CGRect* columnRects = (CGRect*)calloc(finalNumberOfColumns, sizeof(*columnRects));
    
    if (CGRectIsEmpty(rowRect)){
        // Set the first column to cover the entire view.
        rowRect = [PDFRenderer defaultPageRect];
    }
    
    columnRects[0] = rowRect;
    
    // Divide the columns equally across the frame's width.
    CGFloat columnWidth = CGRectGetWidth(rowRect) / columnCount;
    for (column = 0; column < columnCount - 1; column++) {
        CGRectDivide(columnRects[column], &columnRects[column],
                     &columnRects[column + 1], columnWidth, CGRectMinXEdge);
    }
    
    // Check if there are columns to be splited, and if so, that the column number to be splited is valid.
    if (columsWithSubcolumns != nil){
        for (NSNumber* columnNumber  in columsWithSubcolumns){
            NSAssert([columnNumber isLessThanOrEqualTo:[NSNumber numberWithInt:columnCount] ], @"The indicated column to be splited exceeds the number of available columns");
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
        columnRects[column] = CGRectInset(columnRects[column], 4.0, 0.0); // This must be an static variable
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

#pragma mark - Laying paragraph content

+(CGPoint)layoutTitleInPDFContext:(CGContextRef)aCgPDFContextRef text:(NSString*)string atTopLeftCorner:(CGPoint)origin{
    NSDictionary *attributes = [PDFRenderer attributesDictionaryForTitle];
    CGPoint bottomCorner = [PDFRenderer layoutTextPDFContext:aCgPDFContextRef text:string withAttributes:attributes atTopLeftCorner:origin];
    bottomCorner.y-= [PDFRenderer defaultSpacingAfterTitleParagraph];
    return bottomCorner;
}

+(CGPoint)layoutBodyInPDFContext:(CGContextRef)aCgPDFContextRef text:(NSString*)string atTopLeftCorner:(CGPoint)origin{
    NSDictionary *attributes = [PDFRenderer attributesDictionaryForBody];
    CGPoint bottomCorner =  [PDFRenderer layoutTextPDFContext:aCgPDFContextRef text:string withAttributes:attributes atTopLeftCorner:origin];
    bottomCorner.y-= [PDFRenderer defaultSpacingAfterBodyParagraph];
    return bottomCorner;
}

+(CGPoint)layouHeaderInPDFContext:(CGContextRef)aCgPDFContextRef text:(NSString*)string atTopLeftCorner:(CGPoint)origin{
    NSDictionary *attributes = [PDFRenderer attributesDictionaryForHeader];
    CGPoint bottomCorner =  [PDFRenderer layoutTextPDFContext:aCgPDFContextRef text:string withAttributes:attributes atTopLeftCorner:origin];
    bottomCorner.y-= [PDFRenderer defaultSpacingAfterHeaderParagraph];
    return bottomCorner;
}

#pragma mark - Laying Columnar Content

/**
 @brief Layout the given text in a columnar layout with the passed configuration. 
 @discussion This method layout the given text in a columnar layout. The number of columns and the widht of the column is also a parameter. 
 @param aCgPDFContextRef        The context in which the text will be rendered
 @param string                  The string to be layout in the columns
 @param rowRect                 The rectangle corresponding to the area of the complete columnar layout
 @param numberOfColumns         The number of columns in which the text will be layout
 @param splitedColumnsArray     An array with the column numbers of the columsn that will be splited in two equal subcolumns
*/
+(void)layoutColumnarContentInPDFContext:(CGContextRef)aCgPDFContextRef withText:(NSString*)string inRect:(CGRect)rowRect inNumberOfColums:(int)numberOfColumns withSplitedColums:(NSArray<NSNumber*>*)splitedColumsArray{
    
    
    NSMutableArray<NSNumber*>*subcolumns = [NSMutableArray new];
    for (NSNumber *subcolumn in splitedColumsArray){
        [subcolumns addObject:subcolumn];
    }
    
    
    CFStringRef cfString = (__bridge CFStringRef)string;
    
    CFMutableAttributedStringRef attString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString(attString, CFRangeMake(0, 0), cfString);
    
    // Create the frameSetter
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(attString);
    
    // Create the paths corresponding to a three column layout
    CFArrayRef columnPaths = [PDFRenderer newTableRowWithColumnCount:numberOfColumns inRect:rowRect withSubColumnsAtColumnNumbers:subcolumns];
    
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

#pragma mark - Laying  a Table


/**
 @brief Layout a table to render in to a pdf file.
 
 @discussion This method creates a table, given the content, the number of colums for each row, the number of rows and an array of strings to be inserted on each cell.
 The elements in the array are transversed from left to right, top to bottom. The number of elements included in the @c tableContentArray must match the total number of cells, calculated as @c rowCount*numberOfColums. If a @c headerContentArray is given, a header is generated for the table.
 
 @param  numberOfColumns        The number of columns of the table.
 @param  rowCount               The number of rows of the table (Excluding the header)
 @param  columnsWithSubcolumns  Array with the rows that will be divided equally, generating 2 subrows.
 @param  headerContentArray     Array of strings that will fill the header cells.
 @param  tableContentArray      Array of strings that will fill the cells.
 @param  rowSize                Indicates the total width of the table.
 @param  page                   Indicates the rectangular area of the page in which the table will be inserted. If nothing is given, the default page size will be used.
 @param  verticalOffset         The space left from the topo of the given page rectangle.
 @param  isCentered             Indicates if the table will be centered on the page.
 @param  aCgPDFContext          The context in which the page will be rendered.
 
 */
+(void)layoutTableWithColumnCount:(int)numberOfColums
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
    
    /**
     Validations and setup
     ======================
     */
    
    // Get the total number of rows that the table will have, excluding the header
    int totalRows = ([subcolumns count]>0)? (rowCount*(numberOfColums + (int)[subcolumns count])): rowCount*numberOfColums;
    
    // Verify that the elements in the text array are enough to fill the table
    NSAssert(totalRows == tableContentArray.count, @"the total number of cells differs from the number of strings to be inserted in the table");
    
    // Verify that the horizontal space for the table fits in the horizontal space available in the page
    NSAssert(rowsSize.width<=page.size.width, @"The table widht is greater than the available horizontal space");
    
    // Indicates if the table includes a header
    BOOL hasHeader = (headerContentArray != nil && headerContentArray.count > 0);
    // Stores the size corresponding to a header row
    CGSize headerRowSize = rowsSize;
    headerRowSize.height = headerRowSize.height+2.0;
    
    // Indicates the horizontal offset for the tables that are not centered on the page
    CGFloat horizontalOffset = [PDFRenderer defaultHorizontalOffset];
    
    
    // Stores the initialization point for the table view. consider the offset and if the table is centered, and if the table includes a header row
    CGFloat currentRowHeight = hasHeader? headerRowSize.height : rowsSize.height;
    
    // This is the point where the rows will be placed. This point will move downwards as the insertion of rows in the table advances.
    CGPoint currentRowOrigin;
    
    // Place the origin point according to the aligment indicated for the table
    if (isCentered){
        currentRowOrigin = CGPointMake((page.size.width/2) - (rowsSize.width/2), page.size.height - currentRowHeight - verticalOffset);
        
    } else {
        // Verify if the given horizontal offset is appropriate for the page and table widths
        if (page.size.width - rowsSize.width > horizontalOffset){
            currentRowOrigin = CGPointMake(horizontalOffset, page.size.height - currentRowHeight - verticalOffset);
        } else{
            // Assume that no horizontal offset can be applied
            currentRowOrigin =CGPointMake(0, page.size.height-currentRowHeight - verticalOffset);
        }
    }
    
    /**
     The Header (if there is one)
     ======================
     */
    
    // Create the array of paths corresponding to the header. Set the row height of the header a bit bigger than the rest of the table
    if (hasHeader){
        
        //Verify if the header content and the number of columns in the header correspond
        NSAssert(headerContentArray.count == numberOfColums, @"The number of cells of the header does not match the number of strings provided.");
        
        CFArrayRef headerRowPaths = [PDFRenderer newTableRowWithColumnCount:numberOfColums inRect:CGRectMake(currentRowOrigin.x, currentRowOrigin.y, headerRowSize.width, headerRowSize.height)];
        
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
        CFRelease(headerRowPaths);
    }
    
    
    /**
     The Table Rows
     ======================
     */
    
    // Create an array of layout paths, one for each column.
    
    // This index is used to iterate over the tableContentArray, as we insert the content for each cell.
    CFIndex textCellIndex = 0;
    // Dictionary with attributes for cell text.
    NSDictionary *cellAttributes = [PDFRenderer attributesDictionaryForTableCellContent];
    
    // Iteration that creates the rows
    CFArrayRef currentRowPaths;
    for (int rowIndex = 0; rowIndex<rowCount; rowIndex++){
        // Move the origin point downwards
        currentRowOrigin.y -= rowsSize.height;
        // Create the paths for each cell in this row
        currentRowPaths = [PDFRenderer newTableRowWithColumnCount:numberOfColums inRect:CGRectMake(currentRowOrigin.x, currentRowOrigin.y, rowsSize.width, rowsSize.height) withSubColumnsAtColumnNumbers:columnsWithSubcolumns];
        // Insert the text in each cell of the current row
        CFIndex pathCount = CFArrayGetCount(currentRowPaths);
        for (int cell = 0; cell < pathCount; cell++){
            CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(currentRowPaths, cell);
            [PDFRenderer layoutText:[tableContentArray objectAtIndex:textCellIndex] withAttributes:cellAttributes inPath:path usingContext:aCgPDFContextRef];
            textCellIndex++;
        }
        CFRelease(currentRowPaths);
    }
}


#pragma mark - Internal Layout Fuctions


/**
 @brief Lays out text in the given path.
 
 @discussion This method is in charge of laying out the text inside the given path, using the passed context. A dictionary with attributes can be given, to set up the attributed string used to prettify the text. 
 
 @param string Text that will be layout
 @param attributes Dictionary of attributes to be given to the text.
 @param path   Path in which the text will be layout
 @param aCgPDFContextRef CGContextRef that points to the context in which the text will be rendered.
*/
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

/**
 @brief Lays out text.
 @discussion This method lays out text in the given context. The rectagle in which the text is inscribed is calculated by the method, and has top left corner passed as argument.
 @param aCgPDFContextRef    The context in which the text is rendered
 @param string              The text to render
 @param attributes          The attributes of the text to be rendered
 @param corner              The top left corner of the rect in which the text will be rendered, meassured in the @c aCgPDFContextRef
 @return CGPoint            The point corresponding to the bottom left corner of the rectangle used to render the text.
 
 */
+(CGPoint)layoutTextPDFContext:(CGContextRef)aCgPDFContextRef text:(NSString*)string withAttributes:(NSDictionary*)attributes atTopLeftCorner:(CGPoint)corner{
    
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
    
    // Calculate the area required for this text to be rendered properly, considering the available horizontal space.
    CFRange fitRange;
    CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), NULL, CGSizeMake([PDFRenderer defaultParagraphWidth], MAXFLOAT), &fitRange);
    
    // Move the origin to the bottom left corner
    CGRect rect = CGRectMake(corner.x, corner.y - frameSize.height, frameSize.width, frameSize.height);
    
    // Create the path with the calculated size
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    // Create a frame for this column and draw it.
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, aCgPDFContextRef);
    
    CFRelease(frame);
    CFRelease(frameSetter);
    CFRelease(attString);
    CFRelease(path);
    
    // Return the origin of the rectangle inscribed in the path. This rectangle indicates where the text was layout, so the next render method does not overlay the things already drawn.
    return rect.origin;
}


#pragma mark - Common paragraph attributes

/**
 Generates a dictionary with the attributes to be assigned to a default table header. Apply this attributes to a header of type @c NSAttributedString;
*/

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

/**
 Generates a dictionary with the attributes to be assigned to a default table cell. Apply this attributes to a header of type @c NSAttributedString;
 */
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


/**
 Generates a dictionary with the attributes to be assigned to a Title text. Apply this attributes to a header of type @c NSAttributedString;
 */
+(NSDictionary*)attributesDictionaryForTitle{
    // The color of the font
    NSColor *color = [NSColor blueColor];
    // The paragraph Stile of the header
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    // The font for the Header
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *font = [fontManager fontWithFamily:@"Helvetica Neue" traits:NSBoldFontMask weight:0 size:17];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:font forKey:NSFontAttributeName];
    return attributes;
}


/**
 Generates a dictionary with the attributes to be assigned to a body text. Apply this attributes to a header of type @c NSAttributedString;
 */
+(NSDictionary*)attributesDictionaryForBody{
    // The color of the font
    NSColor *color = [NSColor blackColor];
    // The paragraph Stile of the header
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    // The font for the Header
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *font = [fontManager fontWithFamily:@"Helvetica Neue" traits:NSUnboldFontMask weight:0 size:12];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:font forKey:NSFontAttributeName];
    return attributes;
}

/**
 Generates a dictionary with the attributes to be assigned to a default header text. Apply this attributes to a header of type @c NSAttributedString;
 */
+(NSDictionary*)attributesDictionaryForHeader{
    // The color of the font
    NSColor *color = [NSColor blackColor];
    // The paragraph Stile of the header
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    // The font for the Header
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *font = [fontManager fontWithFamily:@"Helvetica Neue" traits:NSBoldFontMask weight:0 size:14];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:font forKey:NSFontAttributeName];
    return attributes;
}

@end


