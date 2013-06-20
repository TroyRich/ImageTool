package lz.iTool {

import atf.Encoder;
import atf.EncodingOptions;
import atf.EncodingOptions;

import flash.desktop.NativeApplication;
import flash.desktop.NativeDragManager;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
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
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.utils.ByteArray;

import lz.net.LoaderBat;
import lz.net.LoaderCell;

import org.villekoskela.utils.RectanglePacker;

import sliz.miniui.Button;
import sliz.miniui.Checkbox;
import sliz.miniui.LabelInput;
import sliz.miniui.Panel;

import sliz.miniui.TabPanel;

import sliz.miniui.Window;
import sliz.miniui.layouts.BoxLayout;

public class ImageTool extends Sprite {
	private var bg:Panel;
	private var outPut:TextField=new TextField();

	private var widthInput:LabelInput;
	private var heightInput:LabelInput;
	private var scaleXInput:LabelInput;
	private var scaleYInput:LabelInput;
	private var isTrim:Checkbox;
	private var isPow2:Checkbox;
	private var isPack:Checkbox;
	private var formatTab:TabPanel;
	private var jxrQ:LabelInput;
	private var jpgQ:LabelInput;
	private var outputInput:LabelInput;
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

		var window:Window=new Window(this,260,13);

		widthInput=new LabelInput("width ");
		window.add(widthInput);
		heightInput=new LabelInput("height");
		window.add(heightInput);
		scaleXInput=new LabelInput("scaleX");
		window.add(scaleXInput);
		scaleYInput=new LabelInput("scaleY");
		window.add(scaleYInput);

		isTrim=new Checkbox("trim");
		isTrim.setToggle(true);
		window.add(isTrim);
		isPow2=new Checkbox("pow2");
		window.add(isPow2);
		isPack=new Checkbox("pack");
		window.add(isPack);

		outputInput=new LabelInput("output");
		outputInput.setValue(ImageToolConfig.DEF_OUTPUT);
		println("output","(url)","(name)","(extension)");
		window.add(outputInput);

		formatTab=new TabPanel(["jxr","jpg","png","atf","ajpg"]);

		jxrQ=new LabelInput("quantization");
		jxrQ.setValue("20")
		formatTab.getPanel(0).add(jxrQ);

		jpgQ=new LabelInput("quality");
		jpgQ.setValue("80")
		formatTab.getPanel(1).add(jpgQ);

		window.add(formatTab);
		window.add(new Button("saveConfig"),null,.5);
		var layout:BoxLayout=new BoxLayout(window,BoxLayout.Y_AXIS,5);
		window.setLayout(layout);
		window.doLayout();
	}

	private function nativeDragEnterHandler(event:NativeDragEvent):void {
		NativeDragManager.acceptDragDrop(this);
	}

	private function nativeDragDropHandler(event:NativeDragEvent):void {
		println("start from drag");
		var data:Array=event.clipboard.formats;
		for each(var type:String in data){
			doFiles(event.clipboard.getData(type),true,null);
		}
	}

	private function doFiles(files:Object,fromDrag:Boolean,config:ImageToolConfig):void{
		var bat:LoaderBat=new LoaderBat();
		bat.userData=config;
		for each(var file:File in files){
			if(file.isDirectory){
				continue;
			}
			var fs:FileStream=new FileStream();
			fs.open(file,FileMode.READ);
			var bytes:ByteArray=new ByteArray();
			fs.readBytes(bytes);
			fs.close();
			if(file.extension=="itb"){
				if(fromDrag)imageToolBat(bytes,file);
			}else{
				bat.addBytesImageLoader(bytes,null,file);
			}
		}
		bat.addEventListener(Event.COMPLETE, bat_completeHandler);
		bat.start();
	}

	private function imageToolBat(bytes:ByteArray,file:File):void{
		var str:String=bytes+"";
		var configObj:Object={};
		var conStrs:Array=str.split("\r\n\r\n");
		for each(var conStr:String in conStrs){
			var lines:Array=conStr.split("\r\n");
			for each(var line:String in lines){
				var data:Array=line.split(":");
				configObj[data[0]]=data[1];
			}
			var config:ImageToolConfig=new ImageToolConfig();
			config.width=int(configObj.width);
			config.height=int(configObj.height);
			config.scaleX=Number(configObj.scaleX);
			config.scaleY=Number(configObj.scaleY);
			config.trim=int(configObj.trim)>0;
			config.pow2=int(configObj.pow2)>0;
			config.pack=int(configObj.pack)>0;
			config.output=configObj.output;
			if(int(configObj.jxr)>0){
				var jxrOption:JPEGXREncoderOptions=new JPEGXREncoderOptions();
				jxrOption.quantization=Number(configObj.quantization);
				config.option.option=jxrOption;
				config.option.extension="wdp";
				config.option.id=0;
			}else if(int(configObj.jpg)>0){
				var jpgOption:JPEGEncoderOptions=new JPEGEncoderOptions();
				jpgOption.quality=Number(configObj.quality);
				config.option.option=jpgOption;
				config.option.extension="jpg";
				config.option.id=1;
			}else if(int(configObj.png)>0){
				var pngOption:PNGEncoderOptions=new PNGEncoderOptions();
				config.option.option=pngOption;
				config.option.extension="png";
				config.option.id=2;
			}else if(int(configObj.atf)>0){
				config.option.option=new EncodingOptions();
				config.option.extension="atf";
				config.option.id=3;
			}else if(int(configObj.ajpg)>0){
				config.option.option=new JPEGEncoderOptions();
				config.option.extension="jpg";
				config.option.id=4;
			}
			println("start from bat file");
			doFiles(file.parent.getDirectoryListing(),false,config);
		}

	}

	private function getOption():ImageOption{
		var option:ImageOption=new ImageOption();
		if(formatTab.getPanel(0).stage){//jxr
			var jxrOption:JPEGXREncoderOptions=new JPEGXREncoderOptions();
			jxrOption.quantization=Number(jxrQ.getValue());
			//jxrOption.colorSpace;
			//jxrOption.trimFlexBits
			option.id=0;
			option.option=jxrOption;
			option.extension="wdp";
		}else if(formatTab.getPanel(1).stage){//jpg
			var jpgOption:JPEGEncoderOptions=new JPEGEncoderOptions();
			jpgOption.quality=Number(jpgQ.getValue());
			option.option=jpgOption;
			option.id=1;
			option.extension="jpg";
		}else if(formatTab.getPanel(2).stage){//png
			var pngOption:PNGEncoderOptions=new PNGEncoderOptions();
			option.option=pngOption;
			option.id=2;
			option.extension="png";
		}else if(formatTab.getPanel(3).stage){//atf
			option.option=new EncodingOptions();
			option.id=3;
			option.extension="atf";
		}else{//ajpg
			var ajpgOption:JPEGEncoderOptions=new JPEGEncoderOptions();
			option.option=ajpgOption;
			option.extension="jpg";
			option.id=4;
		}
		return option;
	}

	private function bat_completeHandler(event:Event):void {
		var bat:LoaderBat= event.currentTarget as LoaderBat;
		var config:ImageToolConfig=(bat.userData as ImageToolConfig);
		if(config==null){
			config=new ImageToolConfig();
			config.width=int(widthInput.getValue());
			config.height=int(heightInput.getValue());
			config.scaleX=Number(scaleXInput.getValue());
			config.scaleY=Number(scaleYInput.getValue());
			config.trim=isTrim.getToggle();
			config.pow2=isPow2.getToggle();
			config.pack=isPack.getToggle();
			config.output=outputInput.getValue();
			config.option=getOption();
		}
		var configImages:Vector.<ConfigImage>;
		var area:int=0;
		var maxHeight:int=0;
		for each(var loader:LoaderCell in bat.loaderComps){
			var bmd:BitmapData=loader.getImage();
			if(bmd){
				var file:File=loader.userData as File;
				if(!config.pack){
					configSave(config,file,bmd);
				}else{
					configImages=configImages||new Vector.<ConfigImage>;
					var ci:ConfigImage=configImage(config,file,bmd);
					configImages.push(ci);
					area+=ci.bmd.width*ci.bmd.height;
					maxHeight=Math.max(maxHeight,bmd.height);
				}
			}
		}
		if(config.pack){
			if(config.width>0&&config.height>0){
				var pw:int=config.width;
				var ph:int=config.height;
			}else{
				pw=4096;
				ph=Math.max(Math.ceil(Math.sqrt(area)),maxHeight);
				if(config.pow2){
					ph=countPow2(ph);
				}
			}
			var rp:RectanglePacker=new RectanglePacker(pw,ph);
			var vss:Object={};
			for(var i:int=0;i< configImages.length;i++){
				ci = configImages[i];
				var vs:Vector.<uint>  =ci.bmd.getVector(ci.bmd.rect);
				var flag:Boolean=false;
				for each(var vs2:Vector.<uint> in vss){
					if(vs2.length==vs.length){
						flag=true;
						for(var j:int= 0,len:int=vs2.length;j<len;j++){
							if(vs2[j]!=vs[j]){
								flag=false;
								break;
							}
						}
						if(flag){
							break;
						}
					}
				}
				if(!flag){
					vss[i]=vs;
					rp.insertRectangle(ci.bmd.width,ci.bmd.height,i);
				}
			}
			rp.packRectangles();
			bmd=new BitmapData(pw,ph,true,0);
			bmd.lock();
			var rect:Rectangle = new Rectangle();
			for (i = 0; i < rp.rectangleCount; i++)
			{
				rp.getRectangle(i, rect);
				var index:int = rp.getRectangleId(i);
				ci=configImages[index];
				vs=vss[index];
				bmd.setVector(rect,vs);
			}
			if(config.width>0&&config.height>0){

			}else{
				bmd=trim(bmd,config.pow2).bmd;
			}
			bmd.unlock();
			save(encode(bmd,config),file.parent.url+"/sheet."+config.option.extension);
		}
		println("over");
		println();
	}

	private function configImage(config:ImageToolConfig,file:File,bmd:BitmapData):ConfigImage{
		var size:Point=new Point(bmd.width,bmd.height);
		if(config.width!=0&&!config.pack)size.x=config.width;
		if(config.height!=0&&!config.pack)size.y=config.height;
		if(config.scaleX!=0)size.x=Math.ceil(bmd.width*config.scaleX);
		if(config.scaleY!=0)size.y=Math.ceil(bmd.height*config.scaleY);
		bmd=resize(bmd,size);

		if(config.trim){
			var bwt:BitmapDataWithTrimInfo=trim(bmd);
			bmd=bwt.bmd;
		}
		if(config.pow2&&!config.pack){
			bmd=pow2(bmd);
		}
		var configImage:ConfigImage=new ConfigImage();
		configImage.config=config;
		configImage.bmd=bmd;
		configImage.file=file;
		return configImage;
	}

	private function configSave(config:ImageToolConfig,file:File,bmd:BitmapData):void{
		bmd=configImage(config,file,bmd).bmd;
		var extension:String= file.extension;
		var name:String = file.name.substr(0,file.name.length-extension.length-1);
		var bytes:ByteArray=encode(bmd,config);
		var url:String=config.output;
		url=url.replace(/\(url\)/g,file.parent.url);
		url=url.replace(/\(name\)/g,name);
		url=url.replace(/\(extension\)/g,config.option.extension);
		save(bytes,url);
		println("convert",file.name,url);
	}

	private function encode(bmd:BitmapData,config:ImageToolConfig):ByteArray{
		if(config.option.id==3){
			var bytes:ByteArray=Encoder.encode(bmd,EncodingOptions(config.option.option),null);
		}else if(config.option.id==4){
			var bmd2:BitmapData=new BitmapData(bmd.width*2,bmd.height,false,0);
			var rect:Rectangle=bmd.rect;
			bmd2.copyChannel(bmd,rect,new Point(),BitmapDataChannel.RED,BitmapDataChannel.RED);
			bmd2.copyChannel(bmd,rect,new Point(),BitmapDataChannel.GREEN,BitmapDataChannel.GREEN);
			bmd2.copyChannel(bmd,rect,new Point(),BitmapDataChannel.BLUE,BitmapDataChannel.BLUE);
			bmd2.copyChannel(bmd,rect,new Point(bmd.width),BitmapDataChannel.ALPHA,BitmapDataChannel.BLUE);
			bytes=bmd2.encode(bmd2.rect,config.option.option);
		}else{
			bytes=bmd.encode(bmd.rect,config.option.option);
		}
		return bytes;
	}

	private function resize(bmd:BitmapData,size:Point):BitmapData{
		var bmd2:BitmapData=new BitmapData(size.x,size.y,bmd.transparent,0);
		bmd2.draw(bmd, new Matrix(bmd2.width / bmd.width, 0, 0, bmd2.height / bmd.height), null, null, null, true);
		return bmd2;
	}

	private function trim(bmd:BitmapData,pow2:Boolean=false):BitmapDataWithTrimInfo{
		var bwt:BitmapDataWithTrimInfo=new BitmapDataWithTrimInfo();
		bwt.rect = bmd.getColorBoundsRect(0xff000000, 0, false);
		if(pow2){
			bwt.rect.width=countPow2(bwt.rect.width);
			bwt.rect.height=countPow2(bwt.rect.height);
		}
		if(bwt.rect.width!=bmd.width||bwt.rect.height!=bmd.height){
			bwt.bmd = new BitmapData(bwt.rect.width, bwt.rect.height, bmd.transparent, 0);
			bwt.bmd.draw(bmd, new Matrix(1, 0, 0, 1, -bwt.rect.x, -bwt.rect.y),null,null,null,true);
		}else{
			bwt.bmd=bmd;
		}

		return bwt;
	}

	private function pow2(bmd:BitmapData):BitmapData{
		return resize(bmd,new Point(countPow2(bmd.width),countPow2(bmd.height)));
	}

	private function countPow2(x:int):int{
		var r:int=1;
		while(r<x){
			r*=2;
		}
		return r;
	}

	private function save(bytes:ByteArray,url:String):void{
		var file:File=new File(url);
		var fs:FileStream=new FileStream();
		fs.open(file,FileMode.WRITE);
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
