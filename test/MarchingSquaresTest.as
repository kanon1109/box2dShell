package  
{
import Box2D.Dynamics.b2Body;
import cn.geckos.box2dShell.core.B2dShell;
import cn.geckos.box2dShell.model.PolyData;
import cn.geckos.box2dShell.utils.B2dUtil;
import cn.geckos.box2dShell.utils.MarchingSquares;
import cn.geckos.box2dShell.utils.RDP;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
/**
 * ...算法自动提取多边形的边缘测试
 * @author Kanon
 */
public class MarchingSquaresTest extends Sprite 
{
	private var b2dShell:B2dShell
	private var bitmapData:BitmapData = new BitmapData(640, 480, true, 0x00000000);
	private var floorMc:Sprite;
	public function MarchingSquaresTest() 
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
		
		
		this.bitmapData.draw(new Logo(278, 429));
		var bitmap:Bitmap = new Bitmap(bitmapData);
		this.addChild(bitmap);
		var marchingSquares:MarchingSquares = new MarchingSquares();
		// at the end of this function, marchingVector will contain the points tracing the contour
		var marchingVector:Vector.<Point> = marchingSquares.marchingSquares(bitmapData);
		marchingVector = RDP.properRDP(marchingVector, 0.1);
		
		 
		var canvas:Sprite = new Sprite();
		this.addChild(canvas);
		canvas.graphics.moveTo(marchingVector[0].x, marchingVector[0].y);
		for (var i:Number = 0; i < marchingVector.length; i++) 
		{
			canvas.graphics.lineStyle(2, 0x000000);
			canvas.graphics.lineTo(marchingVector[i].x, marchingVector[i].y);
			canvas.graphics.lineStyle(1, 0xff0000);
			canvas.graphics.drawCircle(marchingVector[i].x, marchingVector[i].y, 2);
		}
		canvas.graphics.lineStyle(2, 0x000000);
		canvas.graphics.lineTo(marchingVector[0].x, marchingVector[0].y);
		
		
		var vertices:Array = [];
		var length:int = marchingVector.length;
		//最重要的 - 我们需要一个b2Vec2 vector实例这样我们可以传递顶点 
		// 记住，我们的定点是顺时针! 更多信息参考b2Separator.Separate()方法.
		// 注意我是如何逆序vector的。
		for (i = marchingVector.length - 1; i >= 0; i--) 
		{
			if (i % 10 == 0) 
				vertices.push([marchingVector[i].x, marchingVector[i].y]);
		}
		
		var o:Object = B2dUtil.mathSizeByPath(vertices);
		//trace("vertices", vertices);
		polyData = new PolyData();
		polyData.boxPoint = new Point(o.width / 2, o.height / 2);
		polyData.postion = new Point();
		polyData.friction = 1;
		polyData.density = 1;
		polyData.restitution = .1;
		polyData.vertices = vertices;
		polyData.bodyType = b2Body.b2_dynamicBody;
		this.b2dShell.createPoly(polyData);
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
	
	private function enterFrameHandler(event:Event):void 
	{
		this.b2dShell.render();
	}
	
}
}