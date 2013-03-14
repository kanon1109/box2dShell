package cn.geckos.box2dShell.plugs 
{
import cn.geckos.box2dShell.data.PolyData;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.GraphicsPathCommand;
import flash.display.Sprite;
/**
 * ...材质插件
 * @author Kanon
 */
public class Material 
{
	
	/**
	 * 根据顶点坐标创建材质
	 * @param	vertices 顶点坐标列表 格式[[x, y],[x, y],[x, y]];
	 * @return  材质显示对象
	 */
	public static function createMaterialByVertices(vertices:Array, bitmapData:BitmapData):DisplayObject
	{
		var data:Vector.<Number> = new Vector.<Number>();
		var commands:Vector.<int> = new Vector.<int>();
		commands.push(GraphicsPathCommand.MOVE_TO);
		var length:int = vertices.length;
		for (var i:int = 0; i < length; i += 1) 
		{
			var posX:Number = vertices[i][0];
			var posY:Number = vertices[i][1];
			data.push(posX);
			data.push(posY);
			if (i > 0)
				commands.push(GraphicsPathCommand.LINE_TO);
		}
		//一定要保存起点才能封闭整个路径
		data.push(vertices[0][0]);
		data.push(vertices[0][1]);
		commands.push(GraphicsPathCommand.LINE_TO);
		return Material.createBitmapFill(bitmapData, commands, data);
	}
	
	
	/**
	 * 创建位图填充
	 * @param	bitmapData     填充的位图对象
	 * @param	commands       描边的命令
	 * @param	data           线条坐标列表
	 * @param	thickness      线条粗细
	 * @param	color          线条颜色
	 * @return  填充位图后的显示对象
	 */
	public static function createBitmapFill(bitmapData:BitmapData, 
										   commands:Vector.<int>, 
										   data:Vector.<Number>,
										   thickness:Number,
										   color:Number):DisplayObject
	{
		var spt:Sprite = new Sprite();
		spt.graphics.lineStyle(thickness, color);
		spt.graphics.beginBitmapFill(bitmapData);
		spt.graphics.drawPath(commands, data);
		spt.graphics.endFill();
		return spt;
	}
}
}