
import cpp.UInt16;
import haxe.Json;
import haxe.io.Bytes;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class MhatData {
    public var fileName:String;
    public var hostPath:String;
    public var data:Bytes;
    public var version:Int;
    public var heapSize:Int;
    public var indexCache:Array<String>;
    public var count(get, never):Int;
    public var mounted(get, set):Bool;
    public var add:String;
    public var remove:String;

    public var fileCount:UInt16 = 0;
    var zstd:Bool;
    var key:String;

    // Read "Null Terminated String"
    function readNTS(pos:Int):String {
        if (pos < 0 || pos >= data.length)
            return "";
        var builtString:String = "";

        for (i in 0...(data.length - pos)) {
            if (data.get(pos + i) == 0x00)
                return builtString;
            builtString += data.getString(pos + i, 1);
        }
        return builtString;
    }

    public function new(fileName:String, hostPath:String, zstd:Bool, add:String, ?remove:String="", ?key:String=null) {
        this.fileName = fileName;
        this.hostPath = hostPath;
        this.add = add;
        this.remove = remove;
        this.key = key;
        this.zstd = zstd;

        this.data = getFileBytes();

        if (this.data == null)
            return;

        // debug the file
        var pos:Int = 0x20;
        indexCache = new Array<String>();

        for (i in 0...fileCount) {
            var awesomeFileName:String = readNTS(pos);
            pos += awesomeFileName.length + 1;
            var awesomeFileSize:Int = data.getInt32(pos);
            pos += 4;
            trace('MHAT MANAGER: $fileName has a file called "${awesomeFileName}" with the heap size of ${awesomeFileSize}.');
    
            indexCache.push(awesomeFileName);
            pos += awesomeFileSize;
            //File.saveBytes("debug.png", data.sub(pos, awesomeFileSize));
        }
        //

        for (i in 0...data.length)
            data.getData().pop();
        data = null;

        trace('MHAT MANAGER: $fileName\'s constructor is done.');
    }

    function get_count():Int {
        return indexCache.length;
    }

    function get_mounted():Bool {
        return data != null && data.length > 0;
    }

    function getFileBytes():Bytes {
        var filePath:String = 'mounted/' + fileName;
        if (!FileSystem.exists(filePath)) {
            trace('Content $filePath doesn\'t exist!');
            return null;
        }

        var data_local:Bytes = File.getBytes(filePath);

        if (zstd) {
            trace('We don\'t know how to deal with zstandard compression yet!');
            for (i in 0...data_local.length)
                data_local.getData().pop();
            return null;
        }

        if (key != null && key != "") {
            trace('We don\'t know how to decrypt $fileName with key $key!');
            for (i in 0...data_local.length)
                data_local.getData().pop();
            return null;
        }

        heapSize = data_local.length;

        // real reading
        var magic:String = data_local.getString(0, 4);
        if (magic != "MHAT") {
            trace('$fileName has the wrong magic! (Expected MHAT, got $magic)');
            for (i in 0...data_local.length)
                data_local.getData().pop();
            return null;
        }

        var version:UInt16 = data_local.getUInt16(6);
        fileCount = data_local.getUInt16(8);
        trace('MHAT $fileName loaded on v$version with $fileCount files.');

        return data_local;
    }

    function set_mounted(value:Bool):Bool {
        if (value == mounted) {
            trace('MHAT MANAGER: $fileName is already ${mounted ? "mounted" : "unmounted"}.');
            return mounted;
        }
        if (mounted) {
            trace('MHAT MANAGER: Unmounting $fileName.');
            for (i in 0...data.length)
                data.getData().pop();
            data = null;
            trace('MHAT MANAGER: $fileName data: ${data.length} bytes.');
            return false;
        }
        trace('MHAT MANAGER: Mounting $fileName.');
        data = getFileBytes();
        if (data == null)
            return false;
        return true;
    }
}

typedef MhatMetadata = {
    var data:String;
    var parent:String;
    var zstd:Bool;
    var key:String;
    var add:String;
    var remove:String;
}

typedef MountMetadata = {
	var mhats:Array<MhatMetadata>;
    var log_verbose:Bool;
}

class Mhat {
    public static var mount:MountMetadata;
    public static var mhats:Array<MhatData>;

    public static function initialize() {
        trace('MHAT MANAGER: Initializing.');
        mount = cast Json.parse(File.getContent("mount.json"));
        mhats = new Array<MhatData>();

        for (i in mount.mhats) {
            trace('MHAT MANAGER: File ${i.data} detected.');
            mhats.push(new MhatData(i.data, i.parent, i.zstd, i.add, i.remove, i.key));
        }
    }

    public static function call(key:String) {
        if (key == "" || key == null)
            return;
        trace('MHAT MANAGER: Key $key triggered.');
        for (mhat in mhats) {
            trace('MHAT MANAGER: Checking ${mhat.data}; add on "${mhat.add}" & remove on "${mhat.remove}".');
            if (mhat.add == key)
                mhat.mounted = true;
            else if (mhat.remove == key)
                mhat.mounted = false;
        }
    }
}