package  
{
import cn.geckos.box2dShell.engine.B2dShell;
import cn.geckos.box2dShell.plugs.MarchingSquares;
import cn.geckos.utils.RDP;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
/**
 * ...算法自动提取多边形的边缘测试
 * @author Kanon
 */
public class MarchingSquaresTest extends Sprite 
{
	private var b2dShell:B2dShell
	private var bitmapData:BitmapData = new BitmapData(640, 480, true, 0x00000000);
	public function MarchingSquaresTest() 
	{
		this.b2dShell = new B2dShell();
		this.b2dShell.timeStep = 1.0 / 30.0;
		this.b2dShell.velocityIterations = 10;
		this.b2dShell.positionIterations = 10;
		this.b2dShell.createWorld(0, 10, stage, true);
		this.b2dShell.drawDebug(this);
		
		this.bitmapData.draw(new Logo(278, 429), new Matrix(1, 0, 0, 1, 100, 40));
		var bitmap:Bitmap = new Bitmap(bitmapData);
		this.addChild(bitmap);
		var marchingSquares:MarchingSquares = new MarchingSquares();
		// at the end of this function, marchingVector will contain the points tracing the contour
		var marchingVector:Vector.<Point> = marchingSquares.marchingSquares(bitmapData);
		marchingVector = RDP.properRDP(marchingVector, 0.50);
		 
		var canvas:Sprite = new Sprite();
		this.addChild(canvas);
		canvas.graphics.moveTo(marchingVector[0].x + 320, marchingVector[0].y);
		for (var i:Number = 0; i < marchingVector.length; i++) 
		{
			canvas.graphics.lineStyle(2, 0x000000);
			canvas.graphics.lineTo(marchingVector[i].x + 320, marchingVector[i].y);
			canvas.graphics.lineStyle(1, 0xff0000);
			canvas.graphics.drawCircle(marchingVector[i].x + 320, marchingVector[i].y, 2);
		}
		canvas.graphics.lineStyle(2, 0x000000);
		canvas.graphics.lineTo(marchingVector[0].x + 320, marchingVector[0].y);
		
		
		/*var vertices:Array = [];
		var length:int = marchingVector.length;
		for (var i:int = 0; i < length; i += 1) 
		{
			vertices.push([marchingVector[i].x, marchingVector[i].y]);
		}
		//trace("vertices", vertices);
		var polyData:PolyData = new PolyData();
		polyData.boxPoint = new Point(278 / 2, 429 / 2);
		polyData.postion = new Point(278, 429);
		polyData.friction = 1;
		polyData.density = 1;
		polyData.restitution = .1;
		polyData.vertices = vertices;
		polyData.bodyType = b2Body.b2_dynamicBody;
		this.b2dShell.createPoly(polyData);
		
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);*/
	}
	
	private function enterFrameHandler(event:Event):void 
	{
		this.b2dShell.render();
	}
	
}
}