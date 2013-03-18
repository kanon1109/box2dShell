package cn.geckos.box2dShell.plugs
{
import Box2D.Collision.Shapes.b2PolygonShape;
import Box2D.Common.Math.b2Vec2;
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.b2Fixture;
import cn.geckos.box2dShell.data.PolyData;
import cn.geckos.box2dShell.engine.B2dShell;
import cn.geckos.box2dShell.plugs.event.PlugsEvent;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.Dictionary;
/**
 * ...切片插件 将刚体切片
 * @author Kanon
 */
public class Slice extends EventDispatcher
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
	//激光的进入点
	private var entryPointDict:Dictionary;
	//存放不需要切割的刚体
	private var sliceDictionary:Dictionary;
	public function Slice(b2dShell:B2dShell, stage:Stage, canvasContainer:DisplayObjectContainer = null)
	{
		this.b2dShell = b2dShell;
		this.stage = stage;
		this.entryPointDict = new Dictionary();
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
		//如果没有添加进切割列表内则 返回并继续判断切割
		if (this.sliceDictionary && !this.sliceDictionary[affectedBody]) return 1;
		if (!this.entryPointDict[affectedBody])
		{
			//如果之前激光没有碰到过 那么将切点坐标放进列表中
			this.entryPointDict[affectedBody] = point;
		}
		else
		{
			this.splitBody(affectedBody, this.entryPointDict[affectedBody], point.Copy());
		}
		return 1;
	}
	
	/**
	 * 切割多边形
	 * @param	sliceBody 被切割的多边形
	 * @param	A 		  切入点A
	 * @param	B		  切入点B
	 */
	private function splitBody(sliceBody:b2Body, A:b2Vec2, B:b2Vec2):void
	{
		var fixture:b2Fixture = sliceBody.GetFixtureList();
		//获取刚体图形
		var affectedBodyPolygon:b2PolygonShape = fixture.GetShape() as b2PolygonShape;
		var polyVertices:Vector.<b2Vec2> = affectedBodyPolygon.GetVertices();
		//受影响的刚体的顶点数量
		var numVertices:int = affectedBodyPolygon.GetVertexCount();
		//切割后新的2个图形的顶点坐标
		var shape1Vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
		var shape2Vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
		//将2个切入点转换坐标
		var A:b2Vec2 = sliceBody.GetLocalPoint(A);
		var B:b2Vec2 = sliceBody.GetLocalPoint(B);
		
		// I use shape1Vertices and shape2Vertices to store the vertices of the two new shapes that are about to be created. 
		// Since both point A and B are vertices of the two new shapes, I add them to both vectors.
		shape1Vertices.push(A, B);
		shape2Vertices.push(A, B);
		
		var d:Number;
		// I iterate over all vertices of the original body. 
		// I use the function det() ("det" stands for "determinant") to see on which side of AB each point is standing on. The parameters it needs are the coordinates of 3 points:
		// - if it returns a value >0, then the three points are in clockwise order (the point is under AB)
		// - if it returns a value =0, then the three points lie on the same line (the point is on AB)
		// - if it returns a value <0, then the three points are in counter-clockwise order (the point is above AB). 
		for (var i:int = 0; i < numVertices; i += 1)
		{
			d = det(A.x, A.y, B.x, B.y, polyVertices[i].x, polyVertices[i].y);
			if (d > 0) 
				shape1Vertices.push(polyVertices[i]);
			else 
				shape2Vertices.push(polyVertices[i]);
		}
		
		// In order to be able to create the two new shapes, I need to have the vertices arranged in clockwise order.
		// I call my custom method, arrangeClockwise(), which takes as a parameter a vector, representing the coordinates of the shape's vertices and returns a new vector, with the same points arranged clockwise.
		shape1Vertices = this.arrangeClockwise(shape1Vertices);
		shape2Vertices = this.arrangeClockwise(shape2Vertices);
		
		var poly1Vertices:Array = [];
		var poly2Vertices:Array = [];
		var length:int = shape1Vertices.length;
		for (i = 0; i < length; i += 1)
		{
			poly1Vertices.push([shape1Vertices[i].x * B2dShell.CONVERSION, 
								shape1Vertices[i].y * B2dShell.CONVERSION]);
		}
		
		length = shape2Vertices.length;
		for (i = 0; i < length; i += 1)
		{
			poly2Vertices.push([shape2Vertices[i].x * B2dShell.CONVERSION, 
								shape2Vertices[i].y * B2dShell.CONVERSION]);
		}
		
		var bodyData:PolyData = new PolyData();
		bodyData.density = fixture.GetDensity();
		bodyData.friction = fixture.GetFriction();
		bodyData.restitution = fixture.GetRestitution();
		bodyData.vertices = poly1Vertices;
		bodyData.postion = new Point(sliceBody.GetPosition().x * B2dShell.CONVERSION, 
									 sliceBody.GetPosition().y * B2dShell.CONVERSION);
		bodyData.bodyType = b2Body.b2_dynamicBody;
		
		//将要创建的2个新刚体的数据保存至数组中
		var bodyDataList:Array = [];
		var userData:Object = this.b2dShell.getUserDataByBody(sliceBody);
		var texture:BitmapData;
		//获取纹理对象
		if (userData && userData.texture) 
			texture = userData.texture;
		bodyDataList.push( { "bodyData":bodyData, "texture":texture, "shapeVertices":poly1Vertices } );
		
		//创建另一个刚体
		bodyData = new PolyData();
		bodyData.density = fixture.GetDensity();
		bodyData.friction = fixture.GetFriction();
		bodyData.restitution = fixture.GetRestitution();
		bodyData.vertices = poly2Vertices;
		bodyData.radian = sliceBody.GetAngle();
		bodyData.postion = new Point(sliceBody.GetPosition().x * B2dShell.CONVERSION, 
									 sliceBody.GetPosition().y * B2dShell.CONVERSION);
		bodyData.bodyType = b2Body.b2_dynamicBody;
		bodyDataList.push( { "bodyData":bodyData, "texture":texture, "shapeVertices":poly2Vertices } );
		
		//发送事件出去，外部根据事件穿的多边形对象选择是否创建一个新刚体。
		var event:PlugsEvent = new PlugsEvent(PlugsEvent.SLICE_COMPLETE);
		event.data = bodyDataList;
		this.dispatchEvent(event);
		this.b2dShell.destroyBody(sliceBody);
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
	 * 顺时针方向排列点坐标
	 * @param	vec    点列表
	 * @return  排好后的点列表
	 */
	private function arrangeClockwise(vec:Vector.<b2Vec2>):Vector.<b2Vec2> 
	{
		// The algorithm is simple: 
		// First, it arranges all given points in ascending order, according to their x-coordinate.
		// Secondly, it takes the leftmost and rightmost points (lets call them C and D), and creates tempVec, where the points arranged in clockwise order will be stored.
		// Then, it iterates over the vertices vector, and uses the det() method I talked about earlier. It starts putting the points above CD from the beginning of the vector, and the points below CD from the end of the vector. 
		// That was it!
		var n:int = vec.length, d:Number, i1:int = 1, i2:int = n - 1;
		var tempVec:Vector.<b2Vec2> = new Vector.<b2Vec2>(n), C:b2Vec2, D:b2Vec2;
		vec.sort(comp1);
		tempVec[0] = vec[0];
		C = vec[0];
		D = vec[n - 1];
		for (var i:int = 1; i < n - 1; i += 1)
		{
			d = det(C.x, C.y, D.x, D.y, vec[i].x, vec[i].y);
			if (d < 0)
				tempVec[i1++] = vec[i];
			else
				tempVec[i2--] = vec[i];
		}
		tempVec[i1] = vec[n - 1];
		return tempVec;
	}
	
	/**
	 * 一个比较方法 用于arrangeClockwise内
	 * @param	a
	 * @param	b
	 * @return
	 */
	private function comp1(a:b2Vec2, b:b2Vec2):Number
	{
		// This is a compare function, used in the arrangeClockwise() method - a fast way to arrange the points in ascending order, according to their x-coordinate.
		if (a.x > b.x)
			return 1;
		else if (a.x < b.x)
			return -1;
		return 0;
	}

	/**
	 * 它返回一个正数，如果三个点以顺时针方向，
	 * 负的，如果他们是在逆时针的顺序和
	 * 零，如果他们趴在同一行上。
	 * @param	x1
	 * @param	y1
	 * @param	x2
	 * @param	y2
	 * @param	x3
	 * @param	y3
	 * @return
	 */
	private function det(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number):Number 
	{
		// This is a function which finds the determinant of a 3x3 matrix.
		// If you studied matrices, you'd know that it returns a positive number if three given points are in clockwise order, negative if they are in anti-clockwise order and zero if they lie on the same line.
		// Another useful thing about determinants is that their absolute value is two times the face of the triangle, formed by the three given points.
		return x1 * y2 + x2 * y3 + x3 * y1 - y1 * x2 - y2 * x3 - y3 * x1;
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
	 * 添加需要被切割的刚体
	 * @param	body  需要被切割的刚体
	 */
	public function addSliceBody(body:b2Body):void
	{
		if (!this.sliceDictionary)
			this.sliceDictionary = new Dictionary();
		this.sliceDictionary[body] = body;
	}
	
	/**
	 * 删除添加进需要被切割的刚体列表内的刚体
	 * @param	body  不需要被切割的刚体
	 */
	public function deleteSliceBody(body:b2Body):void
	{
		if (!this.sliceDictionary) return;
		delete this.sliceDictionary[body];
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
		this.entryPointDict = null;
		this.sliceDictionary = null;
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