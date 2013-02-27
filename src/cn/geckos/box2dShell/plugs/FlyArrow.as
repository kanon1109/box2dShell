package cn.geckos.box2dShell.plugs 
{
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.b2PreSolveEvent;
import Box2D.Dynamics.b2World;
import Box2D.Dynamics.Joints.b2WeldJointDef;
import cn.geckos.box2dShell.data.PolyData;
import cn.geckos.box2dShell.engine.B2dShell;
import cn.geckos.utils.MathUtil;
import flash.display.DisplayObject;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.utils.Dictionary;
/**
 * ...飞行箭头扩展
 * @author Kanon
 */
public class FlyArrow 
{
	//箭头标签
	private static const ARROW_LABEL:String = "arrow";
	//外部容器对象
	private var _b2dShell:B2dShell;
	private var arrowDict:Dictionary;
	private var contactDict:Dictionary;
	public function FlyArrow(b2dShell:B2dShell) 
	{
		this.arrowDict = new Dictionary();
		this._b2dShell = b2dShell;
	}
	
	/**
	 * 创建箭头
	 * @param	sx     	  起始位置x
	 * @param	sy    	  起始位置y
	 * @param	rotation  起始角度
	 * @param	speed 	  飞行速度
	 * @param	source 	  显示对象资源
	 * @param	vertices  箭头刚体顶点列表 是个二维数组存放顶点位置
	 */
	public function create(sx:Number, sy:Number, rotation:Number, speed:Number, source:DisplayObject = null, vertices:Array = null):b2Body
	{
		if (!this.b2dShell || !this.arrowDict) return null;
		var polyData:PolyData = new PolyData();
		if (!vertices)
			polyData.vertices = [[ -54, 0], [ -23, -3], [ -5, 0], [ -23, 3]];
		else
			polyData.vertices = vertices;
		polyData.density = 1;
		polyData.friction = .5;
		polyData.restitution = .5;
		polyData.postion = new Point(sx, sy);
		polyData.rotation = rotation;
		polyData.bodyType = b2Body.b2_dynamicBody;
		polyData.bodyLabel = "arrow";
		polyData.bullet = true;
		polyData.displayObject = source;
		polyData.params = { "freeFlight":false };
		var body:b2Body = this.b2dShell.createPoly(polyData);
		var angle:Number = MathUtil.dgs2rds(rotation);
		var vx:Number = Math.cos(angle) * speed;
		var vy:Number = Math.sin(angle) * speed;
		var dispatcher:EventDispatcher = new EventDispatcher();
		body.SetEventDispatcher(dispatcher);
		body.GetEventDispatcher().addEventListener(b2World.PRESOLVE, preSolveListener);
		this.b2dShell.setLinearVelocity(body, vx, vy);
		this.arrowDict[body] = body;
		return body;
	}
	
	/**
	 * 碰撞消息
	 * @param	event
	 */
	private function preSolveListener(event:b2PreSolveEvent):void 
	{
		if (event.contact.IsTouching())
		{
			var bodyA:b2Body = event.contact.GetFixtureA().GetBody();
			var bodyB:b2Body = event.contact.GetFixtureB().GetBody();
			this.removeSlowArrowStatus(bodyA);
			this.removeSlowArrowStatus(bodyB);
			this.setArrowContactStatus(bodyA, bodyB);
			this.removeArrowBodyStatus(bodyA);
			this.removeArrowBodyStatus(bodyB);
		}
	}
	
	/**
	 * 删除慢速度的箭头刚体
	 * @param	body  箭头刚体
	 */
	private function removeSlowArrowStatus(body:b2Body):void
	{
		//最小能刺入刚体的速度
		var minVelocity:int = 5;
		var userData:Object = body.GetUserData();
		if (userData && 
			userData.bodyLabel == ARROW_LABEL && 
			body.GetLinearVelocity().x < minVelocity && 
			body.GetLinearVelocity().y < minVelocity)
		{
			userData.params.freeFlight = true;
			body.SetBullet(false);
			this.removeBodyDispatcher(body, preSolveListener);
			delete this.arrowDict[body];
		}
	}
	
	/**
	 * 设置箭头刚体碰撞状态
	 * @param	body  箭头刚体
	 */
	protected function setArrowContactStatus(bodyA:b2Body, bodyB:b2Body):void
	{
		var userDataA:Object = bodyA.GetUserData();
		var userDataB:Object = bodyB.GetUserData();
		if (userDataA && userDataA.bodyLabel == ARROW_LABEL && 
			userDataB && userDataB.bodyLabel == ARROW_LABEL)
		{
			this.b2dShell.destroyBodyAllJoint(bodyA);
			this.b2dShell.destroyBodyAllJoint(bodyB);
		}
		var weldJointDef:b2WeldJointDef;
		if (this.contactDict)
		{
			for each (var label:String in this.contactDict) 
			{
				if (userDataA.bodyLabel == label && 
					userDataB.bodyLabel == ARROW_LABEL)
				{
					if (!userDataB.params.freeFlight) 
					{
						weldJointDef = new b2WeldJointDef();
						weldJointDef.Initialize(bodyB, bodyA, bodyA.GetWorldCenter());
						bodyB.GetWorld().CreateJoint(weldJointDef);
					}
				}
				if (userDataA.bodyLabel == ARROW_LABEL && 
					userDataB.bodyLabel == label)
				{
					if (!userDataA.params.freeFlight) 
					{
						weldJointDef = new b2WeldJointDef();
						weldJointDef.Initialize(bodyA, bodyB, bodyB.GetWorldCenter());
						bodyA.GetWorld().CreateJoint(weldJointDef);
					}
				}
			}
		}
		else
		{
			if (userDataA.bodyLabel != ARROW_LABEL && 
				userDataB.bodyLabel == ARROW_LABEL)
			{
				if (!userDataB.params.freeFlight) 
				{
					weldJointDef = new b2WeldJointDef();
					weldJointDef.Initialize(bodyB, bodyA, bodyA.GetWorldCenter());
					bodyB.GetWorld().CreateJoint(weldJointDef);
				}
			}
			if (userDataA.bodyLabel == ARROW_LABEL && 
				userDataB.bodyLabel != ARROW_LABEL)
			{
				if (!userDataA.params.freeFlight) 
				{
					weldJointDef = new b2WeldJointDef();
					weldJointDef.Initialize(bodyA, bodyB, bodyB.GetWorldCenter());
					bodyA.GetWorld().CreateJoint(weldJointDef);
				}
			}
		}
	}
	
	/**
	 * 更新箭头刚体状态 用于销毁监听 改变箭头旋转的状态 消除子弹模式
	 * @param	body  箭头刚体
	 */
	protected function removeArrowBodyStatus(body:b2Body):void
	{
		var userData:Object = body.GetUserData();
		if (userData && userData.bodyLabel == ARROW_LABEL)
		{
			userData.params.freeFlight = true;
			body.SetBullet(false);
		}
	}
	
	/**
	 * 销毁所有箭头
	 */
	public function destoryAllArrow():void
	{
		if (!this.b2dShell) return;
		for (var body:b2Body = this.b2dShell.world.GetBodyList(); body; body = body.GetNext())
		{
			var userData:Object = body.GetUserData();
			if (userData && userData.bodyLabel && userData.bodyLabel == "arrow")
			{
				body.SetBullet(false);
				this.removeBodyDispatcher(body, preSolveListener);
				this.b2dShell.destroyBody(body);
				delete this.arrowDict[body];
			}
		}
	}
	
	private function removeBodyDispatcher(body:b2Body, listener:Function):void
	{
		if (!body) return;
		if (body.GetEventDispatcher())
			body.GetEventDispatcher().removeEventListener(b2World.BEGINCONTACT, listener);
		body.SetEventDispatcher(null);
	}
	
	/**
	 * 销毁整个插件
	 */
	public function destory():void
	{
		this.destoryAllArrow();
		this.arrowDict = null;
		this.contactDict = null;
		this._b2dShell = null;
	}
	
	/**
	 * 更新箭头状态
	 */
	public function update():void
	{
		if (!this.arrowDict) return;
		var index:int = 0;
		for each (var body:b2Body in this.arrowDict) 
		{
			if (body)
			{
				var o:Object = body.GetUserData();
				if (o && o.params && !o.params.freeFlight)
				{
					if (body.GetType() == b2Body.b2_dynamicBody) 
					{
						var flyingAngle:Number = Math.atan2(body.GetLinearVelocity().y, 
															body.GetLinearVelocity().x);
						body.SetAngle(flyingAngle);
					}
					else
					{
						body.SetBullet(false);
						this.removeBodyDispatcher(body, preSolveListener);
						delete this.arrowDict[body];
					}
				}
			}
		}
	}
	
	/**
	 * 添加碰撞标签 
	 * 箭头根据选择判断，是否碰撞列表内的标签，
	 * 如果在标签内则 则会和这个标签的刚体绑定
	 * @param	str  碰撞标签 
	 */
	public function addContactLabel(str:String):void
	{
		if (!this.contactDict)
			this.contactDict = new Dictionary();
		this.contactDict[str] = str;
	}
	
	/**
	 * 删除碰撞标签 
	 * @param	str  碰撞标签
	 */
	public function deleteContactLabel(str:String):void
	{
		if (!this.contactDict) return;
		if (this.contactDict[str])
			delete this.contactDict[str];
	}
	
	/**
	 * box2d 包装器
	 */
	public function get b2dShell():B2dShell{ return _b2dShell; }
}
}