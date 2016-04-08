//
//  ViewController.swift
//  TestingPDFCreation
//
//  Created by camacholaverde on 3/30/16.
//  Copyright © 2016 gibicgroup. All rights reserved.
//

import Cocoa
import CoreText


class ViewController: NSViewController {
    
    /**
     An example of generating a PDF using pure *Quartz 2D* pipeline.
     
     [Ray Wenderlich CoreText Tutorial]: https://www.raywenderlich.com/4147/core-text-tutorial-for-ios-making-a-magazine-app "Go to website"
     [PDF creation in Cocoa]: http://stackoverflow.com/questions/14118933/pdf-creation-in-cocoa
     
     ### Important note when working with Quartz
     The coordinate system of quartz is different from the coordinate system in iOS higher order API's, such as TextKit. The origin is on 
     the bottom left corner, the Y coordinate increases upwards and the X coordinate increases to the right.
     
     ### Useful Links
     * For the CoreText methods used here view [Ray Wenderlich CoreText Tutorial]
     * For the Quartz 2D workflow used view [PDF creation in Cocoa]
     */
    @IBAction func generatePDF(sender: AnyObject) {
        
        /// An useful way of getting the user's home directory
        let userHomeString = NSHomeDirectory()
        
        /// The final path were the file will be saved
        let filePathString = userHomeString + "/Desktop/createdPDF.pdf"
        
        
        /// Create  rectangle corresponding to the desired page size.
        let rect = CGRectMake(0, 0, 612, 792)
        let pageRect = rect
        
        /// Create the context to be used in the pdf rendering
        //let aCgPDFContextRef:CGContextRef? = createPDFContextWithRect(&rect, path: filePathString as NSString)
        let aCgPDFContextRef = PDFRenderer.newPDFContext(rect, path: filePathString as NSString).takeRetainedValue()
        
        /**
         The First page Contents
         ======================
         */
        
        // Begin a page in the given context
        CGPDFContextBeginPage(aCgPDFContextRef, nil)
        
        // Create an attributed string to add to the file
        //let stringMe:NSAttributedString = NSAttributedString(string: "ALEJANDRO CAMACHO")
        
        // Indicate the drawing mode that will be used for the pdf context
        //CGContextSetTextDrawingMode(aCgPDFContextRef, CGTextDrawingMode.Fill)
        
        // Set the fill color for the context
        //CGContextSetFillColorWithColor(aCgPDFContextRef,  NSColor.blackColor().CGColor)
        
        /**
         The CoreText pipeline
         ======================
        */
        
        // Set the text matrix
        CGContextSetTextMatrix(aCgPDFContextRef, CGAffineTransformIdentity);
        
        // Create a path which bounds the area where you will be drawing text.
        // The path need not be rectangular.
        let path:CGMutablePathRef = CGPathCreateMutable()
        //This step is incredibly important.
        CGPathAddRect(path, nil, CGRectMake((612/2)-100,(792)-100-40, 200,100))
        
        // Initialize a string.
        let textString:CFStringRef = "Hello, World! I know nothing in the world that has as much power as a word. Sometimes I write one, and I look at it, until it begins to shine." as CFString
        
        // Create a mutable attributed string with a max length of 0.
        // The max length is a hint as to how much internal storage to reserve.
        // 0 means no hint.
        let attrString: CFMutableAttributedStringRef = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        
        // Copy the textString into the newly created attrString
        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), textString);
        
        // Create a color that will be added as an attribute to the attrString.
        let rgbColorSpace: CGColorSpaceRef? = CGColorSpaceCreateDeviceRGB()
        let components:[CGFloat] = [ 1.0, 0.0, 0.0, 0.8 ]
        let red:CGColorRef? = CGColorCreate(rgbColorSpace, components)
        
        // Set the color of the first 12 chars to red.
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 12),
                                       kCTForegroundColorAttributeName, red);
        
