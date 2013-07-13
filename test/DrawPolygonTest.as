package  
{
import Box2D.Dynamics.b2Body;
import cn.geckos.box2dShell.model.PolyData;
import cn.geckos.box2dShell.core.B2dShell;
import cn.geckos.box2dShell.plugs.DrawPolygon;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
/**
 * ...绘制测试
 * @author 
 */
public class DrawPolygonTest extends Sprite 
{
	private var drawPolygon:DrawPolygon;
	private var b2dShell:B2dShell;
	public function DrawPolygonTest() 
	{
		this.b2dShell = new B2dShell();
		this.b2dShell.timeStep = 1.0 / 30.0;
		this.b2dShell.velocityIterations = 10;
		this.b2dShell.positionIterations = 10;
		this.b2dShell.createWorld(0, 10, stage, true);
		this.b2dShell.drawDebug(this);
		this.b2dShell.mouseEnabled = false;
		this.drawPolygon = new DrawPolygon(stage, this);
		this.drawPolygon.b2dShell = this.b2dShell;
		
		var floorMc:Sprite = this.getChildByName("floor_mc") as Sprite;
		var polyData:PolyData = new PolyData();
		polyData.friction = 1;
		polyData.density = 1;
		polyData.restitution = .9;
		polyData.displayObject = floorMc;
		polyData.boxPoint = new Point(floorMc.width *.5, floorMc.height *.5);
		polyData.width = floorMc.width;
		polyData.height = floorMc.height;
		polyData.bodyLabel = floorMc.name;
		polyData.postion = new Point(floorMc.x, floorMc.y);
		polyData.bodyType = b2Body.b2_staticBody;
		this.b2dShell.createPoly(polyData);
		
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
	
	private function enterFrameHandler(event:Event):void 
	{
		this.b2dShell.render();
	}
}
}