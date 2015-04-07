//
//  DrawableView.h
//  towing
//
//  Created by Kris Vandermast on 08/02/15.
//  Copyright (c) 2015 Depannage La France. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawableViewProtocol
- (UIColor *) backgroundColor;
- (UIColor *) lineColor;
@end

@interface DrawableView : UIView<DrawableViewProtocol>
- (NSData *) signatureAsPNG;
- (void) clearCanvas;
@end