//        let frameSetter:CTFramesetterRef = CTFramesetterCreateWithAttributedString(stringMe)
//        let frame:CTFrameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, stringMe.length), path, nil)
//        CTFrameDraw(frame, aCgPDFContextRef!)
        
        // Create the framesetter with the attributed string.
        let frameSetter:CTFramesetterRef = CTFramesetterCreateWithAttributedString(attrString)
        
        // Create a frame.
        let frame:CTFrameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        // Draw the specified frame in the given context
        CTFrameDraw(frame, aCgPDFContextRef)
        
        // Terminate the page
        CGPDFContextEndPage(aCgPDFContextRef)
        
        /**
         The Second page Contents
         ======================
         */
        
        // Begin a page in the given context
        CGPDFContextBeginPage(aCgPDFContextRef, nil)
        
        // Draw the specified frame in the given context
        CTFrameDraw(frame, aCgPDFContextRef)
        
        // Terminate the page
        CGPDFContextEndPage(aCgPDFContextRef)
        
        
        /**
         The Third page Contents
         ======================
         */
        
        
        
        let tableString = "MR. UTTERSON the lawyer was a man of a rugged countenance, that was never lighted by a smile; cold, scanty and embarrassed in discourse; backward in sentiment; lean, long, dusty, dreary, and yet somehow lovable. At friendly meetings, and when the wine was to his taste, something eminently human beaconed from his eye; something indeed which never found its way into his talk, but which spoke not only in these silent symbols of the after-dinner face, but more often and loudly in the acts of his life. He was austere with himself; drank gin when he was alone, to mortify a taste for vintages; and though he enjoyed the theatre, had not crossed the doors of one for twenty years. But he had an approved tolerance for others; sometimes wondering, almost with envy, at the high pressure of spirits involved in their misdeeds; and in any extremity inclined to help rather than to reprove.MR. UTTERSON the lawyer was a man of a rugged countenance, that was never lighted by a smile; cold, scanty and embarrassed in discourse; backward in sentiment; lean, long, dusty, dreary, and yet somehow lovable. At friendly meetings, and when the wine was to his taste, something eminently human beaconed from his eye; something indeed which never found its way into his talk, but which spoke not only in these silent symbols of the after-dinner face, but more often and loudly in the acts of his life. He was austere with himself; drank gin when he was alone, to mortify a taste for vintages; and though he enjoyed the theatre, had not crossed the doors of one for twenty years. But he had an approved tolerance for others; sometimes wondering, almost with envy, at the high pressure of spirits involved in their misdeeds; and in any extremity inclined to help rather than to reprove.MR. UTTERSON the lawyer was a man of a rugged countenance, that was never lighted by a smile; cold, scanty and embarrassed in discourse; backward in sentiment; lean, long, dusty, dreary, and yet somehow lovable. At friendly meetings, and when the wine was to his taste, something eminently human beaconed from his eye; something indeed which never found its way into his talk, but which spoke not only in these silent symbols of the after-dinner face, but more often and loudly in the acts of his life. He was austere with himself; drank gin when he was alone, to mortify a taste for vintages; and though he enjoyed the theatre, had not crossed the doors of one for twenty years. But he had an approved tolerance for others; sometimes wondering, almost with envy, at the high pressure of spirits involved in their misdeeds; and in any extremity inclined to help rather than to reprove.MR. UTTERSON the lawyer was a man of a rugged countenance, that was never lighted by a smile; cold, scanty and embarrassed in discourse; backward in sentiment; lean, long, dusty, dreary, and yet somehow lovable. At friendly meetings, and when the wine was to his taste, something eminently human beaconed from his eye; something indeed which never found its way into his talk, but which spoke not only in these silent symbols of the after-dinner face, but more often and loudly in the acts of his life. He was austere with himself; drank gin when he was alone, to mortify a taste for vintages; and though he enjoyed the theatre, had not crossed the doors of one for twenty years. But he had an approved tolerance for others; sometimes wondering, almost with envy, at the high pressure of spirits involved in their misdeeds; and in any extremity inclined to help rather than to reprove.MR. UTTERSON the lawyer was a man of a rugged countenance, that was never lighted by a smile; cold, scanty and embarrassed in discourse; backward in sentiment; lean, long, dusty, dreary, and yet somehow lovable. At friendly meetings, and when the wine was to his taste, something eminently human beaconed from his eye; something indeed which never found its way into his talk, but which spoke not only in these silent symbols of the after-dinner face, but more often and loudly in the acts of his life. He was austere with himself; drank gin when he was alone, to mortify a taste for vintages; and though he enjoyed the theatre, had not crossed the doors of one for twenty years. But he had an approved tolerance for others; sometimes wondering, almost with envy, at the high pressure of spirits involved in their misdeeds; and in any extremity inclined to help rather than to reprove.MR. UTTERSON the lawyer was a man of a rugged countenance, that was never lighted by a smile; cold, scanty and embarrassed in discourse; backward in sentiment; lean, long, dusty, dreary, and yet somehow lovable. At friendly meetings, and when the wine was to his taste, something eminently human beaconed from his eye; something indeed which never found its way into his talk, but which spoke not only in these silent symbols of the after-dinner face, but more often and loudly in the acts of his life. He was austere with himself; drank gin when he was alone, to mortify a taste for vintages; and though he enjoyed the theatre, had not crossed the doors of one for twenty years. But he had an approved tolerance for others; sometimes wondering, almost with envy, at the high pressure of spirits involved in their misdeeds; and in any extremity inclined to help rather than to reprove."
        
        CGPDFContextBeginPage(aCgPDFContextRef, nil);
        
        PDFRenderer.createColumnarContentInPDFContext(aCgPDFContextRef, withText: tableString)
        
        CGPDFContextEndPage(aCgPDFContextRef);
        
        
        /**
         The Fourth page Contents
         ======================
         */
        
        
        let desiredHeight:CGFloat = 100.0
        let rowOffset:CGFloat = 30.0
        let desiredWidth:CGFloat = 400.0
        
        let row:CGRect = CGRectMake((pageRect.size.width/2) - (desiredWidth/2), pageRect.size.height - desiredHeight - rowOffset, desiredWidth, desiredHeight)
        
        CGPDFContextBeginPage(aCgPDFContextRef, nil);
        PDFRenderer.createCustomColumnarContentInPDFContext(aCgPDFContextRef, withText: tableString, inRect: row)        
        CGPDFContextEndPage(aCgPDFContextRef);
        
        
        /**
         The Fifth page Contents
         ======================
         */
        
        

    }
    
    func createPDFContextWithRect(inout aCgRectinMediaBox:CGRect, path aCfStrPath:CFStringRef )-> CGContext?{
        
        //Declare the variables that will be used
        var aCgContextRefNewPDF:CGContextRef?
        var aCfurlRefPDF: CFURLRef?;
        
        // Create the url with the given path
        aCfurlRefPDF = CFURLCreateWithFileSystemPath(kCFAllocatorSystemDefault, aCfStrPath, CFURLPathStyle.CFURLPOSIXPathStyle, false)
        if aCfurlRefPDF != nil{
            aCgContextRefNewPDF = CGPDFContextCreateWithURL(aCfurlRefPDF, &aCgRectinMediaBox, nil)
        }
        
        return aCgContextRefNewPDF
    }
    
    func createColumnsWithColunmCount(columnCount:Int)->(CFArrayRef){
        
        let columnRects:UnsafeMutablePointer<CGRect> = UnsafeMutablePointer<CGRect>(calloc(columnCount, sizeofValue(CGRect)))
        
        // Set the first column to cover the entire view
        let pageSize = CGRectMake(0, 0, 612, 792)
        columnRects[0] = pageSize
        
        // Divide the columns equally across the frame's width
        let columnWidth:CGFloat = CGRectGetWidth(pageSize)/CGFloat(columnCount)
        
        for column in 0..<columnCount{
            CGRectDivide(columnRects[column], &columnRects[column], &columnRects[column+1], columnWidth, CGRectEdge.MinXEdge)
        }
        
        // Insert all the columns by a few pixels of margin
        for column in 0..<columnCount{
            columnRects[column] = CGRectInset(columnRects[column], 8.0, 15.0)
        }
        // Create an array of layout paths, one for each column
        var callBacks = CFArrayCallBacks()
        let array:CFMutableArrayRef = CFArrayCreateMutable(kCFAllocatorDefault, columnCount, &callBacks)
        
        for column in 0..<columnCount{
            var path:CGMutablePathRef = CGPathCreateMutable()
            CGPathAddRect(path, nil, columnRects[column])
            CFArrayInsertValueAtIndex(array, column, &path)
        }
        
        return array
    }
    
    

    

}

