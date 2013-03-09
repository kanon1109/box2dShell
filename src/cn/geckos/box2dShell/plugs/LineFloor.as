package cn.geckos.box2dShell.plugs 
{
import Box2D.Dynamics.b2Body;
import cn.geckos.box2dShell.data.PolyData;
import cn.geckos.box2dShell.engine.B2dShell;
import cn.geckos.box2dShell.plugs.event.PlugsEvent;
import cn.geckos.geom.Vector2D;
import cn.geckos.utils.ArrayUtil;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
/**
 * ...线条绘制的物理地面
 * @author 
 */
public class LineFloor extends EventDispatcher
{
	//外部容器对象
	private var stage:DisplayObjectContainer;
	//鼠标是否点击
	private var isMouseDown:Boolean;
	//绘制线条时上一次的坐标
	private var prevPosX:Number;
	private var prevPosY:Number;
	//线条直接的距离
	private var drawLineDis:int = 20;
	//存放坐标点
	private var pointsList:Array;
	//一种线条转换成物理地板的快捷模式，设置为true 就能看到。
	private var _lineFloorMode:Boolean;
	//绘制线条用的容器
	private var _drawSprite:Sprite;
	//box2d
	private var _b2dShell:B2dShell;
	public function LineFloor(stage:DisplayObjectContainer) 
	{
		this.initStage(stage);
	}
	
	/**
	 * 初始化stage
	 * @param	stage  舞台
	 */
	private function initStage(stage:DisplayObjectContainer):void
	{
		this.stage = stage;
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);	
		this.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);	
	}
	
	private function stageMouseDown(event:MouseEvent):void 
	{
		this.isMouseDown = true;
		if (this.lineFloorMode && this.drawSprite)
		{
			this.pointsList = [];
			this.drawSprite.graphics.lineStyle(3);
			this.drawSprite.graphics.moveTo(this.stage.mouseX, this.stage.mouseY);
			this.prevPosX = this.stage.mouseX;
			this.prevPosY = this.stage.mouseY;
			this.pointsList.push(this.prevPosX, this.prevPosY);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
		}
	}
	
	private function stageMouseMoveHandler(event:MouseEvent):void 
	{
		this.mouseDrawLine();
	}
	
	private function stageMouseUp(event:MouseEvent):void 
	{
		this.isMouseDown = false;
		if (this.lineFloorMode && this.drawSprite)
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			//创建点绘制的路径地板
			this.createPathFloor(this.pointsList);
			this.drawSprite.graphics.clear();
			ArrayUtil.clearList(this.pointsList);
			this.pointsList = null;
			this.dispatchEvent(new PlugsEvent(PlugsEvent.DRAW_COMPLETE));
		}
	}
	
	/**
	 * 鼠标绘制线
	 */
	private function mouseDrawLine():void
	{
		if (this.isMouseDown && 
			this.lineFloorMode && 
			this.drawSprite)
		{
			var v2d:Vector2D = new Vector2D(this.stage.mouseX, this.stage.mouseY);
			if (v2d.dist(new Vector2D(this.prevPosX, this.prevPosY)) >= this.drawLineDis)
			{
				this.drawSprite.graphics.lineTo(this.stage.mouseX, this.stage.mouseY);
				this.prevPosX = this.stage.mouseX;
				this.prevPosY = this.stage.mouseY;
				this.pointsList.push(this.prevPosX, this.prevPosY);
			}
		}
	}
	
	/**
	 * 创建点绘制的路径地板
	 * @param	pathList 路径列表
	 */
	private function createPathFloor(pathList:Array):void
	{
		var length:int = pathList.length / 2 - 1;
		for (var i:int = 0; i < length; i += 1) 
		{
			//参考www.emanueleferonato.com/2013/01/10/way-of-an-idea-prototype-updated-to-box2d-2-1a-and-nape/
			//先线段的 0，1，2，3分成一个规律的组合，0，1分别为上一次鼠标坐标，2，3为当前鼠标坐标。
			var sx:int = pathList[i * 2];
			var sy:int = pathList[i * 2 + 1];
			var ex:int = pathList[i * 2 + 2];
			var ey:int = pathList[i * 2 + 3];
			var v2d:Vector2D = new Vector2D(sx, sy);
			var dist:Number = v2d.dist(new Vector2D(ex, ey));
			var angle:Number = v2d.angleBetween(new Vector2D(ex, ey), false);
			this.createFloorPolygonBody((sx + ex) * .5, (sy + ey) * .5, dist, 4, angle);
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
	private function createFloorPolygonBody(pX:Number, pY:Number, width:Number, height:Number, angle:Number):b2Body
	{
		var polyData:PolyData = new PolyData();
		polyData.container = stage;
		polyData.friction = 0.5;
		polyData.density = 1;
		polyData.restitution = 0.5;
		polyData.bodyLabel = "floor";
		polyData.boxPoint = new Point(width * .5, height * .5);
		polyData.width = width;
		polyData.height = height;
		polyData.postion = new Point(pX, pY);
		polyData.bodyType = b2Body.b2_staticBody;
		var body:b2Body = this.b2dShell.createPoly(polyData);
		body.SetAngle(angle);
		return body;
	}
	
	/**
	 * 一种线条转换成物理地板的快捷模式，设置为true 就能看到
	 */
	public function get lineFloorMode():Boolean { return _lineFloorMode; }
	public function set lineFloorMode(value:Boolean):void 
	{
		_lineFloorMode = value;
	}
	
	/**
	 * 绘制线条用的容器
	 */
	public function get drawSprite():Sprite { return _drawSprite; }
	public function set drawSprite(value:Sprite):void 
	{
		_drawSprite = value;
	}
	
	/**
	 * box2d 包装器
	 */
	public function get b2dShell():B2dShell { return _b2dShell; };
	public function set b2dShell(value:B2dShell):void 
	{
		_b2dShell = value;
	}
	
	/**
	 * 销毁
	 */
	public function destroy():void
	{
		ArrayUtil.clearList(this.pointsList);
		this.pointsList = null;
		if (this.stage)
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);	
			this.stage = null;
		}
		if (this.drawSprite)
			this.drawSprite.graphics.clear();
		this.drawSprite = null;
	}
}
}