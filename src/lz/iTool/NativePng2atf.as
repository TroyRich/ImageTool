/**
 * Created with IntelliJ IDEA.
 * User: lizhi http://matrix3d.github.io/
 */
package lz.iTool {
import flash.filesystem.File;

public class NativePng2atf {
	public var waits:Vector.<String>=new <String>[];
	public var runningCounter:int=0;
	public var maxRunning:int=10;
	public var png2atfUrl:String;
	public function NativePng2atf(png2atfUrl:String) {
		this.png2atfUrl=png2atfUrl;
	}

	public function add(arg:String,input:File,output:String):void{

	}
	public function next():void{

	}
}
}
