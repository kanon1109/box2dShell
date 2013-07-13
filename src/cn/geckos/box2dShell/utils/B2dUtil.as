package cn.geckos.box2dShell.utils 
{
import Box2D.Common.Math.b2Vec2;
import flash.geom.Point;
/**
 * ...b2dShell工具
 * @author Kanon
 */
public class B2dUtil 
{
	
	/**
	 * 标准化角度值，将传入的角度值返回成一个确保落在 0 ~ 360 之间的数字。
     * 
     * <pre>
     * B2dUtil.fixAngle(380); // 返回 20
     * B2dUtil.fixAngle(-340); // 返回 20
     * </pre>
     * 
     * 该方法详情可查看 《Flash MX 编程与创意实现》的第69页。
	 * @param	angle	需要标准化的角度值
	 * @return	标准化后的角度
	 */
    public static function fixAngle(angle:Number):Number
    {
        angle %= 360;
        if (angle < 0)
            return angle + 360;
        return angle;
    }
	
	/**
	* 弧度转换成角度  radians -> degrees
	*  
	* @param radians 弧度
	* @return 相应的角度
	*/ 
    public static function rds2dgs(radians:Number):Number
    {
        return fixAngle(radians * 180 / Math.PI);
    }

    /**
     * 角度转换成弧度 degrees -> radians
     *  
     * @param degrees 角度
     * @return 相应的弧度
     */ 
    public static function dgs2rds(degrees:Number):Number
    {
        return degrees * Math.PI / 180;
    }
	
	/**
	 * 判断2个点的夹角
	 * @param	p1		点1
	 * @param	p2		点2
	 * @param	degrees	返回角度
	 * @return	弧度或角度
	 */
	public static function angleBetween(p1:Point, p2:Point, degrees:Boolean = true):Number
    {
        var dx:Number = p1.x - p2.x; 
        var dy:Number = p1.y - p2.y;
        var radians:Number =  Math.atan2(dy, dx);
        if (degrees) return B2dUtil.rds2dgs(radians);
        return radians;
    }
	
	/**
	 * 根据坐标计算这个坐标形成的图形的尺寸高宽
	 * @param	path 路径列表 二维数组[[x,y],[x,y]]
	 * @return  尺寸对象
	 */
	public static function mathSizeByPath(path:Array):Object
	{
		var minX:Number;
		var maxX:Number;
		var minY:Number;
		var maxY:Number;
		var length:int = path.length;
		for (var i:int = 0; i < length; i += 1) 
		{
			var posX:Number = path[i][0];
			var posY:Number = path[i][1];
			if (isNaN(minX))
				minX = posX;
			else if (posX < minX)
				minX = posX;
				
			if (isNaN(maxX))
				maxX = posX;
			else if (posX > maxX)
				maxX = posX;
				
			if (isNaN(minY))
				minY = posY;
			else if (posY < minY)
				minY = posY;
				
			if (isNaN(maxY))
				maxY = posY;
			else if (posY > maxY)
				maxY = posY;
		}
		var width:Number = (maxX - minX);
		var height:Number = (maxY - minY);
		return { "width":width, "height":height, 
				 "minX":minX, "maxX":maxX,
				 "minY":minY, "maxY":maxY };
	}
	
	/**
	 * 查找多边形的中心
	 * @param	vs    	   多边形顶点坐标
	 * @param	count      顶点数量
	 * @return  中心坐标
	 */
	private function findCentroid(vs:Vector.<b2Vec2>, count:uint):b2Vec2
	{
		var c:b2Vec2 = new b2Vec2();
		var area:Number = 0.0;
		var p1X:Number = 0.0;
		var p1Y:Number = 0.0;
		var inv3:Number = 1.0 / 3.0;
		for (var i:int = 0; i < count; ++i)
		{
			var p2:b2Vec2 = vs[i];
			var p3:b2Vec2 = i + 1 < count ? vs[int(i + 1)] : vs[0];
			var e1X:Number = p2.x - p1X;
			var e1Y:Number = p2.y - p1Y;
			var e2X:Number = p3.x - p1X;
			var e2Y:Number = p3.y - p1Y;
			var D:Number = (e1X * e2Y - e1Y * e2X);
			var triangleArea:Number = 0.5 * D;
			area += triangleArea;
			c.x += triangleArea * inv3 * (p1X + p2.x + p3.x);
			c.y += triangleArea * inv3 * (p1Y + p2.y + p3.y);
		}
		c.x *= 1.0 / area;
		c.y *= 1.0 / area;
		return c;
	}
	
}
}