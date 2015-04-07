//
//   ECAS Software
//   ===================================================
//   Copyright (c) 2014 European Commission
//   Licensed under the EUPL
//   You may not use this work except in compliance with the Licence.
//   You may obtain a copy of the Licence at:
//   http://ec.europa.eu/idabc/eupl
//

#import "CroutonStyle.h"

@implementation CroutonStyle
#pragma mark - init
- (id) initStyleWithBackground:(UIColor *)backgroundColor textColor:(UIColor *)textColor textSize:(float)textSize
{
    self.backgroundColor = backgroundColor;
    self.textColor = textColor;
    self.textSize = textSize;
    
    return self;
}

#pragma mark - getters and setters
- (enum CroutonUIHorizontalAlignment) horizontalAlignment
{
    if(!_horizontalAlignment) {
        _horizontalAlignment = CroutonUIStretch;
    }
    
    return _horizontalAlignment;
}

- (enum CroutonUIVerticalAlignment)verticalAlignment
{
    if(!_verticalAlignment) {
        _verticalAlignment = CroutonUIAlignTop;
    }
    
    return _verticalAlignment;
}

- (float) duration {
    if(!_duration || _duration <= 0) {
        _duration = 5;
    }
    
    return _duration;
}

- (float) textSize {
    if(!_textSize || _textSize <= 0) {
        _textSize = 14;
    }
    
    return _textSize;
}
@end
