package cn.geckos.box2dShell.engine 
{
import Box2D.Collision.b2AABB;
import Box2D.Collision.Shapes.b2CircleShape;
import Box2D.Collision.Shapes.b2PolygonShape;
import Box2D.Collision.Shapes.b2Shape;
import Box2D.Common.Math.b2Vec2;
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.b2BodyDef;
import Box2D.Dynamics.b2DebugDraw;
import Box2D.Dynamics.b2Fixture;
import Box2D.Dynamics.b2FixtureDef;
import Box2D.Dynamics.b2World;
import Box2D.Dynamics.Joints.b2Joint;
import Box2D.Dynamics.Joints.b2MouseJoint;
import Box2D.Dynamics.Joints.b2MouseJointDef;
import cn.geckos.box2dShell.Box2DSeparator.b2Separator;
import cn.geckos.box2dShell.data.CircleData;
import cn.geckos.box2dShell.data.PolyData;
import cn.geckos.utils.MathUtil;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
/**
 * ...box2d壳
 * 用于使用对象创建box2d的数据
 * @author Kanon
 */
public class B2dShell 
{
	//世界
	private var _world:b2World;
	//重力
	private var gravity:b2Vec2;
	private var doSleep:Boolean;
	//时间步
	private var _timeStep:Number;
	//速度迭代
	private var _velocityIterations:int;
	//位置迭代
	private var _positionIterations:int;
	//刚体
	private var body:b2Body;
	//刚体数据
	private var bodyDef:b2BodyDef;
	//米和像素的转换单位
	public static var conversion:int = 30;
	//外部容器对象
	private var stage:DisplayObjectContainer;
	//鼠标关节点
	private var mouseJoint:b2MouseJoint;
	//鼠标点击
	private var _mouseEnabled:Boolean;
	//鼠标是否点击
	private var isMouseDown:Boolean;
	private var isMouseMove:Boolean;
	//鼠标位置
	private var mouseXWorldPhys:Number;
	private var mouseYWorldPhys:Number;
	//鼠标坐标
	private var mousePVec:b2Vec2;
	//刚体装置物
	private var fixtureDef:b2FixtureDef;
	public function B2dShell() 
	{
		this.bodyDef = new b2BodyDef();
		this.mousePVec = new b2Vec2();
		this.fixtureDef = new b2FixtureDef();
	}
	
	/**
	 * 建立b2d世界
	 * @param	x 重力向量x
	 * @param	y 重力向量y
	 * @param	stage 舞台
	 * @param	doSleep 是否休眠
	 */
	public function createWorld(x:Number, y:Number, stage:DisplayObjectContainer, doSleep:Boolean):void
	{
		this.gravity = new b2Vec2(x, y);
		this.stage = stage;
		this.doSleep = doSleep;
		this._world = new b2World(this.gravity, this.doSleep);
	}
	
	/**
	 * 清除世界
	 */
	public function clearWorld():void
	{
		this.clearAll();
		this._world = null;
		this.gravity = null;
	}
	
	/**
	 * 创建方块
	 * @param	bodyData 刚体数据
	 * @return  刚体对像
	 */
	public function createPoly(bodyData:PolyData):b2Body
	{
		//位置
		this.bodyDef.position.Set(bodyData.postion.x / conversion, bodyData.postion.y / conversion);
		this.bodyDef.type = bodyData.bodyType;
		//摩擦力
		this.fixtureDef.friction = bodyData.friction;
		//密度,静态物体需要0密度 
		this.fixtureDef.density = bodyData.density;
		//弹性 0-1
		this.fixtureDef.restitution = bodyData.restitution;
		this.fixtureDef.shape = boxShape;
		this.bodyDef.userData = { };
		if (bodyData.displayObject)
		{
			//用户数据,可为显示对象,或为自己的对象
			this.bodyDef.userData.dpObj = bodyData.displayObject;
			//宽
			this.bodyDef.userData.dpObj.width = bodyData.width;
			//高
			this.bodyDef.userData.dpObj.height = bodyData.height;
		}
		this.bodyDef.userData.bodyLabel = bodyData.bodyLabel;
		//创建刚体
		this.body = this.world.CreateBody(this.bodyDef);
		//多边形写义
		var boxShape:b2PolygonShape = new b2PolygonShape();
		if (!bodyData.vertices)
		{
			//设置注册点
			boxShape.SetAsBox(bodyData.boxPoint.x / conversion, bodyData.boxPoint.y / conversion);
			fixtureDef.shape = boxShape;
			this.body.CreateFixture(fixtureDef);
		}
		else
		{
			//设置顶点
			var vertexCount:int = bodyData.vertices.length;
			trace("vertexCount", vertexCount, "bodyData.vertices", bodyData.vertices);
			if (vertexCount <= 2)
				throw new Error("多边形顶点不能少于3个");
			
			//创建多边形首先要指出顶点数（最多8个）
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for (var i:int = 0; i < vertexCount; i += 1)
			{
				var b2v:b2Vec2 = new b2Vec2();
				var x:Number = bodyData.vertices[i][0] / conversion;
				var y:Number = bodyData.vertices[i][1] / conversion;
				b2v.Set(x, y);
				vertices.push(b2v);
			}
			/**
			 * 将原本创建图形的方法放进Separate内执行
			 * boxShape.SetAsArray(vertices, vertexCount);
			 * fixtureDef.shape = boxShape;
			 * this.body.CreateFixture(fixtureDef)
			 */
			var separator:b2Separator = new b2Separator();
			separator.Separate(this.body, this.fixtureDef, vertices);
		}
		return this.body;
	}
	
	/**
	 * 创建圆形
	 * @param	bodyData 刚体数据
	 */
	public function createCircle(bodyData:CircleData):b2Body
	{
		//位置
		this.bodyDef.position.Set(bodyData.postion.x / B2dShell.conversion, bodyData.postion.y / conversion);
		//圆形写义
		var circleShape:b2CircleShape = new b2CircleShape(bodyData.radius / conversion);
		this.bodyDef.type = bodyData.bodyType;
		//摩擦力
		this.fixtureDef.friction = bodyData.friction;
		//密度,静态物体需要0密度
		this.fixtureDef.density = bodyData.density;
		//弹性 0-1
		this.fixtureDef.restitution = bodyData.restitution;
		this.fixtureDef.shape = circleShape;
		this.bodyDef.userData = { };
		if (bodyData.displayObject)
		{
			//用户数据,可为显示对象,或为自己的对象
			this.bodyDef.userData.dpObj = bodyData.displayObject;
			//宽
			this.bodyDef.userData.dpObj.width = bodyData.radius * 2;
			//高
			this.bodyDef.userData.dpObj.height = bodyData.radius * 2;
		}
		this.bodyDef.userData.bodyLabel = bodyData.bodyLabel;
		//创建刚体
		this.body = this.world.CreateBody(this.bodyDef);
		//创建图形
		this.body.CreateFixture(fixtureDef);
		return this.body;
	}
	
	/**
	 * 渲染
	 */
	public function render():void
	{
		this.updataMousePostion();
		this.mouseDrag();
		//刷新物理世界
		this.world.Step(this.timeStep, this.velocityIterations, this.positionIterations);
		this.world.ClearForces();
		this.world.DrawDebugData();
		for (var bb:b2Body = this.world.GetBodyList(); bb; bb = bb.GetNext())
		{
			//声明bb = 世界对象的刚体列表; //bb(如果为空值, 即null, 0, underfind), 则不运行,
			//bb = bb.GetNext(下一个值为它的GetNext)
			if (this.userDataHasDisplayObject(bb))
			{
				var dpObj:DisplayObject = bb.GetUserData().dpObj;
				dpObj.x = bb.GetPosition().x * conversion;
				dpObj.y = bb.GetPosition().y * conversion;
				dpObj.rotation = MathUtil.rds2dgs(bb.GetAngle());
			}
		}
	}
	
	/**
	 * 获取刚体列表
	 * @return 刚体列表
	 */
	public function getBodyList():Array
	{
		var arr:Array = [];
		for (var bb:b2Body = this.world.GetBodyList(); bb; bb = bb.GetNext())
		{
			if (this.userDataHasDisplayObject(bb))
				arr.push(bb);
		}
		return arr;
	}
	
	/**
	 * 根据名字获取刚体数据
	 * @param	name
	 * @return  刚体
	 */
	public function getBodyByName(name:String):b2Body
	{
		for (var bb:b2Body = this.world.GetBodyList(); bb; bb = bb.GetNext())
		{
			if (this.userDataHasDisplayObject(bb))
			{
				if (DisplayObject(bb.GetUserData().dpObj).name == name)
					return bb;
			}
		}
		return null;
	}
	
	
	/**
	 * 获取关节列表
	 * @return 关节列表
	 */
	public function getJointList():Array
	{
		var arr:Array = [];
		for (var joint:b2Joint = this.world.GetJointList(); joint; joint = joint.GetNext())
		{
			arr.push(joint);
		}
		return arr;
	}
	
	
	//======================
	// GetBodyAtMouse
	//======================
	private function getBodyAtMouse(includeStatic:Boolean = false):b2Body
	{
		// Make a small box.
		if (!this.stage || !this.mouseEnabled) return null;
		this.mousePVec.Set(this.mouseXWorldPhys, this.mouseYWorldPhys);
		var aabb:b2AABB = new b2AABB();
		aabb.lowerBound.Set(this.mouseXWorldPhys - 0.001, this.mouseYWorldPhys - 0.001);
		aabb.upperBound.Set(this.mouseXWorldPhys + 0.001, this.mouseYWorldPhys + 0.001);
		var body:b2Body = null;
		var fixture:b2Fixture;
		
		// Query the world for overlapping shapes.
		function GetBodyCallback(fixture:b2Fixture):Boolean
		{
			var shape:b2Shape = fixture.GetShape();
			if (fixture.GetBody().GetType() != b2Body.b2_staticBody || includeStatic)
			{
				//mousePVec 不是从外部传进来的 是world内部的
				var inside:Boolean = shape.TestPoint(fixture.GetBody().GetTransform(), mousePVec);
				if (inside)
				{
					body = fixture.GetBody();
					return false;
				}
			}
			return true;
		}
		/**
		 * 查找重叠的刚体
		 */
		this.world.QueryAABB(GetBodyCallback, aabb);
		return body;
	}
	
	
	//======================
	// Mouse Drag 
	//======================
	private function mouseDrag():void 
	{
		// mouse press
		if (!this.stage || !this.mouseEnabled) return;
		if (this.isMouseDown && !this.mouseJoint){
			
			var body:b2Body = this.getBodyAtMouse();
			if (body)
			{
				var md:b2MouseJointDef = new b2MouseJointDef();
				md.bodyA = this.world.GetGroundBody();
				md.bodyB = body;
				md.target.Set(this.mouseXWorldPhys, this.mouseYWorldPhys);
				md.collideConnected = true;
				md.maxForce = 300.0 * body.GetMass();
				this.mouseJoint = this.world.CreateJoint(md) as b2MouseJoint;
				body.SetAwake(true);
			}
		}
		// mouse release
		if (!this.isMouseDown){
			if (this.mouseJoint)
			{
				this.world.DestroyJoint(this.mouseJoint);
				this.mouseJoint = null;
			}
		}	
		// mouse move
		if (this.mouseJoint)
		{
			if (this.mouseJoint.GetBodyA() || this.mouseJoint.GetBodyB())
			{
				var p2:b2Vec2 = new b2Vec2(this.mouseXWorldPhys, this.mouseYWorldPhys);
				this.mouseJoint.SetTarget(p2);
			}
			else
			{
				this.mouseJoint = null;
			}
		}
	}
	
	//======================
	// Mouse Destroy
	//======================
	private function mouseDestroy():void
	{
		// mouse press
		if (this.stage && this.mouseEnabled)
		{
			if (!this.isMouseDown)
			{
				var body:b2Body = this.getBodyAtMouse(true);
				this.destroyBody(body);
			}
		}
	}
	
	/**
	 * 单一的静态地面刚体没有碰撞和形状。
	 * @return
	 */
	public function getGroundBody():b2Body
	{
		return this.world.GetGroundBody();
	}
	
	/**
	 * 根据刚体获取显示对象
	 * @param	body  刚体
	 * @return  显示对象
	 */
	public function getUseDataByBody(body:b2Body):DisplayObject
	{
		if (this.userDataHasDisplayObject(body))
			return body.GetUserData().dpObj;
		else
			return null;
	}
	
	/**
	 * 销毁刚体
	 * @param	body 被销毁的刚体
	 */
	public function destroyBody(body:b2Body):void
	{
		if (body)
		{
			if (this.userDataHasDisplayObject(body))
			{
				var displayObj:DisplayObject = body.GetUserData().dpObj as DisplayObject;
				if (displayObj.parent)
					displayObj.parent.removeChild(displayObj);
			}
			this.world.DestroyBody(body);
		}
	}
	
	/**
	 * 根据坐标返回刚体数据
	 * @param	x x位置
	 * @param	y y位置
	 * @return  返回刚体
	 */
	public function getBodyByPostion(x:Number, y:Number):b2Body
	{
		for (var bb:b2Body = this.world.GetBodyList(); bb; bb = bb.GetNext())
		{
			//声明bb = 世界对象的刚体列表; 
			//bb(如果为空值, 即null, 0, underfind), 则不运行,	
			//bb = bb.GetNext(下一个值为它的GetNext)
			if (this.userDataHasDisplayObject(bb)) 
			{
				var displayObj:DisplayObject = bb.GetUserData().dpObj as DisplayObject;
				if (displayObj.hitTestPoint(x, y, true))
				{
					return bb;
				}
			}
		}
		return null;
	}
	
	/**
	 * 判断 GetUserData中是否有显示对象
	 * @param	body  刚体
	 * @return  是否存在
	 */
	private function userDataHasDisplayObject(body:b2Body):Boolean
	{
		if (body.GetUserData() && 
			body.GetUserData().dpObj && 
			body.GetUserData().dpObj is DisplayObject)
		{
			return true;
		}
		return false;
	}
	
	/**
	 * 根据刚体的标签获取刚体
	 * @param	bodyLabel   刚体标签
	 * @return  刚体
	 */
	public function getBodyByLabel(bodyLabel:String):b2Body
	{
		for (var bb:b2Body = this.world.GetBodyList(); bb; bb = bb.GetNext())
		{
			//声明bb = 世界对象的刚体列表; 
			//bb(如果为空值, 即null, 0, underfind), 则不运行,	
			//bb = bb.GetNext(下一个值为它的GetNext)
			if (bb.GetUserData() && bb.GetUserData().bodyLabel) 
			{
				trace("bb.GetUserData().bodyLabel", bb.GetUserData().bodyLabel);
				var label:String = bb.GetUserData().bodyLabel;
				trace(label, bodyLabel);
				if (label == bodyLabel)
					return bb;
			}
		}
		return null;
	}
	
	/**
	 * 调试绘制
	 * @return  绘制的容器
	 */
	public function drawDebug():Sprite
	{
		var debugSprite:Sprite = new Sprite();
		var debugDraw:b2DebugDraw = new b2DebugDraw();
		debugDraw.SetSprite(debugSprite);
		debugDraw.SetLineThickness(.2);
		debugDraw.SetDrawScale(conversion);
		
		debugDraw.SetAlpha(1);
		debugDraw.SetFlags(b2DebugDraw.e_jointBit | b2DebugDraw.e_shapeBit);
		this.world.SetDebugDraw(debugDraw);
		return debugSprite;
	}
	
	/**
	 * 清除
	 */
	public function clearAll():void
	{
		this.world.ClearForces();
		for (var bb:b2Body = this.world.GetBodyList(); bb; bb = bb.GetNext())
		{
			this.destroyBody(bb);
		}
	}
	
	
	/**
	 * 更新鼠标位置
	 */
	private function updataMousePostion():void
	{
		if (this.stage && this.mouseEnabled)
		{
			this.mouseXWorldPhys = this.stage.mouseX / conversion;
			this.mouseYWorldPhys = this.stage.mouseY / conversion;
		}
	}
	
	private function stageMouseDown(event:MouseEvent):void 
	{
		this.isMouseDown = true;
	}
	
	private function stageMouseUp(event:MouseEvent):void 
	{
		this.isMouseDown = false;
		//trace("this.isMouseDown = false;");
	}
	
	
	/**
	 * 时间步
	 */
	public function get timeStep():Number 
	{
		return _timeStep;
	}
	
	public function set timeStep(value:Number):void 
	{
		_timeStep = value;
	}
	
	public function get positionIterations():int 
	{
		return _positionIterations;
	}
	
	public function set positionIterations(value:int):void 
	{
		_positionIterations = value;
	}
	
	public function get velocityIterations():int 
	{
		return _velocityIterations;
	}
	
	public function set velocityIterations(value:int):void 
	{
		_velocityIterations = value;
	}
	
	public function get mouseEnabled():Boolean { return _mouseEnabled; }
	public function set mouseEnabled(value:Boolean):void 
	{
		_mouseEnabled = value;
		if (this.mouseEnabled)
		{
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);	
			this.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUp);	
		}
		else
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUp);	
		}
	}
	
	public function get world():b2World { return _world; };
}
}