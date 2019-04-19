






#import "SDTagListView.h"
#define HORIZONTAL_PADDING 7.0f
#define VERTICAL_PADDING   3.0f
#define LABEL_MARGIN       10.0f
#define BOTTOM_MARGIN      10.0f
#define KBtnTag            1000
#define R_G_B_16(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]
@interface SDTagListView(){
    
    CGFloat _KTagMargin;//左右tag之间的间距
    CGFloat _KBottomMargin;//上下tag之间的间距
    NSInteger _kSelectNum;//实际选中的标签数
    UIButton *_tempBtn;//临时保存对象

}
@end
@implementation SDTagListView
-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        _kSelectNum=0;
        totalHeight=0;
        self.frame=frame;
        _tagArr=[[NSMutableArray alloc]init];
        /**默认是多选模式 */
        self.isSingleSelect=NO;

    }
    return self;
    
}
-(void)setTagWithTagArray:(NSArray*)arr{
    
    previousFrame = CGRectZero;
    [_tagArr addObjectsFromArray:arr];
    __weak __typeof(self) weakSelf = self;
    [arr enumerateObjectsUsingBlock:^(NSString*str, NSUInteger idx, BOOL *stop) {
    
        UIButton*tagBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        tagBtn.frame=CGRectZero;
        
        if(weakSelf.signalTagColor){
            //可以单一设置tag的颜色
            tagBtn.backgroundColor = weakSelf.signalTagColor;
        }else{
            //tag颜色多样
            tagBtn.backgroundColor=[UIColor colorWithRed:random()%255/255.0 green:random()%255/255.0 blue:random()%255/255.0 alpha:1];
        }
        if(weakSelf.canTouch){
            tagBtn.userInteractionEnabled=YES;
            
        }else{
            
            tagBtn.userInteractionEnabled=NO;
        }
        [tagBtn setTitleColor:R_G_B_16(0x818181) forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        tagBtn.titleLabel.font=[UIFont boldSystemFontOfSize:15];
        [tagBtn addTarget:self action:@selector(tagBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [tagBtn setTitle:str forState:UIControlStateNormal];
        tagBtn.tag=KBtnTag+idx;
        tagBtn.layer.cornerRadius=13;
        tagBtn.layer.borderColor=R_G_B_16(0x818181).CGColor;
        tagBtn.layer.borderWidth=0.3;
        tagBtn.clipsToBounds=YES;
        NSDictionary *attrs = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:15]};
        CGSize Size_str=[str sizeWithAttributes:attrs];
        Size_str.width += HORIZONTAL_PADDING*3;
        Size_str.height += VERTICAL_PADDING*3;
        CGRect newRect = CGRectZero;

        if(self->_KTagMargin && self->_KBottomMargin){
            
            if (self->previousFrame.origin.x + self->previousFrame.size.width + Size_str.width + self->_KTagMargin > self.bounds.size.width) {
                
                newRect.origin = CGPointMake(10, self->previousFrame.origin.y + Size_str.height + self->_KBottomMargin);
                self->totalHeight +=Size_str.height + self->_KBottomMargin;
            }
            else {
                newRect.origin = CGPointMake(self->previousFrame.origin.x + self->previousFrame.size.width + self->_KTagMargin, self->previousFrame.origin.y);
                
            }
            [self setHight:self andHight:self->totalHeight + Size_str.height + self->_KBottomMargin];

            
        }else{
            if (self->previousFrame.origin.x + self->previousFrame.size.width + Size_str.width + LABEL_MARGIN > self.bounds.size.width) {
            
                newRect.origin = CGPointMake(10, self->previousFrame.origin.y + Size_str.height + BOTTOM_MARGIN);
                self->totalHeight += Size_str.height + BOTTOM_MARGIN;
        }
        else {
            newRect.origin = CGPointMake(self->previousFrame.origin.x + self->previousFrame.size.width + LABEL_MARGIN, self->previousFrame.origin.y);
            
        }
            [self setHight:self andHight:self->totalHeight+Size_str.height + BOTTOM_MARGIN];
        }
        newRect.size = Size_str;
        [tagBtn setFrame:newRect];
        self->previousFrame = tagBtn.frame;
        [self setHight:self andHight:self->totalHeight+Size_str.height + BOTTOM_MARGIN];
        [self addSubview:tagBtn];


    }];
    if(_SDbackgroundColor){
        
        self.backgroundColor=_SDbackgroundColor;
        
    }else{
        
        self.backgroundColor=[UIColor whiteColor];
        
    }
    

}
#pragma mark-改变控件高度
- (void)setHight:(UIView *)view andHight:(CGFloat)hight
{
    CGRect tempFrame = view.frame;
    tempFrame.size.height = hight;
    view.frame = tempFrame;
}
-(void)tagBtnClick:(UIButton*)button{
    if(_isSingleSelect){
        if(button.selected){
            
            button.selected=!button.selected;
            
        }else{
            
            _tempBtn.selected=NO;
            _tempBtn.backgroundColor=[UIColor whiteColor];
             button.selected=YES;
            _tempBtn=button;
            
        }
        
    }else{
        
        button.selected=!button.selected;
    }
    
    if(button.selected==YES){
        button.backgroundColor=[UIColor orangeColor];
    }else if (button.selected==NO){
        button.backgroundColor=[UIColor whiteColor];
    }
    
    [self didSelectItems];
    
    
}
-(void)didSelectItems{

    NSMutableArray*arr=[[NSMutableArray alloc]init];
    
    for(UIView*view in self.subviews){

        if([view isKindOfClass:[UIButton class]]){

            UIButton *tempBtn = (UIButton*)view;
            tempBtn.enabled = YES;
            if (tempBtn.selected == YES) {
                [arr addObject:_tagArr[tempBtn.tag-KBtnTag]];
                _kSelectNum = arr.count;
            }
        }
    }
    if(_kSelectNum==self.canTouchNum){
        
        for(UIView*view in self.subviews){

            UIButton*tempBtn=(UIButton*)view;

         if (tempBtn.selected == YES) {
             tempBtn.enabled = YES;
             
         }else{
             tempBtn.enabled = NO;
             
         }
    }
    }
    self.didselectItemBlock(arr);
    
    
}
-(void)setMarginBetweenTagLabel:(CGFloat)Margin AndBottomMargin:(CGFloat)BottomMargin{
    
    _KTagMargin = Margin;
    _KBottomMargin = BottomMargin;

}

@end
