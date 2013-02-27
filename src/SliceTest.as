package  
{
import Box2D.Dynamics.b2Body;
import cn.geckos.box2dShell.data.PolyData;
import cn.geckos.box2dShell.engine.B2dShell;
import cn.geckos.box2dShell.plugs.Slice;
import cn.geckos.utils.Random;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;

/**
 * ...切割测试
 * @author Kanon
 */
public class SliceTest extends Sprite 
{
	private var b2dShell:B2dShell;
	private var slice:Slice;
	private var floorMc:Sprite;
	public function SliceTest() 
	{
		this.b2dShell = new B2dShell();
		this.b2dShell.timeStep = 1.0 / 30.0;
		this.b2dShell.velocityIterations = 10;
		this.b2dShell.positionIterations = 10;
		this.b2dShell.createWorld(0, 10, stage, true);
		this.b2dShell.drawDebug(this);
		//this.b2dShell.mouseEnabled = true;
		
		this.floorMc = this.getChildByName("floor_mc") as Sprite;
		var polyData:PolyData = new PolyData();
		polyData.container = this;
		polyData.friction = 5;
		polyData.density = 1;
		polyData.restitution = 0;
		polyData.displayObject = this.floorMc;
		polyData.boxPoint = new Point(this.floorMc.width *.5, this.floorMc.height *.5);
		polyData.width = this.floorMc.width;
		polyData.height = this.floorMc.height;
		polyData.bodyLabel = "wall";
		polyData.postion = new Point(this.floorMc.x, this.floorMc.y);
		polyData.bodyType = b2Body.b2_staticBody;
		var poly:b2Body = this.b2dShell.createPoly(polyData)
		
		this.createRect();
		this.createRect();
		this.slice = new Slice(this.b2dShell, stage, this);
		this.slice.mouseDraw = true;
		this.slice.addDontSliceDict(poly);
		
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
	
	/**
	 * 使用shell创建的刚体对象
	 * @return
	 */
	private function createRect():b2Body
	{
		var polyData:PolyData = new PolyData();
		polyData.container = this;
		polyData.friction = 1;
		polyData.density = 1;
		polyData.restitution = .1;
		polyData.bodyLabel = "rect";
		polyData.boxPoint = new Point(100 / 2, 100 / 2);
		polyData.width = 100;
		polyData.height = 100;
		polyData.postion = new Point(Random.randint(50, 300), Random.randint(50, 300));
		polyData.bodyType = b2Body.b2_dynamicBody;
		return this.b2dShell.createPoly(polyData);
	}
	
	private function enterFrameHandler(event:Event):void 
	{
		if (this.slice)
			this.slice.update();
		this.b2dShell.render();
	}
	
}
}