package cn.geckos.box2dShell.utils 
{
import flash.display.BitmapData;
import flash.geom.Point;
/**
 * ...利用MarchingSquares算法自动提取多边形的边缘。
 * @author Kanon
 */
public class MarchingSquares 
{
	// tolerance is the amount of alpha for a pixel to be considered solid
	private var tolerance:Number = 0x01;
	/**
	 * 将png位图边缘生成一个点的坐标列表
	 * @param	bitmapData 位图对象
	 * @return  点的坐标列表
	 */
	public function marchingSquares(bitmapData:BitmapData):Vector.<Point>
	{
			var contourVector:Vector.<Point> = new Vector.<Point>();
			// getting the starting pixel 找到起始像素
			var startPoint:Point = this.getStartingPixel(bitmapData);
			// if we found a starting pixel we can begin 如果我们找到了起始像素，就可以开始了
			if (startPoint)
			{
				// moving the graphic pen to the starting pixel 把画笔移动到起始像素
				// pX and pY are the coordinates of the starting point  pX，pY起始像素的x,y坐标
				var pX:Number = startPoint.x;
				var pY:Number = startPoint.y;
				// stepX and stepY can be -1, 0 or 1 and represent the step in pixels to reach
				// next contour point
				// stepX 和stepY 可以是 -1, 0 or 1 代表将要到达像素的步骤
				// 轮廓的下一个位置
				var stepX:Number;
				var stepY:Number;
				// we also need to save the previous step, that's why we use prevX and prevY
				// 我们同样需要保存上一步, 这就是我们使用prevX和prevY的原因
				var prevX:Number;
				var prevY:Number;
				// closedLoop will be true once we traced the full contour
				// 如果我们描绘了整个轮廓 closedLoop 会是true
				var closedLoop:Boolean = false;
				while (!closedLoop) 
				{
					// the core of the script is getting the 2x2 square value of each pixel
					// 脚本的核心是得到2x2正方形每个像素的值
					var squareValue:Number = this.getSquareValue(pX, pY, bitmapData);
					switch (squareValue)
					{
							/* going UP with these cases: 以下情况向上:
							
							+---+---+   +---+---+   +---+---+
							| 1 |   |   | 1 |   |   | 1 |   |
							+---+---+   +---+---+   +---+---+
							|   |   |   | 4 |   |   | 4 | 8 |
							+---+---+  	+---+---+  	+---+---+
							
							*/
						case 1 :
						case 5 :
						case 13 :
							stepX = 0;
							stepY = -1;
							break;
							/* going DOWN with these cases: 以下情况向下:
							
							+---+---+   +---+---+   +---+---+
							|   |   |   |   | 2 |   | 1 | 2 |
							+---+---+   +---+---+   +---+---+
							|   | 8 |   |   | 8 |   |   | 8 |
							+---+---+  	+---+---+  	+---+---+
							
							*/
						case 8 :
						case 10 :
						case 11 :
							stepX = 0;
							stepY = 1;
							break;
							/* going LEFT with these cases: 以下情况向左:
							
							+---+---+   +---+---+   +---+---+
							|   |   |   |   |   |   |   | 2 |
							+---+---+   +---+---+   +---+---+
							| 4 |   |   | 4 | 8 |   | 4 | 8 |
							+---+---+  	+---+---+  	+---+---+
							
							*/
						case 4 :
						case 12 :
						case 14 :
							stepX = -1;
							stepY = 0;
							break;
							/* going RIGHT with these cases: 以下情况向右:
							
							+---+---+   +---+---+   +---+---+
							|   | 2 |   | 1 | 2 |   | 1 | 2 |
							+---+---+   +---+---+   +---+---+
							|   |   |   |   |   |   | 4 |   |
							+---+---+  	+---+---+  	+---+---+
							
							*/
						case 2 :
						case 3 :
						case 7 :
							stepX = 1;
							stepY = 0;
							break;
						case 6 :
							/* special saddle point case 1: 特殊鞍点:
							
							+---+---+ 
							|   | 2 | 
							+---+---+
							| 4 |   |
							+---+---+
							
							going LEFT if coming from UP
							else going RIGHT 
							如果从上方来则向左否则向右
							
							*/
							if (prevX == 0 && prevY == -1) 
							{
								stepX = -1;
								stepY = 0;
							}
							else {
								stepX = 1;
								stepY = 0;
							}
							break;
						case 9 :
						/* special saddle point case 2: 的特殊鞍点:
							
							+---+---+ 
							| 1 |   | 
							+---+---+
							|   | 8 |
							+---+---+
							
							going UP if coming from RIGHT
							else going DOWN 
						    如果从右边来就向上
							否则向下
							*/
							if (prevX == 1 && prevY == 0) 
							{
								stepX = 0;
								stepY = -1;
							}
							else
							{
								stepX = 0;
								stepY = 1;
							}
							break;
					}
					// moving onto next point 移到下一个点
					pX += stepX;
					pY += stepY;
					// saving contour point
					//保存顶点
					contourVector.push(new Point(pX, pY));
					prevX = stepX;
					prevY = stepY;
					// if we returned to the first point visited, the loop has finished
					//如果我们到达起始点则循环结束;
					if (pX == startPoint.x && pY == startPoint.y) 
						closedLoop = true;
				}
			}
			return contourVector;
		}

		private function getStartingPixel(bitmapData:BitmapData):Point 
		{
			// finding the starting pixel is a matter of brute force, we need to scan
			// the image pixel by pixel until we find a non-transparent pixel
			//我们需要一个像素一个像素的 扫描整个图片，直到找到非透明像素。
			var zeroPoint:Point = new Point(0, 0);
			var offsetPoint:Point = new Point(0, 0);
			for (var i:Number = 0; i < bitmapData.height; i++)
			{
				for (var j:Number = 0; j < bitmapData.width; j++) 
				{
					offsetPoint.x = j;
					offsetPoint.y = i;
					if (bitmapData.hitTest(zeroPoint, tolerance, offsetPoint)) 
						return offsetPoint;
				}
			}
			return null;
		}

		private function getSquareValue(pX:Number, pY:Number, bitmapData:BitmapData):Number
		{
			/*
			checking the 2x2 pixel grid, assigning these values to each pixel, if not transparent
			检测2x2 像素网格, 如果不透明就把相应位置值赋给相应像素
			+---+---+
			| 1 | 2 |
			+---+---+
			| 4 | 8 | <- current pixel (pX,pY) 当前像素位置(pX,pY)
			+---+---+
			*/
			var squareValue:Number = 0;
			// checking upper left pixel
			if (getAlphaValue(bitmapData.getPixel32(pX - 1, pY - 1)) >= tolerance)
				squareValue += 1;
			// checking upper pixel
			if (getAlphaValue(bitmapData.getPixel32(pX, pY - 1)) > tolerance) 
				squareValue += 2;
			// checking left pixel
			if (getAlphaValue(bitmapData.getPixel32(pX - 1, pY)) > tolerance) 
				squareValue += 4;
			// checking the pixel itself
			if (getAlphaValue(bitmapData.getPixel32(pX, pY)) > tolerance) 
				squareValue += 8;
			return squareValue;
		}

		private function getAlphaValue(n:Number):Number 
		{
			// given an ARGB color value, returns the alpha 0 -> 255
			// 给予一个 ARGB颜色值, 返回alpha 0 -> 255
			return n >> 24 & 0xFF;
		}
	
}
}