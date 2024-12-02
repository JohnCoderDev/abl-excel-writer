CLASS DrawingWriter:
    METHOD PUBLIC STATIC LONGCHAR writeDrawingXMLText():
        DEFINE VARIABLE writer AS XMLWriter.
        ASSIGN writer = NEW XMLWriter().
        writer:addTag("xdr:wsDr", TRUE).
        writer:addTagProperty("xmlns:xdr", "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing").
        writer:addTagProperty("xmlns:a", "http://schemas.openxmlformats.org/drawingml/2006/main").
        writer:addTagProperty("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships").
        writer:addTagProperty("xmlns:c", "http://schemas.openxmlformats.org/drawingml/2006/chart").
        writer:addTagProperty("xmlns:cx", "http://schemas.microsoft.com/office/drawing/2014/chartex").
        writer:addTagProperty("xmlns:cx1", "http://schemas.microsoft.com/office/drawing/2015/9/8/chartex").
        writer:addTagProperty("xmlns:mc", "http://schemas.openxmlformats.org/markup-compatibility/2006").
        writer:addTagProperty("xmlns:dgm", "http://schemas.openxmlformats.org/drawingml/2006/diagram").
        writer:addTagProperty("xmlns:x3Unk", "http://schemas.microsoft.com/office/drawing/2010/slicer").
        writer:addTagProperty("xmlns:sle15", "http://schemas.microsoft.com/office/drawing/2012/slicer").

        RETURN writer:writeXMLText().
    END METHOD.
END CLASS.