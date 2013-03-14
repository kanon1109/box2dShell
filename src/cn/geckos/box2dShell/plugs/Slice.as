package cn.geckos.box2dShell.plugs
{
import Box2D.Collision.Shapes.b2PolygonShape;
import Box2D.Common.Math.b2Vec2;
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.b2Fixture;
import cn.geckos.box2dShell.data.PolyData;
import cn.geckos.box2dShell.engine.B2dShell;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.Dictionary;

/**
 * ...切片插件 将刚体切片
 * @author Kanon
 */
public class Slice
{
	private var b2dShell:B2dShell;
	private var stage:Stage;
	//绘制用的容器
	private var _canvasContainer:DisplayObjectContainer;
	//切入切出点
	private var sliceInPoint:b2Vec2;
	private var sliceOutPoint:b2Vec2;
	//是否在绘制线段
	private var isDrawing:Boolean;
	//切割线条的画布
	private var canvas:Sprite;
	//是否使用鼠标绘制切割线条
	private var _mouseDraw:Boolean;
	//受激光影响的刚体列表
	private var affectedByLaser:Vector.<b2Body>
	//激光的进入点
	private var entryPoint:Vector.<b2Vec2>;
	//存放不需要切割的刚体
	private var ignoreDictionary:Dictionary;
	public function Slice(b2dShell:B2dShell, stage:Stage, canvasContainer:DisplayObjectContainer = null)
	{
		this.b2dShell = b2dShell;
		this.stage = stage;
		this.canvasContainer = canvasContainer;
	}
	
	/**
	 * 设置切割点
	 * @param	x       切割点x坐标
	 * @param	y		切割点y坐标
	 * @param	input   是切入还是切出，true为切入。
	 */
	public function setSlicePoint(x:Number, y:Number, input:Boolean = true):void
	{
		if (input)
		{
			if (!this.sliceInPoint)
				this.sliceInPoint = new b2Vec2(x / B2dShell.CONVERSION, y / B2dShell.CONVERSION);
		}
		else
		{
			if (!this.sliceOutPoint)
				this.sliceOutPoint = new b2Vec2(x / B2dShell.CONVERSION, y / B2dShell.CONVERSION);
		}
	}
	
	/**
	 * 初始化画布
	 */
	private function initCanvas():void
	{
		if (this.canvas || !this.canvasContainer)
			return;
		this.canvas = new Sprite();
		this.canvasContainer.addChild(this.canvas);
	}
	
	/**
	 * 初始化stage
	 * @param	stage  舞台
	 */
	private function initStage(stage:Stage):void
	{
		this.stage = stage;
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHander);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHander);
	}
	
	private function mouseDownHander(event:MouseEvent):void
	{
		this.isDrawing = true;
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHander);
		this.setSlicePoint(this.stage.mouseX, this.stage.mouseY);
	}
	
	private function mouseMoveHander(event:MouseEvent):void
	{
		if (this.isDrawing)
		{
			if (this.canvas)
			{
				this.canvas.graphics.clear();
				this.canvas.graphics.lineStyle(1.5, 0xFFF0000);
				this.canvas.graphics.moveTo(sliceInPoint.x * B2dShell.CONVERSION, sliceInPoint.y * B2dShell.CONVERSION);
				this.canvas.graphics.lineTo(this.stage.mouseX, this.stage.mouseY);
			}
		}
	}
	
	private function mouseUpHander(event:MouseEvent):void
	{
		this.isDrawing = false;
		if (this.canvas)
			this.canvas.graphics.clear();
		this.setSlicePoint(this.stage.mouseX, this.stage.mouseY, false);
	}
	
	/**
	 * 更新切割状态
	 */
	public function update():void
	{
		if (this.sliceInPoint && this.sliceOutPoint && 
			this.b2dShell && this.b2dShell.world && !this.isDrawing)
		{
			this.affectedByLaser = new Vector.<b2Body>();
			this.entryPoint = new Vector.<b2Vec2>();
			//2d世界判断激光碰撞
			this.b2dShell.world.RayCast(this.laserFired, this.sliceInPoint, this.sliceOutPoint);
			this.b2dShell.world.RayCast(this.laserFired, this.sliceOutPoint, this.sliceInPoint);
			this.sliceInPoint = null;
			this.sliceOutPoint = null;
		}
	}
	
	/**
	 * 回调函数包含了一个对我们很有用的参数
	 * @param	fixture  被激光切割的对象
	 * @param	point    与激光接触的b2Vect2点(即我们要找的切入点)
	 * @param	normal   交叉点的单位向量
	 * @param	fraction 交互部分的激光长度，如果你需要知道交互激光长度占总产度比例的话，这个值会很有用。
	 * @return  如果你不希望激光继续切割，返回0，那么激光会停止继续检测。返回1，激光会继续切割其他的对象。
	 */
	private function laserFired(fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number):Number
	{
		//受到激光影响的刚体
		var affectedBody:b2Body = fixture.GetBody();
		//如果有不允许切片的在列表内则 返回并继续判断切割
		if (this.ignoreDictionary && this.ignoreDictionary[affectedBody]) return 1;
		//获取刚体图形
		var affectedBodyPolygon:b2PolygonShape = fixture.GetShape() as b2PolygonShape;
		var fixtureIndex:int = this.affectedByLaser.indexOf(affectedBody);
		if (fixtureIndex == -1)
		{
			//如果之前激光没有碰到过 那么将碰到的刚体和切点坐标放进列表中
			this.affectedByLaser.push(affectedBody);
			this.entryPoint.push(point);
		}
		else
		{
			//如果之前激光碰到过
			//射线的切点中间坐标
			var centerPoint:Point = new Point((point.x + this.entryPoint[fixtureIndex].x) * .5, (point.y + this.entryPoint[fixtureIndex].y) * .5);
			//切割线的中心点坐标
			var rayCenterVec:b2Vec2 = new b2Vec2(centerPoint.x, centerPoint.y);
			//判断切线角度
			var rayAngle:Number = Math.atan2(this.entryPoint[fixtureIndex].y - point.y, this.entryPoint[fixtureIndex].x - point.x);
			//获取受激光影响的图形的顶点坐标				
			var polyVertices:Vector.<b2Vec2> = affectedBodyPolygon.GetVertices();
			//并创建2个新的图形顶点坐标
			var newPolyVertices1:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			var newPolyVertices2:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			var currentPoly:int;
			var cutPlaced1:Boolean; // 当前是否放置
			var cutPlaced2:Boolean; // 当前是否放置
			//遍历顶点列表中的点
			var length:int = polyVertices.length;
			for (var i:int = 0; i < length; i += 1)
			{
				//获取相对于世界的顶点坐标
				var worldPoint:b2Vec2 = affectedBody.GetWorldPoint(polyVertices[i]);
				//切线角度 - 顶点到切线中心点的角度 = 分割角度
				var cutAngle:Number = Math.atan2(worldPoint.y - rayCenterVec.y, worldPoint.x - rayCenterVec.x) - rayAngle;
				if (cutAngle < -Math.PI)
					cutAngle += 2 * Math.PI;
				//切割
				if (cutAngle > 0 && cutAngle <= Math.PI)
				{
					if (currentPoly == 2)
					{
						cutPlaced1 = true;
						newPolyVertices1.push(point);
						newPolyVertices1.push(this.entryPoint[fixtureIndex]);
					}
					newPolyVertices1.push(worldPoint);
					currentPoly = 1;
				}
				else
				{
					if (currentPoly == 1)
					{
						cutPlaced2 = true;
						newPolyVertices2.push(this.entryPoint[fixtureIndex]);
						newPolyVertices2.push(point);
					}
					newPolyVertices2.push(worldPoint);
					currentPoly = 2;
				}
			}
			if (!cutPlaced1)
			{
				newPolyVertices1.push(point);
				newPolyVertices1.push(this.entryPoint[fixtureIndex]);
			}
			if (!cutPlaced2)
			{
				newPolyVertices2.push(this.entryPoint[fixtureIndex]);
				newPolyVertices2.push(point);
			}
			this.splitBody(fixture, newPolyVertices1, newPolyVertices1.length);
			this.splitBody(fixture, newPolyVertices2, newPolyVertices2.length);
			this.b2dShell.destroyBody(affectedBody);
		}
		return 1;
	}
	
	/**
	 * 查找多边形的中心
	 * @param	vs    	   多边形顶点坐标
	 * @param	count      顶点数量
	 * @return  中心坐标
	 */
	private function findCentroid(vs:Vector.<b2Vec2>, count:uint):b2Vec2
	{
		var c:b2Vec2 = new b2Vec2();
		var area:Number = 0.0;
		var p1X:Number = 0.0;
		var p1Y:Number = 0.0;
		var inv3:Number = 1.0 / 3.0;
		for (var i:int = 0; i < count; ++i)
		{
			var p2:b2Vec2 = vs[i];
			var p3:b2Vec2 = i + 1 < count ? vs[int(i + 1)] : vs[0];
			var e1X:Number = p2.x - p1X;
			var e1Y:Number = p2.y - p1Y;
			var e2X:Number = p3.x - p1X;
			var e2Y:Number = p3.y - p1Y;
			var D:Number = (e1X * e2Y - e1Y * e2X);
			var triangleArea:Number = 0.5 * D;
			area += triangleArea;
			c.x += triangleArea * inv3 * (p1X + p2.x + p3.x);
			c.y += triangleArea * inv3 * (p1Y + p2.y + p3.y);
		}
		c.x *= 1.0 / area;
		c.y *= 1.0 / area;
		return c;
	}
	
	/**
	 * 创建切割后的多边形
	 * @param	fixture    被激光切割的对象
	 * @param	vertices     多边形顶点坐标
	 * @param	numVertices  顶点数量
	 */
	private function splitBody(fixture:b2Fixture, vertices:Vector.<b2Vec2>, numVertices:int):void
	{
		if (!fixture) return;
		//多边形
		var polyVertices:Array = [];
		var centre:b2Vec2 = findCentroid(vertices, vertices.length);
		for (var i:int = 0; i < numVertices; i++)
		{
			vertices[i].Subtract(centre);
			polyVertices.push([vertices[i].x * B2dShell.CONVERSION, vertices[i].y * B2dShell.CONVERSION]);
		}
		var bodyData:PolyData = new PolyData();
		bodyData.density = fixture.GetDensity();
		bodyData.friction = fixture.GetFriction();
		bodyData.restitution = fixture.GetRestitution();
		bodyData.vertices = polyVertices;
		bodyData.postion = new Point(centre.x * B2dShell.CONVERSION, centre.y * B2dShell.CONVERSION);
		bodyData.bodyType = b2Body.b2_dynamicBody;
		this.b2dShell.createPoly(bodyData);
		for (i = 0; i < numVertices; i++)
		{
			vertices[i].Add(centre);
		}
	}
	
	/**
	 * 销毁鼠标事件
	 */
	private function removeMouseEvent():void
	{
		if (this.stage)
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHander);
			this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHander);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHander);
		}
	}
	
	/**
	 * 添加不需要被切割的刚体
	 * @param	body  不需要被切割的刚体
	 */
	public function addIgnoreBody(body:b2Body):void
	{
		if (!this.ignoreDictionary)
			this.ignoreDictionary = new Dictionary();
		this.ignoreDictionary[body] = body;
	}
	
	/**
	 * 删除添加进不需要被切割的刚体列表内的刚体
	 * @param	body  需要被切割的刚体
	 */
	public function deleteIgnoreBody(body:b2Body):void
	{
		if (!this.ignoreDictionary) return;
		delete this.ignoreDictionary[body];
	}
	
	/**
	 * 销毁画布
	 */
	private function removeCanvas():void
	{
		if (this.canvas && this.canvas.parent)
		{
			this.canvas.graphics.clear();
			this.canvas.parent.removeChild(this.canvas);
		}
		this.canvas = null;
		this.canvasContainer = null;
	}
	
	/**
	 * 销毁方法
	 */
	public function destroy():void
	{
		this.b2dShell = null;
		this.sliceInPoint = null;
		this.sliceOutPoint = null;
		this.removeCanvas();
		this.removeMouseEvent();
		this.affectedByLaser = null;
		this.entryPoint = null;
		this.affectedByLaser = null;
		this.ignoreDictionary = null;
		this.stage = null;
	}
	
	/**
	 * 是否使用鼠标绘制切割线条
	 */
	public function get mouseDraw():Boolean
	{
		return _mouseDraw;
	}
	
	public function set mouseDraw(value:Boolean):void
	{
		_mouseDraw = value;
		if (this.mouseDraw)
		{
			this.initCanvas();
			this.initStage(this.stage);
		}
		else
		{
			this.removeMouseEvent();
			this.removeCanvas();
		}
	}
	
	/**
	 * 绘制容器
	 */
	public function get canvasContainer():DisplayObjectContainer
	{
		return _canvasContainer;
	}
	
	public function set canvasContainer(value:DisplayObjectContainer):void
	{
		_canvasContainer = value;
	}
}
}