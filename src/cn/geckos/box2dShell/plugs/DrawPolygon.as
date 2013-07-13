package cn.geckos.box2dShell.plugs 
{
import Box2D.Dynamics.b2Body;
import cn.geckos.box2dShell.core.B2dShell;
import cn.geckos.box2dShell.model.PolyData;
import cn.geckos.box2dShell.utils.ArrayUtil;
import cn.geckos.box2dShell.utils.B2dUtil;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
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
	private var pathList:Array;
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
		this.pathList = [];
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
		if (this.pathList.length >= 3)
		{
			var o:Object = this.b2dShell.validatePolygon(this.pathList);
			//如果验证成功则创建刚体
			if (o.success == 1)
			{
				var bodyData:PolyData = new PolyData();
				bodyData.density = .1;
				bodyData.friction = .1;
				bodyData.restitution = .1;
				bodyData.vertices = this.pathList;
				bodyData.width = o.width;
				bodyData.height = o.height;
				bodyData.postion = new Point(0, 0);
				bodyData.boxPoint = new Point(bodyData.width * .5, bodyData.height * .5);
				bodyData.bodyType = b2Body.b2_dynamicBody;
				this.b2dShell.createPoly(bodyData);
			}
		}
		else
		{
			this.createPathLine(this.pathList);
		}
		this.clear();
	}
	
	/**
	 * 创建点绘制的路径
	 * @param	pathList 路径列表
	 */
	private function createPathLine(pathList:Array):void
	{
		var length:int = pathList.length - 1;
		var sx:int;
		var sy:int;
		var ex:int;
		var ey:int;
		var p1:Point;
		var p2:Point;
		var dist:Number;
		var angle:Number;
		for (var i:int = 0; i < length; i += 1) 
		{
			//参考www.emanueleferonato.com/2013/01/10/way-of-an-idea-prototype-updated-to-box2d-2-1a-and-nape/
			//先线段的 0，1，2，3分成一个规律的组合，0，1分别为上一次鼠标坐标，2，3为当前鼠标坐标。
			sx = pathList[i][0];
			sy = pathList[i][1];
			ex = pathList[i + 1][0]
			ey = pathList[i + 1][1];
			p1 = new Point(sx, sy);
			p2 = new Point(ex, ey);
			dist = Point.distance(p1, p2);
			angle = B2dUtil.angleBetween(p1, p2, false);
			this.createLinePolygonBody((sx + ex) * .5, (sy + ey) * .5, dist, 4, angle);
		}
	}
	
	/**
	 * 创建路径地板的多边形刚体
	 * @param	pX    x位置
	 * @param	pY    y位置
	 * @param	w     宽度
	 * @param	h     高度
	 * @param	angle 角度
	 */
	private function createLinePolygonBody(pX:Number, pY:Number, width:Number, height:Number, angle:Number):b2Body
	{
		var polyData:PolyData = new PolyData();
		polyData.friction = .1;
		polyData.density = .1;
		polyData.restitution = .1;
		polyData.bodyLabel = "floor";
		polyData.boxPoint = new Point(width * .5, height * .5);
		polyData.width = width;
		polyData.height = height;
		polyData.postion = new Point(pX, pY);
		polyData.bodyType = b2Body.b2_dynamicBody;
		var body:b2Body = this.b2dShell.createPoly(polyData);
		body.SetAngle(angle);
		return body;
	}
	
	private function mouseMoveHandler(event:MouseEvent):void 
	{
		if (this.isDown)
		{
			this.curPoint.x = this.parent.mouseX;
			this.curPoint.y = this.parent.mouseY;
			this.drawContainer.graphics.lineTo(this.curPoint.x, this.curPoint.y);
			if (this.checkDrawDis(this.prevPoint, this.curPoint, this.minDrawDistance))
			{
				this.pathList.push([this.curPoint.x, this.curPoint.y]);
				this.prevPoint.x = this.parent.mouseX;
				this.prevPoint.y = this.parent.mouseY;
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
		//不能直接保存prevPoint 因为prevPoint会根据鼠标的距离改变。
		this.pathList.push([this.prevPoint.x, this.prevPoint.y]);
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
	 * 清除
	 */
	public function clear():void
	{
		this.drawContainer.graphics.clear();
		ArrayUtil.clearList(this.pathList);
	}
	
	/**
	 * 销毁
	 */
	public function destroy():void
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