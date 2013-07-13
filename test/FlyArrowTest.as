package  
{
import Box2D.Dynamics.b2Body;
import cn.geckos.box2dShell.core.B2dShell;
import cn.geckos.box2dShell.model.CircleData;
import cn.geckos.box2dShell.model.PolyData;
import cn.geckos.box2dShell.plugs.FlyArrow;
import cn.geckos.box2dShell.utils.B2dUtil;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;

/**
 * ...箭头测试
 * @author Kanon
 */
public class FlyArrowTest extends Sprite 
{
	private var b2dShell:B2dShell;
	private var flyArrow:FlyArrow;
	private var boxMc:Sprite;
	private var floorMc:Sprite;
	private var arrow:Sprite;
	private var wallMc:Sprite;
	public function FlyArrowTest() 
	{
		this.init();
	}
	
	private function init():void
	{
		this.b2dShell = new B2dShell();
		this.b2dShell.timeStep = 1.0 / 30.0;
		this.b2dShell.velocityIterations = 10;
		this.b2dShell.positionIterations = 10;
		this.b2dShell.createWorld(0, 10, stage, true);
		this.b2dShell.drawDebug(this);
		this.b2dShell.mouseEnabled = true;
		
		this.floorMc = this.getChildByName("floor_mc") as Sprite;
		var polyData:PolyData = new PolyData();
		polyData.friction = 1;
		polyData.density = 1;
		polyData.restitution = .1;
		polyData.displayObject = this.floorMc;
		polyData.boxPoint = new Point(this.floorMc.width *.5, this.floorMc.height *.5);
		polyData.width = this.floorMc.width;
		polyData.height = this.floorMc.height;
		polyData.bodyLabel = "floor";
		polyData.postion = new Point(this.floorMc.x, this.floorMc.y);
		polyData.bodyType = b2Body.b2_staticBody;
		this.b2dShell.createPoly(polyData);
		
		this.wallMc = this.getChildByName("wall_mc") as Sprite;
		polyData.friction = 1;
		polyData.density = 1;
		polyData.restitution = .1;
		polyData.displayObject = this.wallMc;
		polyData.boxPoint = new Point(this.wallMc.width *.5, this.wallMc.height *.5);
		polyData.width = this.wallMc.width;
		polyData.height = this.wallMc.height;
		polyData.bodyLabel = "wall"
		polyData.postion = new Point(this.wallMc.x, this.wallMc.y);
		polyData.bodyType = b2Body.b2_staticBody;
		this.b2dShell.createPoly(polyData);
		
		this.flyArrow = new FlyArrow(this.b2dShell);
		this.flyArrow.addContactLabel("wall");
		this.flyArrow.addContactLabel("floor");
		this.flyArrow.deleteContactLabel("floor");
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		//创建浮力
		this.b2dShell.createBuoyancy(new Point(0, -1), -300, 2, 10, 10);
		/*this.createPoly()
		this.createCircle()*/
		var poly:b2Body = this.createPoly();
		var circle:b2Body = this.createCircle();
		this.b2dShell.addBuoyancyBody(poly);
		this.b2dShell.addBuoyancyBody(circle);
		this.b2dShell.removeBuoyancyBody(circle);
		this.flyArrow.addContactLabel("poly");
		this.flyArrow.addContactLabel("circle");
		this.flyArrow.deleteContactLabel("circle");
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(MouseEvent.CLICK, clickHandler);
	}
	
	private function clickHandler(event:MouseEvent):void 
	{
		var sx:Number = 0;
		var sy:Number = 0;
		var p1:Point = new Point(mouseX, mouseY);
		var p2:Point = new Point(sx, sy);
		var rotation:Number = B2dUtil.angleBetween(p1, p2);
		//this.arrow = new Arrow();
		//this.addChild(this.arrow);
		this.b2dShell.addBuoyancyBody(this.flyArrow.create(sx, sy, rotation, 30, this.arrow));
	}
	
	private function keyDownHandler(event:KeyboardEvent):void 
	{
		switch(event.keyCode)
		{
			case Keyboard.D:
					//this.createPoly();
					//this.createCircle();
					//this.arrow = new Arrow();
					//this.addChild(this.arrow);
					//trace("keyDownHandler")
					this.flyArrow.destroyAllArrow();
				break;
		}
	}
	
	/**
	 * 使用shell创建的刚体对象
	 * @return
	 */
	private function createCircle():b2Body
	{
		var circleData:CircleData = new CircleData();
		circleData.radius = 20;
		circleData.friction = 1;
		circleData.density = 1;
		circleData.restitution = .1;
		circleData.isWrapAround = true;
		circleData.wrapAroundDirection = 2;
		circleData.postion = new Point(50, 30);
		circleData.bodyType = b2Body.b2_dynamicBody;
		circleData.bodyLabel = "circle";
		return this.b2dShell.createCircle(circleData);
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
		//polyData.isWrapAround = true;
		//polyData.wrapAroundDirection = 2;
		polyData.vertices = [[ -15.95, -33.5], [33.55, -33.5], [33.55, -13.25], [7.05, 33.5], [ -33.7, 33.5], [ -33.55, -2.75]];
		polyData.displayObject = this.boxMc;
		polyData.boxPoint = new Point(this.boxMc.width / 2, this.boxMc.height / 2);
		polyData.width = this.boxMc.width;
		polyData.height = this.boxMc.height;
		polyData.postion = new Point(this.boxMc.x, this.boxMc.y);
		polyData.bodyType = b2Body.b2_dynamicBody;
		polyData.bodyLabel = "poly";
		return this.b2dShell.createPoly(polyData);
	}
	
	private function enterFrameHandler(event:Event):void 
	{
		if (this.flyArrow)
			this.flyArrow.update();
		this.b2dShell.render();
	}
	
}
}