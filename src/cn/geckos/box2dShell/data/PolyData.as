package cn.geckos.box2dShell.data 
{
import Box2D.Common.Math.b2Vec2;
/**
 * ...多边形数据
 * @author Kanon
 */
public class PolyData extends BodyData 
{
	//宽度
	protected var _width:Number;
	//高度
	protected var _height:Number;
	//顶点列表
	protected var _vertices:Array;
	
	public function PolyData() 
	{
		
	}
	
	/**
	 * 宽度
	 */
	public function get width():Number { return _width; }
	public function set width(value:Number):void 
	{
		_width = value;
	}
	
	/**
	 * 高度
	 */
	public function get height():Number { return _height; }
	public function set height(value:Number):void 
	{
		_height = value;
	}
	
	/**
	 * 顶点列表
	 */
	public function get vertices():Array { return _vertices; }
	public function set vertices(value:Array):void 
	{
		_vertices = value;
	}
}
}