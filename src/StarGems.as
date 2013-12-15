package  
{
import data.GemVo;
import flash.geom.Point;
import flash.utils.Dictionary;
import utils.ArrayUtil;
import utils.Random;
/**
 * ...消消看算法 类似于星宝石
 * @author Kanon
 */
public class StarGems 
{
	//总的颜色类型
	private var totalColorType:uint;
	//行数
	private var rows:uint;
	//列数
	private var columns:uint;
	//横向间隔
	private var gapH:uint;
	//纵向间隔
	private var gapV:uint;
	//起始位置x
	private var startX:uint;
	//起始位置y
	private var startY:uint;
	//宝石宽度
    private var gemWidth:Number;
    //宝石高度
    private var gemHeight:Number;
	//默认链接数量
    private var minSameNum:uint;
	//宝石字典
	private var _gemDict:Dictionary;
	//颜色列表
	private var colorList:Array;
	//宝石列表
	private var gemList:Array;
	//下落时的间隔
	private var fallGapV:Number;
	/**
     * @param	totalColorType      总的颜色类型
     * @param	rows                行数
     * @param	columns             列数
     * @param	gapH                横向间隔
     * @param	gapV                纵向间隔
     * @param	startX              起始位置x
     * @param	startY              起始位置y
     * @param	gemWidth            宝石宽度
     * @param	gemHeight           宝石高度
     * @param	minLinkNum          默认链接数量
     */
	public function StarGems(totalColorType:uint, 
							rows:uint, columns:uint, 
							gapH:Number, gapV:Number, 
							startX:Number, startY:Number, 
							gemWidth:Number, gemHeight:Number,
							minSameNum:uint = 2) 
	{
		this.totalColorType = totalColorType;
        this.rows = rows;
        this.columns = columns;
        this.gemWidth = gemWidth;
        this.gemHeight = gemHeight;
        this.startX = startX;
        this.startY = startY;
        this.gapH = gapH;
        this.gapV = gapV;
        this.minSameNum = minSameNum;
        this.initData();
	}
	
	/**
	 * 初始化数据
	 */
	private function initData():void
	{
		this.colorList = [];
		for (var i:int = 1; i <= this.totalColorType; i += 1)
			this.colorList.push(i);
		this.gemList = [];
		this._gemDict = new Dictionary();
		var gVo:GemVo;
        var color:int;
        var point:Point;
        for (var row:int = 0; row < this.rows; row += 1) 
        {
            this.gemList[row] = [];
            for (var column:int = 0; column < this.columns; column += 1) 
            {
				gVo = new GemVo();
                gVo.width = this.gemWidth;
                gVo.height = this.gemHeight;
                gVo.row = row;
                gVo.column = column;
                gVo.isInPosition = true;
                this.gemList[row][column] = gVo;
				//设置坐标位置
                point = this.getGemPos(row, column);
                gVo.x = point.x;
                gVo.y = point.y;
				gVo.color = this.randomColor();
				this._gemDict[gVo] = gVo;
			}
		}
		this.fallGapV = this.gapV * 2;
	}
	
	/**
	 * 判断是否周围上下左右的宝石数据
	 * @param	curRow			当前行坐标
	 * @param	curColumn		当前列坐标
	 * @return	周围4个宝石数据列表
	 */
	private function getSelectRoundGem(curRow:int, curColumn:int):Array
	{
		var arr:Array = [];
		if (curRow > 0)
		{
			var upVo:GemVo = this.gemList[curRow - 1][curColumn];
			if (upVo) arr.push(upVo);
		}
		if (curRow < this.rows - 1)
		{
			var downVo:GemVo = this.gemList[curRow + 1][curColumn];
			if (downVo) arr.push(downVo);
		}
		if (curColumn > 0)
		{
			var leftVo:GemVo = this.gemList[curRow][curColumn - 1];
			if (leftVo) arr.push(leftVo);
		}
		if (curColumn < this.columns - 1)
		{
			var rightVo:GemVo = this.gemList[curRow][curColumn + 1];
			if (rightVo) arr.push(rightVo);
		}
		return arr;
	}
	
	/**
	 * 随机颜色
	 * @param	...args			忽略的颜色
	 * @return	选取的颜色
	 */
	private function randomColor(...args):int
	{
		if (!args || args.length == 0) return Random.randint(1, this.totalColorType);
		var colorArr:Array = ArrayUtil.cloneList(this.colorList);
		var length:int = args.length;
		var index:int;
		var color:int;
		for (var i:int = 0; i < length; i += 1) 
		{
			color = args[i];
			if (color == 0) continue;
			index = colorArr.indexOf(color);
			colorArr.splice(index, 1);
		}
		return Random.choice(colorArr);
	}
	
	/**
	 * 根据行和列获取宝石的坐标
	 * @param	row         行数
	 * @param	column      列数
	 * @return  坐标
	 */
    private function getGemPos(row:int, column:int):Point
    {
        return new Point(this.startX + column * (this.gemWidth + this.gapH),
                         this.startY + row * (this.gemHeight + this.gapV));
    }
	
	/**
     * 根据位置获取宝石数据
     * @param	posX        x位置     
     * @param	posY        y位置
     * @return  宝石数据
     */
    private function getGemVoByPos(posX:Number, posY:Number):GemVo
    {
        var gVo:GemVo;
        for each (gVo in this._gemDict) 
        {
            if (posX >= gVo.x && posX < gVo.x + gVo.width  && 
                posY >= gVo.y && posY < gVo.y + gVo.height)
                return gVo;
        }
        return null;
    }
	
	/**
	 * 获取当前宝石数据相同相邻颜色的宝石数据列表
	 * @param	gVo			当前宝石数据
	 * @return	相同相邻颜色的宝石数据列表
	 */
	private function getSameColorGem(gVo:GemVo):Array
	{
		if (!gVo) return null;
		gVo.isCheck = true;
		var sameColorList:Array = [gVo];
		var roundGVo:GemVo;
		var posAry:Array = this.getSelectRoundGem(gVo.row, gVo.column);
		if (posAry.length == 0) return null;
		var length:int = posAry.length;
		var tempAry:Array;
		for (var i:int = 0; i < length; i += 1) 
		{
			roundGVo = posAry[i];
			//颜色相同
			if (roundGVo && 
				!roundGVo.isCheck && 
				roundGVo.color == gVo.color)
			{
				tempAry = this.getSameColorGem(roundGVo);
				if (tempAry) sameColorList = sameColorList.concat(tempAry);
			}
		}
		return sameColorList;
	}
	
	//***********public function***********
	/**
	 * 点击宝石
	 * @param	posX	x位置	
	 * @param	posY	y位置
	 */
	public function selectGem(posX:Number, posY:Number):Array
	{
		var gVo:GemVo = this.getGemVoByPos(posX, posY);
		if (!gVo) return null;
		var arr:Array = this.getSameColorGem(gVo);
		var length:int = arr.length;
		for (var i:int = 0; i < length; i += 1) 
		{
			gVo = arr[i];
			gVo.isCheck = false;
		}
		return arr;
	}
	
	/**
	 * 宝石字典
	 */
	public function get gemDict():Dictionary{ return _gemDict; }
	
}
}