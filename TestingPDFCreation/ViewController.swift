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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func generatePDF(sender: AnyObject) {
        
        let userHomeString = NSHomeDirectory()
        
        let filePathString = userHomeString + "/Desktop/createdPDF.pdf"
        
        var rect = CGRectMake(0, 0, 612, 792)
        
        // Create the context to be used to render the pdf
        let aCgPDFContextRef:CGContextRef? = createPDFContextWithRect(&rect, path: filePathString as NSString)
        
        // Begin a page in the given context
        CGPDFContextBeginPage(aCgPDFContextRef, nil)
        
        // Insert the content to the page
        let stringMe:NSAttributedString = NSAttributedString(string: "ALEJANDRO CAMACHO")
        CGContextSetTextDrawingMode(aCgPDFContextRef, CGTextDrawingMode.Fill)
        // Set the fill color for the context
        let color = NSColor.blackColor()
        CGContextSetFillColorWithColor(aCgPDFContextRef, color.CGColor)
        // Create a frame
        
        let frameSetter:CTFramesetterRef = CTFramesetterCreateWithAttributedString(stringMe)
        let path:CGMutablePathRef = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRectMake(10,0, 500,500))
        let frame:CTFrameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, stringMe.length), path, nil)
        CTFrameDraw(frame, aCgPDFContextRef!)
        CGPDFContextEndPage(aCgPDFContextRef)
        print("PDF was created successfully???")
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
    


}

