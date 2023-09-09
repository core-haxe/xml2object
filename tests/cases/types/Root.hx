package cases.types;

class Root {
    public function new() {
    }

    @:attr public var attr1:String;
    @:attr public var attr2:Int;
    @:attr public var attr3:Float;
    @:attr public var attr4:Bool;

    public var stringChild:String;
    public var intChild:Int;
    public var floatChild:Float;
    public var boolChild:Bool;

    public var childNodeA:ChildNodeA;
}