package  
{
import Box2D.Dynamics.b2Body;
import cn.geckos.box2dShell.core.B2dShell;
import cn.geckos.box2dShell.model.PolyData;
import cn.geckos.box2dShell.plugs.event.PlugsEvent;
import cn.geckos.box2dShell.plugs.Slice;
import cn.geckos.box2dShell.plugs.textures.Texture;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.getDefinitionByName;
/**
 * ...切割测试
 * @author Kanon
 */
public class SliceTest extends Sprite 
{
	private var b2dShell:B2dShell;
	private var slice:Slice;
	private var floorMc:Sprite;
	//纹理容器
	private var textureContainer:Sprite;
	//线条容器
	private var canvasContainer:Sprite;
	//切割线条的画布
	private var canvas:Sprite;
	//private var chainEffect:ChainEffect;
	//鼠标是否放开了
	private var mouseReleased:Boolean;
	//鼠标是否点击
	private var mouseDown:Boolean;
	//起始点
	private var begX:Number;
	private var begY:Number;
	//结束点
	private var endX:Number;
	private var endY:Number;
	public function SliceTest() 
	{
		this.b2dShell = new B2dShell();
		this.b2dShell.timeStep = 1.0 / 30.0;
		this.b2dShell.velocityIterations = 90;
		this.b2dShell.positionIterations = 90;
		this.b2dShell.createWorld(0, 30, stage, true);
		this.b2dShell.drawDebug(this);
		
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
		
		this.textureContainer = new Sprite();
		this.canvasContainer = new Sprite();
		this.addChild(this.textureContainer);
		this.addChild(this.canvasContainer);
		var bodyList:Array = [];
		bodyList.push(this.createRect());
		bodyList.push(this.createRect());
		
		this.slice = new Slice(this.b2dShell, stage);
		this.slice.initSliceBody(bodyList);
		
		this.slice.addEventListener(PlugsEvent.SLICE_COMPLETE, sliceCompleteHandler);
		
		/*this.chainEffect = new ChainEffect(this);
		this.chainEffect.chainLength = 2;
		this.chainEffect.move(mouseX, mouseY);*/
		
		this.initCanvas();
		this.initMouseEvent();
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
	}
	
	private function keyDownHandler(event:KeyboardEvent):void 
	{
		if (event.keyCode == Keyboard.D)
		{
			this.b2dShell.clearAll();
			this.slice.reset();
			var bodyList:Array = [];
			bodyList.push(this.createRect());
			bodyList.push(this.createRect());
			this.slice.initSliceBody(bodyList);
		}
	}
	
	/**
	 * 初始化画布
	 */
	private function initCanvas():void
	{
		if (this.canvas || !this.canvasContainer)
			return;
		this.canvas = new Sprite();
		this.canvasContainer.addChild(this.canvas);
	}
	
	/**
	 * 初始化鼠标事件
	 */
	private function initMouseEvent():void
	{
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHander);
	}
	
	private function mouseMoveHander(event:MouseEvent):void
	{
		if (this.canvas)
		{
			this.canvas.graphics.clear();
			this.canvas.graphics.lineStyle(1.5, 0xFFF0000);
			this.canvas.graphics.moveTo(this.begX, this.begY);
			this.canvas.graphics.lineTo(this.mouseX, this.mouseY);
		}
	}
	
	private function mouseDownHander(event:MouseEvent):void
	{
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHander);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHander);
		this.begX = this.mouseX; 
		this.begY = this.mouseY;
		/*if (this.chainEffect)
			this.chainEffect.move(mouseX, mouseY);*/
		this.mouseDown = true;
	}
	
	private function mouseUpHander(event:MouseEvent):void 
	{
		this.mouseReleased = true;
		this.mouseDown = false;
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHander);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHander);
		if (this.canvas)
			this.canvas.graphics.clear();
		/*if (this.chainEffect)
			this.chainEffect.clear();*/
	}
	
	private function sliceCompleteHandler(event:PlugsEvent):void 
	{
		var bodyDataList:Array = event.data as Array;
		var length:int = bodyDataList.length;
		for (var i:int = 0; i < length; i += 1) 
		{
			var o:Object = bodyDataList[i];
			var bodyData:PolyData = o.bodyData;
			var texture:BitmapData = o.texture;
			if (texture)
			{
				bodyData.texture = texture;
				bodyData.displayObject = Texture.createTextureByVertices(o.shapeVertices, texture, 1, 0x000000);
				this.textureContainer.addChild(bodyData.displayObject)
			}
			var body:b2Body = this.b2dShell.createPoly(bodyData);
			body.SetBullet(true);
		}
	}
	
	/**
	 * 使用shell创建的刚体对象
	 * @return
	 */
	private function createRect():b2Body
	{
		var polyData:PolyData = new PolyData();
		polyData.friction = .1;
		polyData.density = 2;
		polyData.restitution = .1;
		polyData.bodyLabel = "rect";
		polyData.boxPoint = new Point(150 / 2, 150 / 2);
		polyData.width = 150;
		polyData.height = 150;
		polyData.postion = new Point(100, 100);
		polyData.bodyType = b2Body.b2_dynamicBody;
		var MyClass:Class = getDefinitionByName("T" + int(Math.random() * 4 + 1)) as Class;
		polyData.texture = new MyClass() as BitmapData;
		polyData.displayObject = Texture.createTextureByBoxSize(polyData.width, polyData.height, polyData.texture, 1, 0x000000)
		this.textureContainer.addChild(polyData.displayObject);
		return this.b2dShell.createPoly(polyData);
	}
	
	private function enterFrameHandler(event:Event):void 
	{
		/*if (this.mouseDown && this.chainEffect)
			this.chainEffect.render(this.mouseX, this.mouseY, .5);*/
		if (this.slice && this.mouseReleased)
		{
			this.endX = this.mouseX;
			this.endY = this.mouseY;
			/*this.endX = this.chainEffect.prevPos.x;
			this.endY = this.chainEffect.prevPos.y;*/
			this.slice.update(this.begX, this.begY, this.endX, this.endY);
			this.mouseReleased = false;
		}
		this.b2dShell.render();
	}
	
}
}