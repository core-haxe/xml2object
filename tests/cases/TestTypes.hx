package cases;

import utest.Test;
import utest.Assert;
import utest.Async;

import cases.types.Root;

class TestTypes extends Test {
    function testAttributes(async:Async) {
        var xml = '
        <root attr1="value1" attr2="123" attr3="123.456" attr4="true">
            <childNodeA childAttr1="childValue1" childAttr2="321" childAttr3="654.321" childAttr4="true" />
        </root>
        ';
        var root = new xml2object.XmlParser<Root>().fromXmlString(xml);
        Assert.equals("value1", root.attr1);
        Assert.equals(123, root.attr2);
        Assert.equals(123.456, root.attr3);
        Assert.equals(true, root.attr4);
        Assert.equals("childValue1", root.childNodeA.childAttr1);
        Assert.equals(321, root.childNodeA.childAttr2);
        Assert.equals(654.321, root.childNodeA.childAttr3);
        Assert.equals(true, root.childNodeA.childAttr4);

        // lets convert it to a string, then parse it again to make sure writer is working as expected
        var rootXml = new xml2object.XmlWriter<Root>().toXmlString(root);
        var root = new xml2object.XmlParser<Root>().fromXmlString(rootXml);
        Assert.equals("value1", root.attr1);
        Assert.equals(123, root.attr2);
        Assert.equals(123.456, root.attr3);
        Assert.equals(true, root.attr4);
        Assert.equals("childValue1", root.childNodeA.childAttr1);
        Assert.equals(321, root.childNodeA.childAttr2);
        Assert.equals(654.321, root.childNodeA.childAttr3);
        Assert.equals(true, root.childNodeA.childAttr4);


        async.done();
    }

    function testChildren(async:Async) {
        var xml = '
        <root>
            <stringChild>value1</stringChild>
            <intChild>123</intChild>
            <floatChild>123.456</floatChild>
            <boolChild>true</boolChild>
            <childNodeA>
                <stringChild>childValue1</stringChild>
                <intChild>321</intChild>
                <floatChild>654.321</floatChild>
                <boolChild>true</boolChild>
            </childNodeA>
        </root>
        ';
        var root = new xml2object.XmlParser<Root>().fromXmlString(xml);
        Assert.equals("value1", root.stringChild);
        Assert.equals(123, root.intChild);
        Assert.equals(123.456, root.floatChild);
        Assert.equals(true, root.boolChild);
        Assert.equals("childValue1", root.childNodeA.stringChild);
        Assert.equals(321, root.childNodeA.intChild);
        Assert.equals(654.321, root.childNodeA.floatChild);
        Assert.equals(true, root.childNodeA.boolChild);


        // lets convert it to a string, then parse it again to make sure writer is working as expected
        var rootXml = new xml2object.XmlWriter<Root>().toXmlString(root);
        var root = new xml2object.XmlParser<Root>().fromXmlString(rootXml);
        Assert.equals("value1", root.stringChild);
        Assert.equals(123, root.intChild);
        Assert.equals(123.456, root.floatChild);
        Assert.equals(true, root.boolChild);
        Assert.equals("childValue1", root.childNodeA.stringChild);
        Assert.equals(321, root.childNodeA.intChild);
        Assert.equals(654.321, root.childNodeA.floatChild);
        Assert.equals(true, root.childNodeA.boolChild);

        async.done();
    }
}
