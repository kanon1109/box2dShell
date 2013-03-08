package cn.geckos.box2dShell.plugs 
{
import Box2D.Dynamics.b2Body;
import cn.geckos.box2dShell.data.PolyData;
import cn.geckos.box2dShell.engine.B2dShell;
import cn.geckos.utils.TraceUtil;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.geom.Point;
/**
 * ...绘制多边形插件
 * @author 
 */
public class DrawPolygon 
{
	//绘制容器
	private var drawContainer:Sprite;
	//接受鼠标事件的容器
	private var parent:DisplayObjectContainer;
	//路径列表
	private var pathList:Vector.<Point>;
	//外部容器对象
	private var _b2dShell:B2dShell;
	//上一个点的位置
	private var prevPoint:Point;
	//起始位置
	private var curPoint:Point;
	//起始坐标
	private var startPoint:Point;
	//是否按下鼠标
	private var isDown:Boolean;
	//最小绘制距离
	private var _minDrawDistance:int;
	//线条颜色
	private var _lineColor:Number;
	//线条粗细
	private var _thickness:Number;
	//线条合并时最小的距离
	private var combineMinDistance:int;
	public function DrawPolygon(parent:DisplayObjectContainer, 
								drawContainer:Sprite) 
	{
		this.parent = parent;
		this.drawContainer = drawContainer;
		this.combineMinDistance = 5;
		this.minDrawDistance = 40;
		this.lineColor = 0xFF0000;
		this.thickness = 2;
		this.pathList = new Vector.<Point>();
		this.prevPoint = new Point();
		this.curPoint = new Point();
		this.initEvent();
	}
	
	/**
	 * 初始化事件
	 */
	private function initEvent():void 
	{
		this.parent.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		this.parent.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
	}
	
	private function mouseUpHandler(event:MouseEvent):void 
	{
		this.isDown = false;
		this.parent.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		var o:Object = this.b2dShell.validatePolygon(this.pathList);
		if (o.success == 1)
		{
			var arr:Array = [];
			var length:int = this.pathList.length;
			for (var i:int = 0; i < length; i += 1)
			{
				var pos:Point = this.pathList[i];
				arr.push([pos.x, pos.y]);
			}
			var bodyData:PolyData = new PolyData();
			bodyData.density = .1;
			bodyData.restitution = .1;
			bodyData.friction = .2;
			bodyData.vertices = arr;
			bodyData.width = o.width;
			bodyData.height = o.height;
			bodyData.postion = new Point(bodyData.width * .5 + o.minX, bodyData.height * .5 + o.minY);
			bodyData.boxPoint = new Point(bodyData.width * .5, bodyData.height * .5);
			bodyData.bodyType = b2Body.b2_dynamicBody;
			this.b2dShell.createPoly(bodyData);
		}
		this.clear();
	}
	
	private function mouseMoveHandler(event:MouseEvent):void 
	{
		if (this.isDown)
		{
			this.curPoint.x = this.parent.mouseX;
			this.curPoint.y = this.parent.mouseY;
			if (this.checkDrawDis(this.prevPoint, this.curPoint, this.minDrawDistance))
			{
				//需要this.curPoint的clone对象。
				this.pathList.push(this.curPoint.clone());
				this.prevPoint.x = this.parent.mouseX;
				this.prevPoint.y = this.parent.mouseY;
				this.drawContainer.graphics.lineTo(this.curPoint.x, this.curPoint.y);
			}
			//如果鼠标移动到了 线条的起始位置时，则自动合并这个图形。
			if (this.pathList.length >= 2)
			{
				if (Point.distance(this.curPoint, this.startPoint) <= this.combineMinDistance)
				{
					this.parent.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
					this.drawContainer.graphics.lineTo(this.startPoint.x, this.startPoint.y);
				}
			}
		}
	}
	
	private function mouseDownHandler(event:MouseEvent):void 
	{
		this.parent.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		this.isDown = true;
		this.drawContainer.graphics.clear();
		this.prevPoint.x = this.parent.mouseX;
		this.prevPoint.y = this.parent.mouseY;
		this.startPoint = this.prevPoint.clone();
		this.pathList.push(this.prevPoint);
		this.drawContainer.graphics.lineStyle(this.thickness, this.lineColor);
		this.drawContainer.graphics.moveTo(this.prevPoint.x, this.prevPoint.y);
	}
	
	/**
	 * 判断画线时点的距离
	 * @param	curPoint  当前点
	 * @param	prevPoint 上一个点
	 * @param	dis       允许绘制的距离
	 * @return  是否应该绘制
	 */
	private function checkDrawDis(curPoint:Point, prevPoint:Point, dis:Number):Boolean
	{
		if (Point.distance(curPoint, prevPoint) >= dis)
			return true;
		return false;
	}
	
	/**
	 * 销毁路径列表
	 */
	private function removePathList(vector:Vector.<Point>):void
	{
		if (!vector) return;
		var length:int = vector.length;
		for (var i:int = length - 1; i >= 0 ; i -= 1) 
		{
			vector.splice(i, 1);
		}
	}
	
	/**
	 * 清除
	 */
	public function clear():void
	{
		this.drawContainer.graphics.clear();
		this.removePathList(this.pathList);
	}
	
	/**
	 * 销毁
	 */
	public function destory():void
	{
		if (this.parent)
		{
			this.parent.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.parent.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			this.parent.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.parent = null;
		}
		this.startPoint = null;
		this.curPoint = null;
		this.prevPoint = null;
		this.clear();
		this.drawContainer = null;
		this.pathList = null;
	}
	
	/**
	 * 外部容器对象
	 */
	public function get b2dShell():B2dShell { return _b2dShell; }
	public function set b2dShell(value:B2dShell):void 
	{
		_b2dShell = value;
	}
	
	/**
	 * 最小绘制距离
	 */
	public function get minDrawDistance():int { return _minDrawDistance; }
	public function set minDrawDistance(value:int):void 
	{
		_minDrawDistance = value;
	}
	
	/**
	 * 线条颜色
	 */
	public function get lineColor():Number { return _lineColor; }
	public function set lineColor(value:Number):void 
	{
		_lineColor = value;
	}
	
	/**
	 * 线条粗细
	 */
	public function get thickness():Number { return _thickness; }
	public function set thickness(value:Number):void 
	{
		_thickness = value;
	}
	
}
}