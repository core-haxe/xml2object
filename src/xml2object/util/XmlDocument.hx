package xml2object.util;

class XmlDocument {
    public var xml:Xml;

    public function new(xml:Xml = null) {
        if (xml != null && xml.nodeType == Document) {
            xml = xml.firstElement();
        }
        this.xml = xml;
    }

    public var text(get, set):String;
    private function get_text():String {
        if (xml.firstChild() == null) {
            return null;
        }
        return xml.firstChild().nodeValue;
    }
    private function set_text(value:String):String {
        if (xml == null) {
            trace("WARNING: no parent document");
            return value;
        }
        xml.firstChild().nodeValue = value;
        return value;
    }

    public var nodeName(get, set):String;
    private function get_nodeName():String {
        return xml.nodeName;
    }
    private function set_nodeName(value:String):String {
        if (xml == null) {
            xml = Xml.parse('<$value></$value>').firstElement();
        } else {
            xml.nodeName = value;
        }
        return value;
    }

    public function attr(name:String, value:Any = null):String {
        if (value == null) {
            return xml.get(name);
        }

        xml.set(name, Std.string(value));
        return Std.string(value);
    }

    public function hasAttr(name:String):Bool {
        return xml.exists(name);
    }

    public function childText(name:String, defaultValue:String = null):String {
        var text = defaultValue;
        var elements = xml.elementsNamed(name);
        var count = 0;
        var first = true;
        for (element in elements) {
            if (first == true) {
                text = element.firstChild().nodeValue;
                first = false;
            }
            count++;
        }

        if (count > 1) {
            trace("WARNING: multiple '" + name + "' nodes found, using first");
        }

        return text;
    }

    public function hasChildText(name:String):Bool {
        var has = false;
        var elements = xml.elementsNamed(name);
        var count = 0;
        var first = true;
        for (element in elements) {
            if (first == true) {
                has = true;
                first = false;
            }
            count++;
        }

        if (count > 1) {
            trace("WARNING: multiple '" + name + "' nodes found, using first");
        }

        return has;
    }

    public function child(name:String):XmlDocument {
        var c:XmlDocument = null;
        var elements = xml.elementsNamed(name);
        var count = 0;
        var first = true;
        for (element in elements) {
            if (first == true) {
                c = new XmlDocument(element);
                first = false;
            }
            count++;
        }

        if (count > 1) {
            trace("WARNING: multiple '" + name + "' nodes found, using first");
        }

        return c;
    }

    public function addChild(child:XmlDocument):XmlDocument {
        if (xml == null) {
            trace("WARNING: no parent document");
            return null;
        }

        xml.addChild(child.xml);

        var elements = xml.elementsNamed(child.nodeName);
        var lastElement = null;
        for (element in elements) {
            lastElement = element;
        }
        var c:XmlDocument = new XmlDocument(lastElement);
        return c;
    }

    public function createChild(name:String):XmlDocument {
        if (xml == null) {
            trace("WARNING: no parent document");
            return null;
        }

        var childXml = '<$name></$name>';
        xml.addChild(Xml.parse(childXml).firstElement());

        var elements = xml.elementsNamed(name);
        var lastElement = null;
        for (element in elements) {
            lastElement = element;
        }
        var c:XmlDocument = new XmlDocument(lastElement);
        return c;
    }

    public function children(name:String = null):Array<XmlDocument> {
        var c = [];
        var elements = null;
        if (name != null) {
            elements = xml.elementsNamed(name);
        } else {
            elements = xml.elements();
        }

        for (element in elements) {
            c.push(new XmlDocument(element));
        }

        return c;
    }

    public function hasChild(name:String):Bool {
        var has = false;
        var elements = xml.elementsNamed(name);
        for (element in elements) {
            has = true;
            break;
        }
        return has;
    }
}