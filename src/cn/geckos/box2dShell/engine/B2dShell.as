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
	//线段验证
	private var separator:b2Separator;
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
		this.separator = null;
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
		this.bodyDef.position.Set(bodyData.postion.x / B2dShell.CONVERSION, 
								  bodyData.postion.y / B2dShell.CONVERSION);
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
		//刚体参数
		this.bodyDef.userData.params = bodyData.params;
		//材质
		this.bodyDef.userData.texture = bodyData.texture;
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
		//刚体标签
		this.bodyDef.userData.bodyLabel = bodyData.bodyLabel;
		//创建刚体
		this.body = this.world.CreateBody(this.bodyDef);
		//如果没弧度则设置角度
		if (!bodyData.radian && bodyData.rotation)
			this.body.SetAngle(MathUtil.dgs2rds(bodyData.rotation));
		else if (bodyData.radian)
			this.body.SetAngle(bodyData.radian);
		//多边形写义
		var boxShape:b2PolygonShape = new b2PolygonShape();
		if (!bodyData.vertices)
		{
			//设置注册点
			boxShape.SetAsBox(bodyData.boxPoint.x / B2dShell.CONVERSION, 
							  bodyData.boxPoint.y / B2dShell.CONVERSION);
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
				var x:Number = bodyData.vertices[i][0] / B2dShell.CONVERSION;
				var y:Number = bodyData.vertices[i][1] / B2dShell.CONVERSION;
				b2v.Set(x, y);
				vertices.push(b2v);
			}
			/**
			 * 将原本创建图形的方法放进Separate内执行
			 * boxShape.SetAsArray(vertices, vertexCount);
			 * fixtureDef.shape = boxShape;
			 * this.body.CreateFixture(fixtureDef)
			 */
			//把非凸多边形分离成凸多边形
			if (!this.separator)
				this.separator = new b2Separator();
			this.separator.Separate(this.body, this.fixtureDef, vertices);
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
		this.bodyDef.position.Set(bodyData.postion.x / B2dShell.CONVERSION, 
								  bodyData.postion.y / B2dShell.CONVERSION);
		//圆形写义
		var circleShape:b2CircleShape = new b2CircleShape(bodyData.radius / B2dShell.CONVERSION);
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
		//刚体参数
		this.bodyDef.userData.params = bodyData.params;
		//材质
		this.bodyDef.userData.texture = bodyData.texture;
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
		//如果没弧度则设置角度
		if (!bodyData.radian && bodyData.rotation)
			this.body.SetAngle(MathUtil.dgs2rds(bodyData.rotation));
		else if (bodyData.radian)
			this.body.SetAngle(bodyData.radian);
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
		this.buoyancyController.offset = offset / B2dShell.CONVERSION;
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
	 * 创建一个边界
	 * @param	left      左边界
	 * @param	top       上边界
	 * @param	right     右边界
	 * @param	bottom    下边界
	 * @param	thickness 厚度
	 */
	public function createOutSide(left:Number, top:Number, right:Number, bottom:Number, thickness:Number = 1):void
	{
		//上
		var bodyData:PolyData = new PolyData();
		bodyData.bodyType = b2Body.b2_staticBody;
		bodyData.density = .1;
		bodyData.friction = .1;
		bodyData.restitution = .1;
		bodyData.width = right - left + thickness * 2;
		bodyData.height = thickness;
		bodyData.postion = new Point(left + bodyData.width * .5 - thickness, top - bodyData.height * .5);
		bodyData.boxPoint = new Point(bodyData.width * .5, bodyData.height * .5);
		this.createPoly(bodyData);
		//下
		bodyData.width = right - left + thickness * 2;
		bodyData.height = thickness;
		bodyData.postion = new Point(left + bodyData.width * .5 - thickness, bottom + bodyData.height * .5);
		this.createPoly(bodyData);
		//左
		bodyData.width = thickness;
		bodyData.height = bottom - top + thickness * 2;
		bodyData.postion = new Point(left - bodyData.width * .5, top + bodyData.height * .5 - thickness);
		bodyData.boxPoint = new Point(bodyData.width * .5, bodyData.height * .5);
		this.createPoly(bodyData);
		//右
		bodyData.width = thickness;
		bodyData.height = bottom - top + thickness * 2;
		bodyData.postion = new Point(right + bodyData.width * .5, top + bodyData.height * .5 - thickness);
		this.createPoly(bodyData);
	}
	
	/**
	 * 创建圆环刚体
	 * @param	radius     环的半径
	 * @param	x 		   环的中心点x坐标
	 * @param	y		   环的中心点y坐标
	 * @param	segmentNum 线段的数量
	 */
	public function createCircleGround(radius:Number, x:Number, y:Number, segmentNum:Number = 36):void
	{
		//根据半径和个数计算线段的长度
		var round:Number = Math.PI * 2 * radius;
		var segmentlength:Number = round / segmentNum;
		for (var i:int = 1; i <= segmentNum; i += 1)
		{
			var bodyData:PolyData = new PolyData();
			bodyData.density = .1;
			bodyData.friction = .3;
			bodyData.restitution = .2;
			//计算每个线段的角度、坐标
			var angle:Number = i / segmentNum * Math.PI * 2;
			var bx:Number = radius * Math.cos(angle);
			var by:Number = radius * Math.sin(angle);
			bodyData.bodyType = b2Body.b2_staticBody;
			bodyData.rotation = MathUtil.rds2dgs(angle);
			bodyData.postion = new Point(bx + x, by + y);
			bodyData.width = 5;
			bodyData.height = segmentlength;
			bodyData.boxPoint = new Point(bodyData.width * .5, bodyData.height * .5);
			//创建有方向的矩形刚体，合成总的圆形刚体
			this.createPoly(bodyData);
		}
	}
	
	/**
	 * 验证多边形顶点是否合法
	 * @param	pathList  路径列表 二维数组[[x,y],[x,y]]
	 * @return	Object    返回状态 success 0为失败 1为成功，高宽、最左最右坐标、最上最下坐标。
	 */
	public function validatePolygon(pathList:Array):Object
	{
		if (!pathList) return { "success":0 };
		var sizeObj:Object = this.mathSizeByPath(pathList);
		var length:int = pathList.length;
		var b2Vec2Vector:Vector.<b2Vec2> = new Vector.<b2Vec2>();
		for (var i:int = 0; i < length; i += 1)
		{
			var posX:Number = pathList[i][0];
			var posY:Number = pathList[i][1];
			var b2:b2Vec2 = new b2Vec2(posX / B2dShell.CONVERSION, 
									   posY / B2dShell.CONVERSION);
			b2Vec2Vector.push(b2);
		}
		if (!this.separator)
			this.separator = new b2Separator();
		var status:int = this.separator.Validate(b2Vec2Vector);
		var o:Object;
		if (status == 2)
		{
			//不能为逆时针
			pathList.reverse();
		}
		else if (status != 0)
		{
			//不合法 有交叉
			o = { "success":0 };
			return o;
		}
		//成功
		o = { "success":1, 
			  "width":sizeObj.width, 
			  "height":sizeObj.height, 
			  "minX":sizeObj.minX, "maxX":sizeObj.maxX,
			  "minY":sizeObj.minY, "maxY":sizeObj.maxY };
		return o;
	}
	
	/**
	 * 根据坐标计算这个坐标形成的图形的尺寸高宽
	 * @param	path 路径列表 二维数组[[x,y],[x,y]]
	 * @return  尺寸对象
	 */
	public function mathSizeByPath(path:Array):Object
	{
		var minX:Number;
		var maxX:Number;
		var minY:Number;
		var maxY:Number;
		var length:int = path.length;
		for (var i:int = 0; i < length; i += 1) 
		{
			var posX:Number = path[i][0];
			var posY:Number = path[i][1];
			if (isNaN(minX))
				minX = posX;
			else if (posX < minX)
				minX = posX;
				
			if (isNaN(maxX))
				maxX = posX;
			else if (posX > maxX)
				maxX = posX;
				
			if (isNaN(minY))
				minY = posY;
			else if (posY < minY)
				minY = posY;
				
			if (isNaN(maxY))
				maxY = posY;
			else if (posY > maxY)
				maxY = posY;
		}
		var width:Number = (maxX - minX);
		var height:Number = (maxY - minY);
		return { "width":width, "height":height, 
				 "minX":minX, "maxX":maxX,
				 "minY":minY, "maxY":maxY };
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
	 * 缩放刚体
	 * @param	body      被缩放的刚体
	 * @param	sizeRatio 缩放比例
	 */
	public function resizeBody(body:b2Body, sizeRatio:Number):void
	{
		//静态刚体无法缩放
		if (!body || body.GetType() == b2Body.b2_staticBody) return;
		var shape:b2Shape = body.GetFixtureList().GetShape();
		var displayObj:DisplayObject = this.getDisplayObjectByBody(body);
		if (shape is b2CircleShape)
		{
			//圆形刚体直接缩放半径sizeRatio倍
			b2CircleShape(shape).SetRadius(b2CircleShape(shape).GetRadius() * sizeRatio);
		}
		else if (shape is b2PolygonShape)
		{
			 //遍历图形的所有顶点，将顶点到中心点的距离缩小为sizeRatio倍
			for each( var vec:b2Vec2 in b2PolygonShape(shape).GetVertices())
			{
				vec.Multiply(sizeRatio);
			}
		}
		if (displayObj)
		{
			//先保存之前的角度
			var rotation:Number = displayObj.rotation;
			displayObj.rotation = 0;
			displayObj.width *= sizeRatio;
			displayObj.height *= sizeRatio;
			displayObj.rotation = rotation;
		}
		body.SetAwake(true);
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
				dpObj.x = bb.GetPosition().x * B2dShell.CONVERSION;
				dpObj.y = bb.GetPosition().y * B2dShell.CONVERSION;
				dpObj.rotation = MathUtil.rds2dgs(bb.GetAngle());
			}
			this.bodyWrapAround(bb, this.wrapAroundRange);
		}
	}
	
	/**
	 * 设置刚体穿透屏幕
	 * @param	body    	需要穿透屏幕的刚体
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
				if (body.GetPosition().x * B2dShell.CONVERSION > range.right)
					body.SetPosition(new b2Vec2(range.left / B2dShell.CONVERSION, body.GetPosition().y));
				else if (body.GetPosition().x * B2dShell.CONVERSION < range.left)
					body.SetPosition(new b2Vec2(range.right / B2dShell.CONVERSION, body.GetPosition().y));
			}
			if (isVertical)
			{
				if (body.GetPosition().y * B2dShell.CONVERSION > range.bottom)
					body.SetPosition(new b2Vec2(body.GetPosition().x, range.top / B2dShell.CONVERSION));
				else if (body.GetPosition().y * B2dShell.CONVERSION < range.top)
					body.SetPosition(new b2Vec2(body.GetPosition().x, range.bottom / B2dShell.CONVERSION));
			}
		}
	}
	
	/**
	 * 更新刚体关节的状态 用于删除关节
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
			this.destroyJointDict[body] = null;
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
	 * 根据刚体上的显示对象的名字获取刚体数据
	 * @param	name   显示对象的名字
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
	/**
	 * 获取鼠标位置的刚体
	 * @param	includeStatic  是否包括静态刚体
	 * @return  鼠标位置的刚体
	 */
	private function getBodyAtMouse(includeStatic:Boolean = true):b2Body
	{
		// Make a small box.
		if (!this.stage || !this.mouseEnabled) return null;
		return this.getBodyByPostion(this.mouseXWorldPhys, this.mouseYWorldPhys, includeStatic);
	}
	
	/**
	 * 根据坐标返回刚体数据
	 * @param	x 				x位置（物理位置 非flash坐标位置）
	 * @param	y 				y位置（物理位置 非flash坐标位置）
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
	public function getDisplayObjectByBody(body:b2Body):DisplayObject
	{
		if (this.userDataHasDisplayObject(body))
			return body.GetUserData().dpObj;
		else
			return null;
	}
	
	/**
	 * 根据刚体获取userData
	 * @param	body  刚体
	 * @return  userData用户数据对象
	 */
	public function getUserDataByBody(body:b2Body):Object
	{
		if (body && body.GetUserData())
			return body.GetUserData();
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
			this.debugDraw.SetDrawScale(B2dShell.CONVERSION);
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
			this.destroyJointDict[body] = null;
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
			this.mouseXWorldPhys = this.stage.mouseX / B2dShell.CONVERSION;
			this.mouseYWorldPhys = this.stage.mouseY / B2dShell.CONVERSION;
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