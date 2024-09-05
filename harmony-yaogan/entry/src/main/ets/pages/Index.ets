import curves from '@ohos.curves'

@Entry
@Component
struct Index {
  //鸟的坐标
  @State birdX:number = 200
  @State birdY:number = 120
  //角度
  @State angle:number = 0
  //图片
  @State bird:Resource = $r('app.media.bird')

  //开始状态
  @State isBegin:boolean = false

  //摇杆中心坐标
  private centerX:number = 120
  private centerY:number = 120

  //大小圆形半径
  private maxRadius:number = 100
  private radius:number = 20

  //摇杆初始位置
  @State positionX:number = this.centerX;
  @State positionY:number = this.centerY;

  //角度正余弦
  sin:number = 0
  cos:number = 0

  //移动速度
  speed:number = 0
  //任务id
  taskId:number = -1

  build() {
    Row(){
      Stack(){
        //开始界面
        if(!this.isBegin){
          Button('开始')
            .onClick(() => {
              animateTo({duration:1000},() => {
                //点击后显示
                this.isBegin = true
              })
            })
        }else {
          Image(this.bird)
            .position({x:this.birdX-20,y:this.birdY-20})
            .rotate({angle:this.angle,centerX:'50%',centerY:'50%'})
            .width(80)
            .height(80)
            .transition({
              type:TransitionType.Insert,
              opacity:0,
              translate:{x:-250}
            })
        }
        //摇杆
        Row(){
          Circle({width:this.maxRadius*2,height:this.maxRadius*2})
            .fill('#20101010')
            .position({x:this.centerX - this.maxRadius,y:this.centerY - this.maxRadius})
          Circle({width:this.radius*2,height:this.radius*2})
            .fill('#403A3A3A')
            .position({x:this.positionX - this.radius,y:this.positionY - this.radius})
        }
        .height(240)
        .width(240)
        .justifyContent(FlexAlign.Center)
        .position({x:0,y:120})
        .onTouch(this.handleTouchEvent.bind(this))
      }
      .height('100%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundImage($r('app.media.sky'))
    .backgroundImageSize({height:'105%',width:'100%'})
  }

  //手指移动事件
  handleTouchEvent(event:TouchEvent){
    //判断手势
    switch(event.type){
      case TouchType.Up://手指抬起还原
        this.speed = 0
        clearInterval(this.taskId)//手指抬起时清除定时任务
        animateTo(
          {curve:curves.springMotion()},
          ()=> {  //还原手指动画效果
          this.positionX = this.centerX
          this.positionY = this.centerY
          this.angle = 0
        })
        break
      case  TouchType.Down:
        //移动定时任务
        this.taskId = setInterval(() => {
          this.birdX += this.speed * this.cos
          this.birdY += this.speed * this.sin
        },40)//1s25帧
        break
      case TouchType.Move:
        //1.获取手指坐标
        let x = event.touches[0].x
        let y = event.touches[0].y
        //2.计算手指与中心点的坐标差值
        let vx = x-this.centerX
        let vy = y-this.centerY
        //3.计算手指与中心点连线和X轴正半轴的夹角
        let angle = Math.atan2(vy,vx)  //tan计算  angle是弧度
        //4.计算手指与中心点的距离
        let distance = this.getDistance(vx,vy)
       //5.计算摇杆小球的坐标
        this.sin = Math.sin(angle)
        this.cos = Math.cos(angle)
        animateTo({curve:curves.responsiveSpringMotion()},()=> {  //持续更近手指动画效果
          this.positionX = this.centerX + distance * this.cos
          this.positionY = this.centerY + distance * this.sin

          //6.修改鸟的角度
          if(Math.abs(angle * 2) <Math.PI){   //当角度绝对值小于90度为正向
            this.bird = $r('app.media.bird')
          }else{//大于90度为反向
            this.bird = $r('app.media.bird_rev')
            angle = angle < 0 ? angle+Math.PI : angle - Math.PI  //修正图片正面朝向
          }
          this.angle = angle * 180/Math.PI//算出角度
          this.speed = 5

        })
        break
    }

  }
  getDistance(x:number,y:number){
    let d = Math.sqrt(x*x+y*y)
    return Math.min(d,this.maxRadius)
  }
}