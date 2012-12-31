package cn.geckos.box2dShell.data 
{
/**
 * ...圆形数据
 * @author ...
 */
public class CircleData extends PolyData 
{
	//半径
	private var _radius:Number;
	public function CircleData() 
	{
		
	}
	
	//半径
	public function get radius():Number { return _radius; }
	public function set radius(value:Number):void 
	{
		_radius = value;
	}
	
}
}