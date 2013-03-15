package cn.geckos.box2dShell.plugs.event 
{
import flash.events.Event;
/**
 * ...插件事件
 * @author 
 */
public class PlugsEvent extends Event 
{
	//绘制线条结束
	public static const DRAW_COMPLETE:String = "drawComplete";
	//切割结束
	public static const SLICE_COMPLETE:String = "sliceComplete";
	//需要穿的数据
	public var data:*;
	public function PlugsEvent(type:String, data:*= null, bubbles:Boolean = false, cancelable:Boolean = false)
	{ 
		this.data = data;
		super(type, bubbles, cancelable);
	} 
	
	public override function clone():Event 
	{ 
		return new PlugsEvent(type, data, bubbles, cancelable);
	} 
	
	public override function toString():String 
	{ 
		return formatToString("PlugsEvent", "type", "data", "bubbles", "cancelable", "eventPhase"); 
	}
	
}
}