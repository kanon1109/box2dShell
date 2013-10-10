package cn.geckos.box2dShell.plugs.textures 
{
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.GraphicsPathCommand;
import flash.display.Sprite;
/**
 * ...纹理
 * @author Kanon
 */
public class Texture
{
	/**
	 * 根据高宽创建位图填充材质
	 * @param	width        宽度
	 * @param	height       高度
	 * @param	texture      位图纹理
	 * @param	thickness    线条粗细
	 * @param	color        线条颜色
	 * @return  材质显示对象
	 */
	public static function createTextureByBoxSize(width:Number, 
												  height:Number, 
												  texture:BitmapData, 
												  thickness:Number,
												  color:Number):DisplayObject
	{
		var data:Vector.<Number> = new Vector.<Number>();
		var commands:Vector.<int> = new Vector.<int>();
		commands.push(GraphicsPathCommand.MOVE_TO);
		//把左上，右上，左下，右下。
		var vertices:Array = [[ -1, -1], [1, -1], [1, 1], [ -1, 1]];
		var length:int = vertices.length;
		for (var i:int = 0; i < length; i += 1)
		{
			var arr:Array = vertices[i];
			var posX:Number = arr[0] * width * .5;
			var posY:Number = arr[1] * height * .5;
			data.push(posX);
			data.push(posY);
			if (i > 0)
				commands.push(GraphicsPathCommand.LINE_TO);
		}
		//一定要保存起点才能封闭整个路径
		data.push(vertices[0][0] * width * .5);
		data.push(vertices[0][1] * height * .5);
		commands.push(GraphicsPathCommand.LINE_TO);
		return Texture.createBitmapFill(texture, commands, data, thickness, color);
	}
	
	/**
	/**
	 * 根据顶点坐标创建位图填充材质
	 * @param	vertices     顶点坐标列表 格式[[x, y],[x, y],[x, y]];
	 * @param	texture      位图纹理
	 * @param	thickness    线条粗细
	 * @param	color        线条颜色
	 * @return  材质显示对象
	 */
	public static function createTextureByVertices(vertices:Array, 
												   texture:BitmapData, 
												   thickness:Number,
												   color:Number):DisplayObject
	{
		var data:Vector.<Number> = new Vector.<Number>();
		var commands:Vector.<int> = new Vector.<int>();
		commands.push(GraphicsPathCommand.MOVE_TO);
		var length:int = vertices.length;
		for (var i:int = 0; i < length; i += 1)
		{
			var arr:Array = vertices[i];
			var posX:Number = arr[0];
			var posY:Number = arr[1];
			data.push(posX);
			data.push(posY);
			if (i > 0)
				commands.push(GraphicsPathCommand.LINE_TO);
		}
		//一定要保存起点才能封闭整个路径
		data.push(vertices[0][0]);
		data.push(vertices[0][1]);
		commands.push(GraphicsPathCommand.LINE_TO);
		return Texture.createBitmapFill(texture, commands, data, thickness, color);
	}
	
	/**
	 * 创建位图填充
	 * @param	texture    	   填充的位图纹理对象
	 * @param	commands       描边的命令
	 * @param	data           线条坐标列表
	 * @param	thickness      线条粗细
	 * @param	color          线条颜色
	 * @return  填充位图后的显示对象
	 */
	public static function createBitmapFill(texture:BitmapData, 
										    commands:Vector.<int>, 
										    data:Vector.<Number>,
										    thickness:Number,
										    color:Number):DisplayObject
	{
		var spt:Sprite = new Sprite();
		spt.graphics.lineStyle(thickness, color);
		spt.graphics.beginBitmapFill(texture, null, true, true);
		spt.graphics.drawPath(commands, data);
		spt.graphics.endFill();
		return spt;
	}
}
}