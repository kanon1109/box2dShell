package  
{
import Box2D.Dynamics.b2Body;
import cn.geckos.box2dShell.data.CircleData;
import cn.geckos.box2dShell.engine.B2dShell;
import cn.geckos.box2dShell.plugs.event.PlugsEvent;
import cn.geckos.box2dShell.plugs.LineFloor;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
/**
 * ...线条地板测试
 * @author 
 */
public class LineFloorTest extends Sprite 
{
	private var b2dShell:B2dShell
	private var lineFloor:LineFloor;
	public function LineFloorTest() 
	{
		this.b2dShell = new B2dShell();
		this.b2dShell.timeStep = 1.0 / 30.0;
		this.b2dShell.velocityIterations = 10;
		this.b2dShell.positionIterations = 10;
		this.b2dShell.createWorld(0, 10, stage, true);
		this.b2dShell.drawDebug(this);
		
		this.lineFloor = new LineFloor(stage);
		this.lineFloor.b2dShell = this.b2dShell;
		this.lineFloor.lineFloorMode = true;
		this.lineFloor.drawSprite = new Sprite();
		this.lineFloor.addEventListener(PlugsEvent.DRAW_COMPLETE, drawCompleteHandler);
		this.addChild(this.lineFloor.drawSprite);
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
	}
	
	private function keyDownHandler(event:KeyboardEvent):void 
	{
		switch(event.keyCode)
		{
			case Keyboard.D:
					//销毁有显示对象装饰的刚体 box2d的debug显示对象除外
					this.b2dShell.destroyBody(this.b2dShell.getBodyByPostion(mouseX, mouseY));
					this.lineFloor.destroy();
					this.lineFloor = null;
				break;
		}
	}
	
	private function drawCompleteHandler(event:PlugsEvent):void 
	{
		this.createCircle();
	}
	
	/**
	 * 使用shell创建的刚体对象
	 * @return
	 */
	private function createCircle():b2Body
	{
		var circleData:CircleData = new CircleData();
		circleData.radius = 20;
		circleData.container = this;
		circleData.friction = 1;
		circleData.density = 1;
		circleData.restitution = .1;
		circleData.postion = new Point(50, 30);
		circleData.bodyType = b2Body.b2_dynamicBody;
		circleData.bodyLabel = "circle";
		return this.b2dShell.createCircle(circleData);
	}
	
	private function enterFrameHandler(event:Event):void 
	{
		this.b2dShell.render();
	}
	
}
}