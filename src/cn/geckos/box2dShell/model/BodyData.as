package cn.geckos.box2dShell.model 
{
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;
/**
 * ...刚体的数据模型
 * @author Kanon
 */
public class BodyData 
{
	//摩擦力这用来计算两个对象之间的摩擦，你可以在0.0-1.0之间调整它们。
	public var friction:Number = 0.2;
	//密度,在碰撞的等式中我们使用密度*面积=质量，密度如果是0或者null,将会是一个静止的对象
	public var density:Number = 0.0;
	//弹性
	public var restitution:Number = 0.0;
	//刚体的坐标位置
	public var postion:Point;
	//显示对象
	public var displayObject:DisplayObject;
	//注册点
	public var boxPoint:Point;
	//刚体类型 刚体类型 0:静态刚体 1:运动刚体 2:动态刚体 
	public var bodyType:uint;
	//角度
	public var rotation:Number;
	//弧度
	public var radian:Number;
	//刚体标签 定位刚体
	public var bodyLabel:String
	//是否为子弹 防止逃脱出物理引擎世界
	public var bullet:Boolean;
	//参数
	public var params:Object;
	//是否环绕 用于刚体出屏幕后会从屏幕另一端回来
	public var isWrapAround:Boolean;
	//需要环绕的方向 0左右，1上下，2整个
	public var wrapAroundDirection:int;
	//纹理
	public var texture:BitmapData;
}
}