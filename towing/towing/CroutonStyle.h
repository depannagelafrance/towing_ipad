//
//   ECAS Software
//   ===================================================
//   Copyright (c) 2014 European Commission
//   Licensed under the EUPL
//   You may not use this work except in compliance with the Licence.
//   You may obtain a copy of the Licence at:
//   http://ec.europa.eu/idabc/eupl
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum CroutonUIHorizontalAlignment {
    CroutonUIStretch,
    CroutonUIAlignLeft,
    CroutonUIAlignRight,
    CroutonUIAlignCenter
};

enum CroutonUIVerticalAlignment {
    CroutonUIAlignTop,
    CroutonUIAlignBottom,
    CroutonUIFill
};

@interface CroutonStyle : NSObject

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *textColor;
@property (nonatomic) float textSize;
@property (nonatomic) float duration;
@property (nonatomic) enum CroutonUIHorizontalAlignment horizontalAlignment;
@property (nonatomic) enum CroutonUIVerticalAlignment verticalAlignment;

- (id) initStyleWithBackground:(UIColor *)backgroundColor textColor:(UIColor *) textColor textSize:(float) textSize;

@end
