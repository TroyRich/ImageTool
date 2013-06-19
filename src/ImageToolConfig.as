/**
 * Created with IntelliJ IDEA.
 * User: Administrator
 * Date: 13-6-18
 * Time: 下午9:29
 * To change this template use File | Settings | File Templates.
 */
package {
public class ImageToolConfig {
	public var input:String;
	public var width:int=0;
	public  var height:int=0;
	public  var scaleX:Number=0;
	public var scaleY:Number=0;
	public var trim:Boolean=false;
	public var pow2:Boolean=false;
	public var output:String=DEF_OUTPUT;
	public static var DEF_OUTPUT:String="(url)/(name).(extension)";
	public var formatIndex:int=0;
	public var jxrQuantization:int=20;
	public var quality:int=80;
	public var option:ImageOption=new ImageOption();

	public function ImageToolConfig() {
	}
}
}
