package xml2object.macros.reader;

import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.TypeTools;

using StringTools;

#if !macro

class Builder {}

#else

class Builder {
    private static var parsers = new Map<String, Type>();

    private static function buildParseXmlToExpr(type:Type, exprs:Array<Expr> = null) {
        if (exprs == null) {
            exprs = [];
        }

        switch (type) {
            case TInst(t, params):
                var parentClasses = [];
                var ref = t.get();
                while (ref.superClass != null) {
                    parentClasses.push(ref.superClass.t.get());
                    ref = ref.superClass.t.get();
                }
                parentClasses.reverse();

                var typeList = [];
                for (parentClass in parentClasses) {
                    var name = parentClass.module;
                    typeList.push(Context.getType(name));
                }

                for (tt in typeList) {
                    var ctype = TypeTools.toComplexType(tt);
                    exprs.push(macro {
                        var parser = new xml2object.XmlParser<$ctype>();
                        @:privateAccess parser.parseXmlTo(node, object);
                    });
                }

                for (f in t.get().fields.get()) {
                    buildFieldExpr(f, exprs);
                }
            case _:    
        }
        return macro {
            $b{exprs}
        }
    }

    private static function buildFieldExpr(field:ClassField, exprs:Array<Expr>) {
        switch (field.kind) {
            case FVar(read, write):
                var varName = field.name;
                var varType = TypeTools.toString(field.type);
                var nodeName = varName;

                var isValue = (varName == "value");
                var isNullable = true;

                if (isValue) {
                    switch (varType) {
                        case "String":
                            var defaultValue = macro null;
                            exprs.push(macro object.$varName = $e{defaultValue});
                            exprs.push(macro if (node.text != null) {
                                object.$varName = node.text;
                            });
                        case "Int":
                            var defaultValue = macro 0;
                            if (isNullable) {
                                defaultValue = macro null;
                            }
                            exprs.push(macro object.$varName = $e{defaultValue});
                            exprs.push(macro if (node.text != null) {
                                object.$varName = Std.parseInt(node.text);
                            });
                        case "Bool": 
                            var defaultValue = macro false;
                            if (isNullable) {
                                defaultValue = macro null;
                            }
                            exprs.push(macro object.$varName = $e{defaultValue});
                            exprs.push(macro if (node.text != null) {
                                object.$varName = (node.text == "true");
                            });
                        case "Float":       
                            var defaultValue = macro 0;
                            if (isNullable) {
                                defaultValue = macro null;
                            }
                            exprs.push(macro object.$varName = $e{defaultValue});
                            exprs.push(macro if (node.text != null) {
                                object.$varName = Std.parseFloat(node.text);
                            });
                    }
                } else {
                    switch (varType) {
                        case "String":
                            var defaultValue = macro null;
                            exprs.push(macro object.$varName = $e{defaultValue});
                            exprs.push(macro if (node.hasAttr($v{nodeName})) {
                                object.$varName = node.attr($v{nodeName});
                            } else if (node.hasChild($v{nodeName}) && node.hasChildText($v{nodeName})) {
                                object.$varName = node.childText($v{nodeName});
                            });
                        case "Int":
                            var defaultValue = macro 0;
                            if (isNullable) {
                                defaultValue = macro null;
                            }
                            exprs.push(macro object.$varName = $e{defaultValue});
                            exprs.push(macro if (node.hasAttr($v{nodeName})) {
                                object.$varName = Std.parseInt(node.attr($v{nodeName}));
                            } else if (node.hasChild($v{nodeName}) && node.hasChildText($v{nodeName})) {
                                object.$varName = Std.parseInt(node.childText($v{nodeName}));
                            });
                        case "Bool":
                            var defaultValue = macro false;
                            if (isNullable) {
                                defaultValue = macro null;
                            }
                            exprs.push(macro object.$varName = $e{defaultValue});
                            exprs.push(macro if (node.hasAttr($v{nodeName})) {
                                object.$varName = (node.attr($v{nodeName}) == "true");
                            } else if (node.hasChild($v{nodeName}) && node.hasChildText($v{nodeName})) {
                                object.$varName = (node.childText($v{nodeName}) == "true");
                            });
                        case "Float":
                            var defaultValue = macro 0;
                            if (isNullable) {
                                defaultValue = macro null;
                            }
                            exprs.push(macro object.$varName = $e{defaultValue});
                            exprs.push(macro if (node.hasAttr($v{nodeName})) {
                                object.$varName = Std.parseFloat(node.attr($v{nodeName}));
                            } else if (node.hasChild($v{nodeName}) && node.hasChildText($v{nodeName})) {
                                object.$varName = Std.parseFloat(node.childText($v{nodeName}));
                            });
                        case _:
                            switch (field.type) {
                                case TInst(t, params):
                                    switch (t.toString()) {
                                        case "Array":
                                            var defaultValue = macro [];
                                            exprs.push(macro object.$varName = $e{defaultValue});
                                            switch (TypeTools.toString(params[0])) {
                                                case "String":
                                                    exprs.push(macro for (item in node.children($v{nodeName})) {
                                                        if (item.text != null) {
                                                            object.$varName.push(item.text);
                                                        }
                                                    });
                                                case "Int":
                                                    exprs.push(macro for (item in node.children($v{nodeName})) {
                                                        if (item.text != null) {
                                                            object.$varName.push(Std.parseInt(item.text));
                                                        }
                                                    });
                                                case "Bool":
                                                    exprs.push(macro for (item in node.children($v{nodeName})) {
                                                        if (item.text != null) {
                                                            object.$varName.push(item.text == "true");
                                                        }
                                                    });
                                                case "Float":
                                                    exprs.push(macro for (item in node.children($v{nodeName})) {
                                                        if (item.text != null) {
                                                            object.$varName.push(Std.parseFloat(item.text));
                                                        }
                                                    });
                                                case _:   
                                                    var ctype = TypeTools.toComplexType(params[0]);
                                                    var tpath = typeToTypePath(params[0]);
                                                    exprs.push(macro for (item in node.children($v{nodeName})) {
                                                        var parser = new xml2object.XmlParser<$ctype>();
                                                        var o = new $tpath();
                                                        @:privateAccess parser.parseXmlTo(item, o);
                                                        object.$varName.push(o);
                                                    });
                                            }
                                        case _:     
                                            var ctype = TypeTools.toComplexType(field.type);
                                            var tpath = typeToTypePath(field.type);
            
                                            exprs.push(macro if (node.hasChild($v{nodeName})) {
                                                var parser = new xml2object.XmlParser<$ctype>();
                                                object.$varName = new $tpath();
                                                @:privateAccess parser.parseXmlTo(node.child($v{nodeName}), object.$varName);
                                            });
                                    }
                                case TType(t, params):    
                                    switch (t.toString()) {
                                        case "Map":
                                            var ctype = TypeTools.toComplexType(params[1]);
                                            var tpath = typeToTypePath(params[1]);
                                            
                                            var defaultValue = macro [];
                                            exprs.push(macro object.$varName = $e{defaultValue});
                                            var keyAttrName = "id";
                                            exprs.push(macro for (item in node.children($v{nodeName})) {
                                                var key = item.attr($v{keyAttrName});
                                                if (key != null) {
                                                    var parser = new xml2object.XmlParser<$ctype>();
                                                    var o = new $tpath();
                                                    @:privateAccess parser.parseXmlTo(item, o);
                                                    object.$varName.set(key, o);
                                                }
                                            });
                                    }
                                case _:    
                            }
                    }
                }
            case _:    
        }
    }

