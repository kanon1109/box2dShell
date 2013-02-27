package cn.geckos.box2dShell.engine
{
import Box2D.Collision.Shapes.b2CircleShape;
import Box2D.Collision.Shapes.b2PolygonShape;
import Box2D.Collision.Shapes.b2Shape;
import Box2D.Common.Math.b2Vec2;
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.b2BodyDef;
import Box2D.Dynamics.b2Fixture;
import Box2D.Dynamics.Joints.b2DistanceJoint;
import Box2D.Dynamics.Joints.b2DistanceJointDef;
import Box2D.Dynamics.Joints.b2FrictionJoint;
import Box2D.Dynamics.Joints.b2FrictionJointDef;
import Box2D.Dynamics.Joints.b2Joint;
import Box2D.Dynamics.Joints.b2PulleyJoint;
import Box2D.Dynamics.Joints.b2PulleyJointDef;
import Box2D.Dynamics.Joints.b2RevoluteJoint;
import Box2D.Dynamics.Joints.b2RevoluteJointDef;
import Box2D.Dynamics.Joints.b2WeldJoint;
import Box2D.Dynamics.Joints.b2WeldJointDef;
import cn.geckos.box2dShell.data.CircleData;
import cn.geckos.box2dShell.data.PolyData;
import cn.geckos.box2dShell.engine.B2dShell;
import cn.geckos.utils.MathUtil;
import com.adobe.serialization.json.JSON;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;
/**
 * ...Box2d解析器 
 * 可以将box2dshell内的数据转成json格式
 * 可以将json格式的box2d数据转换成 box2d对象。
 * @author ...Kanon
 */
public class Box2dParser 
{
	/**
	 * 解码 将字符串内容解码成box2d的内容
	 * @param	str JSON格式的字符串
	 * @param	b2dShell box2d外壳
	 * @return  显示格式对象列表
	 */
	public static function decode(str:String, b2dShell:B2dShell):Array
	{
		if (!str || str == "") return null;
		var arr:Array = Box2dParser.decodeBody(str, b2dShell);
		Box2dParser.decodeJoint(str, b2dShell);
		return arr;
	}
	
	/**
	 * 解码刚体
	 * @param	str JSON格式的字符串
	 * @param	b2dShell box2d外壳
	 * @return  刚体的显示对象列表
	 */
	public static function decodeBody(str:String, b2dShell:B2dShell):Array
	{
		if (!str || str == "") return null;
		var obj:Object = JSON.decode(str);
		var arr:Array = [];
		var body:b2Body;
		for (var key:String in obj.bodyData)
		{
			var o:Object = obj.bodyData[key];
			// 图形数据
			if (o && o.shape)
			{
				if (o.shape.type == "poly")
					body = Box2dParser.decodePolyBody(o.shape, b2dShell);
				else if (o.shape.type == "circle")
					body = Box2dParser.decodeCircleBody(o.shape, b2dShell);
				//显示对象
				body.SetAngle(MathUtil.dgs2rds(o.shape.rotation));
				if (body && 
					body.GetUserData() && 
					body.GetUserData().dpObj &&
					body.GetUserData().dpObj is DisplayObject)
				{
					var dpObj:DisplayObject = body.GetUserData().dpObj;
					try
					{
						//防止修改时间轴上的元件
						dpObj.name = o.shape.name;
					}
					catch (e:Error) { };
					arr.push(dpObj);
				}
			}
		}
		return arr;
	}
	
	/**
	 * 解码多边形刚体
	 * @param	shapeData 图形数据
	 * @param	b2dShell box2d外壳  
	 * @return  刚体
	 */
	public static function decodePolyBody(shapeData:Object, b2dShell:B2dShell):b2Body
	{
		var polyData:PolyData = new PolyData();
		var displayObject:Sprite = getSprite(shapeData.className);
		if (displayObject)
			polyData.displayObject = displayObject;
		polyData.bodyLabel = shapeData.bodyLabel;
		polyData.bodyType = shapeData.bodyType;
		polyData.width = shapeData.width;
		polyData.height = shapeData.height;
		polyData.postion = new Point(shapeData.postion.x, shapeData.postion.y);
		polyData.friction = shapeData.friction;
		polyData.density = shapeData.density;
		polyData.restitution = shapeData.restitution;
		if (shapeData.vertices)
			polyData.vertices = shapeData.vertices;
		return b2dShell.createPoly(polyData);
	}
	
	/**
	 * 解码圆形刚体
	 * @param	shapeData 图形数据
	 * @param	b2dShell box2d外壳  
	 * @return  刚体
	 */
	public static function decodeCircleBody(shapeData:Object, b2dShell:B2dShell):b2Body
	{
		var circleData:CircleData = new CircleData();
		var displayObject:Sprite = getSprite(shapeData.className);
		if (displayObject)
			circleData.displayObject = displayObject;
		circleData.bodyLabel = shapeData.bodyLabel;
		circleData.bodyType = shapeData.bodyType;
		circleData.radius = shapeData.radius;
		circleData.density = shapeData.density;
		circleData.friction = shapeData.friction;
		circleData.density = shapeData.density;
		circleData.restitution = shapeData.restitution;
		circleData.postion = new Point(shapeData.postion.x, shapeData.postion.y);
		return b2dShell.createCircle(circleData);
	}
	
	/**
	 * 解码关节
	 * @param	str  关节数据
	 * @param	b2dShell box2d外壳
	 * @return  显示格式对象列表
	 */
	public static function decodeJoint(str:String, b2dShell:B2dShell):Array
	{
		if (!str) return null;
		var obj:Object = JSON.decode(str);
		var arr:Array = [];
		for (var key:String in obj.jointData)
		{
			var o:Object = obj.jointData[key];
			if (o && o.joint)
			{
				if (o.joint.jointType == "revolute")
					Box2dParser.decodeRevoluteJoint(o.joint.jointData, b2dShell);
				if (o.joint.jointType == "distance")
					Box2dParser.decodeDistanceJoint(o.joint.jointData, b2dShell);
				if (o.joint.jointType == "friction")
					Box2dParser.decodeFrictionJoint(o.joint.jointData, b2dShell);
				if (o.joint.jointType == "pulley")
					Box2dParser.decodePulleyJoint(o.joint.jointData, b2dShell);
				if (o.joint.jointType == "weld")
					Box2dParser.decodeWeldJoint(o.joint.jointData, b2dShell);	
			}
		}
		return arr;
	}
	
	/**
	 * 滑轮关节解码
	 * @param	jointData  关节数据对象
	 * @param	b2dShell   box2d外壳
	 * @return  滑轮关节
	 */
	public static function decodePulleyJoint(jointData:Object, b2dShell:B2dShell):b2PulleyJoint
	{
		var pulleyJointDef:b2PulleyJointDef = new b2PulleyJointDef();
		var bodyA:b2Body;
		var bodyB:b2Body;
		if (jointData.bodyALabel == "b2_ground")
			bodyA = b2dShell.getGroundBody();
		else
			bodyA = b2dShell.getBodyByLabel(jointData.bodyALabel);
		if (jointData.bodyBLabel == "b2_ground")
			bodyB = b2dShell.getGroundBody();
		else
			bodyB = b2dShell.getBodyByLabel(jointData.bodyBLabel);
		var gaA:b2Vec2 = new b2Vec2(jointData.gaA.x, jointData.gaA.y);
		var gaB:b2Vec2 = new b2Vec2(jointData.gaB.x, jointData.gaB.y);
		var anchorA:b2Vec2 = new b2Vec2(jointData.anchorA.x, jointData.anchorA.y);
		var anchorB:b2Vec2 = new b2Vec2(jointData.anchorB.x, jointData.anchorB.y);
		var radio:Number = jointData.radio;
		pulleyJointDef.Initialize(bodyA, bodyB, gaA, gaB, anchorA, anchorB, radio);
		pulleyJointDef.lengthA = jointData.lengthA;
		pulleyJointDef.lengthB = jointData.lengthB;
		return b2dShell.world.CreateJoint(pulleyJointDef) as b2PulleyJoint;
	}
	
	
	/**
	 * 旋转关节解码
	 * @param	jointData 关节数据对象
	 * @param	b2dShell  box2d外壳
	 * @return  旋转关节
	 */
	public static function decodeRevoluteJoint(jointData:Object, b2dShell:B2dShell):b2RevoluteJoint
	{
		var revoluteJointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
		var bodyA:b2Body;
		var bodyB:b2Body;
		if (jointData.bodyALabel == "b2_ground")
			bodyA = b2dShell.getGroundBody();
		else
			bodyA = b2dShell.getBodyByLabel(jointData.bodyALabel);
		if (jointData.bodyBLabel == "b2_ground")
			bodyB = b2dShell.getGroundBody();
		else
			bodyB = b2dShell.getBodyByLabel(jointData.bodyBLabel);
		var anchor:b2Vec2 = new b2Vec2(jointData.anchor.x, jointData.anchor.y);
		revoluteJointDef.Initialize(bodyA, bodyB, anchor);
		revoluteJointDef.enableLimit = jointData.enableLimit;
		revoluteJointDef.lowerAngle = jointData.lowerAngle;
		revoluteJointDef.upperAngle = jointData.upperAngle;
		revoluteJointDef.maxMotorTorque = jointData.maxMotorTorque;
		revoluteJointDef.motorSpeed = jointData.motorSpeed;
		revoluteJointDef.enableMotor = jointData.enableMotor;
		return b2dShell.world.CreateJoint(revoluteJointDef) as b2RevoluteJoint;
	}
	
	/**
	 * 距离关节解码
	 * @param	o 距离关节数据对象
	 * @param	b2dShell  box2d外壳
	 * @return  距离关节
	 */
	public static function decodeDistanceJoint(jointData:Object, b2dShell:B2dShell):b2DistanceJoint
	{
		var distanceJointDef:b2DistanceJointDef = new b2DistanceJointDef();
		var bodyA:b2Body;
		var bodyB:b2Body;
		if (jointData.bodyALabel == "b2_ground")
			bodyA = b2dShell.getGroundBody();
		else
			bodyA = b2dShell.getBodyByLabel(jointData.bodyALabel);
		if (jointData.bodyBLabel == "b2_ground")
			bodyB = b2dShell.getGroundBody();
		else
			bodyB = b2dShell.getBodyByLabel(jointData.bodyBLabel);
		var anchorA:b2Vec2 = new b2Vec2(jointData.anchorA.x, jointData.anchorA.y);
		var anchorB:b2Vec2 = new b2Vec2(jointData.anchorB.x, jointData.anchorB.y);
		distanceJointDef.Initialize(bodyA, bodyB, anchorA, anchorB);
		distanceJointDef.dampingRatio = jointData.dampingRatio;
		distanceJointDef.frequencyHz = jointData.frequencyHz;
		distanceJointDef.length = jointData.length;
		return b2dShell.world.CreateJoint(distanceJointDef) as b2DistanceJoint;
	}
	
	/**
	 * 摩擦关节解码
	 * @param	o 摩擦关节数据对象
	 * @param	b2dShell  box2d外壳
	 * @return  摩擦关节
	 */
	public static function decodeFrictionJoint(jointData:Object, b2dShell:B2dShell):b2FrictionJoint
	{
		var frictionJointDef:b2FrictionJointDef = new b2FrictionJointDef();
		var bodyA:b2Body;
		var bodyB:b2Body;
		if (jointData.bodyALabel == "b2_ground")
			bodyA = b2dShell.getGroundBody();
		else
			bodyA = b2dShell.getBodyByLabel(jointData.bodyALabel);
		if (jointData.bodyBLabel == "b2_ground")
			bodyB = b2dShell.getGroundBody();
		else
			bodyB = b2dShell.getBodyByLabel(jointData.bodyBLabel);
		var anchor:b2Vec2 = new b2Vec2(jointData.anchor.x, jointData.anchor.y);
		frictionJointDef.Initialize(bodyA, bodyB, anchor);
		frictionJointDef.maxForce = jointData.maxForce;
		frictionJointDef.maxTorque = jointData.maxTorque;
		return b2dShell.world.CreateJoint(frictionJointDef) as b2FrictionJoint;
	}
	
	
	/**
	 * 焊接关节解码
	 * @param	o 焊接关节数据对象
	 * @param	b2dShell  box2d外壳
	 * @return  焊接关节
	 */
	public static function decodeWeldJoint(jointData:Object, b2dShell:B2dShell):b2WeldJoint
	{
		var weldJointDef:b2WeldJointDef = new b2WeldJointDef();
		var bodyA:b2Body;
		var bodyB:b2Body;
		if (jointData.bodyALabel == "b2_ground")
			bodyA = b2dShell.getGroundBody();
		else
			bodyA = b2dShell.getBodyByLabel(jointData.bodyALabel);
		if (jointData.bodyBLabel == "b2_ground")
			bodyB = b2dShell.getGroundBody();
		else
			bodyB = b2dShell.getBodyByLabel(jointData.bodyBLabel);
		var anchor:b2Vec2 = new b2Vec2(jointData.anchor.x, jointData.anchor.y);
		weldJointDef.Initialize(bodyA, bodyB, anchor);
		return b2dShell.world.CreateJoint(weldJointDef) as b2WeldJoint;
	}
	
 	/**
	 * 编码 将box2d world内的数据保存为字符串形式
 	 * @param	world
	 * @return json格式的字符串
	 */
	public static function encode(b2dShell:B2dShell):String
	{
		var obj:Object = { };
		var arr:Array = b2dShell.getBodyList();
		if (!arr || arr.length == 0) return "";
		var length:int = arr.length;
		obj.bodyData = { };
		for (var i:int = 0; i < length; i += 1)
		{
			obj.bodyData["data" + i] = { };
			var o:Object = obj.bodyData["data" + i];
			var body:b2Body = arr[i];
			o.shape = Box2dParser.encodeBody(body);
		}
		
		var jointAry:Array = b2dShell.getJointList();
		length = jointAry.length;
		obj.jointData = { };
		for (i = 0; i < length; i += 1)
		{
			obj.jointData["data" + i] = { };
			o = obj.jointData["data" + i];
			var joint:b2Joint = jointAry[i];
			o.joint = Box2dParser.encodeJoint(joint, b2dShell);
		}
		return JSON.encode(obj);
	}
	
	/**
	 * 编码关节
	 * @param	joint 关节
	 * @param	b2dShell box2d外壳
	 * @return  关节对象
	 */
	public static function encodeJoint(joint:b2Joint, b2dShell:B2dShell):Object
	{
		var o:Object = { };
		if (joint is b2RevoluteJoint)
		{
			//编码旋转关节
			o.jointType = "revolute";
			o.jointData = Box2dParser.encodeRevoluteJoint(b2RevoluteJoint(joint), b2dShell);
		}
		else if (joint is b2DistanceJoint)
		{
			//编码距离关节
			o.jointType = "distance";
			o.jointData = Box2dParser.encodeDistanceJoint(b2DistanceJoint(joint), b2dShell);
		}
		else if (joint is b2FrictionJoint)
		{
			//编码摩擦关节
			o.jointType = "friction";
			o.jointData = Box2dParser.encodeFrictionJoint(b2FrictionJoint(joint), b2dShell);
		}
		else if (joint is b2PulleyJoint)
		{
			//编码滑轮关节
			o.jointType = "pulley";
			o.jointData = Box2dParser.encodePulleyJoint(b2PulleyJoint(joint), b2dShell);
		}
		else if (joint is b2WeldJoint)
		{
			//编码焊接关节
			o.jointType = "Weld";
			o.jointData = Box2dParser.encodeWeldJoint(b2WeldJoint(joint), b2dShell);
		}
		return o;
	}
	
	/**
	 * 编码焊接关节
	 * @param	b2WeldJoint
	 * @param	b2dShell
	 */
	public static function encodeWeldJoint(joint:b2WeldJoint, b2dShell:B2dShell):Object 
	{
		var o:Object = { };
		var nameObj:Object = getJointBodyName(joint, b2dShell);
		o.bodyALabel = nameObj.bodyALabel;
		o.bodyBLabel = nameObj.bodyBLabel;
		o.bodyAName = nameObj.bodyAName;
		o.bodyBName = nameObj.bodyBName;
		o.anchor = { "x":joint.GetAnchorA().x, "y":joint.GetAnchorA().y };
		return o;
	}
	
	/**
	 * 编码摩擦关节
	 * @param	joint 摩擦关节
	 * @return  摩擦关节对象
	 */
	public static function encodeFrictionJoint(joint:b2FrictionJoint, b2dShell:B2dShell):Object
	{
		var o:Object = { };
		var nameObj:Object = getJointBodyName(joint, b2dShell);
		o.bodyALabel = nameObj.bodyALabel;
		o.bodyBLabel = nameObj.bodyBLabel;
		o.bodyAName = nameObj.bodyAName;
		o.bodyBName = nameObj.bodyBName;
		o.anchor = { "x":joint.GetAnchorA().x, "y":joint.GetAnchorA().y };
		o.maxForce = joint.GetMaxForce();
		o.maxTorque = joint.GetMaxTorque();
		return o;
	}
	
	/**
	 * 编码距离关节
	 * @param	joint 距离关节
	 * @return  距离关节对象
	 */
	public static function encodeDistanceJoint(joint:b2DistanceJoint, b2dShell:B2dShell):Object
	{
		var o:Object = { };
		var nameObj:Object = getJointBodyName(joint, b2dShell);
		o.bodyALabel = nameObj.bodyALabel;
		o.bodyBLabel = nameObj.bodyBLabel;
		o.bodyAName = nameObj.bodyAName;
		o.bodyBName = nameObj.bodyBName;
		o.anchorA = { "x":joint.GetAnchorA().x, "y":joint.GetAnchorA().y };
		o.anchorB = { "x":joint.GetAnchorB().x, "y":joint.GetAnchorB().y };
		o.dampingRatio = joint.GetDampingRatio();
		o.frequencyHz = joint.GetFrequency();
		o.length = joint.GetLength();
		return o;
	}
	
	/**
	 * 编码旋转关节
	 * @param	joint 旋转关节
	 * @return  旋转关节对象
	 */
	public static function encodeRevoluteJoint(joint:b2RevoluteJoint, b2dShell:B2dShell):Object
	{
		var o:Object = { };
		var nameObj:Object = getJointBodyName(joint, b2dShell);
		o.bodyALabel = nameObj.bodyALabel;
		o.bodyBLabel = nameObj.bodyBLabel;
		o.bodyAName = nameObj.bodyAName;
		o.bodyBName = nameObj.bodyBName;
		o.anchor = { "x":joint.GetAnchorA().x, "y":joint.GetAnchorA().y };
		o.enableLimit = joint.IsLimitEnabled();
		o.lowerAngle = joint.GetLowerLimit();
		o.upperAngle = joint.GetUpperLimit();
		o.maxMotorTorque = joint.GetMotorTorque();
		o.motorSpeed = joint.GetMotorSpeed();
		o.enableMotor = joint.IsMotorEnabled();
		return o;
	}
	
	
	/**
	 * 编码滑轮关节
	 * @param	joint 滑轮关节
	 * @return  滑轮关节对象
	 */
	public static function encodePulleyJoint(joint:b2PulleyJoint, b2dShell:B2dShell):Object
	{
		var o:Object = { };
		var nameObj:Object = getJointBodyName(joint, b2dShell);
		o.bodyALabel = nameObj.bodyALabel;
		o.bodyBLabel = nameObj.bodyBLabel;
		o.bodyAName = nameObj.bodyAName;
		o.bodyBName = nameObj.bodyBName;
		o.anchorA = { "x":joint.GetAnchorA().x, "y":joint.GetAnchorA().y };
		o.anchorB = { "x":joint.GetAnchorB().x, "y":joint.GetAnchorB().y };
		o.gaA = { "x":joint.GetGroundAnchorA().x, "y":joint.GetGroundAnchorA().y };
		o.gaB = { "x":joint.GetGroundAnchorB().x, "y":joint.GetGroundAnchorB().y };
		
		o.radio = joint.GetRatio();
		o.lengthA = joint.GetLength1();
		o.lengthB = joint.GetLength1();
		return o;
	}
	
	/**
	  * 获取关节上刚体的名字
	 * @param	joint 关节
	 * @param	b2dShell 
	 * @return  刚体名字对象
	 */
	private static function getJointBodyName(joint:b2Joint, b2dShell:B2dShell):Object
	{
		var name:String = "";
		var userData:Object;
		var o:Object = { };
		if (joint.GetBodyA() == b2dShell.world.GetGroundBody())
		{
			name = "b2_ground"; 
			o.bodyALabel = "b2_ground";
		}
		else
		{
			//获取关节上刚体的显示对象
			userData = joint.GetBodyA().GetUserData();
			if (userData.dpObj && userData.dpObj is DisplayObject)
				name = userData.dpObj.name;
			if (userData.bodyLabel)
				o.bodyALabel = userData.bodyLabel;
		}
		o.bodyAName = name;
		if (joint.GetBodyB() == b2dShell.world.GetGroundBody())
		{
			name = "b2_ground"; 
			o.bodyBLabel = "b2_ground";
		}
		else
		{
			userData = joint.GetBodyB().GetUserData();
			if (userData.dpObj && userData.dpObj is DisplayObject)
				name = userData.dpObj.name;
			if (userData.bodyLabel)
				o.bodyBLabel = userData.bodyLabel;
		}
		o.bodyBName = name;
		return o;
	}
	
	
	/**
	 * 一个刚体的编码
	 * @param	body 刚体
	 * @return  对象
	 */
	public static function encodeBody(body:b2Body):Object
	{
		if (!body) return null;
		var shapeObj:Object = { };
		//所有的刚体数据
		var bodyDef:b2BodyDef = body.GetDefinition();
		//所有的图形数据
		var fixture:b2Fixture = body.GetFixtureList();
		if (!fixture) return null;
		//所有的图形
		var shape:b2Shape = fixture.GetShape();
		if (body.GetUserData())
		{
			var userData:Object = body.GetUserData();
			if (userData.dpObj && userData.dpObj is DisplayObject)
			{
				var dpObj:DisplayObject = userData.dpObj as DisplayObject;
				var className:String = getQualifiedClassName(dpObj);
				shapeObj.className = className;
			}
			if (userData.bodyLabel)
				shapeObj.bodyLabel = userData.bodyLabel;
			shapeObj.name = userData.name;
			shapeObj.bodyType = bodyDef.type;
			shapeObj.postion = { "x":userData.x, "y":userData.y };
			shapeObj.friction = fixture.GetFriction();
			shapeObj.density = fixture.GetDensity();
			shapeObj.restitution = fixture.GetRestitution();
			shapeObj.rotation = MathUtil.rds2dgs(body.GetAngle());
			
			if (shape is b2PolygonShape)
			{
				shapeObj.type = "poly";
				shapeObj.width = userData.width;
				shapeObj.height = userData.height;
				var vector:Vector.<b2Vec2> = b2PolygonShape(shape).GetVertices() as Vector.<b2Vec2>
				var verLength:int = vector.length;
				shapeObj.vertices = [];
				//元素内部顶点坐标
				for (var j:int = 0; j < verLength; j += 1)
				{
					var x:Number = vector[j].x * B2dShell.CONVERSION;
					var y:Number = vector[j].y * B2dShell.CONVERSION;
					shapeObj.vertices[j] = [x, y];
				}
			}
			else if (shape is b2CircleShape)
			{
				shapeObj.type = "circle";
				shapeObj.radius = userData.width * .5;
			}
		}
		return shapeObj;
	}
	
	/**
	 * 获取sprite
	 * @param	name
	 * @return  sprite
	 */
	private static function getSprite(name:String):Sprite
	{
		if (!name || name == "") return null;
		try
		{
			var MyClass:Class = getDefinitionByName(name) as Class;
			return Sprite(new MyClass());
		}
		catch (e:Error) 
		{
			trace("刚体对象找不到相对应于库内的" + name + "链接");
		};
		return null;
	}
}
}
