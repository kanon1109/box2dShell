package  
{
import Box2D.Dynamics.b2Body;
import cn.geckos.box2dShell.core.B2dShell;
import cn.geckos.box2dShell.model.BodyData;
import cn.geckos.box2dShell.model.PolyData;
import cn.geckos.box2dShell.plugs.Hook;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
/**
 * ...钩子测试
 * @author Kanon
 */
public class HookTest extends Sprite 
{
    private var hook:Hook;
    private var b2dShell:B2dShell;
    private var floorMc:Sprite;
    public function HookTest() 
    {
        this.b2dShell = new B2dShell();
        this.b2dShell.createWorld(0, 10, stage, true);
        this.b2dShell.drawDebug(this);
        
        this.hook = new Hook(stage, this.b2dShell);
        
        this.floorMc = this.getChildByName("floor_mc") as Sprite;
		var polyData:PolyData = new PolyData();
		polyData.friction = 5;
		polyData.density = 2;
		polyData.restitution = .1;
		polyData.displayObject = this.floorMc;
		polyData.boxPoint = new Point(this.floorMc.width *.5, this.floorMc.height *.5);
		polyData.width = this.floorMc.width;
		polyData.height = this.floorMc.height;
		polyData.bodyLabel = "wall";
		polyData.postion = new Point(this.floorMc.x, this.floorMc.y);
		polyData.bodyType = b2Body.b2_staticBody;
		this.b2dShell.createPoly(polyData);
        
        var bodyData:PolyData;
        var body:b2Body;
        for (var i:int = 0; i < 20; i++) 
        {
            bodyData = new PolyData();
            bodyData.bodyType =  b2Body.b2_staticBody;
            bodyData.width = 20;
            bodyData.height = 20;
            bodyData.boxPoint = new Point(bodyData.width * .5, bodyData.height * .5);
            bodyData.postion = new Point(Math.random() * 500 + 20, Math.random() * 150 + 20);
            body = this.b2dShell.createPoly(bodyData);
            this.hook.addHookBody(body);
        }
        
        for (i = 0; i < 10; i++) 
        {
            bodyData = new PolyData();
            bodyData.bodyType =  b2Body.b2_dynamicBody;
            bodyData.width = 20;
            bodyData.height = 20;
            bodyData.density = 1;
            bodyData.friction = .5;
            bodyData.restitution = .4;
            bodyData.boxPoint = new Point(bodyData.width * .5, bodyData.height * .5);
            bodyData.postion = new Point(Math.random() * 500 + 20, Math.random() * 370 + 150);
            body = this.b2dShell.createPoly(bodyData);
            this.hook.addSourceBody(body);
            /*if (i < 9)
                this.hook.removeSourceBody(body);*/
        }
        
        this.addEventListener(Event.ENTER_FRAME, loop);
    }
    
    private function loop(event:Event):void 
    {
        this.b2dShell.render();
        this.hook.update();
    }
    
}
}