package  
{
import cn.geckos.box2dShell.engine.B2dShell;
import cn.geckos.box2dShell.plugs.DrawPolygon;
import flash.display.Sprite;
import flash.events.Event;
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
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
	
	private function enterFrameHandler(event:Event):void 
	{
		this.b2dShell.render();
	}
}
}