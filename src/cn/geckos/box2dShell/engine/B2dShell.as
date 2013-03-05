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
import Box2D.Dynamics.Controllers.b2BuoyancyController;
import Box2D.Dynamics.Joints.b2Joint;
import Box2D.Dynamics.Joints.b2JointEdge;
import Box2D.Dynamics.Joints.b2MouseJoint;
import Box2D.Dynamics.Joints.b2MouseJointDef;
import cn.geckos.box2dShell.Box2DSeparator.b2Separator;
import cn.geckos.box2dShell.data.CircleData;
import cn.geckos.box2dShell.data.PolyData;
import cn.geckos.utils.MathUtil;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
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
	//速度计算层级 用于精准性
	private var _velocityIterations:int;
	//位置计算层级
	private var _positionIterations:int;
	//刚体
	private var body:b2Body;
	//刚体数据
	private var bodyDef:b2BodyDef;
	//米和像素的转换单位
	public static var CONVERSION:int = 30;
	//舞台
	private var stage:Stage;
	//鼠标关节点
	private var mouseJoint:b2MouseJoint;
	//鼠标点击
	private var _mouseEnabled:Boolean;
	//鼠标是否点击
	private var isMouseDown:Boolean;
	//鼠标位置
	private var mouseXWorldPhys:Number;
	private var mouseYWorldPhys:Number;
	//刚体装置物
	private var fixtureDef:b2FixtureDef;
	//调试用的绘制容器
	private var debugSprite:Sprite;
	private var destroyJointDict:Dictionary;
	//浮力调节器
	private var buoyancyController:b2BuoyancyController;
	//调试绘制
	private var debugDraw:b2DebugDraw;
	//wrapAround范围
	private var _wrapAroundRange:Rectangle;
	public function B2dShell()
	{
		this.bodyDef = new b2BodyDef();
		this.fixtureDef = new b2FixtureDef();
		this.destroyJointDict = new Dictionary();
	}
	
	/**
	 * 建立b2d世界
	 * @param	x 重力向量x
	 * @param	y 重力向量y
	 * @param	stage 舞台
	 * @param	doSleep 是否休眠
	 */
	public function createWorld(x:Number, y:Number, stage:Stage, doSleep:Boolean):void
	{
		this.gravity = new b2Vec2(x, y);
		this.stage = stage;
		this.doSleep = doSleep;
		this._world = new b2World(this.gravity, this.doSleep);
		if (!this.wrapAroundRange)
			this.wrapAroundRange = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
	}
	
	/**
	 * 创建一个边界
	 * @param	left   左边界
	 * @param	right  右边界
	 * @param	top    上边界
	 * @param	bottom 下边界
	 */
	public function createOutSide(left:Number, right:Number, top:Number, bottom:Number):void
	{
		//上
		var bodyData:PolyData = new PolyData();
		bodyData.bodyType = b2Body.b2_staticBody;
		bodyData.density = .1;
		bodyData.friction = .1;
		bodyData.restitution = .1;
		bodyData.width = right - left;
		bodyData.height = 5;
		bodyData.postion = new Point(left + bodyData.width * .5, top - bodyData.height * .5);
		bodyData.boxPoint = new Point(bodyData.width * .5, bodyData.height * .5);
		this.createPoly(bodyData);
		//下
		bodyData.width = right - left;
		bodyData.height = 5;
		bodyData.postion = new Point(left + bodyData.width * .5, bottom + bodyData.height * .5);
		this.createPoly(bodyData);
		//左
		bodyData.width = 5;
		bodyData.height = bottom - top;
		bodyData.postion = new Point(left - bodyData.width * .5, top + bodyData.height * .5);
		bodyData.boxPoint = new Point(bodyData.width * .5, bodyData.height * .5);
		this.createPoly(bodyData);
		//右
		bodyData.width = 5;
		bodyData.height = bottom - top;
		bodyData.postion = new Point(right + bodyData.width * .5, top + bodyData.height * .5);
		this.createPoly(bodyData);
		
	}
	
	/**
	 * 清除世界
	 */
	public function clearWorld():void
	{
		this.clearAll();
		this._world = null;
		this.wrapAroundRange = null;
		this.gravity = null;
	}
	
	/**
	 * 销毁b2dShell
	 */
	public function destroy():void
	{
		this.clearWorld();
		this.debugDraw = null;
		if (this.debugSprite && 
			this.debugSprite.parent)
			this.debugSprite.parent.removeChild(this.debugSprite);
		this.debugSprite = null;
		this.mouseJoint = null;
		this.stage = null;
		this.bodyDef = null;
		this.fixtureDef = null;
		this.destroyJointDict = null;
	}
	
	/**
	 * 创建方块
	 * @param	bodyData 刚体数据
	 * @return  刚体对像
	 */
	public function createPoly(bodyData:PolyData):b2Body
	{
		//位置
		this.bodyDef.position.Set(bodyData.postion.x / CONVERSION, bodyData.postion.y / CONVERSION);
		this.bodyDef.type = bodyData.bodyType;
		//是否为子弹
		this.bodyDef.bullet = bodyData.bullet;
		//摩擦力
		this.fixtureDef.friction = bodyData.friction;
		//密度,静态物体需要0密度 
		this.fixtureDef.density = bodyData.density;
		//弹性 0-1
		this.fixtureDef.restitution = bodyData.restitution;
		this.bodyDef.userData = { };
		this.bodyDef.userData.params = bodyData.params;
		//是否环绕屏幕
		this.bodyDef.userData.isWrapAround = bodyData.isWrapAround;
		//环绕屏幕的方向
		if (this.bodyDef.userData.isWrapAround)
			this.bodyDef.userData.wrapAroundDirection = bodyData.wrapAroundDirection;
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
		if (bodyData.rotation)
			this.body.SetAngle(MathUtil.dgs2rds(bodyData.rotation));
		//多边形写义
		var boxShape:b2PolygonShape = new b2PolygonShape();
		if (!bodyData.vertices)
		{
			//设置注册点
			boxShape.SetAsBox(bodyData.boxPoint.x / CONVERSION, bodyData.boxPoint.y / CONVERSION);
			this.fixtureDef.shape = boxShape;
			this.body.CreateFixture(fixtureDef);
		}
		else
		{
			//设置顶点
			var vertexCount:int = bodyData.vertices.length;
			if (vertexCount <= 2)
				throw new Error("多边形顶点不能少于3个");
			
			//创建多边形首先要指出顶点数（最多8个）
			var vertices:Vector.<b2Vec2> = new Vector.<b2Vec2>();
			for (var i:int = 0; i < vertexCount; i += 1)
			{
				var b2v:b2Vec2 = new b2Vec2();
				var x:Number = bodyData.vertices[i][0] / CONVERSION;
				var y:Number = bodyData.vertices[i][1] / CONVERSION;
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
		this.bodyDef.position.Set(bodyData.postion.x / CONVERSION, bodyData.postion.y / CONVERSION);
		//圆形写义
		var circleShape:b2CircleShape = new b2CircleShape(bodyData.radius / CONVERSION);
		this.bodyDef.type = bodyData.bodyType;
		//是否为子弹
		this.bodyDef.bullet = bodyData.bullet;
		//摩擦力
		this.fixtureDef.friction = bodyData.friction;
		//密度,静态物体需要0密度
		this.fixtureDef.density = bodyData.density;
		//弹性 0-1
		this.fixtureDef.restitution = bodyData.restitution;
		this.fixtureDef.shape = circleShape;
		this.bodyDef.userData = { };
		this.bodyDef.userData.params = bodyData.params;
		//是否环绕屏幕
		this.bodyDef.userData.isWrapAround = bodyData.isWrapAround;
		//环绕屏幕的方向
		if (this.bodyDef.userData.isWrapAround)
			this.bodyDef.userData.wrapAroundDirection = bodyData.wrapAroundDirection;
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
		if (bodyData.rotation)
			this.body.SetAngle(MathUtil.dgs2rds(bodyData.rotation));
		//创建图形
		this.body.CreateFixture(fixtureDef);
		return this.body;
	}
	
	/**
	 * 创建浮力
	 * @param	p        	水面的法向量
	 * @param	offset   	水面的位置 ＂注意这里和flash内的y轴方向相反，所以你需要设置为坐标的负数＂
	 * @param	density　	水的密度
	 * @param	linearDrag　水中移动阻尼
	 * @param	angularDrag	水中的旋转阻尼
	 */
	public function createBuoyancy(p:Point, offset:Number, density:Number, linearDrag:Number, angularDrag:Number):void
	{
		if (this.buoyancyController || !this.world) return;
		this.buoyancyController = new b2BuoyancyController();
		//设置b2BuoyancyController对象的一些基本属性
		//设置水面的法向量
		this.buoyancyController.normal.Set(p.x, p.y);
		//设置水面的位置
		this.buoyancyController.offset = offset / CONVERSION;
		//设置水的密度，因为我们创建的刚体密度是3，所以水的密度要大于3
		this.buoyancyController.density = density;
		//设置刚体在水中的移动阻尼
		this.buoyancyController.linearDrag = linearDrag;
		//设置刚体在水中的旋转阻尼
		this.buoyancyController.angularDrag = angularDrag;
		this.world.AddController(this.buoyancyController);
	}
	
	/**
	 * 创建需要使用浮力的刚体
	 * @param	body  需要使用浮力的刚体
	 */
	public function addBuoyancyBody(body:b2Body):void
	{
		if (!this.buoyancyController || !body) return;
		this.buoyancyController.AddBody(body);
	}
	
	/**
	 * 删除不需要使用浮力的刚体
	 * @param	body  不需要使用浮力的刚体
	 */
	public function removeBuoyancyBody(body:b2Body):void
	{
		if (!this.buoyancyController || !body) return;
		this.buoyancyController.RemoveBody(body);
	}
	
	/**
	 * 渲染
	 */
	public function render():void
	{
		this.updateMousePostion();
		this.mouseDrag();
		this.updateDestroyJoint();
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
				dpObj.x = bb.GetPosition().x * CONVERSION;
				dpObj.y = bb.GetPosition().y * CONVERSION;
				dpObj.rotation = MathUtil.rds2dgs(bb.GetAngle());
			}
			this.bodyWrapAround(bb, this.wrapAroundRange);
		}
	}
	
	/**
	 * 设置刚体环绕屏幕
	 * @param	body    	需要环绕的刚体
	 * @param	range   	运动范围
	 */
	private function bodyWrapAround(body:b2Body, range:Rectangle):void
	{
		if (!body) return;
		var userData:Object = body.GetUserData();
		if (!userData || !userData.isWrapAround) return;
		//没有关节组的刚体
		if (!body.GetJointList())
		{
			var isHorizontal:Boolean;//横
			var isVertical:Boolean;//纵
			var direction:int = userData.wrapAroundDirection//方向
			if (direction == 0)
			{
				isHorizontal = true;
				isVertical = false;
			}
			else if (direction == 1)
			{
				isHorizontal = false;
				isVertical = true;
			}
			else if (direction == 2)
			{
				isHorizontal = true;
				isVertical = true;
			}
			if (isHorizontal)
			{
				if (body.GetPosition().x * CONVERSION > range.right)
					body.SetPosition(new b2Vec2(range.left / CONVERSION, body.GetPosition().y));
				else if (body.GetPosition().x * CONVERSION < range.left)
					body.SetPosition(new b2Vec2(range.right / CONVERSION, body.GetPosition().y));
			}
			if (isVertical)
			{
				if (body.GetPosition().y * CONVERSION > range.bottom)
					body.SetPosition(new b2Vec2(body.GetPosition().x, range.top / CONVERSION));
				else if (body.GetPosition().y * CONVERSION < range.top)
					body.SetPosition(new b2Vec2(body.GetPosition().x, range.bottom / CONVERSION));
			}
		}
	}
	
	/**
	 * 更新刚体关键的状态 用于删除关节
	 */
	private function updateDestroyJoint():void 
	{
		//将要销毁关节的刚体缓存在destroyJointDict中
		for each (var body:b2Body in this.destroyJointDict) 
		{
			for (var j:b2JointEdge = body.GetJointList(); j; j = j.next)
			{
				body.GetWorld().DestroyJoint(j.joint);
			}
			delete this.destroyJointDict[body];
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
	private function getBodyAtMouse(includeStatic:Boolean = true):b2Body
	{
		// Make a small box.
		if (!this.stage || !this.mouseEnabled) return null;
		return this.getBodyByPostion(this.mouseXWorldPhys, this.mouseYWorldPhys, includeStatic);
	}
	
	/**
	 * 根据坐标返回刚体数据
	 * @param	x 				x位置
	 * @param	y 				y位置
	 * @param	includeStatic   是否包括静态刚体
	 * @return  返回刚体
	 */
	public function getBodyByPostion(x:Number, y:Number, includeStatic:Boolean = true):b2Body
	{
		var posVec:b2Vec2 = new b2Vec2(x, y);
		var aabb:b2AABB = new b2AABB();
		aabb.lowerBound.Set(x - 0.001, y - 0.001);
		aabb.upperBound.Set(x + 0.001, y + 0.001);
		var body:b2Body = null;
		var fixture:b2Fixture;
		
		// Query the world for overlapping shapes.
		function GetBodyCallback(fixture:b2Fixture):Boolean
		{
			var shape:b2Shape = fixture.GetShape();
			if (fixture.GetBody().GetType() != b2Body.b2_staticBody || includeStatic)
			{
				//posVec 不是从外部传进来的 是world内部的
				var inside:Boolean = shape.TestPoint(fixture.GetBody().GetTransform(), posVec);
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
		if (this.isMouseDown && !this.mouseJoint)
		{
			var body:b2Body = this.getBodyAtMouse(false);
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
		if (!this.isMouseDown)
		{
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
				var body:b2Body = this.getBodyAtMouse();
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
			if (this.buoyancyController)
				this.buoyancyController.RemoveBody(body);
			this.world.DestroyBody(body);
		}
	}
	
	/**
	 * 销毁刚体所有的关节
	 * @param	body  需要消耗关节的刚体
	 */
	public function destroyBodyAllJoint(body:b2Body):void
	{
		if (this.destroyJointDict && body) 
			this.destroyJointDict[body] = body;
	}
	
	/**
	 * 根据坐标返回刚体数据
	 * @param	x x位置
	 * @param	y y位置
	 * @return  返回刚体
	 */
	public function getBodyByDisplayObjPostion(x:Number, y:Number):b2Body
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
				var label:String = bb.GetUserData().bodyLabel;
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
	public function drawDebug(container:DisplayObjectContainer):void
	{
		if (!this.world) return;
		if (!this.debugSprite)
		{
			this.debugSprite = new Sprite();
			container.addChild(this.debugSprite);
		}
		if (!this.debugDraw)
		{
			this.debugDraw = new b2DebugDraw();
			this.debugDraw.SetSprite(this.debugSprite);
			this.debugDraw.SetLineThickness(.2);
			this.debugDraw.SetDrawScale(CONVERSION);
			this.debugDraw.SetAlpha(1);
			//绘制模式 e_jointBit关节 e_shapeBit刚体 e_controllerBit碰撞组
			this.debugDraw.SetFlags(b2DebugDraw.e_jointBit | b2DebugDraw.e_shapeBit | b2DebugDraw.e_controllerBit);
			this.world.SetDebugDraw(this.debugDraw);
		}
	}
	
	/**
	 * 清除
	 */
	public function clearAll():void
	{
		this.world.ClearForces();
		this.clearJointDict();
		this.buoyancyController = null;
		for (var bb:b2Body = this.world.GetBodyList(); bb; bb = bb.GetNext())
		{
			this.destroyBody(bb);
		}
	}
	
	/**
	 * 清除待销毁关节的列表
	 */
	private function clearJointDict():void
	{
		if (!this.destroyJointDict) return;
		for each (var body:b2Body in this.destroyJointDict) 
		{
			delete this.destroyJointDict[body];
		}
	}
	
	/**
	 * 更新鼠标位置
	 */
	private function updateMousePostion():void
	{
		if (this.stage && this.mouseEnabled)
		{
			this.mouseXWorldPhys = this.stage.mouseX / CONVERSION;
			this.mouseYWorldPhys = this.stage.mouseY / CONVERSION;
		}
	}
	
	/**
	 * 设置线速度
	 * @param	body  刚体
	 * @param	vx    横向速度
	 * @param	vy    纵向速度
	 */
	public function setLinearVelocity(body:b2Body, vx:Number, vy:Number):void
	{
		if (!body) return;
		body.SetLinearVelocity(new b2Vec2(vx, vy)); 
	}
	
	private function stageMouseDown(event:MouseEvent):void 
	{
		this.isMouseDown = true;
	}
	
	private function stageMouseUp(event:MouseEvent):void 
	{
		this.isMouseDown = false;
	}
	
	/**
	 * 时间步
	 */
	public function get timeStep():Number {	return _timeStep; }
	public function set timeStep(value:Number):void 
	{
		_timeStep = value;
	}
	
	/**
	 * 位置计算层级 
	 */
	public function get positionIterations():int { return _positionIterations; }
	public function set positionIterations(value:int):void 
	{
		_positionIterations = value;
	}
	
	/**
	 * 速度计算层级 
	 */
	public function get velocityIterations():int { return _velocityIterations; }
	public function set velocityIterations(value:int):void 
	{
		_velocityIterations = value;
	}
	
	/**
	 * 是否允许鼠标拖到
	 */
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
	
	/**
	 * box2d世界
	 */
	public function get world():b2World { return _world; };
	
	/**
	 * wrapAround范围
	 */
	public function get wrapAroundRange():Rectangle { return _wrapAroundRange; }
	public function set wrapAroundRange(value:Rectangle):void 
	{
		_wrapAroundRange = value;
	}
	
}
}