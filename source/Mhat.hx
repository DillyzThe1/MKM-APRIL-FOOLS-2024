
import cpp.UInt16;
import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesData;
import lime.system.Endian;
import openfl.filesystem.File as OpenFLFile;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef CachedIndex = {
    var fullPath:String;
    var path:String;
    var pos:UInt;
    var heap:UInt;
}

class MhatData {
    public var fileName:String;
    public var hostPath:String;
    //public var data:Bytes;
    public var stream:FileStream;
    public var version:UInt16;
    public var heapSize:UInt;
    public var indexCache:Array<String>;
    public var count(get, never):Int;
    public var mounted(get, set):Bool;
    private var __mounted:Bool = false;
    public var add:Array<String>;
    public var remove:Array<String>;

    public var indexCache_mapped:Map<String, CachedIndex> = [];

    public var fileCount:UInt16 = 0;
    var zstd:Bool;
    var key:String;

    // Read "Null Terminated String"
    public function readNTS(pos:UInt):String {
        if (pos < 0 || pos >= heapSize) {
            trace('MHAT ERROR: Null-Terminated String call in $fileName caused an overflow!');
            return "";
        }
        var builtString:String = "";

        for (i in 0...(heapSize - pos)) {
            stream.position = pos + i;
            if (stream.readUnsignedByte() == 0x00)
                return builtString;
            stream.position--;
            builtString += stream.readUTFBytes(1);
        }
        return builtString;
    }

    public function new(fileName:String, hostPath:String, zstd:Bool, add:Array<String>, remove:Array<String>, ?key:String=null) {
        this.fileName = fileName;
        this.hostPath = hostPath;
        this.add = add;
        this.remove = remove;
        this.key = key;
        this.zstd = zstd;

        trace("MHAT CONSTRUCTOR: " + hostPath + " | " + Main.hostFolder + "/mounted/" + fileName);
        var epicFile:OpenFLFile = new OpenFLFile(Main.hostFolder + '/mounted/' + fileName);
        if (epicFile == null || !epicFile.exists)
            return;

        this.stream = new FileStream();
        stream.open(epicFile, FileMode.READ);
        heapSize = stream.bytesAvailable;
        __mounted = true;

        // get header data
        stream.endian = Endian.LITTLE_ENDIAN;
        stream.position = 0x06;
        version = stream.readUnsignedShort();
        fileCount = stream.readUnsignedShort();
        trace('MHAT MANAGER: $fileName has $fileCount files on verison $version.');

        // debug the file
        stream.position = 0x20;
        indexCache = new Array<String>();

        for (i in 0...fileCount) {
            //var aaaa:String = StringTools.hex(stream.position);
            var awesomeFileName:String = readNTS(stream.position);
            //pos += awesomeFileName.length + 1;
            var awesomeFileSize:UInt = stream.readUnsignedInt();


            //trace('MHAT ($fileName): $awesomeFileName @ ' + aaaa + ' ($awesomeFileSize @ ${StringTools.hex(stream.position)})');
            indexCache.push(awesomeFileName);
            indexCache_mapped[hostPath + awesomeFileName] = {fullPath: hostPath + awesomeFileName, path: awesomeFileName, pos: stream.position, heap: awesomeFileSize};
            stream.position += awesomeFileSize;
        }
        //

        stream.close();
        __mounted = false;

        trace('MHAT MANAGER: $fileName\'s constructor is done.');
    }

    function get_count():Int {
        return indexCache.length;
    }

    function get_mounted():Bool {
        return __mounted;
    }

    function set_mounted(value:Bool):Bool {
        if (value == mounted) {
            trace('MHAT MANAGER: $fileName is already ${mounted ? "mounted" : "unmounted"}.');
            return mounted;
        }
        if (mounted) {
            trace('MHAT MANAGER: Unmounting $fileName.');
            stream.close();
            __mounted = false;
            return false;
        }
        var epicFile:OpenFLFile = new OpenFLFile(Main.hostFolder + '/mounted/' + fileName);
        if (epicFile == null || !epicFile.exists) {
            trace('MHAT MANAGER: Failed to mount $fileName!');
            __mounted = false;
            return false;
        }
        trace('MHAT MANAGER: Mounting $fileName.');
        stream.open(epicFile, FileMode.READ);
        __mounted = true;
        return true;
    }

    public function getBytes(pos:UInt, length:UInt):Bytes {
        if (pos < 0 || pos + length > heapSize) {
            trace('MHAT MANAGER: $fileName getBytes() call goes OVER the file\'s size!\n(${pos + length} > ${heapSize})');
            return null;
        }
        //trace('MHAT MANAGER: $fileName getBytes() called at ' + StringTools.hex(pos));
        var bestOutput:Bytes = Bytes.alloc(length);
        for (i in 0...length) {
            stream.position = pos + i;
            bestOutput.set(i, stream.readUnsignedByte());
        }
        return bestOutput;
    }
}

typedef MhatMetadata = {
    var data:String;
    var parent:String;
    var zstd:Bool;
    var key:String;
    var add:Array<String>;
    var remove:Array<String>;
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
            //trace('MHAT MANAGER: Checking ${mhat.fileName}; add on "${mhat.add}" & remove on "${mhat.remove}".');
            if (mhat.add.contains(key))
                mhat.mounted = true;
            else if (mhat.remove.contains(key))
                mhat.mounted = false;
        }
    }

    public static function exists(path:String):Bool {
        for (mhat in mhats) {
            if (!mhat.mounted)
                continue;
            if (mhat.indexCache_mapped.exists(path))
                return true;
        }
        return false;
    }

    public static function getFile(path:String):Bytes {
        for (mhat in mhats) {
            if (!mhat.mounted)
                continue;

            mhat.stream.endian = Endian.LITTLE_ENDIAN;
            if (mhat.indexCache_mapped.exists(path)) {
                //trace('MHAT MANAGER: ${mhat.fileName} - $path');
                var ci:CachedIndex = mhat.indexCache_mapped.get(path);
                return mhat.getBytes(ci.pos, ci.heap);
            }
        }
        return null;
    }
}