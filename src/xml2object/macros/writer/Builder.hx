package xml2object.macros.writer;

import xml2object.util.StringUtil;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.TypeTools;

using StringTools;

#if !macro

class Builder {}

#else

class Builder {
    private static var writers = new Map<String, Type>();

    private static function buildWriteXmlFrom(type:Type, exprs:Array<Expr> = null, createDoc:Bool = true) {
        if (exprs == null) {
            exprs = [];
        }

        var nodeName = StringUtil.uncapitalizeFirstLetter(TypeTools.toString(type).split(".").pop());

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
                    buildWriteXmlFrom(tt, exprs, false);
                }

                for (f in t.get().fields.get()) {
                    buildFieldExpr(f, exprs);
                }
            case _:
        }    

        if (createDoc) {
            return macro {
                var doc = new xml2object.util.XmlDocument();
                doc.nodeName = $v{nodeName};
                $b{exprs}
                return doc;
            }
        }
        return macro {
            $b{exprs}
            return doc;
        }
}

    private static function buildFieldExpr(field:ClassField, exprs:Array<Expr>) {
        switch (field.kind) {
            case FVar(read, write):
                var varName = field.name;
                var varType = TypeTools.toString(field.type);
                var nodeName = varName;

                var isValue = (varName == "value");
                var isAttr = field.meta.has(":attr") || field.meta.has(":attribute");
                var isNullable = true;

                if (isValue) {
                    switch (varType) {
                        case "String":
                            exprs.push(macro if (object.$varName != null) {
                                doc.text = object.$varName;
                            });
                        case "Int" | "Bool" | "Float":
                            if (isNullable) {
                                exprs.push(macro if (object.$varName != null) {
                                    doc.text = Std.string(object.$varName);
                                });
                            } else {
                                exprs.push(macro doc.text = Std.string(object.$varName));
                            }
                    }
                } else {

                    switch (varType) {
                        case "String":
                            if (isAttr) {
                                exprs.push(macro if (object.$varName != null) {
                                    doc.attr($v{nodeName}, object.$varName);
                                });
                            } else {
                                exprs.push(macro if (object.$varName != null) {
                                    var childNode = doc.createChild($v{nodeName});
                                    childNode.text = object.$varName;
                                });
                            }
                        case "Int" | "Bool" | "Float":
                            if (isAttr) {
                                if (isNullable) {
                                    exprs.push(macro if (object.$varName != null) {
                                        doc.attr($v{nodeName}, Std.string(object.$varName));
                                    });
                                } else {
                                    exprs.push(macro {
                                        doc.attr($v{nodeName}, Std.string(object.$varName));
                                    });
                                }
                            } else {
                                if (isNullable) {
                                    exprs.push(macro if (object.$varName != null) {
                                        var childNode = doc.createChild($v{nodeName});
                                        childNode.text = Std.string(object.$varName);
                                    });
                                } else {
                                    exprs.push(macro {
                                        var childNode = doc.createChild($v{nodeName});
                                        childNode.text = Std.string(object.$varName);
                                    });
                                }
                            }
                        case _:
                            switch (field.type) {
                                case TInst(t, params):
                                    switch (t.toString()) {
                                        case "Array":
                                            switch (TypeTools.toString(params[0])) {
                                                case "String" | "Int" | "Bool" | "Float":
                                                    exprs.push(macro if (object.$varName != null) {
                                                        for (item in object.$varName) {
                                                            var childNode = doc.createChild($v{nodeName});
                                                            childNode.text = Std.string(item);
                                                        }
                                                    });
                                                case _:
                                                    var ctype = TypeTools.toComplexType(params[0]);
                                                    var tpath = typeToTypePath(params[0]);
                                                    exprs.push(macro if (object.$varName != null) {
                                                        for (item in object.$varName) {
                                                            var writer = new xml2object.XmlWriter<$ctype>();
                                                            var childNode = @:privateAccess writer.writeXmlFrom(item);
                                                            doc.addChild(childNode);
                                                        }
                                                    });
                                            }
                                        case _:
                                            var ctype = TypeTools.toComplexType(field.type);
                                            var tpath = typeToTypePath(field.type);

                                            exprs.push(macro if (object.$varName != null) {
                                                var writer = new xml2object.XmlWriter<$ctype>();
                                                var childNode = @:privateAccess writer.writeXmlFrom(object.$varName);
                                                doc.addChild(childNode);
                                            });
                                    }
                                case TType(t, params):
                                    switch (t.toString()) {
                                        case "Map":
                                            var ctype = TypeTools.toComplexType(params[1]);
                                            var tpath = typeToTypePath(params[1]);

                                            var keyAttrName = "id";
                                            exprs.push(macro if (object.$varName != null) {
                                                for (key in object.$varName.keys()) {
                                                    var item = object.$varName.get(key);
                                                    var writer = new xml2object.XmlWriter<$ctype>();
                                                    var childNode = @:privateAccess writer.writeXmlFrom(item);
                                                    childNode.attr($v{keyAttrName}, Std.string(key));
                                                    doc.addChild(childNode);
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

    private static function buildWriter(c:BaseType, type:Type) {
		var writerMapName = TypeTools.toString(type);

		if (writers.exists(writerMapName)) {
			return writers.get(writerMapName);
		}

        var writerName = "XmlWriter_" + TypeTools.toString(type).replace(".", "_");

        var ctype = TypeTools.toComplexType(type);
        var tpath = typeToTypePath(type);
        var parser = macro class $writerName {
            public function new() {

            }

            public function toXmlString(object:$ctype):String {
                var xml = toXml(object);
                return xml.toString();
            }

            public function toXml(object:$ctype):Xml {
                var doc = new xml2object.util.XmlDocument(Xml.parse("<root_1></root_1>"));
                var doc = writeXmlFrom(object);
                return doc.xml;
            }
        }

        var writeXmlFrom:Field = {
			doc: null,
			kind: FFun({args:[{name: "object", type: ctype}], expr: buildWriteXmlFrom(type), params: null, ret: macro: xml2object.util.XmlDocument}),
			access: [APrivate],
			name: "writeXmlFrom",
			pos:Context.currentPos(),
			meta: null
		}
		parser.fields.push(writeXmlFrom);

        haxe.macro.Context.defineType(parser);

        var constructedType = haxe.macro.Context.getType(writerName);
        writers.set(writerMapName, constructedType);
        return constructedType;
    }

    public static function build() {
        switch (Context.getLocalType()) {
            case TInst(c, [type]):
                return buildWriter(c.get(), type);
            case _:
                Context.fatalError("xml2object: Writing tools must be a class", Context.currentPos());
          }
          return null;
    }
}

#end