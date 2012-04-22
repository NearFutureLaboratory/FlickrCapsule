//
//  PictureImageView.m
//  FlickrCapsule
//
//  Created by Julian Bleecker on 4/21/12.
//  Copyright (c) 2012 Nodesnoop LLC. All rights reserved.
//

#import "PictureImageView.h"
#import <UIKit/UIKit.h>

@implementation PictureImageView
@synthesize label;

//static PictureImageView *ivar;


- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    if (self) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
//    CGSize _size = [image size];
    
}

- (void)commonInit
{
    //ivar = [PictureImageView new];
    self.label = [UILabel alloc];
    [self.label initWithFrame:CGRectMake(0,0,320,200)];
    //self.label.alpha = 0.1;
//// NSArray *fonts = [UIFont familyNames];
    [label setFont:[UIFont fontWithName:@"EuphemiaUCAS-Bold" size:32]];
    self.label.textColor = UIColor.whiteColor; 
    [label setNumberOfLines:0];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setLineBreakMode:UILineBreakModeWordWrap];
    [label setShadowColor:[UIColor grayColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    //self.label.backgroundColor = UIColor.blackColor;
    [self addSubview:self.label];
    
//    [self setContentMode:UIViewContentModeScaleAspectFit];
//    [self setContentMode:UIViewContentModeScaleAspectFit];

    
    //CGRect frame = [[UIScreen mainScreen] bounds];
    //self.frame = CGRectMake(0,0,frame.size.width, frame.size.height);
    
/**
    UISwipeGestureRecognizer *horizontal = [[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(reportHorizontalSwipe:)];
    horizontal.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:horizontal];
**/
}

- (id)initWithImage:(UIImage *)image
{
    if((self = [super initWithImage:image])) {
        [self commonInit];
    }
    return self;
}

- (void)woopsRotated
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.frame = CGRectMake(0,0,frame.size.height, frame.size.width);
}

- (id)initWithCoder:(NSCoder *)coder
{
    if((self = [super initWithCoder:coder])) {
        [self commonInit];
        
    }
    return self;
}
/**
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint startTouchPosition;
    UITouch *touch = [touches anyObject];
    startTouchPosition = [touch locationInView:self];
    //self.label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 200, 20)];
    //[self.label initWithFrame:CGRectMake(50, 100, 200, 20)];
    self.label.text = @"Lorem..";
   // [self addSubview:self.label];
}
*/


- (void)reportHorizontalSwipe:(UIGestureRecognizer *)recognizer {
    //[self foo];
        self.label.text = @"Lorem..Horizontal";
}

- (void)setLabelText:(NSString *)labelText
{
    self.label.text = labelText;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
