package {

import flash.desktop.NativeApplication;
import flash.desktop.NativeDragManager;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.JPEGEncoderOptions;
import flash.display.JPEGXREncoderOptions;
import flash.display.NativeWindow;
import flash.display.PNGEncoderOptions;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.NativeDragEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.utils.ByteArray;

import lz.net.LoaderBat;
import lz.net.LoaderCell;

import sliz.miniui.Button;
import sliz.miniui.Checkbox;
import sliz.miniui.LabelInput;
import sliz.miniui.Panel;

import sliz.miniui.TabPanel;

import sliz.miniui.Window;
import sliz.miniui.layouts.BoxLayout;

public class ImageTool extends Sprite {
	private var bg:Panel;
	private var formatTab:TabPanel;
	private var outPut:TextField=new TextField();
	private var jxrQ:LabelInput;
	private var jpgQ:LabelInput;
	private var isTrim:Checkbox;
    public function ImageTool() {
		println("image tool v 0.1");
		println("drag image file here");

		stage.align=StageAlign.TOP_LEFT;
		stage.scaleMode=StageScaleMode.NO_SCALE;
		stage.addEventListener(Event.RESIZE, stage_resizeHandler);

		addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler);
		addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler);

		bg=new Panel(this);
		bg.addChild(outPut);

		stage_resizeHandler(null);

		var window:Window=new Window(this,281,13);

		isTrim=new Checkbox("trim");
		window.add(isTrim);

		formatTab=new TabPanel(["jxr","jpg","png"]);

		jxrQ=new LabelInput("quantization");
		jxrQ.setValue("20")
		formatTab.getPanel(0).add(jxrQ);

		jpgQ=new LabelInput("quality");
		jpgQ.setValue("80")
		formatTab.getPanel(1).add(jpgQ);

		//

		window.add(formatTab);
		var layout:BoxLayout=new BoxLayout(window,BoxLayout.Y_AXIS,5);
		window.setLayout(layout);
		window.doLayout();
	}

	private function nativeDragEnterHandler(event:NativeDragEvent):void {
		NativeDragManager.acceptDragDrop(this);
	}

	private function nativeDragDropHandler(event:NativeDragEvent):void {
		var data:Array=event.clipboard.formats;
		var bat:LoaderBat=new LoaderBat();
		for each(var type:String in data){
			for each(var file:File in event.clipboard.getData(type)){
				var fs:FileStream=new FileStream();
				fs.open(file,FileMode.READ);
				var bytes:ByteArray=new ByteArray();
				fs.readBytes(bytes);
				fs.close();
				bat.addBytesImageLoader(bytes,null,file);
			}
		}
		bat.addEventListener(Event.COMPLETE, bat_completeHandler);
		bat.start();

		println("start loading");
	}

	private function getOption():ImageOption{
		var option:ImageOption=new ImageOption();
		if(formatTab.getPanel(0).stage){//jxr
			var jxrOption:JPEGXREncoderOptions=new JPEGXREncoderOptions();
			jxrOption.quantization=Number(jxrQ.getValue());
			//jxrOption.colorSpace;
			//jxrOption.trimFlexBits
			option.option=jxrOption;
			option.extension="wdp";
		}else if(formatTab.getPanel(1).stage){//jpg
			var jpgOption:JPEGEncoderOptions=new JPEGEncoderOptions();
			jpgOption.quality=Number(jpgQ.getValue());
			option.option=jpgOption;
			option.extension="jpg";
		}else{//png
			var pngOption:PNGEncoderOptions=new PNGEncoderOptions();
			option.option=pngOption;
			option.extension="png";
		}
		return option;
	}

	private function bat_completeHandler(event:Event):void {
		var option:ImageOption=getOption();

		var bat:LoaderBat= event.currentTarget as LoaderBat;
		for each(var loader:LoaderCell in bat.loaderComps){
			var bmd:BitmapData=loader.getImage();
			if(bmd){
				var file:File=loader.userData as File;
				var extension:String= file.extension;
				var name:String = file.name.substr(0,file.name.length-extension.length-1)+"."+option.extension;

				if(isTrim.getToggle()){
					var bwt:BitmapDataWithTrimInfo=trim(bmd);
					bmd=bwt.bmd;
				}
				var bytes:ByteArray=bmd.encode(bmd.rect,option.option);
				var url:String=file.parent.url+"/"+name;
				save(bytes,url);
				println("convert",file.name,name);
			}
		}
		println("over");
		println();
	}

	private function trim(bmd:BitmapData):BitmapDataWithTrimInfo{
		var bwt:BitmapDataWithTrimInfo=new BitmapDataWithTrimInfo();
		bwt.rect = bmd.getColorBoundsRect(0xff000000, 0, false);
		bwt.bmd = new BitmapData(bwt.rect.width, bwt.rect.height, bmd.transparent, 0);
		bwt.bmd.draw(bmd, new Matrix(1, 0, 0, 1, -bwt.rect.x, -bwt.rect.y),null,null,null,true);
		return bwt;
	}

	private function save(bytes:ByteArray,url:String):void{
		var ofile:File=new File(url);
		var fs:FileStream=new FileStream();
		fs.open(ofile,FileMode.WRITE);
		fs.writeBytes(bytes);
		fs.close();
	}

	private function stage_resizeHandler(event:Event):void {
		bg.setWH(stage.stageWidth,stage.stageHeight);
		outPut.width=stage.stageWidth;
		outPut.height=stage.stageHeight;
	}

	private  function println(...txt):void{
		outPut.appendText(txt+"\n");
		outPut.scrollV=outPut.maxScrollV;
	}
}
}
