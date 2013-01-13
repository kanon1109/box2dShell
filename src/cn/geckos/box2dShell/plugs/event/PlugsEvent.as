package cn.geckos.box2dShell.plugs.event 
{
import flash.events.Event;
/**
 * ...插件事件
 * @author 
 */
public class PlugsEvent extends Event 
{
	public static const DRAW_COMPLETE:String = "drawComplete";
	public function PlugsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
	{ 
		super(type, bubbles, cancelable);
	} 
	
	public override function clone():Event 
	{ 
		return new PlugsEvent(type, bubbles, cancelable);
	} 
	
	public override function toString():String 
	{ 
		return formatToString("PlugsEvent", "type", "bubbles", "cancelable", "eventPhase"); 
	}
	
}
}