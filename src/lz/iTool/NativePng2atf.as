/**
 * Created with IntelliJ IDEA.
 * User: lizhi http://matrix3d.github.io/
 */
package lz.iTool {
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;

public class NativePng2atf {
	public var waits:Vector.<String>=new <String>[];
	public var runningCounter:int=0;
	public var maxRunning:int=10;
	public var png2atfUrl:String;
	private var log:Function;
	public function NativePng2atf(png2atfUrl:String,log:Function=null) {
		this.png2atfUrl=png2atfUrl;
		this.log=log;
	}

	public function add(arg:String,input:File,output:String):void{
		if(arg!="")arg=arg+" ";
		waits.push(arg+"-i "+input.nativePath+" -o "+output);
		if(log!=null){
			log(waits[waits.length-1]);
		}
		next();
	}
	public function next():void{
		if(runningCounter<maxRunning&&waits.length>0){
			var info:NativeProcessStartupInfo=new NativeProcessStartupInfo();
			info.executable=new File(png2atfUrl);
			var line:String=waits.shift();
			var linearr:Array=line.split(/\s+/g);
			info.arguments=Vector.<String>(linearr);
			var np:NativeProcess=new NativeProcess();
			np.addEventListener(NativeProcessExitEvent.EXIT, np_exit);
			np.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, np_standardOutputData);
			np.start(info);
			runningCounter++;
		}
	}
	private function np_standardOutputData(e:ProgressEvent):void
	{
		var np:NativeProcess= e.currentTarget as NativeProcess;
		var data:String = np.standardOutput.readMultiByte(np.standardOutput.bytesAvailable, "gb2312");
		data = data.split("\r\n").join("\n");
		if(log!=null)log(data);
	}

	private function np_exit(e:NativeProcessExitEvent):void
	{
		runningCounter--;
		if(log!=null)log("exit");
		next();
	}
}
}