    private static function typeToTypePath(type:Type):TypePath {
        var typeFullName = TypeTools.toString(type);
        var typePackage = typeFullName.split(".");
        var typeName = typePackage.pop();

        var typePath = { name: typeName, pack: typePackage, params: null, sub: null };
        return typePath;
    }

    private static function buildParser(c:BaseType, type:Type) {
		var parserMapName = TypeTools.toString(type);

		if (parsers.exists(parserMapName)) {
			return parsers.get(parserMapName);
		}

        var parserName = "XmlParser_" + TypeTools.toString(type).replace(".", "_");

        var ctype = TypeTools.toComplexType(type);
        var tpath = typeToTypePath(type);
        var parser = macro class $parserName {
            public function new() {

            }

            public function fromString(s:String) {
                return fromXmlString(s);
            }

            public function fromXmlString(s:String) {
                return fromXml(Xml.parse(s));
            }

            public function fromXml(xml:Xml) {
                var object = new $tpath();
                parseXmlTo(new xml2object.util.XmlDocument(xml), object);
                return object;
            }
        }

        var parseXmlTo:Field = {
			doc: null,
			kind: FFun({args:[{name: "node", type: macro: xml2object.util.XmlDocument}, {name: "object", type: ctype}], expr: buildParseXmlToExpr(type), params: null, ret: macro: Void}),
			access: [APrivate],
			name: "parseXmlTo",
			pos:Context.currentPos(),
			meta: null
		}
		parser.fields.push(parseXmlTo);
        
        haxe.macro.Context.defineType(parser);

        var constructedType = haxe.macro.Context.getType(parserName);
        parsers.set(parserMapName, constructedType);
        return constructedType;
    }

    public static function build() {
        switch (Context.getLocalType()) {
            case TInst(c, [type]):
                return buildParser(c.get(), type);
            case _:
                Context.fatalError("xml2object: Parsing tools must be a class", Context.currentPos());
          }
          return null;
    }
}

#end