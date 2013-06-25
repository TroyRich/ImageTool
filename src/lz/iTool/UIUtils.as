/**
 * Created with IntelliJ IDEA.
 * User: lizhi http://matrix3d.github.io/
 */
package lz.iTool {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.text.TextField;

import sliz.miniui.Input;

import sliz.miniui.Label;
import sliz.miniui.LabelInput;

import sliz.miniui.Panel;
import sliz.miniui.TabBar;
import sliz.miniui.TabPanel;
import sliz.miniui.layouts.BoxLayout;

public class UIUtils {
	public static function getTabPanelIndex(panel:TabPanel):int{
		var i:int=-1;
		var child:Panel;
		while((child = panel.getPanel(++i))!=null){
			if(child.parent)break;
		}
		return i;
	}

	public static function selectPanelIndex(panel:TabPanel,index:int):void{
		var tabbar:TabBar;
		for(var i:int=0;i<panel.numChildren;i++){
			var child:DisplayObject = panel.getChildAt(i);
			if(child is TabBar){
				tabbar=child as TabBar;
			}
		}
		if(tabbar){
			tabbar.select(index);
		}
	}

	public static function dolayoutPanel(panel:Panel):void{
		panel.setLayout(new BoxLayout(panel,BoxLayout.Y_AXIS,5));
		panel.doLayout();
	}

	public static function setLabelInput(lb:LabelInput,width:Number,height:Number,multiline:Boolean,wordWrap:Boolean):void{
		var input:Input=UIUtils.getSome(lb,Input) as Input;
		var tf:TextField=UIUtils.getSome(input,TextField) as TextField;
		tf.height=height;
		tf.width=width;
		tf.multiline=multiline;
		tf.wordWrap=wordWrap;
	}

	public static function getSome(dis:DisplayObjectContainer,c:Class,index:int=0):Object{
		var count:int=0;
		for(var i:int=0;i<dis.numChildren;i++){
			var child:DisplayObject=dis.getChildAt(i);
			if(child is c){
				if((count++)==index){
					return child;
				}
			}
		}
		return null;
	}
}
}
