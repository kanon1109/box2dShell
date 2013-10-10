package cn.geckos.box2dShell.plugs 
{
import Box2D.Common.Math.b2Vec2;
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.Joints.b2DistanceJoint;
import Box2D.Dynamics.Joints.b2DistanceJointDef;
import cn.geckos.box2dShell.core.B2dShell;
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.utils.Dictionary;
/**
 * ...钩子插件
 * 用于快速创建类型Mikey Hooks游戏中的钩子功能
 * @author Kanon
 */
public class Hook 
{
	//存放刚体的字典
	private var bodyDict:Dictionary;
    //存放源头刚体的字典
	private var sourceBodyDict:Dictionary;
    //存放关节的字典
	private var jointsDict:Dictionary;
	//舞台
	private var stage:Stage;
	//是否已经勾住
	private var isHooked:Boolean;
	private var b2dShell:B2dShell;
	public function Hook(stage:Stage, b2dShell:B2dShell)
	{
		this.stage = stage;
		this.b2dShell = b2dShell;
		this.init();
	}
	
	/**
	 * 初始化
	 */
	private function init():void
	{
		this.bodyDict = new Dictionary();
		this.jointsDict = new Dictionary();
		this.sourceBodyDict = new Dictionary();
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
	}
	
	private function mouseUpHandler(event:MouseEvent):void 
	{
		
	}
	
	private function mouseDownHandler(event:MouseEvent):void 
	{
		if (!this.b2dShell) return;
        this.removeJoints();
		var body:b2Body = this.b2dShell.getBodyByPostion(this.stage.mouseX, 
                                                         this.stage.mouseY, 
                                                         true);
        if (this.bodyDict[body])
            this.createHookJoint(body);
	}
    
   /**
    * 讲刚体字典中存放的刚体创建钩子关节
    * @param	touchedBody    点击的刚体
    * @param	point          点击的box2d坐标位置
    */
    private function createHookJoint(touchedBody:b2Body, point:b2Vec2):void
    {
        var sourceBody:b2Body;
        var distanceJoint:b2DistanceJoint;
        for each (sourceBody in this.sourceBodyDict) 
        {
            var distanceJointDef:b2DistanceJointDef = new b2DistanceJointDef();
            distanceJointDef.Initialize(sourceBody, touchedBody,
                                        sourceBody.GetWorldCenter(),
                                        point);
            distanceJointDef.collideConnected = true;
            distanceJoint = this.b2dShell.world.CreateJoint(distanceJointDef) as b2DistanceJoint;
            this.jointsDict[distanceJoint] = distanceJoint;
        }
        this.isHooked = true;
    }
    
    /**
     * 添加源头刚体，源头刚体是发出钩子关节的源头
     * @param	body    一个需要做源头的刚体
     */
    public function addSourceBody(body:b2Body):void
    {
        this.sourceBodyDict[body] = body;
    }
    
    /**
     * 销毁关节列表中的所有关节
     */
    private function removeJoints():void
    {
        var joint:b2DistanceJoint
        for each (joint in this.jointsDict) 
        {
            this.b2dShell.world.DestroyJoint(joint);
            delete this.jointsDict[joint];
        }
    }
	
	/**
	 * 添加需要被勾住的刚体
	 * @param	body    勾住的刚体
	 */
	public function addHookBody(body:b2Body):void
	{
		this.bodyDict[body] = body;
	}
    
    /**
     * 删除需要被勾住的刚体
     * @param	body    勾住的刚体
     */
    public function removeHookBody(body:b2Body):void
	{
        delete this.bodyDict[body];
    }
	
	/**
	 * 销毁
	 */
	public function destroy():void
	{
        this.removeJoints();
		this.jointsDict = null;
		this.bodyDict = null;
		this.sourceBodyDict = null;
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		this.stage = null;
		this.b2dShell = null;
	}
}
}