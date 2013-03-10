package cn.geckos.box2dShell.data 
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
/**
 * ...刚体的数据
 * @author Kanon
 */
public class BodyData 
{
	//摩擦力这用来计算两个对象之间的摩擦，你可以在0.0-1.0之间调整它们。
	protected var _friction:Number = 0.2;
	//密度,在碰撞的等式中我们使用密度*面积=质量，密度如果是0或者null,将会是一个静止的对象
	protected var _density:Number = 0.0;
	//弹性
	protected var _restitution:Number = 0.0;
	//刚体的坐标位置
	protected var _postion:Point;
	//显示对象
	protected var _displayObject:DisplayObject;
	//注册点
	protected var _boxPoint:Point;
	//刚体类型 刚体类型 0:静态刚体 1:运动刚体 2:动态刚体 
	protected var _bodyType:uint;
	//角度
	protected var _rotation:Number;
	//刚体标签 定位刚体
	protected var _bodyLabel:String
	//是否为子弹 防止逃脱出物理引擎世界
	protected var _bullet:Boolean;
	//参数
	protected var _params:Object;
	//是否环绕 用于刚体出屏幕后会从屏幕另一端回来
	protected var _isWrapAround:Boolean;
	//需要环绕的方向 0左右，1上下，2整个
	protected var _wrapAroundDirection:int;
	public function BodyData() 
	{
		
	}
	
	/**
	 * 摩擦力
	 */
	public function get friction():Number {	return _friction; }
	public function set friction(value:Number):void 
	{
		_friction = value;
	}
	
	/**
	 * 密度
	 */
	public function get density():Number { return _density; }
	public function set density(value:Number):void 
	{
		_density = value;
	}
	
	/**
	 * 弹性
	 */
	public function get restitution():Number { return _restitution; }
	public function set restitution(value:Number):void 
	{
		_restitution = value;
	}
	
	/**
	 * 刚体的坐标位置 
	 */
	public function get postion():Point { return _postion; }
	public function set postion(value:Point):void 
	{
		_postion = value;
	}
	
	/**
	 * 显示对象
	 */
	public function get displayObject():DisplayObject { return _displayObject; }
	public function set displayObject(value:DisplayObject):void 
	{
		_displayObject = value;
	}
	
	/**
	 * 注册点
	 */
	public function get boxPoint():Point { return _boxPoint; }
	public function set boxPoint(value:Point):void 
	{
		_boxPoint = value;
	}
	
	/**
	 * 刚体类型 0:静态刚体 1:运动刚体 2:动态刚体 
	 * 运动刚体　是一种混合刚体　没有碰撞的受力，但是能够提供线型速度。
 	 */
	public function get bodyType():uint { return _bodyType; }
	public function set bodyType(value:uint):void 
	{
		_bodyType = value;
	}
	
	/**
	 * 角度
	 */
	public function get rotation():Number {	return _rotation; };
	public function set rotation(value:Number):void 
	{
		_rotation = value;
	}
	
	/**
	 * 刚体标签
	 */
	public function get bodyLabel():String { return _bodyLabel; };
	public function set bodyLabel(value:String):void 
	{
		_bodyLabel = value;
	}
	
	/**
	 * 是否为子弹 物理引擎世界
	 */
	public function get bullet():Boolean{ return _bullet; }
	public function set bullet(value:Boolean):void 
	{
		_bullet = value;
	}
	
	/**
	 * 参数
	 */
	public function get params():Object{ return _params; }
	public function set params(value:Object):void 
	{
		_params = value;
	}
	
	/**
	 * 是否环绕 用于刚体出屏幕后会从屏幕另一端回来
	 */
	public function get isWrapAround():Boolean{ return _isWrapAround; }
	public function set isWrapAround(value:Boolean):void 
	{
		_isWrapAround = value;
	}
	
	/**
	 * 需要环绕的方向 0左右，1上下，2整个
	 */
	public function get wrapAroundDirection():int{ return _wrapAroundDirection; }
	public function set wrapAroundDirection(value:int):void 
	{
		_wrapAroundDirection = value;
	}

}
}