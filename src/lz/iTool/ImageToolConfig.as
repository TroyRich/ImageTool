/**
 * Created with IntelliJ IDEA.
 * User: lizhi http://matrix3d.github.io/
 * Date: 13-6-18
 * Time: 下午9:29
 * To change this template use File | Settings | File Templates.
 */
package lz.iTool {
import flash.filesystem.File;

public class ImageToolConfig {
	public var input:String;
	public var width:int=0;
	public  var height:int=0;
	public  var scaleX:Number=0;
	public var scaleY:Number=0;
	public var trim:Boolean=false;
	public var relative:Boolean=false;
	public var pow2:Boolean=false;
	public var pack:Boolean=false;
	public var output:String=DEF_OUTPUT;
	public static var DEF_OUTPUT:String="(url)/(name).(extension)";
	public static var DEF_PACK_TEMPLATE:String=
			"(fname).xml\n"+
			"<TextureAtlas>\n" +
			"<SubTexture name='(name)' fx='(fx)' fy='(fy)' x='(x)' y='(y)' width='(width)' height='(height)'/>\n"+
			"</TextureAtlas>";
	public var packTemplate:String;
	public var formatIndex:int=0;
	public var jxrQuantization:int=20;
	public var jpgQuality:int=80;
	public var option:ImageOption=new ImageOption();

	public function ImageToolConfig() {
	}

	public function getOutPutUrl(file:File,nativePath:Boolean=false):String{
		var extension:String= file.extension;
		var name:String = file.name.substr(0,file.name.length-extension.length-1);
		var url:String=output;
		url=url.replace(/\(url\)/g,nativePath?file.parent.nativePath:file.parent.url);
		url=url.replace(/\(name\)/g,name);
		url=url.replace(/\(extension\)/g,option.extension);
		return url;
	}
}
}
