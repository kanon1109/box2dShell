package  
{
import Box2D.Common.Math.b2Vec2;
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.Joints.b2WeldJointDef;
import cn.geckos.box2dShell.model.CircleData;
import cn.geckos.box2dShell.model.PolyData;
import cn.geckos.box2dShell.core.B2dParser;
import cn.geckos.box2dShell.core.B2dShell;
import cn.geckos.box2dShell.utils.B2dUtil;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.GraphicsPathCommand;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.getDefinitionByName;
/**
 * ...测试B2dShell 和 B2dParser
 * @author Kanon
 */
public class Test extends Sprite 
{
	private var b2dShell:B2dShell;
	private var boxMc:Sprite;
	private var circleMc:Sprite;
	private var floorMc:Sprite;
	private var body:b2Body;
	public function Test() 
	{
		this.b2dShell = new B2dShell();
		this.b2dShell.timeStep = 1.0 / 30.0;
		this.b2dShell.velocityIterations = 10;
		this.b2dShell.positionIterations = 10;
		this.b2dShell.createWorld(0, 10, stage, true);
		this.b2dShell.drawDebug(this);
		this.floorMc = this.getChildByName("floor_mc") as Sprite;
		
		var polyData:PolyData = new PolyData();
		polyData.friction = 1;
		polyData.density = 1;
		polyData.restitution = .9;
		polyData.displayObject = this.floorMc;
		polyData.boxPoint = new Point(this.floorMc.width *.5, this.floorMc.height *.5);
		polyData.width = this.floorMc.width;
		polyData.height = this.floorMc.height;
		polyData.bodyLabel = this.floorMc.name;
		polyData.postion = new Point(this.floorMc.x, this.floorMc.y);
		polyData.bodyType = b2Body.b2_staticBody;
		this.b2dShell.createPoly(polyData);
		this.b2dShell.mouseEnabled = true;
		
		this.createRect(100, 100);
		this.createCircle();
		this.createPoly();
		
		//this.b2dShell.createOutSide(100, 100, 110, 130, 1);
		//this.b2dShell.createOutSide(0, 0, 550, 400, 30);
		this.b2dShell.createCircleGround(150, stage.stageWidth * .5, stage.stageHeight * .5 , 36);
		
		stage.addEventListener(MouseEvent.CLICK, mouseClickHandler);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		
		//trace(this.getChildByName("stage"));
	}
	
	private function mouseClickHandler(event:MouseEvent):void 
	{
		//一个对变形刚体的数据
		var str:String = '{"bodyData":{"data0":{"shape":{"bodyType":2,"type":"poly","rotation":0,"friction":0,"vertices":[[-57.5,-79.5],[-3.5,-74.5],[57.5,-67.5],[89.5,-22.5],[89.5,28.5],[90.5,78.5],[37.5,79.5],[-12.5,79.5],[-62.5,73.5],[-90.5,30.5],[-90.5,-19.5],[-36.5,-6.5],[16.5,-1.5],[27.5,-50.5],[-22.5,-60.5]],"density":0.1,"name":"instance171","bodyLabel":"instance171","restitution":0,"width":181,"postion":{"x":100,"y":100},"height":159}}}}';
		var arr:Array = B2dParser.decode(str, this.b2dShell);
		//trace(arr.length)
		var length:int = arr.length;
		for (var i:int = 0; i < length; i += 1)
		{
			var o:b2Body = arr[i];
			//trace("bodyLabel", o.GetUserData().bodyLabel)
		}
		//this.createRect(mouseX, mouseY);
		//this.createPolyByBitmap();
		var body:b2Body = this.b2dShell.getBodyByPostion(mouseX / B2dShell.CONVERSION, mouseY / B2dShell.CONVERSION);
		trace("body", body);
		this.b2dShell.resizeBody(body, .9);
		//去掉注释你将看到B2dParser解析的this.b2dShell数据
		//trace(B2dParser.encode(this.b2dShell));
	}
	
	private function keyDownHandler(event:KeyboardEvent):void 
	{
		switch(event.keyCode)
		{
			case Keyboard.SPACE:
					//var bodyA:b2Body = this.createPoly();
					this.body = this.createCircle();
					//this.createJoint(bodyA, bodyB);
				break;
			case Keyboard.D:
					//销毁有显示对象装饰的刚体 box2d的debug显示对象除外
					this.b2dShell.destroyBody(this.b2dShell.getBodyByPostion(mouseX, mouseY));
					this.b2dShell.destroyBody(this.b2dShell.getBodyByLabel("instance171"));
				break;
			case Keyboard.LEFT:
				if (this.body)
				{
					trace(this.body.GetLinearVelocity().x - 6);
					if (this.body.GetLinearVelocity().x - 6 > -6)
						this.body.SetLinearVelocity(new b2Vec2(this.body.GetLinearVelocity().x - 6, 0));
					else
						this.body.SetLinearVelocity(new b2Vec2( -6, 0));
				}
				break;
			case Keyboard.RIGHT:
				if (this.body)
					this.body.SetLinearVelocity(new b2Vec2(this.body.GetLinearVelocity().x + 3, 0));
				break;
		}
	}
	
	/**
	 * 使用shell创建的刚体对象
	 * @return
	 */
	private function createRect(x:Number, y:Number):b2Body
	{
		this.boxMc = new Box();
		this.addChild(this.boxMc);
		this.boxMc.x = x;
		this.boxMc.y = y;
		var polyData:PolyData = new PolyData();
		polyData.friction = 1;
		polyData.density = 1;
		polyData.restitution = .1;
		polyData.displayObject = this.boxMc;
		polyData.bodyLabel = this.boxMc.name;
		polyData.boxPoint = new Point(this.boxMc.width / 2, this.boxMc.height / 2);
		polyData.width = this.boxMc.width;
		polyData.height = this.boxMc.height;
		polyData.postion = new Point(this.boxMc.x, this.boxMc.y);
		polyData.bodyType = b2Body.b2_dynamicBody;
		return this.b2dShell.createPoly(polyData);
	}
	
	/**
	 * 使用shell创建的刚体对象
	 * @return
	 */
	private function createPoly():b2Body
	{
		this.boxMc = new Poly();
		this.addChild(this.boxMc);
		this.boxMc.x = Math.random() * stage.stageWidth;
		this.boxMc.y = Math.random() * stage.stageHeight;
		var polyData:PolyData = new PolyData();
		polyData.friction = 1;
		polyData.density = 1;
		polyData.restitution = .1;
		polyData.vertices = [[ -15.95, -33.5], [33.55, -33.5], [33.55, -13.25], [7.05, 33.5], [ -33.7, 33.5], [ -33.55, -2.75]];
		polyData.displayObject = this.boxMc;
		polyData.boxPoint = new Point(this.boxMc.width / 2, this.boxMc.height / 2);
		polyData.width = this.boxMc.width;
		polyData.height = this.boxMc.height;
		polyData.postion = new Point(this.boxMc.x, this.boxMc.y);
		polyData.bodyType = b2Body.b2_dynamicBody;
		polyData.bodyLabel = this.boxMc.name;
		return this.b2dShell.createPoly(polyData);
	}
	
	/**
	 * 使用shell创建的刚体对象
	 * @return
	 */
	private function createCircle():b2Body
	{
		this.circleMc = new Cirlce();
		this.addChild(this.circleMc);
		this.circleMc.x = Math.random() * stage.stageWidth;
		this.circleMc.y = Math.random() * stage.stageHeight;
		var circleData:CircleData = new CircleData();
		circleData.radius = this.circleMc.width / 2;
		circleData.friction = 1;
		circleData.density = 1;
		circleData.restitution = .1;
		circleData.displayObject = this.circleMc;
		circleData.postion = new Point(this.circleMc.x, this.circleMc.y);
		circleData.bodyType = b2Body.b2_dynamicBody;
		circleData.bodyLabel = this.circleMc.name;
		return this.b2dShell.createCircle(circleData);
	}
	
	/**
	 * 使用shell创建的刚体对象
	 * @return
	 */
	private function createPolyByBitmap():b2Body
	{
		var polyData:PolyData = new PolyData();
		polyData.friction = 1;
		polyData.density = 1;
		polyData.restitution = .1;
		polyData.vertices = [[ -15.95, -33.5], [33.55, -33.5], [33.55, -13.25], [7.05, 33.5], [ -33.7, 33.5], [ -33.55, -2.75]];
		var data:Vector.<Number> = new Vector.<Number>();
		var commands:Vector.<int> = new Vector.<int>();
		commands.push(GraphicsPathCommand.MOVE_TO);
		var length:int = polyData.vertices.length;
		for (var i:int = 0; i < length; i += 1) 
		{
			var posX:Number = polyData.vertices[i][0];
			var posY:Number = polyData.vertices[i][1];
			data.push(posX);
			data.push(posY);
			if (i > 0)
				commands.push(GraphicsPathCommand.LINE_TO);
		}
		//一定要保存起点才能封闭整个路径
		data.push(polyData.vertices[0][0]);
		data.push(polyData.vertices[0][1]);
		commands.push(GraphicsPathCommand.LINE_TO);
		
		var o:Object = B2dUtil.mathSizeByPath(polyData.vertices);
		var MyClass:Class = getDefinitionByName("T" + int(Math.random() * 5 + 1)) as Class;
		var bitmap:BitmapData = new MyClass() as BitmapData;
		polyData.displayObject = this.createBitmapFill(bitmap, commands, data);
		this.addChild(polyData.displayObject)
		polyData.postion = new Point(o.width / 2, o.height / 2);
		polyData.boxPoint = new Point(o.width / 2, o.height / 2);
		polyData.width = o.width;
		polyData.height = o.height;
		polyData.bodyType = b2Body.b2_dynamicBody;
		polyData.bodyLabel = "bitmapBody";
		return this.b2dShell.createPoly(polyData);
	}
	
	
	/**
	 * 创建位图填充
	 * @return
	 */
	private function createBitmapFill(bitmap:BitmapData, commands:Vector.<int>, data:Vector.<Number>):DisplayObject
	{
		var spt:Sprite = new Sprite();
		spt.graphics.lineStyle(3, 0x000000);
		spt.graphics.beginBitmapFill(bitmap);
		spt.graphics.drawPath(commands, data);
		spt.graphics.endFill();
		return spt;
	}
	
	/**
	 * 建立关节
	 * @param	bodyA 第一个刚体
	 * @param	bodyB 第二个刚体
	 */
	private function createJoint(bodyA:b2Body, bodyB:b2Body):void
	{
		/**
		 * 距离关节
		 */
		/*var distanceJointDef:b2DistanceJointDef = new b2DistanceJointDef();
		distanceJointDef.Initialize(bodyA, bodyB, bodyA.GetWorldCenter(), bodyB.GetWorldCenter());
		distanceJointDef.collideConnected = true;
		//阻尼比率
		distanceJointDef.dampingRatio = 0;
		this.b2dShell.world.CreateJoint(distanceJointDef);*/
		
		/**
		 * 摩擦关节
		 */
		/*var frictionJointDef:b2FrictionJointDef = new b2FrictionJointDef();
		frictionJointDef.Initialize(this.b2dShell.getGroundBody(), bodyB, bodyB.GetWorldCenter());
		frictionJointDef.collideConnected = true;
		this.b2dShell.world.CreateJoint(frictionJointDef);*/
		
		/**
		 * 旋转关节
		 */
		/*var revoluteJointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
		revoluteJointDef.Initialize(this.b2dShell.getGroundBody(), bodyA, bodyA.GetWorldCenter());
		revoluteJointDef.enableLimit = true;
		revoluteJointDef.lowerAngle = -0.5 * b2Settings.b2_pi; // -90 degrees
		revoluteJointDef.upperAngle = 0.5 * b2Settings.b2_pi; // 90 degrees
		revoluteJointDef.maxMotorTorque = 10;
		revoluteJointDef.motorSpeed = 10.0;
		revoluteJointDef.enableMotor = true;
		var revoluteJoint:b2RevoluteJoint = this.b2dShell.world.CreateJoint(revoluteJointDef) as b2RevoluteJoint;
		*/
		/**
		 * 移动关节
		 */
		/*var prismaticJointDef:b2PrismaticJointDef = new b2PrismaticJointDef();
		var axis:b2Vec2 = new b2Vec2(0, 1);
		prismaticJointDef.Initialize(bodyA, bodyB, bodyB.GetWorldCenter(), axis);
		prismaticJointDef.upperTranslation = -5.0;
		prismaticJointDef.lowerTranslation  = 2.5;
		//prismaticJointDef.enableLimit = true;
		prismaticJointDef.maxMotorForce = 1.0;
		prismaticJointDef.motorSpeed = 0.0;
		prismaticJointDef.enableMotor = true;
		var prismaticJoint:b2PrismaticJoint = this.b2dShell.world.CreateJoint(prismaticJointDef) as b2PrismaticJoint;*/
		
		/**
		 * 滑轮关节
		 */
		/*var pulleyJointDef:b2PulleyJointDef = new b2PulleyJointDef();
		var gaA:b2Vec2 = new b2Vec2(bodyA.GetWorldCenter().x, bodyA.GetWorldCenter().y - 10);
		var gaB:b2Vec2 = new b2Vec2(bodyB.GetWorldCenter().x, bodyB.GetWorldCenter().y - 10);
		var radio:Number = 2;
		pulleyJointDef.Initialize(bodyA, bodyB, gaA, gaB, bodyA.GetWorldCenter(), bodyB.GetWorldCenter(), radio);
		this.b2dShell.world.CreateJoint(pulleyJointDef);*/
		
		/**
		 * 齿轮关节
		 */
		/*var grearJointDef:b2GearJointDef = new b2GearJointDef();
		grearJointDef.bodyA = bodyA;
		grearJointDef.bodyB = bodyB;
		grearJointDef.joint1 = revoluteJoint;
		grearJointDef.joint2 = prismaticJoint;
		grearJointDef.ratio = 2.0 * b2Settings.b2_pi / (300 / 30);
		this.b2dShell.world.CreateJoint(grearJointDef);*/
		
		/**
		 * 线关节 比移动关节多一个角度
		 */
		/*var lineJointDef:b2LineJointDef = new b2LineJointDef();
		var axis:b2Vec2 = new b2Vec2(1, 0);
		lineJointDef.Initialize(this.b2dShell.world.GetGroundBody(), bodyB, bodyB.GetWorldCenter(), axis);
		lineJointDef.upperTranslation = -5.0;
		lineJointDef.lowerTranslation  = 2.5;
		//lineJointDef.enableLimit = true;
		lineJointDef.maxMotorForce = 1.0;
		lineJointDef.motorSpeed = 0.0;
		lineJointDef.enableMotor = true;
		var lineJoint:b2LineJointDef = this.b2dShell.world.CreateJoint(lineJointDef) as b2LineJointDef;*/
		
		/**
		 * 焊接关节
		 */
		var weldJointDef:b2WeldJointDef = new b2WeldJointDef();
		var anchor:b2Vec2 = new b2Vec2(bodyB.GetWorldCenter().x, bodyB.GetWorldCenter().y);
		weldJointDef.Initialize(bodyA, bodyB, anchor);
		this.b2dShell.world.CreateJoint(weldJointDef);
	}
	
	private function enterFrameHandler(event:Event):void 
	{
		this.b2dShell.render();
		/*var arr:Array = this.b2dShell.getBodyList();
		for each (var body:b2Body in arr) 
		{
			var velocity:b2Vec2 = body.GetLinearVelocity();
			//单位化刚体速度，只保留速度的方向
			velocity.Normalize();
			//设置刚体速度的大小为speed，因为是在ENTER_FRAME事件处理器里实时更新
			//所以我们看不到刚体速度的减慢
			velocity.Multiply(.7);
		}*/
	}
	
}
}