//
//  PictureImageView.h
//  FlickrCapsule
//
//  Created by Julian Bleecker on 4/21/12.
//  Copyright (c) 2012 Nodesnoop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureImageView : UIImageView {

    
//UILabel *label;
}

@property UILabel *label;


- (void)setLabelText:(NSString *) labelText;
- (void)woopsRotated;

@end
