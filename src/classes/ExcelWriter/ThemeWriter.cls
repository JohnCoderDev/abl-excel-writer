USING Classes.ExcelWriter.*. 
CLASS Classes.ExcelWriter.ThemeWriter:
    METHOD PUBLIC STATIC LONGCHAR writeThemeXMLText():
        DEFINE VARIABLE writer AS XMLWriter.
        ASSIGN writer = NEW XMLWriter().

        writer:addTag("a:theme").
        writer:addTagProperty("xmlns:a", "http://schemas.openxmlformats.org/drawingml/2006/main").
        writer:addTagProperty("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships").
        writer:addTagProperty("name", "Sheets").

        writer:addTag("a:themeElements").

        writer:addTag("a:clrScheme").
        writer:addTagProperty("name", "Sheets").

        writer:addTag("a:dk1").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "000000").
        
        writer:addClosingTag("a:dk1").
        writer:addTag("a:lt1").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "FFFFFF").
        
        writer:addClosingTag("a:lt1").
        writer:addTag("a:dk2").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "000000").
        
        writer:addClosingTag("a:dk2").
        writer:addTag("a:lt2").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "FFFFFF").
        
        writer:addClosingTag("a:lt2").
        writer:addTag("a:accent1").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "4285F4").
        
        writer:addClosingTag("a:accent1").
        writer:addTag("a:accent2").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "EA4335").
        
        writer:addClosingTag("a:accent2").
        writer:addTag("a:accent3").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "FBBC04").
        
        writer:addClosingTag("a:accent3").
        writer:addTag("a:accent4").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "34A853").
        
        writer:addClosingTag("a:accent4").
        writer:addTag("a:accent5").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "FF6D01").
        
        writer:addClosingTag("a:accent5").
        writer:addTag("a:accent6").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "46BDC6").
        
        writer:addClosingTag("a:accent6").
        writer:addTag("a:hlink").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "1155CC").
        
        writer:addClosingTag("a:hlink").
        writer:addTag("a:folHlink").

        writer:addTag("a:srgbClr", TRUE).
        writer:addTagProperty("val", "1155CC").
        
        writer:addClosingTag("a:folHlink").
        writer:addClosingTag("a:clrScheme").
        writer:addTag("a:fontScheme").
        writer:addTagProperty("name", "Sheets").

        writer:addTag("a:majorFont").

        writer:addTag("a:latin", TRUE).
        writer:addTagProperty("typeface", "Arial").
        
        writer:addTag("a:ea", TRUE).
        writer:addTagProperty("typeface", "Arial").
        
        writer:addTag("a:cs", TRUE).
        writer:addTagProperty("typeface", "Arial").
        
        writer:addClosingTag("a:majorFont").
        writer:addTag("a:minorFont").

        writer:addTag("a:latin", TRUE).
        writer:addTagProperty("typeface", "Arial").
        
        writer:addTag("a:ea", TRUE).
        writer:addTagProperty("typeface", "Arial").
        
        writer:addTag("a:cs", TRUE).
        writer:addTagProperty("typeface", "Arial").
        
        writer:addClosingTag("a:minorFont").
        writer:addClosingTag("a:fontScheme").
        writer:addTag("a:fmtScheme").
        writer:addTagProperty("name", "Office").

        writer:addTag("a:fillStyleLst").

        writer:addTag("a:solidFill").

        writer:addTag("a:schemeClr", TRUE).
        writer:addTagProperty("val", "phClr").
        
        writer:addClosingTag("a:solidFill").
        writer:addTag("a:gradFill").
        writer:addTagProperty("rotWithShape", "1").

        writer:addTag("a:gsLst").

        writer:addTag("a:gs").
        writer:addTagProperty("pos", "0").

        writer:addTag("a:schemeClr").
        writer:addTagProperty("val", "phClr").

        writer:addTag("a:lumMod", TRUE).
        writer:addTagProperty("val", "110000").
        
        writer:addTag("a:satMod", TRUE).
        writer:addTagProperty("val", "105000").
        
        writer:addTag("a:tint", TRUE).
        writer:addTagProperty("val", "67000").
        
        writer:addClosingTag("a:schemeClr").
        writer:addClosingTag("a:gs").
        writer:addTag("a:gs").
        writer:addTagProperty("pos", "50000").

        writer:addTag("a:schemeClr").
        writer:addTagProperty("val", "phClr").

        writer:addTag("a:lumMod", TRUE).
        writer:addTagProperty("val", "105000").
        
        writer:addTag("a:satMod", TRUE).
        writer:addTagProperty("val", "103000").
        
        writer:addTag("a:tint", TRUE).
        writer:addTagProperty("val", "73000").
        
        writer:addClosingTag("a:schemeClr").
        writer:addClosingTag("a:gs").
        writer:addTag("a:gs").
        writer:addTagProperty("pos", "100000").

        writer:addTag("a:schemeClr").
        writer:addTagProperty("val", "phClr").

        writer:addTag("a:lumMod", TRUE).
        writer:addTagProperty("val", "105000").
        
        writer:addTag("a:satMod", TRUE).
        writer:addTagProperty("val", "109000").
        
        writer:addTag("a:tint", TRUE).
        writer:addTagProperty("val", "81000").
        
        writer:addClosingTag("a:schemeClr").
        writer:addClosingTag("a:gs").
        writer:addClosingTag("a:gsLst").
        writer:addTag("a:lin", TRUE).
        writer:addTagProperty("ang", "5400000").
        writer:addTagProperty("scaled", "0").
        
        writer:addClosingTag("a:gradFill").
        writer:addTag("a:gradFill").
        writer:addTagProperty("rotWithShape", "1").

        writer:addTag("a:gsLst").

        writer:addTag("a:gs").
        writer:addTagProperty("pos", "0").

        writer:addTag("a:schemeClr").
        writer:addTagProperty("val", "phClr").

        writer:addTag("a:satMod", TRUE).
        writer:addTagProperty("val", "103000").
        
        writer:addTag("a:lumMod", TRUE).
        writer:addTagProperty("val", "102000").
        
        writer:addTag("a:tint", TRUE).
        writer:addTagProperty("val", "94000").
        
        writer:addClosingTag("a:schemeClr").
        writer:addClosingTag("a:gs").
        writer:addTag("a:gs").
        writer:addTagProperty("pos", "50000").

        writer:addTag("a:schemeClr").
        writer:addTagProperty("val", "phClr").

        writer:addTag("a:satMod", TRUE).
        writer:addTagProperty("val", "110000").
        
        writer:addTag("a:lumMod", TRUE).
        writer:addTagProperty("val", "100000").
        
        writer:addTag("a:shade", TRUE).
        writer:addTagProperty("val", "100000").
        
        writer:addClosingTag("a:schemeClr").
        writer:addClosingTag("a:gs").
        writer:addTag("a:gs").
        writer:addTagProperty("pos", "100000").

        writer:addTag("a:schemeClr").
        writer:addTagProperty("val", "phClr").

        writer:addTag("a:lumMod", TRUE).
        writer:addTagProperty("val", "99000").
        
        writer:addTag("a:satMod", TRUE).
        writer:addTagProperty("val", "120000").
        
        writer:addTag("a:shade", TRUE).
        writer:addTagProperty("val", "78000").
        
        writer:addClosingTag("a:schemeClr").
        writer:addClosingTag("a:gs").
        writer:addClosingTag("a:gsLst").
        writer:addTag("a:lin", TRUE).
        writer:addTagProperty("ang", "5400000").
        writer:addTagProperty("scaled", "0").
        
        writer:addClosingTag("a:gradFill").
        writer:addClosingTag("a:fillStyleLst").
        writer:addTag("a:lnStyleLst").

        writer:addTag("a:ln").
        writer:addTagProperty("w", "6350").
        writer:addTagProperty("cap", "flat").
        writer:addTagProperty("cmpd", "sng").
        writer:addTagProperty("algn", "ctr").
        writer:addTag("a:solidFill").

        writer:addTag("a:schemeClr", TRUE).
        writer:addTagProperty("val", "phClr").
        
        writer:addClosingTag("a:solidFill").
        writer:addTag("a:prstDash", TRUE).
        writer:addTagProperty("val", "solid").
        
        writer:addTag("a:miter", TRUE).
        writer:addTagProperty("lim", "800000").
        
        writer:addClosingTag("a:ln").
        writer:addTag("a:ln").
        writer:addTagProperty("w", "12700").
        writer:addTagProperty("cap", "flat").
        writer:addTagProperty("cmpd", "sng").
        writer:addTagProperty("algn", "ctr").
        writer:addTag("a:solidFill").

        writer:addTag("a:schemeClr", TRUE).
        writer:addTagProperty("val", "phClr").
        
        writer:addClosingTag("a:solidFill").
        writer:addTag("a:prstDash", TRUE).
        writer:addTagProperty("val", "solid").
        
        writer:addTag("a:miter", TRUE).
        writer:addTagProperty("lim", "800000").
        
        writer:addClosingTag("a:ln").
        writer:addTag("a:ln").
        writer:addTagProperty("w", "19050").
        writer:addTagProperty("cap", "flat").
        writer:addTagProperty("cmpd", "sng").
        writer:addTagProperty("algn", "ctr").
        writer:addTag("a:solidFill").

        writer:addTag("a:schemeClr", TRUE).
        writer:addTagProperty("val", "phClr").
        
        writer:addClosingTag("a:solidFill").
        writer:addTag("a:prstDash", TRUE).
        writer:addTagProperty("val", "solid").
        
        writer:addTag("a:miter", TRUE).
        writer:addTagProperty("lim", "800000").
        
        writer:addClosingTag("a:ln").
        writer:addClosingTag("a:lnStyleLst").
        writer:addTag("a:effectStyleLst").

        writer:addTag("a:effectStyle").

        writer:addTag("a:effectLst", TRUE).
        
        writer:addClosingTag("a:effectStyle").
        writer:addTag("a:effectStyle").

        writer:addTag("a:effectLst", TRUE).
        
        writer:addClosingTag("a:effectStyle").
        writer:addTag("a:effectStyle").

        writer:addTag("a:effectLst").

        writer:addTag("a:outerShdw").
        writer:addTagProperty("blurRad", "57150").
        writer:addTagProperty("dist", "19050").
        writer:addTagProperty("dir", "5400000").
        writer:addTagProperty("algn", "ctr").
        writer:addTagProperty("rotWithShape", "0").

        writer:addTag("a:srgbClr").
        writer:addTagProperty("val", "000000").

        writer:addTag("a:alpha", TRUE).
        writer:addTagProperty("val", "63000").
        
        writer:addClosingTag("a:srgbClr").
        writer:addClosingTag("a:outerShdw").
        writer:addClosingTag("a:effectLst").
        writer:addClosingTag("a:effectStyle").
        writer:addClosingTag("a:effectStyleLst").
        writer:addTag("a:bgFillStyleLst").

        writer:addTag("a:solidFill").

        writer:addTag("a:schemeClr", TRUE).
        writer:addTagProperty("val", "phClr").
        
        writer:addClosingTag("a:solidFill").
        writer:addTag("a:solidFill").

        writer:addTag("a:schemeClr").
        writer:addTagProperty("val", "phClr").

        writer:addTag("a:tint", TRUE).
        writer:addTagProperty("val", "95000").
        
        writer:addTag("a:satMod", TRUE).
        writer:addTagProperty("val", "170000").
        
        writer:addClosingTag("a:schemeClr").
        writer:addClosingTag("a:solidFill").
        writer:addTag("a:gradFill").
        writer:addTagProperty("rotWithShape", "1").

        writer:addTag("a:gsLst").

        writer:addTag("a:gs").
        writer:addTagProperty("pos", "0").

        writer:addTag("a:schemeClr").
        writer:addTagProperty("val", "phClr").

        writer:addTag("a:tint", TRUE).
        writer:addTagProperty("val", "93000").
        
        writer:addTag("a:satMod", TRUE).
        writer:addTagProperty("val", "150000").
        
        writer:addTag("a:shade", TRUE).
        writer:addTagProperty("val", "98000").
        
        writer:addTag("a:lumMod", TRUE).
        writer:addTagProperty("val", "102000").
        
        writer:addClosingTag("a:schemeClr").
        writer:addClosingTag("a:gs").
        writer:addTag("a:gs").
        writer:addTagProperty("pos", "50000").

        writer:addTag("a:schemeClr").
        writer:addTagProperty("val", "phClr").

        writer:addTag("a:tint", TRUE).
        writer:addTagProperty("val", "98000").
        
        writer:addTag("a:satMod", TRUE).
        writer:addTagProperty("val", "130000").
        
        writer:addTag("a:shade", TRUE).
        writer:addTagProperty("val", "90000").
        
        writer:addTag("a:lumMod", TRUE).
        writer:addTagProperty("val", "103000").
        
        writer:addClosingTag("a:schemeClr").
        writer:addClosingTag("a:gs").
        writer:addTag("a:gs").
        writer:addTagProperty("pos", "100000").

        writer:addTag("a:schemeClr").
        writer:addTagProperty("val", "phClr").

        writer:addTag("a:shade", TRUE).
        writer:addTagProperty("val", "63000").
        
        writer:addTag("a:satMod", TRUE).
        writer:addTagProperty("val", "120000").
        
        writer:addClosingTag("a:schemeClr").
        writer:addClosingTag("a:gs").
        writer:addClosingTag("a:gsLst").
        writer:addTag("a:lin", TRUE).
        writer:addTagProperty("ang", "5400000").
        writer:addTagProperty("scaled", "0").
        
        writer:addClosingTag("a:gradFill").
        writer:addClosingTag("a:bgFillStyleLst").
        writer:addClosingTag("a:fmtScheme").
        writer:addClosingTag("a:themeElements").
        writer:addClosingTag("a:theme").
        RETURN writer:writeXMLText().
    END METHOD.
END CLASS.